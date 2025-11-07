import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base/theme_view_model.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保当前context在ThemeViewModel Provider的作用域内
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // 使用Consumer监听主题变化
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return SwitchListTile(
                title: const Text('跟随系统主题'),
                value: themeViewModel.followSystem,
                onChanged: (value) => themeViewModel.toggleFollowSystem(value),
              );
            },
          ),
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return ListTile(
                title: const Text('手动切换主题'),
                subtitle: Text(
                  themeViewModel.themeMode == ThemeMode.light
                      ? '当前：浅色模式'
                      : '当前：深色模式',
                ),
                onTap: () => themeViewModel.toggleTheme(),
                enabled: !themeViewModel.followSystem,
              );
            },
          ),
        ],
      ),
    );
  }
}