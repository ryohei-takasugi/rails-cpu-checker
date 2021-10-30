require_relative "common"

module PsModule
  include CommonModule
  def ps(opt: nil, head_line: nil)
    if feasible_opt?(opt)
      if head_line.nil?
        console_result = `ps #{opt}`
      else
        console_result = `ps #{opt} | head -n #{head_line}`
      end
      if feasible_result?(console_result)
        # シェルで実行した結果を配列に変換してから、ハッシュ型に変換する
        convert_of_ps(console_result)
      else
        # 簡易判定でNG場合、エラーメッセージを出して終了する
        output_error("Not a valid option. Console results do not include 'PID'.")
      end
    else
      # オプションに無効文字が含まれる場合、エラーメッセージを出して終了する
      output_error("Not a valid option.")
    end
  end
  private
  # 処理できないオプションはfalseにする
  def feasible_opt?(opt)
    case
    when opt.nil?                      then return true
    when opt.include?("s")             then return false
    when opt.include?("c")             then return false
    when opt.include?("v")             then return false
    when opt.include?("h")             then return false
    when opt.include?("f")             then return false
    when opt.include?("help")          then return false
    when opt.match(/\A[a-z]+\z/) == nil then return false
    else
      return true
    end
  end
  # 実行結果が有効か簡易判定する
  def feasible_result?(console_result)
    # 実行してみて結果が帰ってこない場合もfalseにする
    console_result.include?("PID")
  end
  # 変換のメイン処理
  def convert_of_ps(console_result)
    # コンソールの表データを配列形式に変換する
    array_type_result = convert_text_to_array(console_result)
    # psコマンドの行名称（COMMAND列の値）を取得する
    key_lv1 = array_type_result.transpose.last[1..array_type_result.transpose.last.length]
    # psコマンドの列名称（USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND）を取得する
    key_lv2 = array_type_result[0]
    # 表形式の各使用量(行列名称を含まない)を取得する
    value = array_type_result[1..array_type_result.length]
    # 行名称、列名称、使用量をハッシュ形式に変換する
    return convert(key_lv1, key_lv2, value)
  end
  # エラー文言
  def output_error(error_string)
    <<-TEXT
    error: This options cannot be used by this script.
           Or you specified an option that does not exist.
            -s, -c, -v, -h, -f 
            --version, --help
    #{error_string}
    TEXT
  end
end