// D:/flutter_demo/test_flutter/lib/MediaQueryTest.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  // --- 🔴 修改开始 ---
  // 使用 MaterialApp 作为应用的根 Widget
  runApp(MaterialApp(
    // home 属性指定了应用的默认首页
    home: MyHomePage(),
    // (可选) 去掉右上角的 "DEBUG" 标签
    debugShowCheckedModeBanner: false,
  ));
  // --- 🟢 修改结束 ---
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 这行打印现在可以正常工作，因为它在 MaterialApp 的子树中
    print("22--------- MyHomePage ${MediaQuery.of(context).size}");
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return EditPage();
                  }));
                },
                child: new Text("Click", style: TextStyle(fontSize: 50)))));
  }
}

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: new Text("ControllerDemoPage")),
        extendBody: true,
        body: Column(children: [
          new Spacer(),
          new Container(
              margin: EdgeInsets.all(10),
              child: new Center(child: new TextField())),
          new Spacer()
        ]));
  }
}
