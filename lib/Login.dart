import 'package:flutter/material.dart';

class Login extends StatelessWidget
{

  const Login({super.key});

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    '登录',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )
                ),
                backgroundColor: Colors.deepPurple
            ),
            body: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // ========== 新增：圆形头像 ==========
                        CircleAvatar(
                            radius: 48, // 头像半径
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: AssetImage('assets/imgs/seu.jpg'), // 占位图，可替换为本地图片 AssetImage('assets/images/avatar.png')
                            child: Stack(
                                children: [
                                    // 如果没有图片，显示默认图标
                                    if (/* 条件：无头像 */ true)
                                    Container(
                                        color: Colors.transparent, // 确保不遮挡 CircleAvatar 的背景
                                        child: Icon(
                                            Icons.person,
                                            size: 48,
                                            color: Colors.white
                                        )
                                    )
                                ]
                            )
                        ),

                        SizedBox(height: 24), // 头像与用户名之间的间距

                        _buildTextField(
                            label: '用户名',
                            hintText: '请输入用户名',
                            icon: Icons.person
                        ),

                        SizedBox(height: 20), // 间距

                        // 第二行：密码 + 输入框
                        _buildTextField(
                            label: '密码',
                            hintText: '请输入密码',
                            icon: Icons.lock,
                            isPassword: true
                        ),

                        SizedBox(height: 30), // 较大间距

                        // 第三行：忘记密码 + 确认按钮
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                // 忘记密码按钮（文字按钮）
                                TextButton(
                                    onPressed: ()
                                    {
                                        print('点击了忘记密码');
                                        // 跳转到找回密码页面
                                    },
                                    child: Text(
                                        '忘记密码？',
                                        style: TextStyle(color: Colors.grey)
                                    )
                                ),

                                // 确认按钮（主按钮）
                                ElevatedButton(
                                    onPressed: ()
                                    {
                                        print('点击了确认登录');
                                        // 执行登录逻辑
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
                        )
                    ]
                )
            )
        );
    }

    // 封装输入框组件，避免重复代码
    Widget _buildTextField({
        required String label,
        required String hintText,
        required IconData icon,
        bool isPassword = false
    })
    {
        return Column(
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
                    obscureText: isPassword, // 密码时隐藏文本
                    decoration: InputDecoration(
                        hintText: hintText,

                        prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 0, left: 10), // ✅ 设置图标与文本间距为 10
                            child: Icon(icon, size: 18)
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0), // ✅ 必须加

                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2)
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 160)
                    ),
                    style: TextStyle(fontSize: 16)
                )
            ]
        );
    }
}
