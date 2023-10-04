class YPHelp

  def self.message
    puts %q{
      
      🍎🍎🍎 - iOS开发者（IOS Developer）
      autocre: use [yptools autocre ...] 自动化工具命令
               use [yptools autocre -objc ...] 根据 json 自动创建 Objective-C 数据库操作文件 .h|.m 文件。（依赖三方库 FMDB ）
               use [yptools autocre -init] 构建数据库操作文件的json模板
      
      install: use [yptools install mvvm] 为xcode创建OC语言的mvvm的模板
      
      mgc: use [yptools mgc suffix] 在当前目录生成垃圾代码（当前目录需要有.xcworkspace或者.xcodeproj目录）
      
      showipa: use [yptools showipa ...] 用于解析ipa文件
      
      ufct: use [yptools ufct] 更新当前目录下面文件后缀为.h|.m 的文件创建时间
      
      xpj: use [yptools xpj ...] use xcodeproj api
           use [yptools xpj check] 检查当前目录项目文件是否存在引用的问题

      png2jpeg: use [yptools png2jpeg ...] 将当前目录下面的png转为jpeg格式（目的可以用于减少文件大小，方便上传）

      🤖🤖🤖 - 智能聊天、绘画（OpenAI）
      chatgpt: use [yptools chatgpt] 创建会话列表与 chatgpt 聊天，会记录上下内容（科学上网）
                   [yptools chatgpt ...] 快速与 chatgpt 沟通，不会记录上下内容

      openai: use [yptools openaiimg ...] 根据文本描述生成图像（eg: yptools openaiimg '老虎和狮子大战' ）
      
      🤡🤡🤡 - hacker
      scanlocalips: use [yptools scanlocalips] 扫描本地局域网下所有 IP
      
      portscan: use [yptools portscan <ip地址或域名> [<端口范围>]] 扫描指定 IP 端口是否开放

      dosattack: use [yptools dosattack <ip> <n>] DOS攻击 「警告：此方法仅用于学习使用」 ip=请求域名 n=攻击次数 （eg: yptools dosattack https://example.com 10000）

      unzip: use [yptools unzip <文件>] 分析压缩文件，破解密码。【扩展说明：n='0-10' a='a-z' A='A-Z' s='特殊字符'】(eg：yptools unzip -n -a -A file.zip)

      💩💩💩 - 帮助（help & update）
      update: use [yptools update] 更新yptools

      help: use [yptools help] 查看帮助

    }
  end

end
