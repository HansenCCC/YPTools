class Help

  def self.message
    puts %q{
      mgc: use [yptools mgc "suffix"] 在当前目录生成垃圾代码（当前目录需要有.xcworkspace或者.xcodeproj目录）
      help: use [yptools help] 查看帮助
      mvvm: use [yptools mvvm] 为xcode创建OC语言的mvvm的模板
    }
  end

end
