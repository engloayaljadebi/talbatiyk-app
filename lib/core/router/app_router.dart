import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text("Splash"))),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text("Home"))),
    ),
    GoRoute(
      path: RouteNames.products,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text("Products"))),
    ),
  ],
);
