import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {},
      ),
      title: const Text(
        'طلبيتك',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: onProfileTap,
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }
}