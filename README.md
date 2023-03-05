YPTools

[![Build Status](https://img.shields.io/badge/Github-QMKKXProduct-brightgreen.svg)](https://github.com/HansenCCC/YPTools)
[![Build Status](https://img.shields.io/badge/platform-ios-orange.svg)](https://github.com/HansenCCC/YPTools)
[![Build Status](https://img.shields.io/badge/HansenCCC-Github-blue.svg)](https://github.com/HansenCCC)
[![Build Status](https://img.shields.io/badge/HansenCCC-知乎-lightgrey.svg)](https://www.zhihu.com/people/EngCCC)
[![Build Status](https://img.shields.io/badge/已上架AppStore-Apple-success.svg)](https://apps.apple.com/cn/app/ios%E5%AE%9E%E9%AA%8C%E5%AE%A4/id1568656582)

## What's YPTools? 

最近在学Ruby，就用Ruby写了个 gem 库来玩玩，偏向 iOS Objective-C 开发者设计的。

> YPTools 能干嘛？

- [x] 根据 json 创建数据库管理类（依赖于<FMDB/FMDB.h>框架）
- [x] 为 Xcode 创建 OC 语言的 mvvm 的模板
- [x] 快速解析 IPA 文件
- [x] 混淆中给 OC 代码注入大量垃圾代码
- [x] 混淆中更新当前目录下面文件后缀为 .h|.m 的文件创建时间
- [x] 检查工程是否存在引用的问题

## Installation

用终端执行以下安装命令

```sh
$ gem install yptools
```

## Quickstart

### $ yptools help

> 安装之后，可以通过【yptools help】命令来查看帮助文档

```
chatai: use [yptools chatai ...] 快速与 chatgpt 沟通（科学上网）

autocre: use [yptools autocre ...] 自动化工具命令
         use [yptools autocre -init] 构建数据库操作文件的 json 模板
         use [yptools autocre -objc ...] 根据 json 自动创建 Objective-C 数据库管理文件 .h|.m 文件。（依赖三方库 FMDB ）

install: use [yptools install mvvm] 为 Xcode 创建 OC 语言的 mvvm 的模板

mgc: use [yptools mgc suffix] 在当前目录生成垃圾代码（当前目录需要有 .xcworkspace 或者 .xcodeproj 目录）

showipa: use [yptools showipa ...] 用于解析 IPA 文件

update: use [yptools update] 更新 yptools

ufct: use [yptools ufct] 更新当前目录下面文件后缀为 .h|.m 的文件创建时间

xpj: use [yptools xpj ...] use xcodeproj api
     use [yptools xpj check] 检查当前目录项目文件是否存在引用的问题

help: use [yptools help] 查看帮助
```

### $ yptools autocre ...

> 使用 `yptools autocre -init` 命令，创建一个模板。

```sh
yptools autocre -init
```

> 使用 `yptools autocre -objc <#filePath.json#>` 命令，根据 `<#filePath.json#>`  json文件创建 Objective-C 数据库管理文件 .h|.m 文件。

```sh
yptools autocre -objc YpImMessage.json
```

```objectivec
#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import <CoreGraphics/CoreGraphics.h>

@interface YpImMessage : NSObject <NSCopying>
@property (nonatomic) long id;
@property (nonatomic) int64_t msgid;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSDate *sendTime;
@property (nonatomic) BOOL isMute;
@property (nonatomic) CGFloat money;
@end

@interface YpIdContent : NSObject <NSCopying>
@property (nonatomic) long id;
@property (nonatomic, copy) NSString *content;
@end

@interface YpImMessageDao : NSObject

// basic
+ (instancetype)get;
- (BOOL)openWithPath:(NSString *)path;
- (FMDatabaseQueue *)getQueue;
- (BOOL)insertYpImMessage:(YpImMessage *)record aRid:(int64_t *)rid;
- (BOOL)batchInsertYpImMessage:(NSArray *)records;
- (BOOL)deleteYpImMessageByPrimaryKey:(int64_t)key;
- (BOOL)deleteYpImMessageBySQLCondition:(NSString *)condition;
- (BOOL)batchUpdateYpImMessage:(NSArray *)records;
- (BOOL)updateYpImMessageByPrimaryKey:(int64_t)key aYpImMessage:(YpImMessage *)aYpImMessage;
- (BOOL)updateYpImMessageBySQLCondition:(NSString *)condition aYpImMessage:(YpImMessage *)aYpImMessage;
- (YpImMessage *)selectYpImMessageByPrimaryKey:(int64_t)key;
- (NSArray *)selectYpImMessageBySQLCondition:(NSString *)condition;
- (int)selectYpImMessageCount:(NSString *)condition;

// struct
- (BOOL)updateYpIdContentByPrimaryKey:(int64_t)key aYpIdContent:(YpIdContent *)aYpIdContent;
- (BOOL)updateYpIdContentBySQLCondition:(NSString *)condition aYpIdContent:(YpIdContent *)aYpIdContent;
- (YpIdContent *)selectYpIdContentByPrimaryKey:(int64_t)key;
- (NSArray *)selectYpIdContentBySQLCondition:(NSString *)condition;

@end

```

### $ yptools install mvvm

> 使用此命令，可以为 Xcode 创建 OC 语言的 mvvm 的模板。
> 
> 下图2 中，Subclass of 需要填 UIVIewController 或 其子类。

<img src="https://pic2.zhimg.com/80/v2-2197cdd300016d9bf2591d3cf8bcdc55.png" width="700">

### $ yptools mgc ...

> 混淆注入垃圾代码行不行我不知道，倒是可以试试。

```sh
yptools mgc suffix

🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀
当前目录 /Users/hansen/iOS/QMKKXProduct
垃圾代码生成目录 /Users/hansen/iOS/QMKKXProduct/suffix
后缀 suffix
2022-10-13 15:06:06.358538 +0800 生成 KKUploadImageService+suffix.h、KKUploadImageService+suffix.m 完成
2022-10-13 15:06:06.359202 +0800 生成 KKNetworkPostedService+suffix.h、KKNetworkPostedService+suffix.m 完成
2022-10-13 15:06:06.359464 +0800 生成 KKFindPostedRequestModel+suffix.h、KKFindPostedRequestModel+suffix.m 完成
2022-10-13 15:06:06.359735 +0800 生成 KKPostedIssueRequestModel+suffix.h、KKPostedIssueRequestModel+suffix.m 完成
....
....
....
🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀
```

### $ yptools ufct

> 更新当前目录下所有的 .h | .m 为后缀的文件创建时间。

### $ yptools showipa ...

> 当你需要解压 IPA 时，或许你可以用一下它（命令末尾空格多加个任何字符可以不移除临时目录）

```sh
➜  yptools showipa wechat.ipa

将ipa解压到临时目录./ipa-20221013151157-424
./ipa-20221013151157-424/Payload/xxxxxxxx.app
./ipa-20221013151157-424/Payload/xxxxxxxx.app/Info.plist
./ipa-20221013151157-424/Payload/xxxxxxxx.app/embedded.mobileprovision
./ipa-20221013151157-424/Payload/xxxxxxxx.app/mobileprovision.plist
============================================================
 输出描述文件embedded.mobileprovision
./ipa-20221013151157-424/Payload/xxxxxxxx.app/mobileprovision.plist

 程序名称:	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 团队名称:	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 创建时间:	2022-04-06T01:25:03+00:00
 过期时间:	2023-04-06T01:25:03+00:00
 系统平台:	["iOS"]

 udids
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

============================================================
 输出Info.plist文件Info.plist
./ipa-20221013151157-424/Payload/xxxxxxxx.app/Info.plist

 CFBundleDisplayName:	xxxxxxxx
 CFBundleIdentifier:	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 CFBundleVersion:	202210131118

============================================================
移除临时目录./ipa-20221013151157-424
```

### $ yptools xpj check

> 检查当前目录项目文件是否存在引用的问题

```sh
yptools xpj check

🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀
当前目录 /Users/hansen/iOS/QMKKXProduct
检查/Users/hansen/iOS/QMKKXProduct/QMKKXProduct.xcodeproj项目是否有异常文件
发现以下 targets，需要分析哪个？
1、QMKKXProduct
2、QMKKXProductDev
QMKKXProduct
开始解析target:'QMKKXProduct'
正在检测项目引用的文件是否存在:
请注意，以下'9个'文件不存在:
QMKKXProductDev.app -> ${BUILT_PRODUCTS_DIR}/QMKKXProductDev.app
QMKKXProduct.app -> ${BUILT_PRODUCTS_DIR}/QMKKXProduct.app
StoreKit.framework -> ${SDKROOT}/System/Library/Frameworks/StoreKit.framework
...
...
...
正在检测'.m'文件引用问题:
请注意，以下'189个'文件没有被引用:
KKIDCardScanBackgroundView+suffix.m -> /Users/hansen/iOS/QMKKXProduct/suffix/KKIDCardScanBackgroundView+suffix.m
KKFileManagerViewController+suffix.m -> /Users/hansen/iOS/QMKKXProduct/suffix/KKFileManagerViewController+suffix.m
KKDistrict+suffix.m -> /Users/hansen/iOS/QMKKXProduct/suffix/KKDistrict+suffix.m
...
...
...
🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀
```

### $ yptools update

> update

## Author

chenghengsheng, 2534550460@qq.com

## Log

```
2022.11.01  1.0.12版本，增加【yptools autocre ..】自动化工具命令，根据 json 文件自动创建管理数据库单例；
2022.09.04  1.0.11版本，优化一下安装流程；
2022.09.16  1.0.8版本，增加【yptools shopipa ..】命令，用于快速预览ipa一些信息；
2022.08.20  1.0.7版本，增加【yptools ufct】更新当前目录下面文件后缀为.h|.m 的文件创建时间；
2022.08.14  1.0.6版本，增加【yptools xpj check】 命令用于检测 xcode 项目索引问题；
2022.08.13  1.0.5版本，增加【yptools update】 命令用于 yptools 更新；
2022.08.02  1.0.4版本，修复一些bug，提高性能；
2022.08.08  1.0.3版本，fix: 优化一些代码逻辑；【yptools mgc ...】流程优化；
2022.07.29  1.0.2版本，增加一些依赖库；
2022.07.29  1.0.1版本，新增安装【yptools install mvvm】为xcode创建OC语言的mvvm的模板；新增【yptools mgc ...】在当前目录生成垃圾代码（当前目录需要有.xcworkspace或者.xcodeproj目录）；新增【yptools help】使用文档；
2022.07.16  1.0.0版本，新的版本从这里开始；

```
