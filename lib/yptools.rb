require_relative 'yptools/mgc/yp_makegarbagecode'
require_relative 'yptools/help/help'
require_relative 'yptools/log/yp_log'
require_relative 'yptools/mvvm/yp_install_template'

class YPTools
    
    def self.cmd_dispatch(argvs)
        cmd = argvs[0]
        case cmd
        when 'help'
            YPTools.help
        when 'mgc'
            if argvs.size > 1
                suffix = argvs[1]
                YPTools.mgc suffix
            else
                yp_log_fail "'yptools mgc ..' 参数缺失"
                self.help
            end
        when 'mvvm'
            YPTools.mvvm
        else
            YPTools.help
        end
        
    end
    
    def self.help
        Help.message
    end
    
    def self.mgc(suffix)
        yp_tools_method_makeGarbage suffix
    end
    
    def self.mvvm
        yp_install_template
    end
end

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


YPTools.cmd_dispatch(ARGV)

