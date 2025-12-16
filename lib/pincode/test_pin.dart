import 'package:flutter/material.dart';

/// 手机验证码
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Verification Code Input',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SmsVerificationPage(),
    );
  }
}

class SmsVerificationPage extends StatefulWidget {
  @override
  _SmsVerificationPageState createState() => _SmsVerificationPageState();
}

class _SmsVerificationPageState extends State<SmsVerificationPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _verificationCode = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      _verificationCode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMS Verification Code Input')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Enter the verification code sent to your phone:'),
            SizedBox(height: 20),
            SmsCodeInput(
              numberOfBoxes: 6, // 可以通过外部参数设置输入框数量
              onChanged: _onCodeChanged,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 提交验证码逻辑
                print('Verification Code: $_verificationCode');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class SmsCodeInput extends StatefulWidget {
  final int numberOfBoxes;
  final ValueChanged<String> onChanged;

  SmsCodeInput({required this.numberOfBoxes, required this.onChanged});

  @override
  _SmsCodeInputState createState() => _SmsCodeInputState();
}

class _SmsCodeInputState extends State<SmsCodeInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _currentCode = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.numberOfBoxes,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.numberOfBoxes, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onBoxChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.numberOfBoxes - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
      _currentCode =
          _currentCode.substring(0, index) +
          value +
          _currentCode.substring(index + 1);
      widget.onChanged(_currentCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.numberOfBoxes, (index) {
        return Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            //obscureText: true,
            keyboardType: TextInputType.number,
            // 1. 移除 TextStyle 中的 height 属性
            style: TextStyle(fontSize: 20),
            // 2. 在 decoration 中设置 contentPadding 和 textAlignVertical
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              // 3. 将 isCollapsed 设为 true，移除 TextField 的最小内边距
              isCollapsed: true,
              // 4. 设置垂直方向的对齐方式为居中
              contentPadding: EdgeInsets.symmetric(vertical: 5), // 可以微调这个值
            ),
            // 5. 使用 textAlignVertical 实现垂直居中
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) => _onBoxChanged(index, value),
          ),
        );
      }),
    );
  }
}
