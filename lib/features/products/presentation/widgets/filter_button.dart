import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
  });

  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'فلترة المنتجات',
          onPressed: onPressed,
          icon: const Icon(Icons.filter_list_rounded),
        ),
        if (isActive)
          const PositionedDirectional(
            top: 9,
            start: 9,
            child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFE53935)),
          ),
      ],
    );
  }
}
