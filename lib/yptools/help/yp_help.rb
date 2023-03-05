class YPHelp

  def self.message
    puts %q{
      
      chatai: use [yptools chatai ...] 快速与 chatgpt 沟通（科学上网）

      autocre: use [yptools autocre ...] 自动化工具命令
               use [yptools autocre -objc ...] 根据 json 自动创建 Objective-C 数据库操作文件 .h|.m 文件。（依赖三方库 FMDB ）
               use [yptools autocre -init] 构建数据库操作文件的json模板
      
      install: use [yptools install mvvm] 为xcode创建OC语言的mvvm的模板
      
      mgc: use [yptools mgc suffix] 在当前目录生成垃圾代码（当前目录需要有.xcworkspace或者.xcodeproj目录）
      
      showipa: use [yptools showipa ...] 用于解析ipa文件
      
      update: use [yptools update] 更新yptools
      
      ufct: use [yptools ufct] 更新当前目录下面文件后缀为.h|.m 的文件创建时间
      
      xpj: use [yptools xpj ...] use xcodeproj api
           use [yptools xpj check] 检查当前目录项目文件是否存在引用的问题
      
      help: use [yptools help] 查看帮助
      
    }
  end

end
