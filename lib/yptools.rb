require_relative 'yptools/mgc/yp_makegarbagecode'
require_relative 'yptools/help/yp_help'
require_relative 'yptools/log/yp_log'
require_relative 'yptools/install/yp_install'
require_relative 'yptools/update/yp_update'
require_relative 'yptools/xcodeproj/yp_xcodeproj'

class YPTools
    
    def self.cmd_dispatch(argvs)
        cmd = argvs[0]
        case cmd
        when 'help'
            self.help
        when 'mgc'
            if argvs.size > 1
                suffix = argvs[1]
                self.mgc suffix
            else
                yp_log_fail "'yptools mgc ..' 参数缺失"
                self.help
            end
        when 'install'
            if argvs.size > 1
                name = argvs[1]
                self.install name
            else
                yp_log_fail "'yptools install ..' 参数缺失"
                self.help
            end
        when 'update'
            self.update
        when 'xpj'
            if argvs.size > 1
                cmd = argvs[1]
                self.xpj cmd
            else
                yp_log_fail "'yptools xpj ..' 参数缺失"
                self.help
            end
        else
            self.help
        end
        
    end
    
    def self.help
        YPHelp.message
    end
    
    def self.mgc(suffix)
        yp_tools_method_makeGarbage suffix
    end
    
    def self.install(name)
        YPInstall.install(name)
    end
    
    def self.update
        YPUpdate.update
    end
    
    def self.xpj(cmd)
        YPXcodeproj.xcodeproj(cmd)
    end
    
end


# xcode自动添加文件 > xcodeproj
# 自动生成xcode icon
# 垃圾代码自动添加
# 自动打包功能
# SDK自动生成

#puts "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀";
#
#path = "/Users/Hansen/Desktop/QMKKXProduct"
#outPath = "/Users/Hansen/Desktop/QMKKXProduct/CHS"
#suffix = "YPYP"
#
#yp_method_rmdir outPath
#yp_method_mkdir outPath
#yp_method_makeGarbage path, outPath, suffix
#
#puts "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀";

#yptools = YPTools.new
#


#YPTools.cmd_dispatch(ARGV)

