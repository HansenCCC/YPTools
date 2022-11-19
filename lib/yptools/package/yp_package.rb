# -*- coding: UTF-8 -*-

require 'pathname'
require 'colored'
require 'plist'
require 'json'
require_relative '../log/yp_log'
require_relative '../mgc/yp_makegarbagecode'


class YPPackage
    
    def self.analysis(filePath, delete = 1)

        fileName = File.basename(filePath)
        fileBasename = File.basename(filePath, ".*")
        fileSuffix = File.extname(filePath)
        fileDirname = File.dirname(filePath)
        
        yp_path = `pwd`
        yp_path = yp_path.sub("\n","")
        
#        yp_outPath = yp_path + '/Payload + ' + Time.new.inspect
        yp_outPath = fileDirname + '/ipa-' + Time.new.strftime("%Y%m%d%H%M%S-%L")
        yp_method_mkdir yp_outPath
        yp_log_doing "将ipa解压到临时目录#{yp_outPath}"
        `tar -xf #{filePath} -C #{yp_outPath}`
        
        yp_resourceFile = "#{yp_outPath}/Payload/"

        yp_resourceFile_app = ""
        Dir.entries(yp_resourceFile).each do |sub|
            if sub.end_with?(".app")
                yp_resourceFile_app = yp_resourceFile + sub;
            end
        end
    
        if yp_resourceFile_app.length == 0
            yp_log_fail "解析失败，请检查压缩包是否是ipa文件"
            return
        end
    
        puts yp_resourceFile_app
        
        yp_infoPlistName = "Info.plist"
        yp_infoPlistPath = ""
        
        yp_mobileprovisionName = ".mobileprovision"
        yp_mobileprovisionPath = ""
        
        Dir.entries(yp_resourceFile_app).each do |sub|
            if sub == yp_infoPlistName
                yp_infoPlistPath = yp_resourceFile_app + "/" + sub;
            end
            if sub.end_with?(yp_mobileprovisionName)
                yp_mobileprovisionPath = yp_resourceFile_app + "/" + sub;
            end
        end
        
        puts yp_infoPlistPath
        
        if yp_mobileprovisionPath.length > 0
            puts yp_mobileprovisionPath
            yp_mobileprovisionPlistPath = yp_resourceFile_app + "/" + "mobileprovision.plist"
            # 解析描述文件
            yp_mobileprovisionDatum = `security cms -D -i #{yp_mobileprovisionPath}`
            
            puts yp_mobileprovisionPlistPath
            
            yp_plistCreateFile = File.new(yp_mobileprovisionPlistPath,"w+")
            yp_plistCreateFile.syswrite(yp_mobileprovisionDatum)
            yp_plistCreateFile.close
                    
            yp_log_success "============================================================"
            
            yp_plist = Plist.parse_xml(yp_mobileprovisionPlistPath)
            
            if !yp_plist
                yp_plist = {}
            end
            
            yp_appIDName = yp_plist["AppIDName"]
            yp_applicationIdentifierPrefix = yp_plist["ApplicationIdentifierPrefix"]
            yp_creationDate = yp_plist["CreationDate"]
            yp_platform = yp_plist["Platform"]
            yp_isXcodeManaged = yp_plist["IsXcodeManaged"]
            yp_developerCertificates = yp_plist["DeveloperCertificates"]
            yp_DER_Encoded_Profile = yp_plist["DER-Encoded-Profile"]
            yp_entitlements = yp_plist["Entitlements"]
            yp_expirationDate = yp_plist["ExpirationDate"]
            yp_name = yp_plist["Name"]
            yp_provisionsAllDevices = yp_plist["ProvisionsAllDevices"]
            yp_teamIdentifier = yp_plist["TeamIdentifier"]
            yp_teamName = yp_plist["TeamName"]
            yp_timeToLive = yp_plist["TimeToLive"]
            yp_uUID = yp_plist["UUID"]
            yp_version = yp_plist["Version"]
            yp_provisionedDevices = yp_plist["ProvisionedDevices"]
            
            yp_log_success " 输出描述文件embedded.mobileprovision"
            puts yp_mobileprovisionPlistPath
            puts ''
            yp_log_doing " 程序名称:\t#{yp_appIDName}"
            yp_log_doing " 团队名称:\t#{yp_teamName}"
            yp_log_doing " 创建时间:\t#{yp_creationDate}"
            yp_log_fail " 过期时间:\t#{yp_expirationDate}"
            yp_log_doing " 系统平台:\t#{yp_platform}"
            
            if yp_provisionedDevices.class == Array
                yp_log_doing " \n udids"
                for device in  yp_provisionedDevices
                    yp_log_doing " #{device}"
                end
            end
            
            puts ''
            
        else
            yp_log_success "============================================================"
            yp_log_success "==================== 来自 AppStore 下载 ===================="
            
        end
        
