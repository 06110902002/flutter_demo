/// Author: Rambo.Liu
/// Date: 2026/1/28 11:05
/// @Copyright by ZYQL Since 2025
/// Description: 混排的滚动列表，要求支持，文字，富文本，图片，视频

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedPage(),
    );
  }
}

// ================= 混排 Feed =================

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  // 在真实的应用中，这些数据通常来自网络请求。
  static final List<Widget> _feedItems = [
    const Padding(padding: EdgeInsets.all(16), child: Text('普通文本 Item')),
    Padding(
      padding: const EdgeInsets.all(16),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(text: '这是一个 '),
            TextSpan(
              text: '富文本',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 26,
              ),
            ),
            TextSpan(text: ' Item'),
          ],
        ),
      ),
    ),
    const Padding(
      padding: EdgeInsets.all(16),
      child: Image(image: NetworkImage('https://picsum.photos/600/300')),
    ),
    const VideoItem(
      url:
          'https://stream7.iqilu.com/10339/upload_transcode/202002/09/20200209105011F0zPoYzHry.mp4',
    ),
    // 添加更多 Item 来演示滚动性能
    const Padding(padding: EdgeInsets.all(16), child: Text('另一个普通文本 Item')),
    const Padding(padding: EdgeInsets.all(16), child: Text('又一个普通文本 Item')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('混排 Video Feed Demo')),
      // 对于长列表，使用 ListView.builder 是性能更好的选择
      body: ListView.builder(
        itemCount: _feedItems.length,
        itemBuilder: (context, index) {
          return _feedItems[index];
        },
      ),
    );
  }
}

// ================= Video Item =================

class VideoItem extends StatefulWidget {
  final String url;

  const VideoItem({super.key, required this.url});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final VideoPlayerController _controller;
  late final AnimationController _controlsAnimController;
  late final Animation<Offset> _controlsOffset;
  late final OverlayPortalController _overlayPortalController;
  bool _showFullscreenControls = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _overlayPortalController = OverlayPortalController();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });

    _controlsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _controlsOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
        .animate(
          CurvedAnimation(
            parent: _controlsAnimController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controlsAnimController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _controlsAnimController.reverse();
    } else {
      _controller.play();
      _controlsAnimController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_controller.value.isInitialized) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => setState(
              () => _showFullscreenControls = !_showFullscreenControls,
            ),
            child: Center(
              child: Hero(
                tag: widget.url,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      AnimatedOpacity(
                        opacity: _showFullscreenControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: _buildFullscreenControls(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Hero(
        tag: widget.url,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: ClipRect(
            child: Stack(
              children: [
                VideoPlayer(_controller),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _togglePlay,
                  ),
                ),
                _buildCenterPlayButton(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SlideTransition(
                    position: _controlsOffset,
                    child: _buildBottomControls(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _buildCenterPlayButton() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (_, value, __) {
        if (value.isPlaying) return const SizedBox.shrink();
        return GestureDetector(
          onTap: _togglePlay,
          child: const Center(
            child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.black54,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: _controller,
        builder: (_, value, __) {
          final pos = value.position;
          final dur = value.duration;

          String fmt(Duration d) {
            final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
            final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
            return '$m:$s';
          }

          return Row(
            children: [
              Text(fmt(pos), style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              Expanded(
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(fmt(dur), style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _enterFullscreen,
                child: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFullscreenControls() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
          ),
          Expanded(
            child: VideoProgressIndicator(_controller, allowScrubbing: true),
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
            onPressed: _exitFullscreen,
          ),
        ],
      ),
    );
  }

  void _enterFullscreen() {
    setState(() {
      _showFullscreenControls = true;
      _overlayPortalController.show();
    });
  }

  void _exitFullscreen() {
    // 恢复列表内控制条的状态
    if (_controller.value.isPlaying) {
      _controlsAnimController.forward();
    } else {
      _controlsAnimController.reverse();
    }
    setState(() {
      _overlayPortalController.hide();
    });
  }
}
