import 'package:flutter/material.dart';

class SnapAppBar extends StatelessWidget {
  const SnapAppBar({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    var pageViewChildren = <SliverToBoxAdapter>[];
    // Generate 6 ContentPage widgets for the PageView
    for (int i = 0; i < 6; ++i)
    {
      pageViewChildren.add(SliverToBoxAdapter(child: Text("${i}")));
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true,
                snap: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    "assets/imgs/seu.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                forceElevated: innerBoxIsScrolled,
              ),
            ),
          ];
        },
        body: Builder(builder: (BuildContext context) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              ...pageViewChildren.toList()
              // SliverToBoxAdapter(child: Text("1")),
              // SliverToBoxAdapter(child: Text("2")),
              // SliverToBoxAdapter(child: Text("3")),
              // SliverToBoxAdapter(child: Text("4")),
              // SliverToBoxAdapter(child: Text("5")),
              // SliverToBoxAdapter(child: Text("6")),
              // SliverToBoxAdapter(child: Text("7")),
              // SliverToBoxAdapter(child: Text("8")),
            ],
          );
        }),
      ),
    );
  }
}