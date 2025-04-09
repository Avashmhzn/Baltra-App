import 'package:flutter/material.dart';

class BaltraSkeletonizerWidget extends StatefulWidget {
  final bool isLoading;

  const BaltraSkeletonizerWidget({super.key, this.isLoading = true});

  @override
  State<BaltraSkeletonizerWidget> createState() => _BaltraSkeletonizerWidgetState();
}

class _BaltraSkeletonizerWidgetState extends State<BaltraSkeletonizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void didUpdateWidget(BaltraSkeletonizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 200,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The text is always there but overlaid with skeleton when loading
              const Text(
                'Baltra',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black12, // Very light color as skeleton base
                  letterSpacing: 2.0,
                ),
              ),

              // Skeleton overlay with red shimmer
              if (widget.isLoading)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: const [
                            Colors.black12,
                            Colors.red, // Changed to red for the shimmer effect
                            Colors.black12,
                          ],
                          stops: [0.0, (_animation.value).clamp(0.0, 1.0), 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: const Text(
                        'Baltra',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White so the shader shows through
                          letterSpacing: 2.0,
                        ),
                      ),
                    );
                  },
                ),

              // Show the actual text when not loading
              if (!widget.isLoading)
                const Text(
                  'Baltra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}