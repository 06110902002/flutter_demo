import 'package:flutter/material.dart';

class GlobalModal
{
    static OverlayEntry? _currentEntry;

    /// 显示全局模态窗口
    static void show({
        required BuildContext context, // 窗口上下文
        required Widget child, // 窗口内容
        Size? size, // 窗口尺寸
        Offset? position, // 窗口左上角坐标
        Color barrierColor = Colors.black54, // 背景色
        bool barrierDismissible = true, // 点击背景是否关闭
        bool draggable = false, // 是否允许拖拽
        Duration animationDuration = const Duration(milliseconds: 300),
        Curve animationCurve = Curves.easeOutBack
    }) 
    {
        // 如果已有窗口显示，先关闭
        if (_currentEntry != null) 
        {
            _currentEntry?.remove();
            _currentEntry = null;
        }

        final overlayState = Overlay.of(context);
        final mediaQuery = MediaQuery.of(context);

        // 默认尺寸为屏幕的80%
        final modalSize = size ?? Size(
                mediaQuery.size.width * 0.8,
                mediaQuery.size.height * 0.8
            );

        // 默认居中显示
        final modalPosition = position ?? Offset(
                (mediaQuery.size.width - modalSize.width) / 2,
                (mediaQuery.size.height - modalSize.height) / 2
            );

        Offset currentPosition = modalPosition; // 模态窗口的当前坐标

        _currentEntry = OverlayEntry(
            builder: (context)
            {
                return Stack(
                    children: [
                        // 半透明背景层（遮罩层）
                        Positioned.fill(
                            child: GestureDetector(
                                onTap: barrierDismissible ? () => dismiss() : null, // 控制点击遮罩层是否销毁该模态窗口
                                child: Container(color: barrierColor) // 背景色
                            )
                        ),

                        // 模态窗口内容
                        Positioned(
                            left: currentPosition.dx,
                            top: currentPosition.dy,
                            child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                    width: modalSize.width, // 尺寸
                                    height: modalSize.height,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: Column(
                                        children: [
                                            // 拖拽手柄区域
                                            if (draggable)
                                            GestureDetector(
                                                onPanUpdate: (details)
                                                {
                                                    currentPosition += details.delta;
                                                    _currentEntry?.markNeedsBuild();
                                                },
                                                child: Container(
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius: const BorderRadius.vertical(
                                                            top: Radius.circular(12)
                                                        )
                                                    ),
                                                    child: const Center(
                                                        child: Icon(
                                                            Icons.drag_handle,
                                                            color: Colors.grey
                                                        )
                                                    )
                                                )
                                            ),

                                            // 关闭按钮
                                            const Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                    icon: Icon(Icons.close),
                                                    onPressed: dismiss
                                                )
                                            ),

                                            // 内容区域
                                            Expanded(
                                                child: Padding(
                                                    padding: const EdgeInsets.all(16),
                                                    child: child // 内容窗口
                                                )
                                            )
                                        ]
                                    )
                                )
                            )
                        )
                        // //   ),
                    ]
                );
            }
        );

        overlayState.insert(_currentEntry!);
    }

    /// 关闭当前模态窗口
    static void dismiss() 
    {
        if (_currentEntry != null) 
        {
            _currentEntry?.remove();
            _currentEntry = null;
        }
    }
}
