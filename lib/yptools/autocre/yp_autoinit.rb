# -*- coding: UTF-8 -*-

require 'pathname'
require 'colored'
require 'plist'
require 'json'
require_relative '../log/yp_log'
require_relative '../mgc/yp_makegarbagecode'


class YPAutoInit
    
    def self.createObjcInitJson
        yp_path = `pwd`
        yp_path = yp_path.sub("\n","")
        fileName = "YpImMessage.json"
        filePath = yp_path + "/" + fileName
        
        if File.exists?(filePath)
            File.delete(filePath)
        end
        
        jsonContents = Array.new
        
        jsonContentsJson = File.new(filePath, "w+")
        
        jsonContents.push '{'
        jsonContents.push '    "mode": "DAO",'
        jsonContents.push '    "module": "YpImMessage",'
        jsonContents.push '    "table": "yp_im_message",'
        jsonContents.push '    "property": {'
        jsonContents.push '      "id": "long",'
        jsonContents.push '      "msgid": "int64_t",'
        jsonContents.push '      "content": "NSString",'
        jsonContents.push '      "sendTime": "NSDate",'
        jsonContents.push '      "isMute": "BOOL",'
        jsonContents.push '      "money": "CGFloat"'
        jsonContents.push '    },'
        jsonContents.push '    "index": {'
        jsonContents.push '      "primary-autoincrement": "id"'
        jsonContents.push '    },'
        jsonContents.push '    "struct": {'
        jsonContents.push '        "YpIdContent": ['
        jsonContents.push '              "id",'
        jsonContents.push '              "content"'
        jsonContents.push '        ]'
        jsonContents.push '    }'
        jsonContents.push '}'
            
        jsonContents.each { |lineText|
            jsonContentsJson.syswrite(lineText);
            jsonContentsJson.syswrite("\n");
        }
        
        jsonContentsJson.close
        
    end
end
