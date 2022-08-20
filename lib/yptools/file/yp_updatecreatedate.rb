require 'pathname'
require 'colored'
require_relative '../log/yp_log'
require_relative '../mgc/yp_makegarbagecode'

def yp_copy_ignoringFiles
    return ".", "..", ".DS_Store"
end

def yp_updatereateDate (path)
    yp_log_msg '#{path}'
    # 筛选文件的正则
    script = /(\.h|\.m)$/
    # 配置忽略文件
    ignoringFiles = yp_copy_ignoringFiles
    # 获取符合条件的文件列表
    fileList = yp_method_fileList path, script, ignoringFiles
    
    yp_log_doing "正在准备更新当前目录下面文件后缀为.h|.m 的文件创建时间"
    
    fileList.each { |fileDic|
        fileDic.each { |key, value|
            createTime = Time.new
            fileName = File.basename(value,".*")
            yp_log_success "已更新文件:#{key}"
            yp_updateCreateDateWithPath value
        }
    }
    
    yp_log_success "已更新完成，总共更新#{fileList.count}个文件"
end

# 重新生成文件（目的是为了重置创建时间）
def yp_updateCreateDateWithPath (path)
    
    pathFile = File.open(path, "r")
    fileName = File.basename(path,".*")
    allLines = Array.new
    
    createTime = Time.new
    allLines.push('// YPTools Auto Update Create Date https://github.com/HansenCCC/YPTools')
    allLines.push("\n")
    allLines.push("// #{createTime}")
    allLines.push("\n")
    
    fileLine = 0
    while textLine = pathFile.gets
        fileLine += 1
        allLines.push(textLine)
    end
    
    allLines.push("\n")
    allLines.push("// #{createTime}")
    allLines.push("\n")
    allLines.push('// YPTools Auto Update Create Date https://github.com/HansenCCC/YPTools')
    
    filePath = path
    
    pathFile.close
    
    File.delete(path)
    
    createFile = File.new(filePath,"w+")
    allLines.each {|lineTest|
        createFile.syswrite(lineTest)
    }
    
    createFile.close
end
