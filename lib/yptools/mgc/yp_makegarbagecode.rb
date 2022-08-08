#!/usr/bin/ruby
require 'pathname'
require 'colored'
require_relative '../log/yp_log'

## 需要忽略的文件或者文件夹
def yp_method_ignoringFiles
    return ".", "..", ".DS_Store", "Pods", "LocalPods", "main.m", "doc"
end

# 正则查询文件列表，path:传路径 script:正则表达式 ignoringFiles:忽略的文件或者文件夹  retun [{文件名:文件路径},{文件名2:文件路径2}]
def yp_method_fileList (path,script,ignoringFiles)
    
    unless File.directory?(path)
        return
    end

    unless path =~ /(\/$)/
        path = path + "/"
    end
    
    fileList = Array.new
    Dir.entries(path).each do |sub|
        unless ignoringFiles.include?(sub)
            subPath = path + sub;
            if File.directory?(subPath)
                subFileList = yp_method_fileList subPath, script, ignoringFiles
                fileList = fileList + subFileList;
            else
                if subPath =~ script
                    obj = Hash.new
                    obj[sub] = subPath
                    fileList.push(obj)
                end
            end
            
        end
    end
    
    return fileList
end

# 删除文件夹（包括文件夹下面的文件）
def yp_method_rmdir (path)
    if File.exists?(path)
        if File.directory?(path)
            Dir.foreach(path) do |subPath|
                if subPath != '.' and subPath != '..'
                    tempSubPath = File.join(path, subPath)
                    yp_method_rmdir(tempSubPath)
                end
            end
            Dir.rmdir(path)
        else
            File.delete(path)
        end
    end
end

# 创建文件夹
def yp_method_mkdir (path)
    Dir.mkdir(path)
end



# 根据.m文件创建垃圾代码
def yp_method_ceateGarbageCodeByObjC_m(path,outPath,suffix)
    
    pathFile = File.open(path, "r")
    
    maxLineThreshold = 10000
    fileLine = 0
    
    fileName = File.basename(path,".*")
    
    mainStringH = "@interface " + fileName + " (#{suffix})"
    mainStringM = "@implementation " + fileName + " (#{suffix})"
    
    importStringsH = Array.new
    importStringsM = Array.new
    
    methodStringsH = Array.new
    methodStringsM = Array.new
    
    pathFileStrings = Array.new
    
    isClass = 0
    
    while textLine = pathFile.gets
        fileLine += 1
        
        if pathFileStrings.include?(textLine)
            next
        end
        
        if textLine.include?("@implementation #{fileName}")
            isClass = 1
        end
        
        pathFileStrings.push(textLine)
        
        if textLine.include?("#import")
            importStringsH.push(textLine)
        elsif textLine.start_with?("-(") | textLine.start_with?("- (")
        
            if textLine.include?("API_AVAILABLE")
                next
            end
        
            textLine = textLine.sub(" \{","\{")
            textLine = textLine.sub("\n","")
            
            unless textLine.include?("{")
                textLine = textLine + "{"
            end
            
            returnStringM = ""
            if textLine.include?("-(void") | textLine.include?("- (void")
                returnStringM = "   return;"
            elsif textLine.include?("- (IBAction") | textLine.include?("-(IBAction")
                returnStringM = "   return;"
            elsif textLine.include?("- (CGFloat") | textLine.include?("-(CGFloat")
                returnStringM = "   return 0.f;"
            elsif textLine.include?("- (CGRect") | textLine.include?("-(CGRect")
                returnStringM = "   return CGRectZero;"
            elsif textLine.include?("- (CGSize") | textLine.include?("-(CGSize")
                returnStringM = "   return CGSizeZero;"
            elsif textLine.include?("- (UIEdgeInsets") | textLine.include?("-(UIEdgeInsets")
                returnStringM = "   return UIEdgeInsetsZero;"
            else
                next
            end
            
            # .h 文件生成
            replaceStringH = ""
            if textLine.include?(":")
                replaceStringH = " " + suffix + ":(NSString *)" + suffix + ";"
            else
                replaceStringH = suffix + ":(NSString *)" + suffix + ";"
            end
            
            tempTextLineH = textLine.sub("\{",replaceStringH)
            methodStringsH.push("/// " + suffix)
            methodStringsH.push("\n")
            methodStringsH.push(tempTextLineH)
            methodStringsH.push("\n")
            methodStringsH.push("\n")
            
            # .m 文件生成
            replaceStringM = ""
            if textLine.include?(":")
                replaceStringM = " " + suffix + ":(NSString *)" + suffix + "\ {"
            else
                replaceStringM = suffix + ":(NSString *)" + suffix + "\ {"
            end
            
            tempTextLineM = textLine.sub("\{",replaceStringM)
            methodStringsM.push("/// " + suffix)
            methodStringsM.push("\n")
            methodStringsM.push(tempTextLineM)
            methodStringsM.push("\n")
            methodStringsM.push("   NSLog(@\"%@\",#{suffix});")
            methodStringsM.push("\n")
            methodStringsM.push(returnStringM)
            methodStringsM.push("\n")
            methodStringsM.push("}")
            methodStringsM.push("\n")
            methodStringsM.push("\n")
        end
        
    end
    
    if isClass != 1
        return
    end
    
    importStringsH.push("\n")
    importStringsH.push(mainStringH)
    importStringsH.push("\n")
    importStringsH.push("\n")
    methodStringsH.push("@end")
    
    file_h = importStringsH + methodStringsH
    
    
    importStringsM.push("#import \"#{fileName}+#{suffix}.h\"")
    importStringsM.push("\n")
    importStringsM.push("\n")
    importStringsM.push(mainStringM)
    importStringsM.push("\n")
    importStringsM.push("\n")
    methodStringsM.push("@end")
    
    file_m = importStringsM + methodStringsM
    
    unless outPath =~ /(\/$)/
        outPath = outPath + "/"
    end
        
    filePathH = outPath + fileName + "+#{suffix}.h"
    filePathM = outPath + fileName + "+#{suffix}.m"

    createFileH = File.new(filePathH,"w+")
    file_h.each {|lineTest|
        createFileH.syswrite(lineTest)
    }

    createFileM = File.new(filePathM,"w+")
    file_m.each {|lineTest|
        createFileM.syswrite(lineTest)
    }
    
    pathFile.close
