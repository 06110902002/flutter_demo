import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base/theme_view_model.dart';
import 'view/user_list_page.dart';
import 'utils/toast.dart';

void main()
{
    runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) 
    {
        // 关键：在根Widget层级创建Provider，确保所有子Widget都能访问
        return ChangeNotifierProvider(
            create: (context) => ThemeViewModel()..init(),
            // 使用builder获取新的context，确保能访问Provider
            builder: (context, child)
            {
                return MaterialApp(
                    title: 'Flutter MVVM Demo',
                    theme: ThemeData(
                        primarySwatch: Colors.blue,
                        brightness: Brightness.light
                    ),
                    darkTheme: ThemeData(
                        primarySwatch: Colors.blueGrey,
                        brightness: Brightness.dark,
                        scaffoldBackgroundColor: Colors.grey[900]
                    ),
                    // 通过Consumer获取主题模式（确保context正确）
                    themeMode: Provider.of<ThemeViewModel>(context).themeMode,
                    home: UserListPage(),
                    navigatorKey: navigatorKey
                );
            }
        );
    }
}
