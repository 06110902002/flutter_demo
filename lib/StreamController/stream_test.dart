import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget
{
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) 
    {
        return MaterialApp(
            title: 'Producer-Consumer Demo',
            home: Scaffold(
                appBar: AppBar(title: const Text('生产者-消费者')),
                body: const ProducerConsumerWidget()
            )
        );
    }
}

class ProducerConsumerWidget extends StatefulWidget
{
    const ProducerConsumerWidget({super.key});

    @override
    State<ProducerConsumerWidget> createState() => _ProducerConsumerWidgetState();
}

class _ProducerConsumerWidgetState extends State<ProducerConsumerWidget>
{
    late StreamController<int> _streamController;
    final List<int> _consumedItems = [];

    @override
    void initState() 
    {
        super.initState();
        _streamController = StreamController<int>.broadcast();

        // 启动生产者
        _startProducer();

        // 启动消费者
        _startConsumer();
    }

    void _startProducer() 
    {
        int counter = 0;
        Timer.periodic(const Duration(seconds: 1), (timer)
            {
                if (counter >= 10) 
                {
                    timer.cancel();
                    _streamController.close(); // 关闭流
                    return;
                }
                final value = Random().nextInt(100);
                print('.Producer: 发送 $value');
                _streamController.add(value);
                counter++;
            }
        );
    }

    void _startConsumer() 
    {
        _streamController.stream.listen((value)
            {
                print('.Consumer: 接收并处理 $value');
                setState(()
                    {
                        _consumedItems.add(value);
                    }
                );
            }, onDone: ()
            {
                print('流已关闭');
            }
        );
    }

    @override
    void dispose() 
    {
        _streamController.close();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) 
    {
        return ListView.builder(
            itemCount: _consumedItems.length,
            itemBuilder: (context, index)
            {
                return ListTile(
                    title: Text('消费项 #${index + 1}: ${_consumedItems[index]}')
                );
            }
        );
    }
}
