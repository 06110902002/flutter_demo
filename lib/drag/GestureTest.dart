import 'package:flutter/material.dart';

/// 测试手势
class GestureTest extends StatelessWidget
{
    const GestureTest({super.key});

    @override
    Widget build(BuildContext context) 
    {
        return const MaterialApp(
            title: 'Flutter Gesture Demo',
            home: GestureDemoPage()
        );
    }
}

class GestureDemoPage extends StatelessWidget
{
    const GestureDemoPage({super.key});

    @override
    Widget build(BuildContext context) 
    {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Gesture Demo')
            ),
            body: Center(
                child: GestureDetector(
                    onTap: ()
                    {
                        print('Box Clicked!');
                    },
                    onDoubleTap: ()
                    {
                        print('Box DoubleClicked!');
                    },
                    onLongPress: ()
                    {
                        print('Box Long Pressed!');
                    },
                    onVerticalDragDown: (details)
                    {
                        print("onVerticalDragDown");
                    },
                    onVerticalDragStart: (details)
                    {
                        print("onVerticalDragStart");
                    },
                    onVerticalDragUpdate: (details)
                    {
                        print("onVerticalDragUpdate ${details.delta.dy}");
                    },
                    onVerticalDragEnd: (details)
                    {
                        print("onVerticalDragEnd");
                    },
                    onVerticalDragCancel: ()
                    {
                        print("onVerticalDragCancel");
                    },
                    child: Container(
                        // 这里存放需要监听事件的组件
                        width: 200,
                        height: 200,
                        color: Colors.blue,
                        alignment: Alignment.center,
                        child: const Text(
                            'Click or Long Press',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center
                        )
                    )
                )
            )
        );
    }
}
