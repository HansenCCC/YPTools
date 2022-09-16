class YPHelp

  def self.message
    puts %q{
        
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
