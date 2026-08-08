// ignore_for_file: avoid_print

import 'feature_generator.dart';

class ProjectGenerator {
  static final features = [
    'splash',
    'onboarding',
    'auth',
    'home',
    'profile',
    'users',
    'products',
    'categories',
    'cart',
    'orders',
    'checkout',
    'payment',
    'wallet',
    'notifications',
    'chat',
    'search',
    'favorites',
    'settings',
    'reports',
    'dashboard',
    'scanner',
    'camera',
    'maps',
    'ai',
    'voice',
    'sync',
    'offline',
    'backup',
    'admin',
  ];

  static void generate() {
    print("""
================================
🚀 Talbytk Enterprise Generator
================================
""");

    for (final feature in features) {
      FeatureGenerator.createFeature(feature, "riverpod");
    }

    print("""
================================
✅ Enterprise Architecture Created
================================
""");
  }
}
