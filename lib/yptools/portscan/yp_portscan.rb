class YPPortScan
    def self.portscan(port, range) 
        script = %Q(
            #!/bin/bash
            
            if [ -n "#{range}" ]; then
                all_port="#{range}"
              else
                all_port="1-65535"
            fi

            port_range=(${all_port//-/ })
            timeout=0.02
            ip_address=#{port}

            port_range+=(#{range})
                
            echo "正在扫描 ${ip_address} 的端口 ${port_range[0]} 到 ${port_range[1]}..."
            echo ${port_range[1]}
          
            open_ports=()
            closed_ports=()
          
            for ((port = ${port_range[0]}; port <= ${port_range[1]}; port++)); do
              (echo >/dev/tcp/${ip_address}/${port}) >/dev/null 2>&1 &
              pid=$!
              (
                sleep ${timeout}
                kill ${pid} >/dev/null 2>&1
              ) &
              timer=$!
              if wait ${pid} 2>/dev/null; then
                echo "\\033[32m${port} 是开放的\\033[0m"
                open_ports+=($port)
              else
                echo "\\033[31m${port} 是关闭的\\033[0m"
                closed_ports+=($port)
              fi
              kill ${timer} >/dev/null 2>&1
            done
          
            allCount=$((${#open_ports[@]} + ${#closed_ports[@]}))
          
            echo ${allCount} "个端口扫描完成。"
            echo "共有 ${#open_ports[@]} 个端口是开放的，${#closed_ports[@]} 个端口是关闭的。"
            echo "开放的端口: " "\\033[32m${open_ports[@]}\\033[0m"
          )
          system(script)
    end
end
