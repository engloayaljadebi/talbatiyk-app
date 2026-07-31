import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.onFilterPressed,
  });

  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج أو شركة...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: onFilterPressed,
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }
}