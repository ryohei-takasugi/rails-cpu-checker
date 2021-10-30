# コマンドに共通する処理
module CommonModule
  private
  # 最大列数を取得する
  def get_max_columns(console_result, target_line_number)
    max_number_of_columns = 0
    console_result.each_line.with_index do |line, index|
      max_number_of_columns = line.chomp.split(" ").length if target_line_number == index
    end
    max_number_of_columns
  end

  # コマンドの結果（表形式）をネストした配列（１層目は行別、２層目は列別）に変換する
  def convert_text_to_array(console_result)
    array_type_command = Array.new
    console_result.each_line.with_index do |line, index|
      array_type_command[index] = line.chomp.split(" ", get_max_columns(console_result, 0)) 
    end
    array_type_command
  end

  # ハッシュにデータを１つずつ入れる
  def set_to_hash(key, value)
    result = Hash.new
    case value
      when /^[0-9]+$/           then result.store(key, value.to_i)
      when /^[0-9]+\.[0-9]+$/   then result.store(key, value.to_f)
      when /^[0-9]+\%$/         then result.store(key, value.delete("%").to_i)
      else                           result.store(key, value)
    end
    result
  end

  # メイン変換処理
  def convert(key_lv1, key_lv2, value)
    result = Hash.new
    key_lv1.each_with_index do |lv1, i|
      value_v1 = Hash.new
      key_lv2.each_with_index do |lv2, j|
        lv2 = lv2.chomp(":") if lv2.end_with?(":")
        value_v1.update(set_to_hash(lv2, value[i][j])) unless value[i][j].nil?
      end
      result.update(set_to_hash(lv1, value_v1))
    end
    result
  end
end