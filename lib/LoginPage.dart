import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget
{
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
    // 创建两个控制器
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    // 添加一个状态变量来存储Checkbox的状态
    bool _rememberMe = false;
    bool _isOn = false;
    String _loginMode = "auto";

    void login(String userName, String password)
    {
        if (userName.isEmpty)
        {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('请输入用户名'))
            );
            return;
        }
        if (password.isEmpty)
        {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('请输入密码'))
            );
            return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登录成功'))
        );
    }

    @override
    void dispose()
    {
        // 必须释放控制器，避免内存泄漏
        _usernameController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(
                title: Text('登录'),
                backgroundColor: Colors.deepPurple
            ),
            body: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // 圆形头像
                        CircleAvatar(
                            radius: 48, // 头像半径
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: NetworkImage(
                                'https://via.placeholder.com/100') // 占位图，可替换为本地图片 AssetImage('assets/images/avatar.png')
                        ),

                        SizedBox(height: 24), // 头像与用户名之间的间距

                        // 用户名输入框
                        _buildTextField(
                            label: '用户名',
                            hintText: '请输入用户名',
                            icon: Icons.person,
                            controller: _usernameController,
                            backgroundColor: Colors.blue.shade50
                        ),

                        SizedBox(height: 20),

                        // 密码输入框
                        _buildTextField(
                            label: '密码',
                            hintText: '请输入密码',
                            icon: Icons.lock,
                            isPassword: true,
                            controller: _passwordController,
                            backgroundColor: Colors.green.shade50
                        ),

                        SizedBox(height: 30),

                        // 忘记密码 + 确认按钮
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                TextButton(
                                    onPressed: ()
                                    {
                                        print('点击了忘记密码');
                                    },
                                    child: Text(
                                        '忘记密码？',
                                        style: TextStyle(color: Colors.grey)
                                    )
                                ),
                                ElevatedButton(
                                    onPressed: ()
                                    {
                                        String username = _usernameController.text.trim();
                                        String password = _passwordController.text.trim();

                                        print('95----用户名: $username');
                                        print('96----密码: $password');
                                        login(username, password);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8)
                                        )
                                    ),
                                    child: Text(
                                        '确认',
                                        style: TextStyle(color: Colors.white, fontSize: 16)
                                    )
                                )
                            ]
                        ),

                        SizedBox(height: 20), // 确认按钮与Checkbox之间的间距

                        // 新增：Checkbox 和 "记住我" 文本
                        Row(
                            children: [
                                Checkbox(
                                    value: _rememberMe,
                                    onChanged: (bool? newValue)
                                    {
                                        setState(()
                                            {
                                                _rememberMe = newValue ?? false;
                                            }
                                        );
                                    }
                                ),
                                Switch(
                                    value: _isOn,
                                    activeColor: Colors.yellow,        // 打开时的滑块颜色（thumb color）
                                    inactiveTrackColor: Colors.green,  // 关闭时的轨道颜色（track color）
                                    inactiveThumbColor: Colors.white, // 可选：关闭时滑块颜色，默认白色
                                    onChanged: (bool value)
                                    {
                                        setState(()
                                            {
                                                _isOn = value;
                                            }
                                        );
                                    }
                                ),

                                Text(
                                    '记住我',
                                    style: TextStyle(fontSize: 16)
                                )
                            ]
                        ),
                        // 右侧：Radio 按钮 + "自动登录"
                        Row(
                            children: [
                                Radio<String>(
                                    value: 'auto',                    // 这个按钮代表 "auto"
                                    groupValue: _loginMode,           // 当前选中的是哪个
                                    onChanged: (String? value)
                                    {      // 用户点击时触发
                                        setState(()
                                            {
                                                _loginMode = value!;          // 更新状态
                                            }
                                        );
                                    }
                                ),
                                Radio<String>(
                                    value: 'maunua',                    // 这个按钮代表 "auto"
                                    groupValue: _loginMode,           // 当前选中的是哪个
                                    onChanged: (String? value)
                                    {      // 用户点击时触发
                                        setState(()
                                            {
                                                _loginMode = value!;          // 更新状态
                                            }
                                        );
                                    }
                                ),

                                Text(
                                    _loginMode,
                                    style: TextStyle(fontSize: 16)
                                )
                            ]
                        ),
                        Column(
                            children: [
                                ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text('张三'),
                                    subtitle: Text('软件工程师'),
                                    trailing: Text('关注')
                                ),
                                Divider(),
                                ListTile(
                                    title: Text('列表项2')
                                )
                            ]
                        )
                    ]
                )
            )
        );
    }

    // 修改 _buildTextField 方法，接收 controller 参数
    Widget _buildTextField({
        required String label,
        required String hintText,
        required IconData icon,
        bool isPassword = false,
        required TextEditingController controller,
        Color backgroundColor = Colors.transparent
    })
    {
        return Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        label,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14
                        )
                    ),
                    SizedBox(height: 8),
                    TextField(
                        controller: controller, // 绑定控制器
                        obscureText: isPassword,
                        decoration: InputDecoration(
                            hintText: hintText,
                            prefixIcon: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(icon, size: 18)
                            ),
                            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero
                        ),
                        style: TextStyle(fontSize: 16)
                    )
                ]
            )
        );
    }
}
