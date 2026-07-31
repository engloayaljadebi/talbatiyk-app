import 'package:flutter/material.dart';

class ViewToggle extends StatelessWidget {
  const ViewToggle({super.key, required this.isGrid, required this.onChanged});

  final bool isGrid;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onChanged,
      icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
    );
  }
}
