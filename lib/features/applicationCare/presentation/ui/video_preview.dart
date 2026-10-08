import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPreview extends StatefulWidget {
  final String videoUrl;
  const VideoPreview({super.key, required this.videoUrl});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (_isDisposed || !mounted) return;
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
        });
      }).catchError((e) {
        log('Video initialization error: $e');
        if (_isDisposed || !mounted) return;
      });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl), // Unique key for visibility tracking
      onVisibilityChanged: (VisibilityInfo info) {
        if (_isDisposed || !mounted) return;
        if (info.visibleFraction > 0.5) {
          // If more than 50% of the video is visible, play
          _controller.play();
        } else {
          // Otherwise, pause the video
          _controller.pause();
        }
      },
      child: Container(
        height: 150,
        width: 140,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _isInitialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_controller),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
