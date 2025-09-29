import 'package:flutter/material.dart';

class TabViewRoute1 extends StatefulWidget
{
    @override
    _TabViewRoute1State createState() => _TabViewRoute1State();
}

class _TabViewRoute1State extends State<TabViewRoute1>
    with SingleTickerProviderStateMixin
{
    late TabController _tabController;
    List tabs = ["新闻", "历史", "图片"];

    @override
    void initState() 
    {
        super.initState();
        _tabController = TabController(length: tabs.length, vsync: this);
    }

    @override
    Widget build(BuildContext context) 
    {
        return Scaffold(
            appBar: AppBar(
                title: Text("App Name"),
                bottom: TabBar(
                    controller: _tabController,
                    tabs: tabs.map((e) => Tab(text: e)).toList()
                )
            ),
            body: TabBarView( //构建
                controller: _tabController,
                children: tabs.map((e)
                    {
                        return KeepAliveWrapper(
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(e, textScaleFactor: 5)
                            )
                        );
                    }
                ).toList()
            )
        );
    }

    @override
    void dispose() 
    {
        // 释放资源
        _tabController.dispose();
        super.dispose();
    }
}

class KeepAliveWrapper extends StatefulWidget
{
    const KeepAliveWrapper({
        Key? key,
        this.keepAlive = true,
        required this.child
    }) : super(key: key);
    final bool keepAlive;
    final Widget child;

    @override
    _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin
{
    @override
    Widget build(BuildContext context) 
    {
        super.build(context);
        return widget.child;
    }

    @override
    void didUpdateWidget(covariant KeepAliveWrapper oldWidget) 
    {
        if (oldWidget.keepAlive != widget.keepAlive) 
        {
            // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
            updateKeepAlive();
        }
        super.didUpdateWidget(oldWidget);
    }

    @override
    bool get wantKeepAlive => widget.keepAlive;
}