end

# 生成垃圾数据
def yp_method_makeGarbage (path, outPath, suffix)
    # 筛选文件的正则
    script = /^(?!.*(\+)).*.(\.m)$/
    # 配置忽略文件
    ignoringFiles = yp_method_ignoringFiles
    # 获取符合条件的文件列表
    fileList = yp_method_fileList path, script, ignoringFiles
    
    fileList.each { |fileDic|
        fileDic.each { |key, value|
            createTime = Time.new
            fileName = File.basename(value,".*")
            filePathH = fileName + "+#{suffix}.h"
            filePathM = fileName + "+#{suffix}.m"
            yp_log_success createTime.inspect + " 生成 " + filePathH + "、" + filePathM + " 完成"
            
            yp_method_ceateGarbageCodeByObjC_m(value,outPath,suffix)
        }
    }
end


# 生成垃圾数据
def yp_tools_method_makeGarbage (suffix)
    
    yp_log_doing "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀";

    yp_path = `pwd`
    yp_path = yp_path.sub("\n","")
    yp_outPath = "#{yp_path}/" + suffix
    
    yp_log_doing "当前目录 #{yp_path}"
    yp_log_doing "垃圾代码生成目录 #{yp_outPath}"
    yp_log_doing "后缀 #{suffix}"
    
    if suffix.length == 0
        yp_log_fail "后缀不能为空"
        return
    end
    
    yp_isTruePath = 0
    Dir.entries(yp_path).each do |subFile|
        if subFile.include?(".xcodeproj") | subFile.include?(".xcworkspace")
            yp_isTruePath = 1
            break
        end
    end

    if yp_isTruePath == 0
        yp_log_fail "#{yp_path} " + "此目录没有工程，请切换到项目目录下再执行 'yptools mgc ..' 命令"
        return
    end
    
    yp_isDo = 1
    
    if File.exists?(yp_outPath)
        yp_isDo = 0
        yp_log_success "检测'#{yp_outPath}' 文件夹已经存在，是否覆盖？(Enter Yes Or No)' :"
        val = $stdin.gets.chomp
        
        if val == 'Yes' || val == 'yes' || val == 'YES' || val == 'Y' || val == 'y' || val.length == 0
            yp_isDo = 1
        end
    end
    
    if yp_isDo == 1
        yp_method_rmdir yp_outPath
        yp_method_mkdir yp_outPath
        yp_method_makeGarbage yp_path, yp_outPath, suffix
    else
        yp_log_fail "操作已取消"
    end
    
    yp_log_doing "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀";
end

#yp_tools_method_makeGarbage "suffix"
