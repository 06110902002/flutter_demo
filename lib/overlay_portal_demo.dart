import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    title: 'OverlayPortal 组件库',
    home: OverlayExamplesHome(),
    debugShowCheckedModeBanner: false,
  ));
}

class OverlayExamplesHome extends StatelessWidget {
  const OverlayExamplesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OverlayPortal 示例集')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            SectionTitle(title: '1. 下拉菜单 (Dropdown Menu)'),
            DropdownMenuExample(),
            SizedBox(height: 30),

            SectionTitle(title: '2. 工具提示 (Tooltip)'),
            TooltipExample(), // 已修复此组件的报错
            SizedBox(height: 30),

            SectionTitle(title: '3. 弹窗提示 (Toast)'),
            ToastExample(),
            SizedBox(height: 30),

            SectionTitle(title: '4. 上下文菜单 (Context Menu)'),
            ContextMenuExample(),
            SizedBox(height: 30),

            SectionTitle(title: '5. 加载指示器 (Loading)'),
            LoadingIndicatorExample(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// 1. 下拉菜单 (Dropdown Menu) - 代码不变
class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> with SingleTickerProviderStateMixin {
  late final OverlayPortalController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  String? _selectedItem;

  final List<String> _items = ['选项 1', '选项 2', '选项 3', '选项 4', '选项 5'];

  @override
  void initState() {
    super.initState();
    _controller = OverlayPortalController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_controller.isShowing) {
      _animationController.reverse().then((_) => _controller.hide());
    } else {
      _controller.show();
      _animationController.forward();
    }
  }

  void _selectItem(String item) {
    setState(() => _selectedItem = item);
    _toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Positioned(
            top: 50, // 位于触发按钮下方
            left: 0,
            right: 0,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _items.map((item) {
                  final isSelected = _selectedItem == item;
                  return ListTile(
                    title: Text(item),
                    onTap: () => _selectItem(item),
                    leading: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                    hoverColor: Colors.grey[100],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          icon: Icon(_controller.isShowing ? Icons.arrow_circle_up : Icons.arrow_circle_down),
          label: Text(_selectedItem ?? '选择一个选项'),
          onPressed: _toggleMenu,
        ),
      ),
    );
  }
}

// 2. 工具提示 (Tooltip) - 已修复报错
class TooltipExample extends StatefulWidget {
  const TooltipExample({super.key});

  @override
  State<TooltipExample> createState() => _TooltipExampleState();
}

class _TooltipExampleState extends State<TooltipExample> with SingleTickerProviderStateMixin {
  late final OverlayPortalController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = OverlayPortalController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTooltip() {
    if (_controller.isShowing) {
      _animationController.reverse().then((_) => _controller.hide());
    } else {
      _controller.show();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 修复：使用正确的嵌套结构，将 IconButton 作为 MouseRegion 的子组件
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Positioned(
            bottom: 50, // 位于图标上方
            left: 0,
            child: Material(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  '这是一个自定义工具提示，可以显示详细信息',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        );
      },
      // 修复：正确的手势处理结构
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.help, // 鼠标悬停时显示帮助光标
          child: GestureDetector(
            onTap: _toggleTooltip,
            child: const Icon(
              Icons.info,
              size: 28,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

// 3. 弹窗提示 (Toast-like messages) - 代码不变
// 3. 弹窗提示 (Toast-like messages) - 确保位置正确
// 3. 弹窗提示 (Toast-like messages) - 基于屏幕的绝对定位
class ToastExample extends StatefulWidget {
  const ToastExample({super.key});

  @override
  State<ToastExample> createState() => _ToastExampleState();
}

class _ToastExampleState extends State<ToastExample> with SingleTickerProviderStateMixin {
  late final OverlayPortalController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // 距离屏幕底部的距离
  final double _bottomDistance = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = OverlayPortalController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // 动画从屏幕外下方滑入
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // 从屏幕下方外部开始
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showToast() {
    if (!_controller.isShowing) {
      _controller.show();
      _animationController.forward();

      // 3秒后自动隐藏
      Future.delayed(const Duration(seconds: 3), () {
        if (_controller.isShowing) {
          _animationController.reverse().then((_) => _controller.hide());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        // 获取屏幕尺寸
        final screenSize = MediaQuery.of(context).size;

        return Positioned(
          // 关键：使用屏幕尺寸计算绝对位置
          top: screenSize.height - _bottomDistance - 50, // 50是Toast自身高度的近似值
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Material(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      '操作成功！',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Center(
        child: ElevatedButton(
          onPressed: _showToast,
          child: const Text('显示提示消息'),
        ),
      ),
    );
  }
}



// 4. 上下文菜单 (Context Menu) - 代码不变
class ContextMenuExample extends StatefulWidget {
  const ContextMenuExample({super.key});

  @override
  State<ContextMenuExample> createState() => _ContextMenuExampleState();
}

class _ContextMenuExampleState extends State<ContextMenuExample> with SingleTickerProviderStateMixin {
  late final OverlayPortalController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  Offset? _menuPosition;

  @override
  void initState() {
    super.initState();
    _controller = OverlayPortalController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showContextMenu(BuildContext context, Offset position) {
    setState(() => _menuPosition = position);
    _controller.show();
    _animationController.forward();
  }

  void _hideContextMenu() {
    _animationController.reverse().then((_) => _controller.hide());
  }

  void _handleMenuAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('选择了: $action')),
    );
    _hideContextMenu();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Positioned(
            left: _menuPosition?.dx ?? 0,
            top: _menuPosition?.dy ?? 0,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContextMenuItem('复制', Icons.copy, () => _handleMenuAction('复制')),
                  _buildContextMenuItem('剪切', Icons.cut, () => _handleMenuAction('剪切')),
                  _buildContextMenuItem('粘贴', Icons.paste, () => _handleMenuAction('粘贴')),
                  const Divider(height: 1),
                  _buildContextMenuItem('分享', Icons.share, () => _handleMenuAction('分享')),
                ],
              ),
            ),
          ),
        );
      },
      child: Center(
        child: GestureDetector(
          onLongPressStart: (details) {
            _showContextMenu(context, details.globalPosition);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('长按此处显示上下文菜单'),
          ),
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}

// 5. 加载指示器 (Loading indicators) - 代码不变
class LoadingIndicatorExample extends StatefulWidget {
  const LoadingIndicatorExample({super.key});

  @override
  State<LoadingIndicatorExample> createState() => _LoadingIndicatorExampleState();
}

class _LoadingIndicatorExampleState extends State<LoadingIndicatorExample> with SingleTickerProviderStateMixin {
  late final OverlayPortalController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = OverlayPortalController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLoading() {
    if (_controller.isShowing) {
      _animationController.reverse().then((_) => _controller.hide());
    } else {
      _controller.show();
      _animationController.forward();

      // 模拟加载过程，3秒后自动关闭
      Future.delayed(const Duration(seconds: 3), () {
        if (_controller.isShowing) {
          _animationController.reverse().then((_) => _controller.hide());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black54,
            child: const Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('加载中...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Center(
        child: ElevatedButton(
          onPressed: _toggleLoading,
          child: Text(_controller.isShowing ? '取消加载' : '开始加载'),
        ),
      ),
    );
  }
}
