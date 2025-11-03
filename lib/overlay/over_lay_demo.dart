import 'package:flutter/material.dart';
import './global_manager.dart';

/// 使用overlay 实现弹出菜单，对话框
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget
{
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) 
    {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                appBar: AppBar(
                    title: const Text('Overlay 示例')
                ),
                body: const GlobalModalExample()
            )
        );
    }
}

class GlobalModalExample extends StatelessWidget
{
    const GlobalModalExample({super.key});

    @override
    Widget build(BuildContext context) 
    {
        return Scaffold(
            appBar: AppBar(title: const Text('全局模态窗口示例')),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        ElevatedButton(
                            child: const Text('基本模态窗口'),
                            onPressed: () => GlobalModal.show(
                                context: context,
                                child: const Center(
                                    child: Text('这是一个基本模态窗口', style: TextStyle(fontSize: 20))
                                )
                            )
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                            child: const Text('自定义尺寸模态窗口'),
                            onPressed: () => GlobalModal.show(
                                context: context,
                                size: const Size(300, 400),
                                child: ListView.builder(
                                    itemCount: 20,
                                    itemBuilder: (_, index) => ListTile(
                                        title: Text('项目 $index')
                                    )
                                )
                            )
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                            child: const Text('可拖拽模态窗口'),
                            onPressed: () => GlobalModal.show(
                                context: context,
                                draggable: true,
                                child: const Column(
                                    children: [
                                        Text('可拖拽窗口', style: TextStyle(fontSize: 20)),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                            onPressed: GlobalModal.dismiss,
                                            child: Text('关闭')
                                        )
                                    ]
                                )
                            )
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                            child: const Text('禁止点击外部关闭'),
                            onPressed: () => GlobalModal.show(
                                context: context,
                                barrierDismissible: false,
                                child: const Center(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Text('必须点击按钮关闭', style: TextStyle(fontSize: 20)),
                                            SizedBox(height: 20),
                                            ElevatedButton(
                                                onPressed: GlobalModal.dismiss,
                                                child: Text('关闭窗口')
                                            )
                                        ]
                                    )
                                )
                            )
                        )
                    ]
                )
            )
        );
    }
}

