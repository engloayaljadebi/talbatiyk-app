import 'package:flutter/material.dart';

Color ordersCanvasColor(ColorScheme colors) => colors.surfaceContainer;

class OrderCardSurface extends StatelessWidget {
  const OrderCardSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    final radius = BorderRadius.circular(22);
    final base = isDark ? colors.surfaceContainerHigh : colors.surface;
    final tint = Color.lerp(base, colors.primary, isDark ? 0.12 : 0.055)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.25 : 0.08),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [base, base, tint],
              stops: const [0, 0.35, 1],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
