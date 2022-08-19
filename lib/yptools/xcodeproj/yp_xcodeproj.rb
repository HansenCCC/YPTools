require 'xcodeproj'
require_relative '../log/yp_log'
require_relative '../mgc/yp_makegarbagecode'

class YPXcodeproj

    def self.xcodeproj(cmd)
        case cmd
        when 'check'
            self.check
        when 'message'
            self.message
        else
            yp_log_fail "'yptools xcp #{name}' 暂无，敬请期待"
        end
    end
    
    def self.message

    end
        
    def self.check
        
        yp_log_doing "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀";

        yp_path = `pwd`
        yp_path = yp_path.sub("\n","")
        
        yp_log_doing "当前目录 #{yp_path}"
        
        yp_isTruePath = 0
        
        project_path = ''
        
        Dir.entries(yp_path).each do |subFile|
            if subFile.include?(".xcodeproj")
                yp_isTruePath = 1
                project_path = yp_path + "/" + subFile
                break
            end
        end

        if yp_isTruePath == 0
            yp_log_fail "#{yp_path} " + "此目录没有工程，请切换到项目目录下再执行 'yptools xcj check' 命令"
            return
        end
        
        yp_log_success "检查#{project_path}项目是否有异常文件"
        project = Xcodeproj::Project.open(project_path)
        
        target = project.targets.first
        
        if project.targets.count == 0
            yp_log_fail "解析失败，当前工程没有target"
            return
        elsif project.targets.count == 1
            yp_log_doing "开始解析target:'#{target}'"
        else
            yp_log_success '发现以下 targets，需要分析哪个？'
            index = 1
            project.targets.to_a.each do |t|
                yp_log_msg "#{index}、" + t.name
                index += 1
            end
            
            input_target = $stdin.gets.chomp.strip
            if input_target.empty?
                yp_log_fail '请选一个 target'
                return
            end
            
            target = nil
            
            project.targets.to_a.each do |t|
                if t.name == input_target
                    target = t
                end
            end
            
            unless target
                yp_log_fail "解析失败，输入terget名字与项目中不匹配"
                return
            end
            
        end
        
        not_exist_files = project.files.to_a.map do |file|
            file.real_path.to_s
        end.select do |path|
            !File.exists?(path)
        end
        
        exist_files = project.files.to_a.map do |file|
            file.real_path.to_s
        end.select do |path|
            File.exists?(path)
        end
        
        yp_log_doing "开始解析target:'#{target}'"
        yp_log_success "正在检测项目引用的文件是否存在:"
        if not_exist_files.count > 0
            yp_log_fail "请注意，以下'#{not_exist_files.count}个'文件不存在:"
            not_exist_files.to_a.map do |path|
                yp_log_fail File.basename(path) + ' -> ' + path
            end
        else
            yp_log_success "暂无异常"
        end
        
        subPath = yp_path
        script = /^*(\.m)$/
        ignoringFiles = ".", "..", ".DS_Store", "Pods"
        file_list = yp_method_fileList subPath, script, ignoringFiles
        
        all_file_list = Array.new
        file_list.each { |fileDic|
            fileDic.each { |key, value|
                all_file_list.push(value)
            }
        }
        
        target_files = target.source_build_phase.files.to_a.map do |pbx_build_file|
            pbx_build_file.file_ref.real_path.to_s
        end.select do |path|
            path.end_with?(".m", ".mm", ".swift")
        end.select do |path|
            File.exists?(path)
        end
        
        not_imports = all_file_list - target_files
        
        yp_log_success "正在检测'.m'文件引用问题:"
        if not_imports.count > 0
            yp_log_fail "请注意，以下'#{not_imports.count}个'文件没有被引用:"
            not_imports.to_a.map do |path|
                yp_log_fail File.basename(path) + ' -> ' + path
            end
        else
            yp_log_success "暂无异常"
        end
        
        yp_log_doing "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀";
        
    end

end


#xcodeproj工程配置脚本化 https://www.jianshu.com/p/67ab2522daa7

##        puts project.main_group.path
#        files_m = target.source_build_phase.files.to_a.map do |pbx_build_file|
#            pbx_build_file.file_ref.real_path.to_s
#        end.select do |path|
#            path.end_with?(".m", ".mm", ".swift")
#        end.select do |path|
#            !File.exists?(path)
#        end
#
##         files_h = target.headers_build_phase.files.to_a.map do |pbx_build_file|
##             puts pbx_build_file
###             pbx_build_file.file_ref.real_path.to_s
##         end.select do |path|
##             path.end_with?(".m", ".mm", ".swift")
##         end.select do |path|
##             File.exists?(path)
##         end
#
#         project.groups.to_a.map do |group|
##             puts group.class
##            puts pbx_build_file.file_ref.real_path.to_s
#         end
#
#
##         puts files_h
##        puts files_m
#
#        #     app_target = project.targets.first
#        #
#        #     puts app_target
#        #     new_group = project.new_group("CHSS")
#        #
#        #     header_ref = new_group.new_file('/Users/Hansen/Desktop/CHSS/CoverView+CHSS.h')
#        #     implm_ref = new_group.new_file('/Users/Hansen/Desktop/CHSS/CoverView+CHSS.m')
#        #     app_target.add_file_references([implm_ref])
#        #     project.save()
