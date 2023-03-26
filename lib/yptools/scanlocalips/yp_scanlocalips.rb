require 'socket'

class YPScanLocalIPs

    def self.scanlocalips() 
        self.scan_local_ips
    end

    def self.ping(ip)
        IO.popen("ping -c 1 -t 1 #{ip} > /dev/null 2>&1") { |f| f.close }
        if $?.exitstatus == 0
          puts ip
        elsif $?.exitstatus == 2
          # No route to host
        elsif $?.exitstatus == 68
          # Name or service not known
        end
    rescue => e
        # handle exception
    end
    
    def self.scan_local_ips
        # 获取本机IP地址前三位，例如 192.168.0
        prefix = Socket.ip_address_list.find { |intf| intf.ipv4? && !intf.ipv4_loopback? }.ip_address.split('.')[0, 3].join('.') + '.'
        threads = []
      
        # 遍历所有可能的IP地址
        (1..255).each do |i|
          threads << Thread.new(prefix, i) do |pr, j|
            # 组合出IP地址，例如 192.168.0.1
            ip = "#{pr}#{j}"
            # 使用ping命令测试是否能够ping通，并手动关闭文件句柄
            ping(ip)
          end
        end
      
        # 等待所有线程执行完毕
        threads.each(&:join)
      
        # 输出所有结果
        results = threads.map(&:value).compact
        results.each { |ip| puts ip + "🚀" }
    end
end