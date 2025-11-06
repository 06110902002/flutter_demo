/// @author: jiangjunhui
/// @date: 2025/3/7
library;

import 'package:flutter/material.dart';
import 'package:test_flutter/page_frame_work/router/router_observer.dart';

/// 自定义的 RouteAwareState
abstract class RouteAwareState<T extends StatefulWidget> extends State<T>
    with RouteAware
{
    @override
    void didChangeDependencies() 
    {
        super.didChangeDependencies();
        final route = ModalRoute.of(context);
        if (route != null) 
        {
            MyRouteObserver().subscribe(this, route);
        }
    }

    @override
    void dispose() 
    {
        MyRouteObserver().unsubscribe(this);
        super.dispose();
    }

    /// 处理页面可见性变化
    void didChangeVisibility(bool isVisible) 
    {
        if (isVisible) 
        {
            onPageVisible();
        }
        else 
        {
            onPageHidden();
        }
    }

    /// 页面可见时调用
    void onPageVisible();

    /// 页面隐藏时调用
    void onPageHidden();
}
