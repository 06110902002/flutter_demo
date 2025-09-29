import 'package:flutter/material.dart';

import 'PageA.dart';
import 'PageB.dart';

///provider 的使用 参考 https://cloud.tencent.com/developer/article/1884861
class ChangeNotifierProxyProviderExample extends StatefulWidget
{
    @override
    _ChangeNotifierProxyProviderExampleState createState() => _ChangeNotifierProxyProviderExampleState();
}

class _ChangeNotifierProxyProviderExampleState extends State<ChangeNotifierProxyProviderExample>
{

    var _selectedIndex = 0;
    var _pages = <Widget>[PageA(), PageB()];

    @override
    Widget build(BuildContext context) 
    {
        return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index)
                {
                    setState(()
                        {
                            _selectedIndex = index;
                        }
                    );
                },
                items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.book),
                        label: "书籍列表"
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: "收藏"
                    )
                ]
            )
        );
    }
}
