# =====================
# 
# @os:Ubuntu 21.04
# @ruby-version: ruby 2.7.4p191 (2021-07-07 revision a21a3b7d23) [aarch64-linux]
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
  ps("aux", 4).each do |key, value|
    # CPU使用率60%以上、かつ、spring/application/bootを含むプロセスのみ通知する
    if value["%CPU"] > 60.0 && value["COMMAND"].include?("spring/application/boot")
      puts Time.now
      puts JSON.pretty_generate(value)
      `say "ルビーのCPU使用率が高くなっています。確認してください。"`
    end
    sleep(10)
  end
end
