require_relative '../log/yp_log'
require 'net/http'
require 'json'
require 'base64'

class YPChatAI
    
    def self.startChatAI
        system('clear')
        yp_log_msg "\n欢迎使用 YPTools & ChatGPT"
        yp_log_msg "YPTools源码地址：https://github.com/HansenCCC/YPTools"
        yp_log_msg "OpenAI地址：https://github.com/openai\n"
        yp_log_success "ChatGPT"
        yp_log_doing "输入 'q' 或者 'quit' 退出当前会话"
        yp_log_msg '我是一个非常聪明的ChatGPT机器人。如果您问我一个根源于真理的问题，我会给您答案。'
        yp_log_msg 'Q: 全球人类的平均寿命是多少？'
        yp_log_msg 'A: 根据世界卫生组织公布的数据，2019年全球人类的平均寿命为71.4岁。'

        yp_contents = Array.new
        while true
            Encoding.default_external = Encoding::UTF_8
            Encoding.default_internal = Encoding::UTF_8
            # 使用while循环
            print "Q: "
            yp_question = STDIN.gets.chomp
            if (yp_question.upcase == 'Q' || yp_question.upcase == 'QUIT')
                break
            end
            yp_contents.push({
                'USER' => yp_question,
                'AI' => ""
            })
            yp_answer = self.chatGPTWithQuestion(yp_contents)
            print "A: " + yp_answer + "\n"
            yp_item = yp_contents.pop
            yp_item["AI"] = yp_answer
            yp_contents.push(yp_item)
        end
    end

    def self.chatGPTWithQuestion(content)
        yp_chataiURL = 'https://api.openai.com/v1/completions'
        # yp_chataiURL = 'https://api.openai.com/v1/engines/davinci-codex/completions'
        # 开始发送网络请求
        url = URI.parse(yp_chataiURL)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true 
        # 简单了加了下密，免费的apikey，就不要扒去用了（我的代码是开源放到GitHub，加密的目的是ChatGPT会检测秘钥是否在网络泄露）
        yp_token = "c2stTVRVMVZqeUdpNWxzYlU1TmNlU1pUM0JsYmtGSmNYam5iUk5ROENVYUd2QVR4WXpp"
        # 将Base64字符串解码为原始二进制数据
        decoded_data = Base64.decode64(yp_token).force_encoding("UTF-8")
        # 设置请求头
        headers = {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + decoded_data
        }
        # 设置ai根据上下文
        question = ''
        for key in content
            user = key['USER']
            ai = key['AI']
            question += '\nUSER: ' + user + '\nAI: ' + ai
        end

        # 设置请body
        data = {
            # 'engine' => 'davinci',
            'model' => 'text-davinci-003', # 然后GPT-3模型会根据您的输入文本自动生成文本补全或摘要。
            'prompt' => question, # 问的问题
            'max_tokens' => 999, # 设置回答最多多少个字符 
            'temperature' => 0.7, # 文本创意度，默认 1
            "n": 1, #几个回答
            "stop": "\n"
        }
        
        request = Net::HTTP::Post.new(url.path, headers)
        request.body = data.to_json

        begin
            response = http.request(request)
            # 处理响应数据
            yp_message_response = JSON(response.body)
            if !yp_message_response["error"]
                created = yp_message_response["created"]
                choices = yp_message_response["choices"]
                if !choices.empty?
                    text = choices.first["text"]
                    text = text.gsub(/\n+/, "")
                    return text
                else 
                    yp_log_fail "请求失败，" + yp_message_response
                    return ""
                end
            else 
                message = yp_message_response["error"]["message"]
                yp_log_fail  "请求失败，请稍后再试！！！\n" + message
                return ""
            end
        rescue StandardError => e
            # 处理异常
            yp_log_fail "请求的次数太多了，请稍后再试！！！"
            yp_log_fail "发生异常：#{e.message}"
        end
    end

    def self.message(message)
        yp_log_doing "你的问题：#{message}"
        yp_log_msg "请求中，请等待..."
        yp_contents = Array.new
        yp_contents.push({
            'USER' => message,
            'AI' => ""
        })
        yp_answer = self.chatGPTWithQuestion(yp_contents)
        yp_log_success "chatGPT：" + yp_answer.gsub(/\n+/, "\n")
    end

    def self.openaiimg(message) 
        yp_chataiURL = 'https://api.openai.com/v1/images/generations'
        # 开始发送网络请求
        url = URI.parse(yp_chataiURL)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true 
        # 简单了加了下密，免费的apikey，就不要扒去用了（我的代码是开源放到GitHub，加密的目的是ChatGPT会检测秘钥是否在网络泄露）
        yp_token = "c2stTVRVMVZqeUdpNWxzYlU1TmNlU1pUM0JsYmtGSmNYam5iUk5ROENVYUd2QVR4WXpp"
        # 将Base64字符串解码为原始二进制数据
        decoded_data = Base64.decode64(yp_token).force_encoding("UTF-8")
        # 设置请求头
        headers = {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + decoded_data
        }
        # 设置ai根据上下文
        question = message

        # 设置请body
        data = {
            # 'model' => 'text-davinci-003', # 然后GPT-3模型会根据您的输入文本自动生成文本补全或摘要。
            'prompt' => question, # 问的问题
            "n": 3, #几个回答
            "size": "512x512"
        }
        
        request = Net::HTTP::Post.new(url.path, headers)
        request.body = data.to_json

        begin
            response = http.request(request)
            # 处理响应数据
            yp_message_response = JSON(response.body)
            if !yp_message_response["error"]
                created = yp_message_response["created"]
                data = yp_message_response["data"]
                if !data.empty?
                    index = 1
                    for item in data
                        yp_log_success "图#{index}"
                        puts ""
                        yp_log_msg item["url"]
                        puts ""
                    end
                else 
                    yp_log_fail "请求失败，" + yp_message_response
                end
            else 
                message = yp_message_response["error"]["message"]
                yp_log_fail  "请求失败，请稍后再试！！！\n" + message
            end
        rescue StandardError => e
            # 处理异常
            yp_log_fail "请求的次数太多了，请稍后再试！！！"
            yp_log_fail "发生异常：#{e.message}"
        end
    end

end