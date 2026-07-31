import 'package:flutter/material.dart';

import 'features/products/presentation/pages/products_page.dart';

void main() {
  runApp(const TalbatiykApp());
}

class TalbatiykApp extends StatelessWidget {
  const TalbatiykApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'طلبيتك',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Cairo',
      ),

      home: ProductsPage(),
    );
  }
}
