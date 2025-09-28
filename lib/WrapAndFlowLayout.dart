import 'package:flutter/material.dart';

class Wrapandflowlayout extends StatelessWidget
{

    @override
    Widget build(BuildContext context)
    {

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
                                valueColor: AlwaysStoppedAnimation(Colors.red)
                            )
                        )
                    ]
                ),

                body: Wrap(
                    spacing: 8.0, // 主轴(水平)方向间距
                    runSpacing: 4.0, // 纵轴（垂直）方向间距
                    alignment: WrapAlignment.start, //沿主轴方向居中
                    children: [
                        Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('A')),
                            label: Text('Hamilton')
                        ),
                        Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('M')),
                            label: Text('Lafayette')
                        ),
                        Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('H')),
                            label: Text('Mulligan')
                        ),
                        Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('J')),
                            label: Text('Laurens')
                        )
                    ]
                )
            )
        );

    }
}