#        yp_log_msg " 标识符🚀:\t#{yp_applicationIdentifierPrefix}"
#        yp_log_msg " 证书证书:\t#{yp_developerCertificates}"
#        yp_log_msg " 证书证书:\t#{yp_DER_Encoded_Profile}"
#        yp_log_doing " 随便看看:\t#{yp_entitlements}"
#        yp_log_msg " 名字名字:\t#{yp_name}"
#        yp_log_msg " 支持设备:\t#{yp_provisionsAllDevices}"
#        yp_log_msg " 团队标识:\t#{yp_teamIdentifier}"
#        puts " 生存时间:\t#{yp_timeToLive}"
#        puts " uuid🚀🚀:\t#{yp_uUID}"
#        puts " 版本号🚀:\t#{yp_version}"
        yp_log_success "============================================================"
        
#        puts yp_infoPlistPath

        # 解析加密之后的plist文件
        `plutil -convert json #{yp_infoPlistPath}`
        yp_info_plist = `cat #{yp_infoPlistPath}`
        yp_info_plist_hash = JSON.parse(yp_info_plist)
        yp_log_success " 输出Info.plist文件#{yp_infoPlistName}"
        puts yp_infoPlistPath
        
        puts ''
        yp_log_doing " CFBundleDisplayName:\t#{yp_info_plist_hash['CFBundleDisplayName']}"
        yp_log_doing " CFBundleIdentifier:\t#{yp_info_plist_hash['CFBundleIdentifier']}"
        yp_log_doing " CFBundleVersion:\t#{yp_info_plist_hash['CFBundleVersion']}"
#        if yp_info_plist_hash['NSContactsUsageDescription']
#            yp_log_doing " NSContactsUsageDescription:\t#{yp_info_plist_hash['NSContactsUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSPhotoLibraryUsageDescription']
#            yp_log_doing " NSPhotoLibraryUsageDescription:\t#{yp_info_plist_hash['NSPhotoLibraryUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSBluetoothAlwaysUsageDescription']
#            yp_log_doing " NSBluetoothAlwaysUsageDescription:\t#{yp_info_plist_hash['NSBluetoothAlwaysUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSLocationAlwaysAndWhenInUseUsageDescription']
#            yp_log_doing " NSLocationAlwaysAndWhenInUseUsageDescription:\t#{yp_info_plist_hash['NSLocationAlwaysAndWhenInUseUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSLocationWhenInUseUsageDescription']
#            yp_log_doing " NSLocationWhenInUseUsageDescription:\t#{yp_info_plist_hash['NSLocationWhenInUseUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSCameraUsageDescription']
#            yp_log_doing " NSCameraUsageDescription:\t#{yp_info_plist_hash['NSCameraUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSLocationAlwaysUsageDescription']
#            yp_log_doing " NSLocationAlwaysUsageDescription:\t#{yp_info_plist_hash['NSLocationAlwaysUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSBluetoothPeripheralUsageDescription']
#            yp_log_doing " NSBluetoothPeripheralUsageDescription:\t#{yp_info_plist_hash['NSBluetoothPeripheralUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSPhotoLibraryAddUsageDescription']
#            yp_log_doing " NSPhotoLibraryAddUsageDescription:\t#{yp_info_plist_hash['NSPhotoLibraryAddUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSMicrophoneUsageDescription']
#            yp_log_doing " NSMicrophoneUsageDescription:\t#{yp_info_plist_hash['NSMicrophoneUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSMotionUsageDescription']
#            yp_log_doing " NSMotionUsageDescription:\t#{yp_info_plist_hash['NSMotionUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSSiriUsageDescription']
#            yp_log_doing " NSSiriUsageDescription:\t#{yp_info_plist_hash['NSSiriUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSCalendarsUsageDescription']
#            yp_log_doing " NSCalendarsUsageDescription:\t#{yp_info_plist_hash['NSCalendarsUsageDescription']}"
#        end
#        if yp_info_plist_hash['NSFaceIDUsageDescription']
#            yp_log_doing " NSFaceIDUsageDescription:\t#{yp_info_plist_hash['NSFaceIDUsageDescription']}"
#        end
        puts ''
        yp_log_success "============================================================"
        
        if delete == 1
            yp_log_doing "移除临时目录#{yp_outPath}"
            yp_method_rmdir yp_outPath
        end
            
    end

end
