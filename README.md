![](http://upload-images.jianshu.io/upload_images/790890-2346a0a31ab1f3d8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
说起启动盘制作工具，目前国外的开发人员已经开发有《DiskMaker》 和 《Install Disk Creator》这两个软件。

>DiskMaker下载地址：
http://diskmakerx.com/
Install Disk Creator 下载地址：
https://macdaddy.io/install-disk-creator/

我在写代码的时候还不知道有这两个工具，后来知道了有这两个工具了，所以本篇文章更多的是讲解下我当初的基本制作过程，顺便把源码分享给大家。

---
#####成品展示：
![由于简书图片大小的限制，未录制GIF完整，到最后一步，进度条走完就制作完成了](http://upload-images.jianshu.io/upload_images/790890-9b84e269bba2e161.gif?imageMogr2/auto-orient/strip)
##### 一、起因

由于本人经常折腾系统，所以很容易就搞坏了系统，然后每次都需要做系统盘，然后重做系统，很是麻烦。大概是要做一下步骤：
>1. 进入MAC 终端程序
2. 输入"sudo"
3. 输入"空格"
4. 拖文件“createinstallmedia”到终端（文件位置在安装程序》右键显示包文件》Contents》Resources里）（程序自动空格，若无空格请自行空格）
5. 然后输入 "--volume"
6. 输入"空格"
7. 拖你准备的盘符为 "disk"盘或分区到终端（程序自动空格，若无空格请自行空格）
8. 输入"--applicationpath"
9. 输入"空格"
10. 拖OS X安装程序到终端（程序自动空格，若无空格请自行空格）
11. 然后输入 "--nointeraction"
12. 按“return”（即回车）
13. 输入系统密码（密码不会显示，直接回车）
14. 等待启动盘制作完成。

然后我思考是否能做一个程序能够更方便的制作启动盘的一个工具，然后就开始行动了。

##### 二、方案 与 思考
制作之前，我考虑到基本上需要做到的基本功能要有：

>* 确定主要核心命令执行的方案。
* 做到能够调用系统终端命令。
* 做到能够使用Root权限调用系统终端命令。
* 做到能够自动识别获取到当前的磁盘盘符。
* 做到能够区分系统盘符和移动磁盘盘符。
* 做到能够监听磁盘重命名，插入，和卸载的变化。
* 做到能够监听制作的进度。
* 做到能够监听基本的制作过程的错误处理。
* 设计一个磁盘处理相关的类，用于外部调用处理。

#####主要核心命令执行的三个方案：
######（1）使用NSTask 执行核心命令
NSTask是MAC OS X用来执行系统终端命令的一个类，所以使用NSTask可以执行系统终端命令，但是NSTask有一个缺点，在我所知的是，无法以Root权限进行执行命令，但是正好启动盘制作工具 createinstallmedia 是必须需要Root权限执行的，所以说这个方案不考虑了。

######（2）使用 AppleScript 制作脚本，OS 开发程序调用
NSAppleScript 是可以执行AppleScript脚本的 一个类，用它可以执行AppleScript脚本，在AppleScript中，可以获得Root权限进行执行命令。

DiskMaker 就是用AppleScript脚本实现的核心功能，可以下载此软件，然后右键--显示包内容，然后找到源码.

![](http://upload-images.jianshu.io/upload_images/790890-37030e9333dce751.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

######（3）使用STPrivilegedTask执行终端命令，支持Root权限
可以通过 AuthorizationRef 来获取权限，执行命令，STPrivilegedTask就是对AuthorizationRef的封装，类似于NStask，只不过可以以Root权限执行命令。

---
最终我选择了使用 STPrivilegedTask 来实现核心命令执行。
##### 三、行动

#####UI界面：
首先，我使用Xcode 创建了Mac OS 工程，然后
在Main.storyboard调整出了基本界面。
添加了 Combox 控件用于展示磁盘列表。
添加了按钮，用于触发进行开始制作。
添加了NSView实现NSDraggingDestination代理方法，用于接收用户拖拽的系统文件。

#####核心功能讲解：
一些比较简单的基本控件的使用我就不详细说了，例如拖拽获取文件，combox控件的使用等等。
（1）获取监听磁盘装载与卸载
想要获取和监听磁盘装载与卸载，需要用过苹果的一个 DiskArbitration 框架，这个框架提供了可支持注册监听磁盘的装载与卸载，和信息修改等回调事件。
下面直接贴上来有关代码
```
+ (void)registerDiskNotice{

//创建一个新的会话
DASessionRef session = DASessionCreate(kCFAllocatorDefault);

//注册一个回调函数被称为磁盘时已经探测。
DARegisterDiskMountApprovalCallback(session,NULL,hello_diskmount,NULL);

//注册一个回调函数的调用，每当一个卷卸载。
DARegisterDiskUnmountApprovalCallback(session, NULL, goodbye_diskmount, NULL);

//注册一个回调函数称为每当一个磁盘已经出现了。
DARegisterDiskAppearedCallback(session, NULL, hello_disk, NULL);

//注册一个回调函数称为每当一个磁盘已经消失了。
DARegisterDiskDisappearedCallback(session, NULL, goodbye_disk, NULL);

//注册磁盘信息变化回调
DARegisterDiskDescriptionChangedCallback(session, NULL, NULL, DiskDescription, NULL);

//运行循环的调度会话。
DASessionScheduleWithRunLoop(session,CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

//注销一个核心基础对象。
CFRelease(session);
}

void DiskDescription( DADiskRef disk,CFArrayRef keys,void *context){
// 磁盘休息修改后，通过代理，告诉comBox要刷新视图
[selfObjc.comBoxdelegate diskDidChangeState:selfObjc.diskDict];
}

void hello_disk(DADiskRef disk, void *context){

[selfObjc diskChange:DiskChangeTypeAppear disk:disk];
}

void goodbye_disk(DADiskRef disk, void *context){
[selfObjc diskChange:DiskChangeTypeDismiss disk:disk];
/// 磁盘拔出或异常中断后，发出通知，用于处理中断的通知。
[[NSNotificationCenter defaultCenter]postNotificationName:DiskDisappeared object:(__bridge id _Nullable)(disk)];
}

DADissenterRef hello_diskmount(DADiskRef disk, void *context){
[selfObjc diskChange:DiskChangeTypeAppear disk:disk];
return NULL;
}

DADissenterRef goodbye_diskmount(DADiskRef disk, void *context){
[selfObjc diskChange:DiskChangeTypeDismiss disk:disk];
return NULL;
}

```

（2）区分系统磁盘和移动磁盘
为了能够区分系统磁盘和移动磁盘，肯定是先要获取磁盘的相关信息，磁盘出现后的，监听回调里面有一个DADiskRef 类型的参数 ，这个DADiskRef变量里面存储了磁盘相关的信息，通过 DADiskCopyDescription 函数，把disk对象当做参数，调用后可以获取到磁盘描述信息，类型可转换为字典，如下图：
![](http://upload-images.jianshu.io/upload_images/790890-a404868b8f39877f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

---
通过打印出来的信息可看到不少相关有用的内容，例如：
>* DAMediaBSDName：
用于唯一标识的磁盘，如果磁盘有重名那么BSDName也是唯一的。
* DAVolumeName：
是卷名，也是有用的。因为检测可以检测到磁盘和卷，一个磁盘可以有多个卷，磁盘的话，是没有DAVolumeName的，可以用于更准确的筛选。
* DAMediaSize：
磁盘的大小
* DADeviceProtocol：
这个是最主要的，如果是移动磁盘，DADeviceProtocol 就会是USB，所以可通过这个计算。

过滤系统磁盘 和 移动磁盘的代码：
相关宏定义：
![](http://upload-images.jianshu.io/upload_images/790890-7798dec13aff40c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
```
/// 统一处理磁盘的装载与卸载
- (void)diskChange:(DiskChangeType)state disk:(DADiskRef)disk{
NSLog(@"%@",Disk_Des);
// 过滤掉系统盘符，和小于8G的盘符
if (![VolumeName length] || ![BSDName length] || ![self checkDiskType:disk]) {
return;
}
// 用于记录磁盘，为了给combox传递数据
switch (state) {
case DiskChangeTypeAppear:
[self.diskDict setValue:(__bridge id _Nullable)(disk) forKey:BSDName];
break;
case DiskChangeTypeDismiss:
[self.diskDict removeObjectForKey:BSDName];
default:
break;
}

[self.comBoxdelegate diskDidChangeState:self.diskDict];
}

/// 检查是不是移动盘符，和是否小于8G
- (BOOL)checkDiskType:(DADiskRef)disk{
if (![DiskProtocol isEqualToString:@"USB"] || !VolumeName || DiskSize < 8.0) {
return NO;
}
return YES;
}

```

（3）监听磁盘信息的变化，例如重命名

注册这个监听即可
```
//注册磁盘信息变化回调
DARegisterDiskDescriptionChangedCallback(session, NULL, NULL, DiskDescription, NULL);
```
（4）监听制作进度
这里说一个思路，制作启动盘的时候，createinstallmedia会自动格式化磁盘，然后把指定的系统盘文件，慢慢拷贝进移动盘中，所以监听制作进度，我这里使用的是时钟，不断获取磁盘中系统文件的大小，如果达到和原文件一样的大小，说明就是制作进度完成了。

（5）调用系统终端命令
主要是看文档，然后看下STPrivilegedTask 怎么使用即可，剩下就是设计逻辑，和实现方式。
我大概说下我这边的：
首先是根据各个外部的变量，进行拼接成字符串，然后传递进DSTask自定义处理的一个类中，再进行分割参数，然后设置参数，和启动工具，然后执行launch命令即可。
```
- (void)runShell{

if (!self.codeArray.count) { return; }

[self resetTask];

// 配置运行参数
NSString *code = self.codeArray[0];
NSMutableArray *parameter = [code componentsSeparatedByString:@" "].mutableCopy;
for (int i =0; i<parameter.count; i++) {
NSString *tempStr = parameter[i];
tempStr = [[tempStr componentsSeparatedByCharactersInSet:FileDoNotWant(replaceChar)]componentsJoinedByString:@" "];
parameter[i] = tempStr;
}

[self.task setLaunchPath:parameter.firstObject];
[self.task setArguments:parameter];
self.codeArray = parameter;
dispatch_async(dispatch_get_global_queue(0, 0), ^{
[self.task launch];
dispatch_async(dispatch_get_main_queue(), ^{
[self startClock];
});
[self.task waitUntilExit];
});
}

```
#####其它说明：
还有很多细节没有说到，例如判断磁盘是否装载，制作过程中断处理，combox和工具类的建立和处理，逻辑之间的数据交换，空格文件名和磁盘空格的处理，等等这些，详细的可去看源码。
另外STPrivilegedTask 默认有个BUG，中文不支持，会计算错误长度。
```
需要修改这一块：
for (int i = 0; i < numberOfArguments; i++) {
NSString *argString = arguments[i];
NSUInteger stringLength = [argString length];

args[i] = malloc((stringLength + 1) * sizeof(char));
snprintf(args[i], stringLength + 1, "%s", [argString fileSystemRepresentation]);
}

为：

for (int i = 0; i < numberOfArguments; i++) {
NSString *argString = arguments[i];
args[i] = [argString UTF8String];
}
```
####使用注意：
在使用STPrivilegedTask，我发现无法监听到执行过程中内部的一些错误回调，所以说只有尽量避免了这种情况的出现，如果使用中发现制作不成功，或者点击制作后很久没有变化，可能内部命令提示出现错误，可手动格式化磁盘一次再进行制作，或者拔插磁盘后重新进行制作。

---
源码地址：https://github.com/DaSens/StartupDisk

![](http://upload-images.jianshu.io/upload_images/790890-0be7d342da16b285.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
