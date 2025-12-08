import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 调用ios 原生代码
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.example.flutter_ios_communication/native');

  String _response = '等待响应...';

  Future<void> _callNativeMethod() async {
    String response;
    try {
      response = await platform.invokeMethod('getNativeString');
    } on PlatformException catch (e) {
      response = "调用失败: '${e.message}'.";
    }

    setState(() {
      _response = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter调用iOS原生代码'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '从iOS原生代码获取的响应:',
            ),
            Text(
              _response,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _callNativeMethod,
        tooltip: '调用原生方法',
        child: Icon(Icons.add),
      ),
    );
  }
}