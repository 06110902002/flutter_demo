import 'package:flutter/material.dart';

import 'base_widget_page.dart';

void main()
{
    runApp(const MaterialApp(
            title: 'Container  Demo',
            home: MyHomePage(),
            debugShowCheckedModeBanner: false
        ));

}

class MyHomePage extends BaseWidgetPage
{
    const MyHomePage({super.key});

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseWidgetPageState<MyHomePage>
{
    int _counter = 0;

    @override
    String get appBarTitle => '我的主页';

    @override
    Color getAppBarColor(BuildContext context) => Colors.blue;

    @override
    List<Widget> get appBarActions => [
        IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _counter++)
        )
    ];

    @override
    Widget buildBody(BuildContext context) 
    {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Text('当前计数：'),
                    Text('$_counter', style: Theme.of(context).textTheme.headlineMedium)
                ]
            )
        );
    }

    @override
    FloatingActionButton buildFloatingActionButton(BuildContext context) 
    {
        return FloatingActionButton(
            onPressed: () => setState(() => _counter--),
            child: const Icon(Icons.remove)
        );
    }
}
