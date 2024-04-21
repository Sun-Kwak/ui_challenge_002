
import 'package:flutter/material.dart';

/// A widget to show a "3D" pushable button
class PushableButton extends StatefulWidget {
  const PushableButton({
    Key? key,
    this.child,
    required this.hslColor,
    required this.height,
    this.elevation = 8.0,
    this.shadow,
    this.onPressed,
  })  : assert(height > 0),
        super(key: key);

  /// Child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// Height of the top layer
  final double height;

  /// Elevation or "gap" between the top and bottom layer
  final double elevation;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;

  /// Button pressed callback
  final VoidCallback? onPressed;

  @override
  State<PushableButton> createState() => _PushableButtonState();
}

class _PushableButtonState extends State<PushableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(_) {
    _controller.forward(from: 0);
  }

  void _handleTapUp(_) {
    _controller.reverse(from: 1);
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    _controller.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    final top = _animation.value * widget.elevation;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: _buildButtonStack(top),
    );
  }

  Widget _buildButtonStack(double top) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SizedBox(
          height: widget.height + widget.elevation,
          width: constraint.maxWidth,
          child: Stack(
            children: [
              _buildBottomLayer(),
              _buildTopLayer(top, constraint),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomLayer() {
    return Positioned.fill(
      top: widget.elevation,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.hslColor
              .withLightness((widget.hslColor.lightness - 0.15).clamp(0.0, 1.0))
              .toColor(),
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow: widget.shadow != null ? [widget.shadow!] : null,
        ),
      ),
    );
  }

  Widget _buildTopLayer(double top, BoxConstraints constraint) {
    return Positioned(
      top: top,
      child: Container(
        height: widget.height,
        width: constraint.maxWidth,
        decoration: BoxDecoration(
          color: widget.hslColor.toColor(),
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

