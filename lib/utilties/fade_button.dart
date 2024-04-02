import 'package:flutter/material.dart';

class FadeButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const FadeButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<FadeButton> createState() => _FadeButtonState();
}

class _FadeButtonState extends State<FadeButton> {
  double opacity = 1.0;
  Duration duration = const Duration(milliseconds: 0);
  void _onTapDown() {
    setState(() {
      duration = const Duration(milliseconds: 0);
      opacity = 0.5;
    });
  }

  void _onTapUp() {
    setState(() {
      duration = const Duration(milliseconds: 150);
      opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapUp,
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        duration: duration,
        opacity: opacity,
        child: widget.child,
      ),
    );
  }
}
