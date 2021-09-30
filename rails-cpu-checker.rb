# =====================
# 
# @os:Ubuntu 21.04
# @ruby-version: ruby 2.7.4p191 (2021-07-07 revision a21a3b7d23) [aarch64-linux]
# 
# =====================
# TODO: 急ぎ作ったものなので整理が必要
# =====================
require "json"

# DFコマンドとFreeコマンドに共通する処理
module CommonModule
  private
  # ヘッダーを基準に最大列数を取得する
  def get_max_columns(console_result)
    max_number_of_columns = 0
    console_result.each_line.with_index do |line, index|
      tmp = line.chomp.split(" ").length
      max_number_of_columns = tmp if max_number_of_columns < tmp and index > 0
    end
    return max_number_of_columns
  end

  # コマンドの結果（表形式）をネストした配列（１層目は行別、２層目は列別）に変換する
  def convert_text_to_array(console_result, max_number_of_columns)
    array_type_command = Array.new
    console_result.each_line.with_index do |line, index|
      array_type_command[index] = line.chomp.split(" ", max_number_of_columns) 
    end
    return array_type_command
  end

  # ハッシュにデータを１つずつ入れる
  def set_to_hash(key, value)
    result = Hash.new
    case value
      when /^[0-9]+$/         then result.store(key, value.to_i)
      when /^[0-9]+\.[0-9]+$/ then result.store(key, value.to_f)
      when /^[0-9]+\%$/       then result.store(key, value.delete("%").to_i)
      else                    result.store(key, value)
    end
    return result
  end

  # メイン変換処理
  def convert(key_lv1, key_lv2, value)
    result = Hash.new
    key_lv1.each_with_index do |lv1, i|
      tmp = Hash.new
      key_lv2.each_with_index do |lv2, j|
        lv2 = lv2.chomp(":") if lv2.end_with?(":")
        tmp.update(set_to_hash(lv2, value[i][j])) unless value[i][j].nil?
      end
      result.update(set_to_hash(lv1, tmp))
    end
    return result
  end
end


include CommonModule
# 変換のメイン処理
def ps_hash
  # コンソールの表データを配列形式に変換する
  array_type_df = convert_text_to_array(`ps aux | head -n 4`, 11)
  # psコマンドの行名称（COMMAND列の値）を取得する
  key_lv1 = array_type_df.transpose.last[1..array_type_df.transpose.last.length]
  # psコマンドの列名称（USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND）を取得する
  key_lv2 = array_type_df[0]
  # 表形式だった各使用量をネストさせた配列形式に変換する
  value = array_type_df[1..array_type_df.length]
  # 行名称、列名称、使用量をハッシュ形式に変換する
  return convert(key_lv1, key_lv2, value)
end

loop do
  ps_hash.each do |key, value|
    if value["%CPU"] > 60.0 && value["COMMAND"].include?("spring/application/boot")
      puts Time.now
      puts JSON.pretty_generate(value)
      `say "ルビーのCPU使用率が高くなっています。確認してください。"`
    end
    sleep(3)
  end
end
