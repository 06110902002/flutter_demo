import 'package:flutter/material.dart';

import 'InfoCard.dart';

class Layout1 extends StatelessWidget
{
    const Layout1({super.key});

    @override
    Widget build(BuildContext context)
    {

        Widget redBox = DecoratedBox(
            decoration: BoxDecoration(color: Colors.red)
        );

        return MaterialApp(
            title: 'Flutter Demo',
            home: Scaffold(
                appBar: AppBar(
                  title: Text("this"),
                  actions: <Widget>[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.red),
                      ),
                    )
                  ],
                ),

                body: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 50, //宽度尽可能大
                        minHeight: 50.0 //最小高度为50像素
                    ),
                    child: SizedBox(
                        width: 480.0,
                        height: 280.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("data"),
                                Text("data2"),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(" hello world "),
                                Text(" I am Jack "),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                Text(" hello world "),
                                Text(" I am Jack "),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              verticalDirection: VerticalDirection.up,
                              children: <Widget>[
                                Text(" hello world ", style: TextStyle(fontSize: 30.0),),
                                Text(" I am Jack "),
                              ],
                            ),
                          ],
                        )
                    )
                )
            )
        );

    }
}
