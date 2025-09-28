import 'package:flutter/material.dart';

import '../general_services/backend_services/api_service/dio_api_service/shared.dart';

class SwipeIndicator extends StatefulWidget {
  final bool isRtl;
  final double size;
  final Duration duration;
  final Duration showFor; // المدة اللي يظهر فيها

  const SwipeIndicator({
    Key? key,
    this.isRtl = false,
    this.size = 40,
    this.duration = const Duration(milliseconds: 1200),
    this.showFor = const Duration(seconds: 10), // الافتراضي 10 ثواني
  }) : super(key: key);

  @override
  State<SwipeIndicator> createState() => _SwipeIndicatorState();
}

class _SwipeIndicatorState extends State<SwipeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _position;
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    // بعد showFor يخفي الانيميشن
    Future.delayed(widget.showFor, () {
      if (mounted) {
        setState(() => _visible = false);
        _controller.stop();
        CacheHelper.setString(key: "show", value: "show");

      }
    });

    _controller =
    AnimationController(vsync: this, duration: widget.duration)..repeat();

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _position = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 20.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 20.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink(); // يختفي تمامًا

    final arrowIcon = widget.isRtl
        ? Icons.arrow_back_ios_new
        : Icons.arrow_forward_ios;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(widget.isRtl ? -_position.value : _position.value, 0),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                arrowIcon,
                size: widget.size * 0.5,
                color: Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }
}

