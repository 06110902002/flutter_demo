import 'package:flutter/material.dart';

/// layout_test
void main()
{
    runApp(const MaterialApp(
            title: 'Container  Demo',
            home: ContainerTest(),
            debugShowCheckedModeBanner: false
        ));

    /// 调试布局约束
    // runApp(
    //     LayoutBuilder(
    //         builder: (BuildContext context, BoxConstraints constraints)
    //         {
    //             print('17--------Root constraints $constraints');
    //             return Container(
    //                 color: Colors.cyan.shade200,
    //                 width: 10,
    //                 height: 10,
    //                 child: Center(
    //                     child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints)
    //                         {
    //                             print('25------Center constraints $constraints');
    //                             return Container(
    //                                 color: Colors.red.shade200,
    //                                 width: 300,
    //                                 height: 300,
    //                                 child: FlutterLogo(size: 1000)
    //                             );
    //                         }
    //                     )
    //                 )
    //             );
    //         }
    //     )
    // );

}


class ContainerTest extends StatelessWidget
{
    const ContainerTest({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context)
    {
        //演示约束规则  传递过程
        // return ConstrainedBox(
        //   constraints: BoxConstraints.loose(Size(200, 200)),
        //   child: Container(
        //     width: 100,
        //     height: 100,
        //     color: Colors.blue,
        //   ),
        // );

        return Scaffold( // <--- 使用 Scaffold
            body: Center( // <--- 使用 Center 让内容居中
                child: ConstrainedBox(
                    constraints: BoxConstraints.loose(Size(200, 200)), //创建宽松约束，让子widget 尺寸在本范围内生效
                    child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.blue,
                    ),
                ),
            ),
        );
    }
}
