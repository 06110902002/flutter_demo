import 'package:flutter/material.dart';

/// 导航按钮拦截
class WillPopScopeTestRoute extends StatefulWidget
{
    const WillPopScopeTestRoute({super.key});

    @override
    State<WillPopScopeTestRoute> createState() => _WillPopScopeTestRouteState();
}

class _WillPopScopeTestRouteState extends State<WillPopScopeTestRoute>
{
    bool _canPop = true; // 控制是否允许返回
    final TextEditingController _textController = TextEditingController();

    @override
    void dispose() 
    {
        _textController.dispose();
        super.dispose();
    }

    Future<bool> _handlePop() async
    {
        if (_textController.text.isEmpty) return true; // 允许直接返回

        // 弹出二次确认对话框
        final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('确认退出？'),
                content: const Text('输入内容未保存，确定要离开吗？'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消')
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('确定')
                    )
                ]
            )
        );
        return confirm ?? false; // 用户点击确定时返回true
    }

    @override
    Widget build(BuildContext context) 
    {
        return PopScope(
            canPop: _canPop, // 动态控制返回手势是否生效 [[6]][[7]]
            onPopInvoked: (didPop) async
            {
                if (didPop) return; // 如果已经弹出则直接返回
                final allowed = await _handlePop();
                if (allowed && mounted) 
                {
                    Navigator.pop(context); // 手动触发返回操作 [[2]][[4]]
                }
            },
            child: Scaffold(
                appBar: AppBar(title: const Text('PopScope 示例')),
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        children: [
                            TextField(
                                controller: _textController,
                                onChanged: (value)
                                {
                                    // 输入内容变化时更新canPop状态
                                    setState(() => _canPop = value.isEmpty);
                                }
                            )
                        ]
                    )
                )
            )
        );
    }
}
