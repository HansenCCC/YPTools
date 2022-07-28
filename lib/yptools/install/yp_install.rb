#!/usr/bin/ruby
require 'pathname'
require 'fileutils'
require 'colored'
require_relative '../mgc/yp_makegarbagecode'

class YPInstall
    
    def self.install(name)
        
        templates_url = "git@github.com:HansenCCC/kMVVM.git"
        templates_path = Dir.pwd
        templates_name = "kMVVM"
        
        templates_path = templates_path + "/#{templates_name}"
        yp_log_doing "生成临时文件#{templates_path}"
        
        # 删除旧库
        yp_method_rmdir templates_path
        
        system("git clone #{templates_url}")
        FileUtils.cd 'kMVVM'
        system("sh install-template.sh")
        FileUtils.cd '..'
        
        # 删除缓存
        yp_method_rmdir templates_path
        yp_log_doing "移除临时文件#{templates_path}"
        yp_log_success "安装#{templates_url}完成，重新打开Xcode才能生效"
        
    end
    
end


#mkdir -p ~/Library/Developer/Xcode/Templates/Source/
#
#rm -rf dir ~/Library/Developer/Xcode/Templates/Source/kMVVM.xctemplate
#
#cp -R kMVVM.xctemplate  ~/Library/Developer/Xcode/Templates/Source/kMVVM.xctemplate
