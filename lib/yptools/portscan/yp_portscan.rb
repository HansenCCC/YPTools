require 'colored'

class YPPortScan
  COMMON_PORTS = [21, 22, 23, 25, 53, 80, 81, 88, 110, 111, 135, 139, 143, 161, 389, 443, 445, 465, 514, 587, 631, 993, 995, 1080, 1194, 1433, 1521, 2049, 2082, 2083, 2181, 2222, 2375, 2376, 3389, 3690, 4443, 5432, 5900, 5984, 6379, 7001, 7002, 8080, 8081, 8086, 8443, 8888, 9090, 9200, 9300, 10000, 11211, 15672, 27017, 28017, 50000, 50070, 50075, 50090]

  def self.portscan(address, range)
    ip_address = address
    if range.nil? || range.empty? || range == "-d" || range == "-default"
      port_range = COMMON_PORTS
      yp_log_doing "正在扫描 #{ip_address} 常用的端口"
    else
      temp_port_range = range.split("-").map(&:to_i)
      yp_log_doing "正在扫描 #{ip_address} 的端口 #{temp_port_range.min} 到 #{temp_port_range.max}..."
      port_range = temp_port_range.size == 1 ? [temp_port_range[0]] : (temp_port_range[0]..temp_port_range[1]).to_a
    end

    open_ports = []
    closed_ports = []

    port_range.each do |port|
      `nc -w 1 -z #{ip_address} #{port} 2>&1 | grep succeeded`
      if $?.success?
        yp_log_success "#{port} 是开放的"
        open_ports << port
      else
        yp_log_fail "#{port} 是关闭的"
        closed_ports << port
      end
    end

    all_count = open_ports.size + closed_ports.size
    yp_log_doing "共有 #{open_ports.size} 个端口是开放的，#{closed_ports.size} 个端口是关闭的。"
    yp_log_success "#{all_count} 个端口扫描完成，" + "开放的端口: #{open_ports}"
  end
end
