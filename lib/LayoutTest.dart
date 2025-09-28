import 'package:flutter/material.dart';

import 'InfoCard.dart';

class LayoutTest extends StatelessWidget
{
    const LayoutTest({super.key});

    @override
    Widget build(BuildContext context)
    {
        Widget titleSection = Container(
            padding: const EdgeInsets.all(10),
            child: Row(
                children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Container(
                                    padding: const EdgeInsets.only(bottom: 8), //define
                                    child: const Text(
                                        'School of Computer Science',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                ),
                                Text(
                                    'Birmingham, UK',
                                    style: TextStyle(
                                        color: Colors.grey[500]
                                    )
                                )
                            ]
                        )
                    )
                ]
            )
        );
        Widget buttonSection = Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                ElevatedButton.icon(
                    onPressed: ()
                    {
                        print("45--------phone click");
                    },
                    icon: const Icon(
                        //each button has an icon and a text label.
                        Icons.phone,
                        size: 24.0
                    ),
                    label: Text('CONTACT')
                ),
                TextButton(
                    onPressed: ()
                    {
                        print("57-------find us click");
                    },
                    style: ButtonStyle(
                        // 设置默认背景颜色（未按下状态）
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states)
                            {
                                if (states.contains(MaterialState.pressed))
                                {
                                    return Colors.grey.shade400; // 按下时的颜色
                                }
                                return Colors.green.shade300; // 默认状态下的颜色
                            }
                        ),
                        // 设置前景色（例如文字颜色）
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        // 设置圆角
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0) // 圆角半径
                            )
                        ),
                        // 可选：设置按下时的覆盖颜色（通常用于涟漪效果）
                        overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states)
                            {
                                if (states.contains(MaterialState.pressed))
                                {
                                    return Colors.black.withOpacity(0.1); // 按下时的覆盖颜色
                                }
                                return Colors.transparent; // 默认状态下的覆盖颜色
                            }
                        )
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text('FIND US'),
                            SizedBox(width: 8),
                            Icon(Icons.near_me, size: 24.0)
                        ]
                    )
                ),
                ElevatedButton.icon(
                    onPressed: ()
                    {
                        print("45--------get INFO");
                    },
                    icon: const Icon(
                        Icons.download,
                        size: 24.0
                    ),
                    label: Text('GET INFO')
                )
            ]
        );
        Widget textSection = const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
                'The University of Birmingham School of Computer Science was ranked 3rd in the 2022 UK REF. '
                'It is research groups specialising in CyberSecurity, Human-Centred Computing,'
                'Artificial Intelligence and Robotics, Computational LifeSciences, '
                'and Computational Theory.',
                softWrap: true
            )
        );

        //测试container
        Widget container = Container(
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(80.0)
            ),
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 12.0),
            constraints: BoxConstraints(
                maxWidth: 20.0, // 最大宽度限制为 20
                minWidth: 20.0 // 最小宽度也设为 20，实现固定宽度
            ),
            height: 100.0,
            child: Text(
                '这是一个带样式的Container',
                style: TextStyle(color: Colors.white, fontSize: 24)
            )
        );

        // 测试container
        Widget container2 = SizedBox(
            width: 20.0, // ✅ 强制固定宽度
            child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(color: Colors.red, width: 2), // 调试用：红色边框
                    borderRadius: BorderRadius.circular(10.0) // ✅ 修正：不能超过 width/2
                ),
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                    '短',
                    style: TextStyle(color: Colors.white, fontSize: 12), // ✅ 减小字体
                    overflow: TextOverflow.ellipsis,
                    softWrap: false
                )
            )
        );

        Widget container3 = Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 200.0,
                    minWidth: 20.0
                ),
                child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(color: Colors.red, width: 2), // 调试用：红色边框
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                        child: Text(
                            '这是一条短文案',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true
                        )
                    )
                )
            )
        );

        final List<InfoCard> cards = [
            InfoCard(
                'School of Computer Science',
                'The University of Birmingham School of Computer Science was ranked 3rd in the 2022 UK REF.',
                1,
                Colors.blue
            ),
            InfoCard(
                'Research Areas',
                'CyberSecurity, Human-Centred Computing, Artificial Intelligence and Robotics.',
                2,
                Colors.green
            ),
            InfoCard(
                'Location',
                'Birmingham, UK',
                1,
                Colors.orange
            ),
            InfoCard(
                'Location3',
                'Birmingham, UK',
                2,
                Colors.orange
            ),
            InfoCard(
                'Location4',
                'Birmingham, UK',
                1,
                Colors.orange
            ),
            InfoCard(
                'Location',
                'Birmingham, UK',
                1,
                Colors.orange
            )

        ];

        return MaterialApp(
            home: Scaffold(
                appBar: AppBar(title: Text('动态 ListView'),
                    backgroundColor: Colors.blue,
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white), // 返回箭头图标
                        onPressed: ()
                        {
                            Navigator.of(context).pop(); // 点击时返回上一页
                        }
                    )
                ),
                body: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index)
                    {
                        final card = cards[index];
                        switch (card.type)
                        {
                            case 1:
                                return InkWell(
                                    onTap: ()
                                    {
                                        print('点击了: ${card.title}');
                                    },
                                    onLongPress: ()
                                    {
                                        // 可选：长按事件
                                        print('长按: ${card.title}');
                                    },

                                    child: Container(
                                        margin: EdgeInsets.all(8.0),
                                        padding: EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                            color: card.backgroundColor.withOpacity(0.1),
                                            border: Border(
                                                left: BorderSide(
                                                    color: card.backgroundColor,
                                                    width: 5
                                                )
                                            ),
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    card.title,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: card.backgroundColor
                                                    )
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                    card.content,
                                                    style: TextStyle(fontSize: 14, color: Colors.black87)
                                                )
                                            ]
                                        )
                                    )
                                );

                            case 2:
                                return InkWell(
                                    onTap: ()
                                    {
                                        print('点击了: ${card.title}');
                                    },
                                    onLongPress: ()
                                    {
                                        // 可选：长按事件
                                        print('长按: ${card.title}');
                                    },

                                    child: Container(
                                        margin: EdgeInsets.all(8.0),
                                        padding: EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                            color: card.backgroundColor.withOpacity(0.1),
                                            border: Border(
                                                left: BorderSide(
                                                    color: card.backgroundColor,
                                                    width: 5
                                                ),
                                                right: BorderSide(
                                                    color: card.backgroundColor,
                                                    width: 5
                                                )
                                            ),
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    card.title,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: card.backgroundColor
                                                    )
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                    card.content,
                                                    style: TextStyle(fontSize: 14, color: Colors.black87)
                                                )
                                            ]
                                        )
                                    )
                                );
                        }

                    }
                )
            )
        );

        // return MaterialApp(
        //     home: Scaffold(
        //         appBar: AppBar(
        //             title: const Text('Welcome to the School of Computer Science')
        //         ),
        //         body: ListView(
        //             children: [
        //                 Image.asset('assets/imgs/seu.jpg',
        //                     width: 150,
        //                     height: 300,
        //                     fit: BoxFit.cover), //make the image as small as possible but to
        //                 titleSection,
        //                 textSection,
        //                 buttonSection,
        //                 container,
        //                 container3
        //
        //             ]
        //         )
        //     )
        // );
    }
}
