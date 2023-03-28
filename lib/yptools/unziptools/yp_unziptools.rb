require_relative '../log/yp_log'

class YPUnzipTools

    def self.unzip(argvs) 

      # 测试方法
      password_characters = []
      
      arr_n = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
      arr_a = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",]
      arr_A = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",]
      arr_s = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "+", "=", "{", "}", "[", "]", "|", "\\", ":", ";", "<", ">", ",", ".", "?", "/"]

      filename = argvs.last
      if File.exist?(filename)
        yp_log_doing "#{filename} 存在，准备开始扫描"
      else
        yp_log_fail "#{filename} 不存在"
        return
      end
    
      if argvs.include?("-n") 
        password_characters += arr_n
      end
      
      if (argvs.include?("-a")) 
        password_characters += arr_a
      end

      if argvs.include?("-A") 
        password_characters += arr_A
      end

      if argvs.include?("-s") 
        password_characters += arr_s
      end

      if (password_characters.length == 0)
        password_characters = arr_n + arr_a + arr_A + arr_s
      end

      yp_log_msg "扫描由下面数组组成的密码"
      yp_log_success "#{password_characters}"

      characters = password_characters
      
      length = 10000
      allCount = 0
      for num in 1..length do
        allCount += self.generate_passwords(filename, num, characters)
      end
      yp_log_fail "暂未发现密码，共尝试了#{allCount}个密码！"

    end

    def self.generate_passwords(filename, length, characters, prefix = "", count = 0)
        sleep(0.01)
        # 如果密码长度为0，直接返回前缀并增加计数器
        if length == 0
          result = self.unzip_file(filename, prefix)
          if result == 1
            yp_log_success "解压成功，密码是#{prefix}"
            exit
            return count
          else
            yp_log_msg "#{prefix}：密码错误，解压失败"
          end
          count += 1
        else
          # 对于每个字符，将其加入到前缀中并递归生成更短的密码
          characters.each do |c|
            new_prefix = prefix + c
            count = self.generate_passwords(filename, length - 1, characters, new_prefix, count)
          end
        end
        return count
    end
      
    def self.unzip_file(filePath, password) 
        zip_file = filePath
        # 执行解压命令
        puts "unzip -P #{password} -o -q #{zip_file}"
        system("unzip -P #{password} -o -q #{zip_file}")
        # 判断解压是否成功
        if $?.exitstatus == 0
            return 1
        else
            return 0
        end  
    end

end