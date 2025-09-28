import 'package:flutter/material.dart';

class AnimatedListRoute extends StatefulWidget
{
    const AnimatedListRoute({Key? key}) : super(key: key);

    @override
    _AnimatedListRouteState createState() => _AnimatedListRouteState();
}

class _AnimatedListRouteState extends State<AnimatedListRoute>
{
    var data = <String>[];
    int counter = 5;

    final globalKey = GlobalKey<AnimatedListState>();

    @override
    void initState()
    {
        for (var i = 0; i < counter; i++)
        {
            data.add('${i + 1}');
        }
        super.initState();
    }

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

                body: Stack(
                    children: [
                        AnimatedList(
                            key: globalKey,
                            initialItemCount: data.length,
                            itemBuilder: (
                                BuildContext context,
                                int index,
                                Animation<double> animation
                            )
                            {
                                //添加列表项时会执行渐显动画
                                return FadeTransition(
                                    opacity: animation,
                                    child: buildItem(context, index)
                                );
                            }
                        ),
                        buildAddBtn()
                    ]
                )
            )
        );

    }

    // 创建一个 “+” 按钮，点击后会向列表中插入一项
    Widget buildAddBtn()
    {
        return Positioned(
            child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: ()
                {
                    // 添加一个列表项
                    data.add('${++counter}');
                    // 告诉列表项有新添加的列表项
                    globalKey.currentState!.insertItem(data.length - 1);
                    print('添加 $counter');
                }
            ),
            bottom: 30,
            left: 0,
            right: 0
        );
    }

    // 构建列表项
    Widget buildItem(context, index)
    {
        String char = data[index];
        return Column( // 使用Column包裹ListTile和Divider
          children: [
            ListTile(
              //数字不会重复，所以作为Key
              key: ValueKey(char),
              title: Text(char),
              trailing: IconButton(
                  icon: Icon(Icons.delete),
                  // 点击时删除
                  onPressed: () => onDelete(context, index)),
            ),
            Padding( // 使用Padding包裹Divider来设置边距
              padding: EdgeInsets.symmetric(horizontal: 3.0), // 设置左右边距为3
              child: Divider(
                height: 2, // 设置高度为2
                thickness: 2, // 你也可以设置厚度，如果需要更明显的分隔线
                color: Colors.grey, // 你也可以设置颜色
              ),
            ),
          ],
        );
    }

    void onDelete(context, index)
    {
        setState(()
            {
                globalKey.currentState!.removeItem(
                    index,
                    (context, animation)
                    {
                        // 删除过程执行的是反向动画，animation.value 会从1变为0
                        var item = buildItem(context, index);
                        print('删除 ${data[index]}');
                        data.removeAt(index);
                        // 删除动画是一个合成动画：渐隐 + 收缩列表项
                        return FadeTransition(
                            opacity: CurvedAnimation(
                                parent: animation,
                                //让透明度变化的更快一些
                                curve: const Interval(0.5, 1.0)
                            ),
                            // 不断缩小列表项的高度
                            child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: 0.0,
                                child: item
                            )
                        );
                    },
                    duration: Duration(milliseconds: 200) // 动画时间为 200 ms
                );
            }
        );
    }
}
