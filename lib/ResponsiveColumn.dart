import 'package:flutter/material.dart';

class ResponsiveColumn extends StatelessWidget
{
    const ResponsiveColumn({Key? key, required this.children}) : super(key: key);

    final List<Widget> children;

    @override
    Widget build(BuildContext context)
    {

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

                body: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints)
                    {
                        if (constraints.maxWidth < 200)
                        {
                            // 最大宽度小于200，显示单列
                            return Column(children: children, mainAxisSize: MainAxisSize.min);
                        }
                        else
                        {
                            // 大于200，显示双列
                            var _children = <Widget>[];
                            for (var i = 0; i < children.length; i += 2)
                            {
                                if (i + 1 < children.length)
                                {
                                    _children.add(Row(
                                            children: [children[i], children[i + 1]],
                                            mainAxisSize: MainAxisSize.min
                                        ));
                                }
                                else
                                {
                                    _children.add(children[i]);
                                }
                            }
                            return Column(children: _children, mainAxisSize: MainAxisSize.min);
                        }
                    }
                )
            )
        );

    }
}

// class LayoutBuilderRoute extends StatelessWidget {
//   const LayoutBuilderRoute({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     var _children = List.filled(6, Text("A"));
//     // Column在本示例中在水平方向的最大宽度为屏幕的宽度
//     return Column(
//       children: [
//         // 限制宽度为190，小于 200
//         SizedBox(width: 190, child: ResponsiveColumn(children: _children)),
//         ResponsiveColumn(children: _children),
//         LayoutLogPrint(child:Text("xx")) // 下面介绍
//       ],
//     );
//   }
// }
