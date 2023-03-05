require_relative '../log/yp_log'
require 'net/http'
require 'json'
require 'base64'

class YPChatAI
    
    def self.message(message)
        yp_log_doing "你的问题：#{message}"
        yp_log_msg "请求中，请等待..."
        yp_chataiURL = 'https://api.openai.com/v1/completions'

        # 开始发送网络请求
        url = URI.parse(yp_chataiURL)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true 
        # 设置请求头
        yp_token = "c2stTVRVMVZqeUdpNWxzYlU1TmNlU1pUM0JsYmtGSmNYam5iUk5ROENVYUd2QVR4WXpp"
        # 将Base64字符串解码为原始二进制数据
        decoded_data = Base64.decode64(yp_token).force_encoding("UTF-8")

        headers = {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + decoded_data
        }
        # 设置请body
        data = {
            'model' => 'text-davinci-003', # 然后GPT-3模型会根据您的输入文本自动生成文本补全或摘要。
            'prompt' => message, # 问的问题
            'max_tokens' => 999, # 设置回答最多多少个字符 
            'temperature' => 0.9, # 文本创意度，默认 1
        }

        request = Net::HTTP::Post.new(url.path, headers)
        request.body = data.to_json
        response = http.request(request)

        yp_message_response = JSON(response.body)
        if !yp_message_response["error"]
            created = yp_message_response["created"]
            choices = yp_message_response["choices"]
            if !choices.empty?
                text =  choices.first["text"]
                yp_log_success "chatGPT：" + text.gsub(/\n+/, "\n")
            else 
                yp_log_fail "请求失败，" + yp_message_response
            end
        else 
            message = yp_message_response["error"]["message"]
            yp_log_fail  "请求失败，请稍后再试！！！\n" + message
        end
    end

end