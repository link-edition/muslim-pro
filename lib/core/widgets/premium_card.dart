import 'package:flutter/material.dart';
import 'package:muslim_pro/core/theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool animatePress;
  final LinearGradient? customGradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.animatePress = true,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _PremiumCardPressWrapper(
      onTap: onTap,
      animatePress: animatePress,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: customGradient == null
              ? (isDark ? context.colors.cardBg : Colors.white)
              : null,
          gradient: customGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? context.colors.softGold.withValues(alpha: 0.08)
                : const Color(0xFFD4AF37).withOpacity(0.08),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (!isDark)
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _PremiumCardPressWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animatePress;

  const _PremiumCardPressWrapper({
    required this.child,
    this.onTap,
    required this.animatePress,
  });

  @override
  State<_PremiumCardPressWrapper> createState() => _PremiumCardPressWrapperState();
}

class _PremiumCardPressWrapperState extends State<_PremiumCardPressWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null || !widget.animatePress) {
      return widget.child;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
