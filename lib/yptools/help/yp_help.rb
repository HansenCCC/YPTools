class YPHelp

  def self.message
    puts %q{
        
      install: use [yptools install mvvm] 为xcode创建OC语言的mvvm的模板
      
      mgc: use [yptools mgc suffix] 在当前目录生成垃圾代码（当前目录需要有.xcworkspace或者.xcodeproj目录）
      
      update: use [yptools update] 更新yptools
      
      help: use [yptools help] 查看帮助
      
    }
  end

end
