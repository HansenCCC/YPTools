# -*- coding: UTF-8 -*-

require 'pathname'
require 'colored'
require 'plist'
require 'json'
require_relative '../log/yp_log'
require_relative '../mgc/yp_makegarbagecode'


class YPAutoCreate
    
    @yp_filePath
    @yp_fileName
    @yp_fileBasename
    @yp_fileSuffix
    @yp_fileDirname
    @yp_path
    @yp_completePath
    @yp_json
    
    @yp_json_mode
    @yp_json_module
    @yp_json_table
    @yp_json_property
    @yp_json_index
    @yp_json_unique
    @yp_json_normal
    @yp_json_struct
    
    @yp_dao
    @yp_dao_h
    @yp_dao_m
    @yp_create_h
    @yp_create_m
    
    @yp_propertys
    @yp_propertys_type
    @yp_primarykey
    @yp_bool_haveprimarykey
    @yp_bool_havepropertys
    @yp_uniques
    @yp_normals
    @yp_struct
    @yp_copyArray
    @yp_bool_autoincrement
    @yp_need_log #控制是否使用YPLog 默认先关闭
    
    def self.createObjcSQL (filePath)
        
        @yp_filePath = filePath
        
        fileName = File.basename(filePath)
        fileBasename = File.basename(filePath, ".*")
        fileSuffix = File.extname(filePath)
        fileDirname = File.dirname(filePath)
        
        yp_path = `pwd`
        yp_path = yp_path.sub("\n","")
        
        yp_completePath = fileDirname + "/#{fileName}"
        yp_file = File.read(filePath)
        yp_json = JSON.parse(yp_file)
        
        yp_json_mode = yp_json["mode"]
        yp_json_module = yp_json["module"]
        yp_json_table = yp_json["table"]
        yp_json_property = yp_json["property"]
        
        yp_json_index = Hash.new
        if yp_json["index"] != nil
            yp_json_index = yp_json["index"]
        end
        
        yp_json_unique = Hash.new
        if yp_json["unique"] != nil
            yp_json_unique = yp_json["unique"]
        end
        
        yp_json_normal = Hash.new
        if yp_json["normal"] != nil
            yp_json_normal = yp_json["normal"]
        end
        
        yp_json_struct = Hash.new
        if yp_json["struct"] != nil
            yp_json_struct = yp_json["struct"]
        end
                
        yp_error = ""
        if yp_json_mode.class == NilClass || yp_json_mode.length == 0
            yp_error = "mode 参数为空了"
        end
        
        if yp_json_module.class == NilClass || yp_json_module.length == 0
            yp_error = "module 参数为空了"
        end
        
        if yp_json_table.class == NilClass || yp_json_table.length == 0
            yp_error = "table 参数为空了"
        end
        
        if yp_json_property.class == NilClass
            yp_error = "property 参数为空了"
        elsif yp_json_property.class != Hash
            yp_error = "property 不是json"
        end
        
        if yp_json_index.class != Hash && yp_json_index.class != NilClass
            yp_error = "index 不是json"
        end
        
        if yp_json_struct.class != Hash && yp_json_struct.class != NilClass
            yp_error = "struct 不是json"
        end
        
        if yp_error.length != 0
            yp_log_fail "构建失败，#{yp_error}"
            return
        end
        
        yp_dao = "#{yp_json_module}Dao"
        yp_dao_h = "/#{yp_dao}.h"
        yp_dao_m = "/#{yp_dao}.m"
        
        yp_create_h = fileDirname + yp_dao_h
        yp_create_m = fileDirname + yp_dao_m

        if File.exists?(yp_create_h)
            File.delete(yp_create_h)
        end
        
        if File.exists?(yp_create_m)
            File.delete(yp_create_m)
        end
        
        # model
        yp_h_contents = Array.new
        yp_m_contents = Array.new
        
        yp_h_contents.push "#import <Foundation/Foundation.h>"
        yp_h_contents.push("\n")
        yp_h_contents.push '#import "FMDatabaseQueue.h"'
        yp_h_contents.push("\n")
        yp_h_contents.push '#import <CoreGraphics/CoreGraphics.h>'
        yp_h_contents.push("\n")
        yp_h_contents.push("\n")
        
        yp_m_contents.push "#import \"#{yp_json_module}Dao.h\""
        yp_m_contents.push("\n")
        yp_m_contents.push '#import <FMDB/FMDB.h>'
        yp_m_contents.push("\n")
        if @yp_need_log == 1
            yp_m_contents.push '#import <YPLog/YPLog.h>'
            yp_m_contents.push("\n")
        end
        yp_m_contents.push("\n")
        yp_m_contents.push("#define DATABASE_NAME @\"welldown_enc.sqlite\"")
        yp_m_contents.push("\n")
        yp_m_contents.push("\n")
        
        yp_h_contents.push "@interface #{yp_json_module} : NSObject <NSCopying>"
        yp_h_contents.push("\n")
        
        yp_m_contents.push "@implementation #{yp_json_module}"
        yp_m_contents.push("\n")
        yp_m_contents.push "- (id)copyWithZone:(NSZone *)zone {"
        yp_m_contents.push("\n")
        yp_m_contents.push "    #{yp_json_module} *copy = (#{yp_json_module} *)[[[self class] allocWithZone:zone] init];"
        yp_m_contents.push("\n")
        
        propertyStr = ""
        copyArray = ["NSString","NSDate"]
        @yp_copyArray = copyArray
        
        yp_m_descriptions = Array.new
        yp_m_descriptions.push "    NSMutableString *result = [NSMutableString string];"
        yp_m_descriptions.push("\n")
        
        yp_propertys = yp_json_property.keys
        @yp_propertys = yp_propertys
        
        yp_propertys_type = Array.new
        yp_propertys.each { |key|
            value = yp_json_property[key]
            yp_propertys_type.push value
            if copyArray.include?(value)
                propertyStr = "@property (nonatomic, copy) #{value} *#{key};"
                yp_m_descriptions.push "    [result appendFormat:@\"#{key} %@, \\r\", self.#{key}];"
            else
                propertyStr = "@property (nonatomic) #{value} #{key};"
                yp_m_descriptions.push "    [result appendFormat:@\"#{key} %@, \\r\", @(self.#{key})];"
            end
            yp_h_contents.push(propertyStr)
            yp_h_contents.push("\n")
            
            yp_m_contents.push "    copy.#{key} = self.#{key};"
            yp_m_contents.push("\n")
            
            yp_m_descriptions.push("\n")
        }
            
        @yp_propertys_type = yp_propertys_type
        
        yp_h_contents.push "@end"
        yp_h_contents.push("\n")
        
        yp_m_contents.push("    return copy;")
        yp_m_contents.push("\n")
        yp_m_contents.push "}"
        yp_m_contents.push("\n")
        
        yp_m_contents.push("- (NSString *)description {")
        yp_m_contents.push("\n")
        yp_m_contents += yp_m_descriptions
        yp_m_contents.push("    return result;")
        yp_m_contents.push("\n")
        yp_m_contents.push("}")
        yp_m_contents.push("\n")
        
        
        yp_m_contents.push "@end"
        yp_m_contents.push("\n")
        
        yp_struct = yp_json_struct.keys
        yp_struct.each { |structKey|
            structValue = yp_json_struct[structKey]
            structValue_propertys = structValue
            
            yp_h_contents.push("\n")
            yp_h_contents.push "@interface #{structKey} : NSObject <NSCopying>"
            yp_h_contents.push("\n")
            
            yp_m_contents.push("\n")
            yp_m_contents.push "@implementation #{structKey}"
            yp_m_contents.push("\n")
            yp_m_contents.push "- (id)copyWithZone:(NSZone *)zone {"
            yp_m_contents.push("\n")
            yp_m_contents.push "    #{structKey} *copy = (#{structKey} *)[[[self class] allocWithZone:zone] init];"
            yp_m_contents.push("\n")
            
            
            yp_m_struct_descriptions = Array.new
            yp_m_struct_descriptions.push "    NSMutableString *result = [NSMutableString string];"
            yp_m_struct_descriptions.push("\n")
            
            structValue_propertys.each { |structValueKey|
                structValue_propertys_value = yp_json_property[structValueKey]
                if copyArray.include?(structValue_propertys_value)
                    propertyStr = "@property (nonatomic, copy) #{structValue_propertys_value} *#{structValueKey};"
                    yp_m_struct_descriptions.push "    [result appendFormat:@\"#{structValueKey} %@, \\r\", self.#{structValueKey}];"
                else
                    propertyStr = "@property (nonatomic) #{structValue_propertys_value} #{structValueKey};"
                    yp_m_struct_descriptions.push "    [result appendFormat:@\"#{structValueKey} %@, \\r\", @(self.#{structValueKey})];"
                end
                yp_h_contents.push(propertyStr)
                yp_h_contents.push("\n")
                
                yp_m_contents.push "    copy.#{structValueKey} = self.#{structValueKey};"
                yp_m_contents.push("\n")
                
                yp_m_struct_descriptions.push("\n")
            }
            yp_h_contents.push "@end"
            yp_h_contents.push("\n")
            
            yp_m_contents.push("    return copy;")
            yp_m_contents.push("\n")
            yp_m_contents.push "}"
            yp_m_contents.push("\n")
            
            yp_m_contents.push("- (NSString *)description {")
            yp_m_contents.push("\n")
            yp_m_contents += yp_m_struct_descriptions
            yp_m_contents.push("    return result;")
            yp_m_contents.push("\n")
            yp_m_contents.push("}")
            yp_m_contents.push("\n")
            
            yp_m_contents.push "@end"
            yp_m_contents.push("\n")
        }
        

        # 赋值
        
        yp_primarykey = yp_json_index["primary-autoincrement"]
        if yp_primarykey
            @yp_bool_autoincrement = 1
        elsif
            yp_primarykey = yp_json_index["primary"]
            @yp_bool_autoincrement = 0
        end
        
        yp_bool_haveprimarykey = yp_propertys.include?(yp_primarykey)
        yp_bool_havepropertys = yp_propertys.count != 0
        
        yp_uniques = Array.new
        if yp_json_unique != nil
            yp_uniques = yp_json_unique.keys
        end
        
        yp_normals = Array.new
        if yp_json_normal != nil
            yp_normals = yp_json_normal.keys
        end
        
        @yp_filePath = filePath
        @yp_fileName = fileName
        @yp_fileBasename = fileBasename
        @yp_fileSuffix = fileSuffix
        @yp_fileDirname = fileDirname
        @yp_path = yp_path
        @yp_completePath = yp_completePath
        @yp_json = yp_json
        
        @yp_json_mode = yp_json_mode
        @yp_json_module = yp_json_module
        @yp_json_table = yp_json_table
        @yp_json_property = yp_json_property
        @yp_json_index = yp_json_index
        @yp_json_unique = yp_json_unique
        @yp_json_normal = yp_json_normal
        @yp_json_struct = yp_json_struct
        
        @yp_dao = yp_dao
        @yp_dao_h = yp_dao_h
        @yp_dao_m = yp_dao_m
        @yp_create_h = yp_create_h
        @yp_create_m = yp_create_m
        
        @yp_primarykey = yp_primarykey
        @yp_bool_haveprimarykey = yp_bool_haveprimarykey
        @yp_bool_havepropertys = yp_bool_havepropertys
        @yp_uniques = yp_uniques
        @yp_normals = yp_normals
        @yp_struct = yp_struct
        
        # dao
        
        yp_h_contents.push("\n")

        yp_h_contents.push "@interface #{yp_dao} : NSObject"
        yp_h_contents.push("\n")
        
        yp_m_contents.push("\n")

        yp_m_contents.push "@implementation #{yp_dao} {"
        yp_m_contents.push("\n")
        
        yp_m_contents.push("    FMDatabaseQueue*   _dbQueue;")
        yp_m_contents.push("\n")
        yp_m_contents.push("    NSString*          _path;")
        yp_m_contents.push("\n")
        yp_m_contents.push("}")
        yp_m_contents.push("\n")
        
        yp_methods = Array.new
        yp_methods_m = Array.new
        yp_methods.push "+ (instancetype)get"
        yp_methods_m.push self.get
        yp_methods.push "- (BOOL)openWithPath:(NSString *)path"
        yp_methods_m.push self.openWithPath
        yp_methods.push "- (FMDatabaseQueue *)getQueue"
        yp_methods_m.push self.getQueue
        
        yp_methods.push ""
        yp_methods_m.push self.hideMethod
        
        yp_methods.push "- (BOOL)insert#{yp_json_module}:(#{yp_json_module} *)record aRid:(int64_t *)rid"
        yp_methods_m.push self.insertModel
        yp_methods.push "- (BOOL)batchInsert#{yp_json_module}:(NSArray *)records"
        yp_methods_m.push self.batchInstallModel
            
        if yp_bool_haveprimarykey
            yp_methods.push "- (BOOL)delete#{yp_json_module}ByPrimaryKey:(int64_t)key"
            yp_methods_m.push self.deleteByPrimaryKey
        end
        
        yp_methods.push "- (BOOL)delete#{yp_json_module}BySQLCondition:(NSString *)condition"
        yp_methods_m.push self.deleteBySQLCondition
        
        if yp_bool_haveprimarykey
            yp_methods.push "- (BOOL)batchUpdate#{yp_json_module}:(NSArray *)records"
            yp_methods_m.push self.batchUpdateModels
        end
        
        if yp_bool_haveprimarykey
            yp_methods.push "- (BOOL)update#{yp_json_module}ByPrimaryKey:(int64_t)key a#{yp_json_module}:(#{yp_json_module} *)a#{yp_json_module}"
            yp_methods_m.push self.updateByPrimaryKey
        end
        
        yp_methods.push "- (BOOL)update#{yp_json_module}BySQLCondition:(NSString *)condition a#{yp_json_module}:(#{yp_json_module} *)a#{yp_json_module}"
        yp_methods_m.push self.updateBySQLCondition
        
        if yp_bool_haveprimarykey
            yp_methods.push "- (#{yp_json_module} *)select#{yp_json_module}ByPrimaryKey:(int64_t)key"
            yp_methods_m.push self.selectByPrimaryKey
        end
        
        yp_methods.push "- (NSArray *)select#{yp_json_module}BySQLCondition:(NSString *)condition"
        yp_methods_m.push self.selectBySQLCondition
                
        yp_methods.push "- (int)select#{yp_json_module}Count:(NSString *)condition"
        yp_methods_m.push self.selectCount
        
        yp_h_contents.push("\n")
        yp_h_contents.push("// basic")
        yp_h_contents.push("\n")
        
        yp_m_contents.push("\n")
        yp_m_contents.push("// basic")
        yp_m_contents.push("\n")
        
        yp_methods.each { |method|
            mIndex = yp_methods.index method
            if method.length != 0
                yp_h_contents.push(method + ";")
                yp_h_contents.push("\n")
                
                yp_m_contents.push(method + " {")
                yp_m_contents.push("\n")
                yp_m_contents += yp_methods_m[mIndex]
                if yp_m_contents.last != "\n"
                    yp_m_contents.push("\n")
                end
                yp_m_contents.push("}")
                yp_m_contents.push("\n")
            else
                yp_m_contents += yp_methods_m[mIndex]
            end
        }
        
        if yp_uniques.count > 0
            yp_h_contents.push("\n")
            yp_h_contents.push("// unique")
            yp_h_contents.push("\n")
            
            yp_m_contents.push("\n")
            yp_m_contents.push("// unique")
            yp_m_contents.push("\n")
        end
        
        yp_methods_unique = Array.new
        yp_methods_unique_m = Array.new
        yp_uniques.each { | uniqueKey |
            unique_delete_line = "- (BOOL)delete#{yp_json_module}By#{uniqueKey}"
            unique_update_line = "- (BOOL)update#{yp_json_module}By#{uniqueKey}"
            unique_select_line = "- (#{yp_json_module} *)select#{yp_json_module}By#{uniqueKey}"
            uniques = yp_json_unique[uniqueKey]
            uniques.each { | unique_value |
                unique_type = yp_json_property[unique_value]
                unique_head_str = unique_value == uniques.first ? ":" : " #{unique_value}:"
                if copyArray.include?(unique_type)
                    unique_delete_line += unique_head_str + "(#{unique_type} *)#{unique_value}"
                    unique_update_line += unique_head_str + "(#{unique_type} *)#{unique_value}"
                    unique_select_line += unique_head_str + "(#{unique_type} *)#{unique_value}"
                else
                    unique_delete_line += unique_head_str + "(#{unique_type})#{unique_value}"
                    unique_update_line += unique_head_str + "(#{unique_type})#{unique_value}"
                    unique_select_line += unique_head_str + "(#{unique_type})#{unique_value}"
                end
            }
            yp_methods_unique.push unique_delete_line
            yp_methods_unique_m.push self.deleteByUnique(uniqueKey)
            yp_methods_unique.push (unique_update_line + " a#{yp_json_module}:(#{yp_json_module} *)a#{yp_json_module}")
            yp_methods_unique_m.push self.updateByUnique(uniqueKey)
            yp_methods_unique.push unique_select_line
            yp_methods_unique_m.push self.selectByUnique(uniqueKey)
        }
        
        yp_methods_unique.each { |method|
            yp_h_contents.push(method + ";")
            yp_h_contents.push("\n")
            
            yp_m_contents.push(method + " {")
            yp_m_contents.push("\n")
            mIndex = yp_methods_unique.index method
            yp_m_contents += yp_methods_unique_m[mIndex]
            yp_m_contents.push("\n")
            yp_m_contents.push("}")
            yp_m_contents.push("\n")
        }
        
        if yp_normals.count > 0
            yp_h_contents.push("\n")
            yp_h_contents.push("// normal")
            yp_h_contents.push("\n")
            
            yp_m_contents.push("\n")
            yp_m_contents.push("// normal")
            yp_m_contents.push("\n")
        end
        
        yp_methods_normal = Array.new
        yp_methods_normal_m = Array.new
        yp_normals.each { | normalKey |
            normal_delete_line = "- (BOOL)delete#{yp_json_module}By#{normalKey}"
            normal_update_line = "- (BOOL)update#{yp_json_module}By#{normalKey}"
            normal_select_line = "- (NSArray *)select#{yp_json_module}By#{normalKey}"
            normals = yp_json_normal[normalKey]
            normals.each { | normal_value |
                normal_type = yp_json_property[normal_value]
                normal_head_str = normal_value == normals.first ? ":" : " #{normal_value}:"
                if copyArray.include?(normal_type)
                    normal_delete_line += normal_head_str + "(#{normal_type} *)#{normal_value}"
                    normal_update_line += normal_head_str + "(#{normal_type} *)#{normal_value}"
                    normal_select_line += normal_head_str + "(#{normal_type} *)#{normal_value}"
                else
                    normal_delete_line += normal_head_str + "(#{normal_type})#{normal_value}"
                    normal_update_line += normal_head_str + "(#{normal_type})#{normal_value}"
                    normal_select_line += normal_head_str + "(#{normal_type})#{normal_value}"
                end
            }
            yp_methods_normal.push normal_delete_line
            yp_methods_normal_m.push self.deleteByNormal(normalKey)
            yp_methods_normal.push (normal_update_line + " a#{yp_json_module}:(#{yp_json_module} *)a#{yp_json_module}")
            yp_methods_normal_m.push self.updateByNormal(normalKey)
            yp_methods_normal.push normal_select_line
            yp_methods_normal_m.push self.selectByNormal(normalKey)
        }
        
        yp_methods_normal.each { |method|
            yp_h_contents.push(method + ";")
            yp_h_contents.push("\n")
            
            yp_m_contents.push(method + " {")
            yp_m_contents.push("\n")
            mIndex = yp_methods_normal.index method
            yp_m_contents += yp_methods_normal_m[mIndex]
            yp_m_contents.push("\n")
            yp_m_contents.push("}")
            yp_m_contents.push("\n")
        }

        if yp_struct.count > 0
            yp_h_contents.push("\n")
            yp_h_contents.push("// struct")
            yp_h_contents.push("\n")
            
            yp_m_contents.push("\n")
            yp_m_contents.push("// struct")
            yp_m_contents.push("\n")
        end
        
        yp_methods_struct = Array.new
        yp_methods_struct_m = Array.new
        yp_struct.each { | structKey |
            if yp_bool_haveprimarykey
                yp_methods_struct.push "- (BOOL)update#{structKey}ByPrimaryKey:(int64_t)key a#{structKey}:(#{structKey} *)a#{structKey}"
                yp_methods_struct_m.push self.updateStructByPrimaryKey(structKey)
            end
            
            yp_uniques.each { | uniqueKey |
                struct_unique_method_str = "- (BOOL)update#{structKey}By#{uniqueKey}"
                uniques = yp_json_unique[uniqueKey]
                uniques.each { | unique_value |
                    unique_type = yp_json_property[unique_value]
                    unique_head_str = unique_value == uniques.first ? ":" : " #{unique_value}:"
                    if copyArray.include?(unique_type)
                        struct_unique_method_str += unique_head_str + "(#{unique_type} *)#{unique_value}"
                    else
                        struct_unique_method_str += unique_head_str + "(#{unique_type})#{unique_value}"
                    end
                }
                struct_unique_method_str += " a#{structKey}:(#{structKey} *)a#{structKey}"
                yp_methods_struct.push struct_unique_method_str
                yp_methods_struct_m.push self.updateStructByUniqueKey(structKey, uniqueKey)
            }
            
            yp_normals.each { | normalKey |
                struct_normal_method_str = "- (BOOL)update#{structKey}By#{normalKey}"
                normals = yp_json_normal[normalKey]
                normals.each { | normal_value |
                    normal_type = yp_json_property[normal_value]
                    normal_head_str = normal_value == normals.first ? ":" : " #{normal_value}:"
                    if copyArray.include?(normal_type)
                        struct_normal_method_str += normal_head_str + "(#{normal_type} *)#{normal_value}"
                    else
                        struct_normal_method_str += normal_head_str + "(#{normal_type})#{normal_value}"
                    end
                }
                struct_normal_method_str += " a#{structKey}:(#{structKey} *)a#{structKey}"
                yp_methods_struct.push struct_normal_method_str
                yp_methods_struct_m.push self.updateStructByNormalKey(structKey, normalKey)
            }
            
            yp_methods_struct.push "- (BOOL)update#{structKey}BySQLCondition:(NSString *)condition a#{structKey}:(#{structKey} *)a#{structKey}"
            yp_methods_struct_m.push self.updateStructBySQLCondition(structKey)
            if yp_bool_haveprimarykey
                yp_methods_struct.push "- (#{structKey} *)select#{structKey}ByPrimaryKey:(int64_t)key"
                yp_methods_struct_m.push self.selectStructBySQLCondition(structKey)
            end
            
            yp_uniques.each { | uniqueKey |
                struct_unique_method_str = "- (#{structKey} *)select#{structKey}By#{uniqueKey}"
                uniques = yp_json_unique[uniqueKey]
                uniques.each { | unique_value |
                    unique_type = yp_json_property[unique_value]
                    unique_head_str = unique_value == uniques.first ? ":" : " #{unique_value}:"
                    if copyArray.include?(unique_type)
                        struct_unique_method_str += unique_head_str + "(#{unique_type} *)#{unique_value}"
                    else
                        struct_unique_method_str += unique_head_str + "(#{unique_type})#{unique_value}"
                    end
                }
                yp_methods_struct.push struct_unique_method_str
                yp_methods_struct_m.push self.selectStructByUnique(structKey, uniqueKey)
            }
            
            yp_normals.each { | normalKey |
                struct_normal_method_str = "- (NSArray *)select#{structKey}By#{normalKey}"
                normals = yp_json_normal[normalKey]
                normals.each { | normal_value |
                    normal_type = yp_json_property[normal_value]
                    normal_head_str = normal_value == normals.first ? ":" : " #{normal_value}:"
                    if copyArray.include?(normal_type)
                        struct_normal_method_str += normal_head_str + "(#{normal_type} *)#{normal_value}"
                    else
                        struct_normal_method_str += normal_head_str + "(#{normal_type})#{normal_value}"
                    end
                }
                yp_methods_struct.push struct_normal_method_str
                yp_methods_struct_m.push self.selectStructByNormal(structKey, normalKey)
            }
            
            yp_methods_struct.push "- (NSArray *)select#{structKey}BySQLCondition:(NSString *)condition"
            yp_methods_struct_m.push self.selectStructSQLCondition(structKey)
        }
        
        yp_methods_struct.each { |method|
            yp_h_contents.push(method + ";")
            yp_h_contents.push("\n")
            
            yp_m_contents.push(method + " {")
            yp_m_contents.push("\n")
            mIndex = yp_methods_struct.index method
            yp_m_contents += yp_methods_struct_m[mIndex]
            yp_m_contents.push("\n")
            yp_m_contents.push("}")
            yp_m_contents.push("\n")
        }
        
        yp_h_contents.push("\n")
        yp_h_contents.push "@end"
        yp_h_contents.push("\n")
        
        yp_m_contents.push("\n")
        yp_m_contents.push "@end"
        yp_m_contents.push("\n")
        
        yp_create_file_h = File.new(yp_create_h, "w+")
        yp_create_file_m = File.new(yp_create_m, "w+")
        
        yp_h_contents.each { |lineText|
            yp_create_file_h.syswrite(lineText);
        }
        
        yp_m_contents.each { |lineText|
            yp_create_file_m.syswrite(lineText);
        }
        
    end

    def self.insertModel
        codes = Array.new
        tableName = @yp_json_table
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        propertyNameTemp = Array.new
        @yp_json_property.each { | property, type |
            sqlType = self.sqlType(type)
            if property == @yp_primarykey && @yp_bool_autoincrement == 1
                next
            end
            
            valueNameTemp.push "?"
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "record.#{property}"
            else
                recordsNameTemp.push "@(record.#{property})"
            end
            propertyNameTemp.push property
            
        }
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = recordsNameTemp.join(", ")
        propertyName = "(" + propertyNameTemp.join(", ") + ")"
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"INSERT INTO #{tableName} #{propertyName} VALUES #{valueName}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{recordsName}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    } else {"
        codes.push "        if (rid != nil) *rid = [db lastInsertRowId];"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end

    def self.batchInstallModel
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        
        propertyNameTemp = Array.new
        @yp_json_property.each { | property, type |
            sqlType = self.sqlType(type)
            if property == @yp_primarykey && @yp_bool_autoincrement == 1
                next
            end
            
            valueNameTemp.push "?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "record.#{property}"
            else
                recordsNameTemp.push "@(record.#{property})"
            end
            propertyNameTemp.push property
            
        }
        
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = recordsNameTemp.join(", ")
        propertyName = "(" + propertyNameTemp.join(", ") + ")"
        
        codes.push "if (records.count == 0) return YES;"
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"INSERT INTO #{tableName} #{propertyName} VALUES #{valueName}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    for (#{@yp_json_module}* record in records) {"
        codes.push "        errorOccurred = ![db executeUpdate:sql, #{recordsName}];"
        codes.push "        if (errorOccurred) {"
        codes.push "        }"
        codes.push "    }"
        codes.push "}];"
        codes.push "return YES;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end

    def self.deleteByPrimaryKey
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "record.#{property}"
            else
                recordsNameTemp.push "@(record.#{property})"
            end
        }
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"DELETE FROM #{tableName} WHERE #{@yp_primarykey}=?\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, @(key)];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
   
    def self.deleteBySQLCondition
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "record.#{property}"
            else
                recordsNameTemp.push "@(record.#{property})"
            end
        }
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString *sql = @\"DELETE FROM #{tableName}\";"
        codes.push "if(condition != nil) {"
        codes.push "    sql = [NSString stringWithFormat:@\"%@ WHERE %@\", sql, condition];"
        codes.push "}"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end

    def self.batchUpdateModels
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "record.#{property}"
            else
                recordsNameTemp.push "@(record.#{property})"
            end
        }
        
        recordsNameTemp.push "@(record.#{@yp_primarykey})"
        
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"

        codes.push "if (records.count == 0) return YES;"
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{tableName} SET #{valueNameTemp.join(", ")} WHERE #{@yp_primarykey}=?\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    for (#{@yp_json_module} *record in records) {"
        codes.push "        errorOccurred = ![db executeUpdate:sql, #{recordsNameTemp.join(", ")}];"
        codes.push "        if (errorOccurred) {"
        codes.push "        }"
        codes.push "    }"
        codes.push "}];"
        codes.push "return YES;"

        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end

    def self.updateByPrimaryKey
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
        
        recordsNameTemp.push "@(key)"
        
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"

        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{tableName} SET #{valueNameTemp.join(", ")} WHERE #{@yp_primarykey}=?\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{recordsNameTemp.join(", ")}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"

        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end

    def self.updateBySQLCondition
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"

        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{valueNameTemp.join(", ")}\";"
        codes.push "if(condition != nil) {"
        codes.push "    sql = [NSString stringWithFormat:@\"%@ WHERE %@\", sql, condition];"
        codes.push "}"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{recordsNameTemp.join(", ")}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        

        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end

    def self.selectByPrimaryKey
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block #{@yp_json_module}* record = [[#{@yp_json_module} alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{@yp_propertys.join(", ")} FROM #{@yp_json_table} WHERE #{@yp_primarykey}=?\";"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql, @(key)];"
        codes.push "    while (resultSet.next) {"
        
        @yp_json_property.each { | property , type |
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        
        codes.push "        found = YES;"
        codes.push "        break;"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return record;"

        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectBySQLCondition
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        
        
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block NSMutableArray* records = [[NSMutableArray alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{@yp_propertys.join(", ")} FROM #{@yp_json_table}\";"
        codes.push "if(condition != nil) {"
        codes.push "    sql = [NSString stringWithFormat:@\"%@ WHERE %@\", sql, condition];"
        codes.push "}"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql];"
        codes.push "    while (resultSet.next) {"
        codes.push "        #{@yp_json_module}* record = [[#{@yp_json_module} alloc] init];"
        
        @yp_json_property.each { | property , type |
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        
        codes.push "        found = YES;"
        codes.push "        [records addObject:record];"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return records;"

        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectCount
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        codes.push "if (!_dbQueue) return -1;"
        codes.push "__block int count = 0;"
        codes.push "NSString* sql = @\"SELECT COUNT(*) FROM #{@yp_json_table}\";"
        codes.push "if(condition != nil) {"
        codes.push "    sql = [NSString stringWithFormat:@\"%@ WHERE %@\", sql, condition];"
        codes.push "}"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql];"
        codes.push "    if (resultSet.next) {"
        codes.push "        count = [resultSet intForColumnIndex:0];"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "return count;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.deleteByUnique (uniqueName)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        unique_array = Array.new
        @yp_json_unique[uniqueName].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        uniqueString = unique_array.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"DELETE FROM #{@yp_json_table} WHERE #{conditionString}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{uniqueString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.updateByUnique (uniqueName)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        unique_array = Array.new
        @yp_json_unique[uniqueName].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        recordsNameTemp += unique_array
        uniqueString = recordsNameTemp.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{valueName} WHERE #{conditionString}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{uniqueString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectByUnique (uniqueName)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        unique_array = Array.new
        @yp_json_unique[uniqueName].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        uniqueString = unique_array.join(", ")
                
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block #{@yp_json_module}* record = [[#{@yp_json_module} alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{valueName} FROM #{@yp_json_table} WHERE #{conditionString}\";"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql, #{uniqueString}];"
        codes.push "    while (resultSet.next) {"
        @yp_json_property.each { | property , type |
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        codes.push "        found = YES;"
        codes.push "        break;"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return record;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.deleteByNormal(normalKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = "(" + valueNameTemp.join(", ") + ")"
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        unique_array = Array.new
        @yp_json_normal[normalKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        uniqueString = unique_array.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"DELETE FROM #{@yp_json_table} WHERE #{conditionString}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{uniqueString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.updateByNormal(normalKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}=?"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "a#{@yp_json_module}.#{property}"
            else
                recordsNameTemp.push "@(a#{@yp_json_module}.#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        unique_array = Array.new
        @yp_json_normal[normalKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        recordsNameTemp += unique_array
        uniqueString = recordsNameTemp.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{valueName} WHERE #{conditionString}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{uniqueString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectByNormal(normalKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        unique_array = Array.new
        @yp_json_normal[normalKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        uniqueString = unique_array.join(", ")
                
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block NSMutableArray* records = [[NSMutableArray alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{valueName} FROM #{@yp_json_table} WHERE #{conditionString}\";"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql, #{uniqueString}];"
        codes.push "    while (resultSet.next) {"
        codes.push "    __block #{@yp_json_module}* record = [[#{@yp_json_module} alloc] init];"
        @yp_json_property.each { | property , type |
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        codes.push "        found = YES;"
        codes.push "        [records addObject:record];"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return records;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.updateStructByPrimaryKey(structKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        @yp_json_struct[structKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{conditionString} WHERE #{@yp_primarykey}=?\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{structString}, @(key)];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.updateStructByUniqueKey(structKey, uniqueKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        @yp_json_struct[structKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        unique_condition_array = Array.new
        unique_array = Array.new
        @yp_json_unique[uniqueKey].each { | property |
            unique_condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        unique_conditionString = unique_condition_array.join(" and ")
        
        uniqueString = unique_array.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{conditionString} WHERE #{unique_conditionString}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{structString}, #{uniqueString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.updateStructByNormalKey(structKey, normalKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        @yp_json_struct[structKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        normal_condition_array = Array.new
        normal_array = Array.new
        @yp_json_normal[normalKey].each { | property |
            normal_condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                normal_array.push "#{property}"
            else
                normal_array.push "@(#{property})"
            end
        }
        
        normal_conditionString = normal_condition_array.join(" and ")
        
        normalString = normal_array.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{conditionString} WHERE #{normal_conditionString}\";"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{structString}, #{normalString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.updateStructBySQLCondition(structKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        @yp_json_struct[structKey].each { | property |
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        codes.push "if (!_dbQueue) return NO;"
        codes.push "NSString* sql = @\"UPDATE #{@yp_json_table} SET #{conditionString}\";"
        codes.push "if(condition != nil) {"
        codes.push "    sql = [NSString stringWithFormat:@\"%@ WHERE %@\", sql, condition];"
        codes.push "}"
        codes.push "__block BOOL errorOccurred = NO;"
        codes.push "[_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollBack) {"
        codes.push "    errorOccurred = ![db executeUpdate:sql, #{structString}];"
        codes.push "    if (errorOccurred) {"
        codes.push "        *rollBack = YES;"
        codes.push "    }"
        codes.push "}];"
        codes.push "return !errorOccurred;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectStructBySQLCondition(structKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        struct_property_array = Array.new
        @yp_json_struct[structKey].each { | property |
            struct_property_array.push property
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        struct_property_arrayString = struct_property_array.join(", ")
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block #{structKey}* record = [[#{structKey} alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{struct_property_arrayString} FROM #{@yp_json_table} WHERE #{@yp_primarykey}=?\";"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql, @(key)];"
        codes.push "    while (resultSet.next) {"
        
        struct_property_array.each { | property |
            type = @yp_json_property[property]
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        
        codes.push "        found = YES;"
        codes.push "        break;"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return record;"
        
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectStructByUnique(structKey, uniqueKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        struct_property_array = Array.new
        @yp_json_struct[structKey].each { | property |
            struct_property_array.push property
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        struct_property_arrayString = struct_property_array.join(", ")
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        unique_condition_array = Array.new
        unique_array = Array.new
        @yp_json_unique[uniqueKey].each { | property |
            unique_condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                unique_array.push "#{property}"
            else
                unique_array.push "@(#{property})"
            end
        }
        
        unique_conditionString = unique_condition_array.join(" and ")
        
        uniqueString = unique_array.join(", ")
        
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block #{structKey}* record = [[#{structKey} alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{struct_property_arrayString} FROM #{@yp_json_table} WHERE #{unique_conditionString}\";"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql, #{uniqueString}];"
        codes.push "    while (resultSet.next) {"
        struct_property_array.each { | property |
            type = @yp_json_property[property]
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        codes.push "        found = YES;"
        codes.push "        break;"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return record;"
        
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectStructByNormal(structKey, normalKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        struct_property_array = Array.new
        @yp_json_struct[structKey].each { | property |
            struct_property_array.push property
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        struct_property_arrayString = struct_property_array.join(", ")
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        normal_condition_array = Array.new
        normal_array = Array.new
        @yp_json_normal[normalKey].each { | property |
            normal_condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                normal_array.push "#{property}"
            else
                normal_array.push "@(#{property})"
            end
        }
        
        normal_conditionString = normal_condition_array.join(" and ")
        
        normalString = normal_array.join(", ")
        
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block NSMutableArray* records = [[NSMutableArray alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{struct_property_arrayString} FROM #{@yp_json_table} WHERE #{normal_conditionString}\";"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql, #{normalString}];"
        codes.push "    while (resultSet.next) {"
        codes.push "        #{structKey}* record = [[#{structKey} alloc] init];"
        struct_property_array.each { | property |
            type = @yp_json_property[property]
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        codes.push "        found = YES;"
        codes.push "        [records addObject:record];"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return records;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.selectStructSQLCondition(structKey)
        codes = Array.new
        tableName = @yp_json_table
        propertyName = "(" + @yp_propertys.join(", ") + ")"
        valueNameTemp = Array.new
        recordsNameTemp = Array.new
        @yp_json_property.each { | property, type |
            valueNameTemp.push "#{property}"
            
            if @yp_copyArray.include?(type)
                recordsNameTemp.push "#{property}"
            else
                recordsNameTemp.push "@(#{property})"
            end
        }
                
        valueName = valueNameTemp.join(", ")
        recordsName = "(" + recordsNameTemp.join(", ") + ")"
        
        condition_array = Array.new
        struct_array = Array.new
        struct_property_array = Array.new
        @yp_json_struct[structKey].each { | property |
            struct_property_array.push property
            condition_array.push "#{property}=?"
            type = @yp_json_property[property]
            if @yp_copyArray.include?(type)
                struct_array.push "a#{structKey}.#{property}"
            else
                struct_array.push "@(a#{structKey}.#{property})"
            end
        }
        
        struct_property_arrayString = struct_property_array.join(", ")
        
        conditionString = condition_array.join(" and ")
        
        structString = struct_array.join(", ")
        
        codes.push "if (!_dbQueue) return nil;"
        codes.push "__block NSMutableArray* records = [[NSMutableArray alloc] init];"
        codes.push "NSString* sql = @\"SELECT #{struct_property_arrayString} FROM #{@yp_json_table}\";"
        codes.push "if(condition != nil) {"
        codes.push "    sql = [NSString stringWithFormat:@\"%@ WHERE %@\", sql, condition];"
        codes.push "}"
        codes.push "__block BOOL found = NO;"
        codes.push "[_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "    FMResultSet *resultSet = [db executeQuery:sql];"
        codes.push "    while (resultSet.next) {"
        codes.push "        #{structKey}* record = [[#{structKey} alloc] init];"
        struct_property_array.each { | property |
            type = @yp_json_property[property]
            method = self.codeStringForColumnWithType(type)
            codes.push "        record.#{property} = [resultSet #{method}:@\"#{property}\"];"
        }
        codes.push "        found = YES;"
        codes.push "        [records addObject:record];"
        codes.push "    }"
        codes.push "    [resultSet close];"
        codes.push "}];"
        codes.push "if(!found) return nil;"
        codes.push "return records;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.getQueue
        codes = Array.new
       
        codes.push "return _dbQueue;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.get
        codes = Array.new
       
        codes.push "static #{@yp_dao} *sI;"
        codes.push "static dispatch_once_t onceToken;"
        codes.push "dispatch_once(&onceToken, ^{"
        codes.push "    sI = [[#{@yp_dao} alloc] initPrivate];"
        codes.push "});"
        codes.push "return sI;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.openWithPath
        codes = Array.new
       
        codes.push "@synchronized(self) {"
        codes.push "    if(_dbQueue != nil) {"
        codes.push "        if([path isEqual:_path]) return YES;"
        codes.push "    }"
        codes.push "    _path = path;"
        codes.push "    NSString *dbDirectoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:path];"
        codes.push "    NSFileManager *fileManager = [NSFileManager defaultManager];"
        codes.push "    if (![fileManager fileExistsAtPath:dbDirectoryPath]) {"
        codes.push "        [fileManager createDirectoryAtPath:dbDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];"
        codes.push "    }"
        codes.push "    NSString* dbPath = [dbDirectoryPath stringByAppendingPathComponent:DATABASE_NAME];"
        codes.push "    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];"
        codes.push "}"
        codes.push "[self _createTables];"
        codes.push "return YES;"
        
        temp = Array.new
        codes.each { | code |
            temp.push "    " + code
            temp.push "\n"
        }
        return temp
    end
    
    def self.hideMethod
        codes = Array.new
       
        codes.push "- (instancetype)init {"
        codes.push "    @throw [NSException exceptionWithName:@\"Can't init!\" reason:@\"instance class!\" userInfo:nil];"
        codes.push "    return nil;"
        codes.push "}"
        
        codes.push "- (void)dealloc {"
        codes.push "    [[NSNotificationCenter defaultCenter] removeObserver:self];"
        codes.push "}"
        
        codes.push "- (void)resetDatebaseDBQueue {"
        codes.push "    @synchronized(self) {"
        codes.push "        _dbQueue = nil;"
        codes.push "        _path = nil;"
        codes.push "    }"
        codes.push "}"
        codes.push "- (instancetype)initPrivate {"
        codes.push "    self = [super init];"
        codes.push "    if (!self) {"
        codes.push "        return nil;"
        codes.push "    }"
        codes.push "    _dbQueue = nil;"
        codes.push "    _path = nil;"
        codes.push "    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetDatebaseDBQueue) name:@\"kYPDatebaseServiceResetDBQueue\" object:nil];"
        codes.push "    return self;"
        codes.push "}"
        
        
        codes.push "- (void)_createTables {"
        codes.push "    __block NSString* sql = nil;"
        codes.push "    sql = @\"SELECT * FROM #{@yp_json_table} limit 1\";"
        codes.push "    [_dbQueue inDatabase:^(FMDatabase *db) {"
        codes.push "        FMResultSet *resultSet = [db executeQuery:sql];"
        codes.push "        if(resultSet != nil) {"
        
        @yp_json_property.each { | property, type |
            sqlType = self.sqlType(type)
            if property != @yp_primarykey
                codes.push "            if([resultSet columnIndexForName:@\"#{property}\"] < 0) {"
                codes.push "                sql = @\"ALTER TABLE #{@yp_json_table} ADD COLUMN #{property} #{sqlType}\";"
                codes.push "                [db executeUpdate:sql];"
                codes.push "            }"
            end
        }
        codes.push "            [resultSet close];"
        codes.push "        } else {"
        
        createProperty = Array.new
        @yp_json_property.each { | property, type |
            sqlType = self.sqlType(type)
            if property != @yp_primarykey
                createProperty.push property + " " + sqlType
            elsif
                if @yp_bool_autoincrement == 1
                    createProperty.push property + " " + sqlType + " " + "PRIMARY KEY AUTOINCREMENT"
                elsif
                    createProperty.push property + " " + sqlType + " " + "PRIMARY KEY"
                end
            end
        }
        
        @yp_json_unique.each { | property, type |
            createProperty.push "UNIQUE(#{type.join(", ")})"
        }
        
        createPropertyStr = createProperty.join(", ")
        
        codes.push "            sql = @\" CREATE TABLE IF NOT EXISTS #{@yp_json_table}(#{createPropertyStr})\";"
        codes.push "            if ([db executeUpdate:sql]) {"
        if @yp_need_log
            codes.push "                YPLogDebug(@\"create table #{@yp_json_table} success\");"
        elsif
            codes.push "                NSLog(@\"create table #{@yp_json_table} success\");"
        end
        codes.push "            } else {"
        if @yp_need_log
            codes.push "                YPLogError(@\"create table #{@yp_json_table} failed\");"
        elsif
            codes.push "                NSLog(@\"create table #{@yp_json_table} failed\");"
        end
        codes.push "                return;"
        codes.push "           }"
        codes.push "       }"
        codes.push "   }];"
        
        @yp_json_normal.each { | property, type |
            codes.push "   sql = @\"SELECT * FROM sqlite_master where tbl_name = '#{@yp_json_table}' and type = 'index' and name = '#{property}'\";"
            codes.push "   [_dbQueue inDatabase:^(FMDatabase *db) {"
            codes.push "       FMResultSet *resultSet = [db executeQuery:sql];"
            codes.push "       if(!resultSet.next) {"
            codes.push "           sql = @\"CREATE INDEX #{property} ON #{@yp_json_table}(#{type.join(", ")})\";"
            codes.push "           if ([db executeUpdate:sql]) {"
            if @yp_need_log
                codes.push "               YPLogDebug(@\"create index #{@yp_json_table} success\");"
            elsif
                codes.push "               NSLog(@\"create index #{@yp_json_table} success\");"
            end
            codes.push "           } else {"
            if @yp_need_log
                codes.push "               YPLogError(@\"create table #{@yp_json_table} failed\");"
            elsif
                codes.push "               NSLog(@\"create table #{@yp_json_table} failed\");"
            end
            codes.push "               return;"
            codes.push "           }"
            codes.push "       }"
            codes.push "       [resultSet close];"
            codes.push "   }];"
        }
        codes.push "}"
        
        temp = Array.new
        codes.each { | code |
            temp.push code
            temp.push "\n"
        }
        return temp
    end

    
    def self.sqlType (type)
        if type == "long" || type == "int64_t" || type == "int32_t" || type == "NSInteger" || type == "NSUInteger"
            return "INTEGER"
        elsif type == "NSDate"
            return "TIMESTAMP"
        elsif type == "BOOL"
            return "INTEGER"
        elsif type == "CGFloat"
            return "FLOAT"
        elsif type == "NSString"
            return "TEXT"
        else
            return "TEXT"
        end
    end
    
    def self.codeStringForColumnWithType (type)
        if type == "long" || type == "int64_t" || type == "int32_t" || type == "NSInteger" || type == "NSUInteger"
            return "longLongIntForColumn"
        elsif type == "NSDate"
            return "dateForColumn"
        elsif type == "BOOL"
            return "boolForColumn"
        elsif type == "CGFloat"
            return "doubleForColumn"
        elsif type == "NSString"
            return "stringForColumn"
        else
            return "stringForColumn"
        end
    end
    
end
