import 'package:flutter/material.dart';

class SingleChildScrollViewTestRoute extends StatelessWidget
{
    @override
    Widget build(BuildContext context) 
    {
        String str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        return MaterialApp(
            title: 'Flutter Demo',
            home: Scaffold(
                appBar: AppBar(
                    title: Text(
                        'Hello Flutter this is first demo',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Roboto'
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                    )
                ),

                body: Scrollbar( // 显示进度条
                    child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                            child: Column(
                                //动态创建一个List<Widget>
                                children: str.split("")
                                    //每一个字母都用一个Text显示,字体为原来的两倍
                                    .map((c) => Text(c, textScaleFactor: 2.0))
                                    .toList()
                            )
                        )
                    )
                )
            )
        );

    }
}
