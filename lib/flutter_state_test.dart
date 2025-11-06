import 'package:flutter/material.dart';

void main()
{
    runApp(const MaterialApp(
            title: 'State Demo',
            home: StateTest(),
            debugShowCheckedModeBanner: false));
}

// 1. 将 StateTest 从 StatelessWidget更改为 StatefulWidget
class StateTest extends StatefulWidget
{
    const StateTest({Key? key}) : super(key: key);

    @override
    // 2. StatefulWidget 必须实现 createState 方法，返回一个 State 对象
    State<StateTest> createState() => _StateTestState();
}

// 3. 创建与 StateTest 关联的 State 类
class _StateTestState extends State<StateTest>
{
    // 4. 将需要变化的变量 'child' 移动到 State 类中
    Widget child = const Text("我是第一个build的text");

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("31--------------initState");
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print("32--------------didChangeDependencies");

  }

  @override
  void didUpdateWidget(covariant StateTest oldWidget) {
      // TODO: implement didUpdateWidget
      print("45--------------didUpdateWidget");
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print("46----------------deactivate");
  }

    @override
    Widget build(BuildContext context) 
    {
      print("58------------build");
        return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
                // 5. 在 build 方法中直接使用 State 中的 child 变量
                // (可选) 为了让 child 居中，可以包裹一个 Center
                child: Center(child: child),
                color: Colors.blue
            ),
            // 6. 使用 ElevatedButton 替换已废弃的 FlatButton
            floatingActionButton: ElevatedButton(
                child: const Text('切换 Widget'),
                onPressed: ()
                {
                    // 7. 现在可以在这里合法地调用 setState
                    setState(()
                        {
                            // 当按钮被按下时，更新 child 变量
                            child = const SecondWidget();
                        }
                    );
                }
            )
        );
    }
}

class SecondWidget extends StatelessWidget
{ // SecondWidget 可以是无状态的
    const SecondWidget({super.key});



    @override
    Widget build(BuildContext context) 
    {
        // 注意：throw 会导致应用崩溃，这里改为返回一个 Text Widget
        return const Text(
            "我是 SecondWidget",
            style: TextStyle(color: Colors.white, fontSize: 20)
        );
    }
}
