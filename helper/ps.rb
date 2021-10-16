require_relative "common"

module PsModule
  include CommonModule
  def ps(opt: nil)
    # コマンドを実行する
    console_result = terminal(opt)
    # オプションコマンドが有効か判定する
    if feasible?(opt, console_result)
      # シェルで実行した結果を配列に変換してから、ハッシュ型に変換する
      return convert_of_ps(console_result)
    else
      # オプションに無効文字が含まれる場合、エラーメッセージを出して終了する
      puts "error: This options cannot be used by linuxcmd-by-ruby."
      puts "       --version          output version information and exit"
      puts "       --help"
    end
  end
  private
  def terminal(opt)
    `ps #{opt}`
  end
  # オプションコマンドが有効か判定する
  def feasible?(opt, console_result)
    # オプションが無いならOK
    return true if opt.nil?
    # 処理できないオプションはfalseにする
    return false if (opt.include?("s") || opt.include?("c") || opt.include?("v") || opt.include?("help"))
    # 実行してみて結果が帰ってこない場合もfalseにする
    return console_result.include?("PID")
  end
  # 変換のメイン処理
  def convert_of_ps(console_result)
    # 範囲指定に使う列数の最大値を取得する
    max_number_of_columns = get_max_columns(console_result, 0)
    # コンソールの表データを配列形式に変換する
    array_type_result = convert_text_to_array(console_result, max_number_of_columns)
    # psコマンドの行名称（COMMAND列の値）を取得する
    key_lv1 = array_type_result.transpose.last[1..array_type_result.transpose.last.length]
    # psコマンドの列名称（USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND）を取得する
    key_lv2 = array_type_result[0]
    # 表形式だった各使用量をネストさせた配列形式に変換する
    value = array_type_result[1..array_type_result.length]
    # 行名称、列名称、使用量をハッシュ形式に変換する
    return convert(key_lv1, key_lv2, value)
  end
end