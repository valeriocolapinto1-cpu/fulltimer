import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final bool active;

  const GlassButton({super.key, required this.child, this.onTap,
      this.borderRadius = 16, this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      this.active = false});

  @override State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down() { setState(() => _pressed = true); _ctrl.forward(); HapticFeedback.selectionClick(); }
  void _up()   { setState(() => _pressed = false); _ctrl.reverse(); widget.onTap?.call(); }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final dark = th.brightness == Brightness.dark;
    final isActive = _pressed || widget.active;

    return GestureDetector(
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: () { setState(() => _pressed = false); _ctrl.reverse(); },
      child: ScaleTransition(scale: _scale,
        child: AnimatedContainer(duration: const Duration(milliseconds: 110),
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: isActive
                ? (dark ? Colors.white.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.10))
                : (dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
            border: Border.all(
              color: isActive
                  ? (dark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.18))
                  : (dark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08)),
            ),
            boxShadow: isActive ? [] : [BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.25 : 0.06),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: widget.child)),
    );
  }
}
