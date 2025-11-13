import 'package:flutter/material.dart';

import 'app_router_delegate.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => globalRouter.popRoute(),
        ),
      ),
      body: const Center(child: Text('设置页面')),
    );
  }
}