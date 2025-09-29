import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CounterModel extends ChangeNotifier
{
    int _count = 0;

    int get count => _count;

    void increment() 
    {
        _count++;
        notifyListeners(); // 通知所有监听者数据已更新
    }

    void decrement() 
    {
        _count--;
        notifyListeners();
    }

    void reset() 
    {
        _count = 0;
        notifyListeners();
    }
}

class CounterPage extends StatelessWidget
{
    @override
    Widget build(BuildContext context) 
    {
      print("35---------------build");
        return Scaffold(
            appBar: AppBar(title: Text('Provider Counter')),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text('计数器值：'),
                        // 方式1：使用Consumer
                        Consumer<CounterModel>(
                            builder: (context, counter, child)
                            {
                                return Text(
                                    '${counter.count}',
                                    style: Theme.of(context).textTheme.headlineMedium
                                );
                            }
                        ),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                ElevatedButton(
                                    onPressed: ()
                                    {
                                        // 方式2：使用Provider.of获取实例并调用方法
                                        Provider.of<CounterModel>(context, listen: false).decrement();
                                        int count = Provider.of<CounterModel>(context, listen: false).count;
                                        print("62---------------count = ${count}");
                                    },
                                    child: Text('-')
                                ),
                                ElevatedButton(
                                    onPressed: ()
                                    {
                                        // 方式3：使用context.read()
                                        context.read<CounterModel>().reset();
                                    },
                                    child: Text('重置')
                                ),
                                ElevatedButton(
                                    onPressed: ()
                                    {
                                        context.read<CounterModel>().increment();
                                    },
                                    child: Text('+')
                                )
                            ]
                        )
                    ]
                )
            )
        );
    }
}

class Providerroute extends StatelessWidget
{
    @override
    Widget build(BuildContext context) 
    {
        return MaterialApp(
            title: 'Provider Demo',
            home: CounterPage()
        );
    }
}

