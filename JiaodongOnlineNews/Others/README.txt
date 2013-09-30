iOS-Hierarchy-Viewer 用来查看视图层级

步骤：
1.make sure that you have added “-ObjC -all_load” to “other linker flags” (click at project root element, select “Build settings” tab, search for “other linker flags”)
2.if you already have JSONKit.m file in your project, please remove it because of linker conflict
3.add QuartzCore to frameworks list
4.launch hierarchy viewer in your code by calling [iOSHierarchyViewer start];. The best place for it is AppDelegate::applicationDidBecomeActive callback
5.find or get from logs device/simulator ip address and go to ‘http://[ip_address]:9449′ address (Chrome/Firefox only)

使用完毕后反向操作，以减小发布包的大小。

##########################################################################################

百度云推送测试

步骤：
1.build setting中修改签名为开发者签名
2.BPushConfig.plist中 设置product_mode = no
3.推送后台web界面上选择"开发版"

发布时需调整为生产版本，以上操作反向。

##########################################################################################

开发阶段关闭友盟统计

步骤：
1.JDOAppDelegate 中注释掉对应的三行

##########################################################################################