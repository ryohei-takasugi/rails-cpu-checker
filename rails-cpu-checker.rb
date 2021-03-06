# =====================
# 
# @os:
# @ruby-version: 
# 
# =====================
# TODO: 急ぎ作ったものなので整理が必要
# =====================
require "json"
require_relative "helper/ps"

include PsModule

# 無限ループ（停止方法 Ctrl+C）
loop do
  # ps aux | head -n 4
  result = ps(opt: "aux", head: 4)
  unless result.include?("SCRIPT ERROR")
    result.each do |key, value|
      # CPU使用率60%以上、かつ、spring/application/bootを含むプロセスのみ通知する
      if value["%CPU"] > 60.0 && value["COMMAND"].include?("spring/application/boot")
        puts "--------------------------"
        puts Time.now
        puts JSON.pretty_generate(value)
        `say "ルビーのCPU使用率が高くなっています。スプリングストップコマンドを実行してください。"`
      end
    end
  else
    puts result
    puts "stop script."
    break
  end
  sleep(10)
end
