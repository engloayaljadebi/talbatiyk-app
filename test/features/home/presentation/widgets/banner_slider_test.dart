import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/home/presentation/widgets/banner_slider.dart';

void main() {
  testWidgets('BannerSlider يظل مرتبطًا بCTA المنتجات الحقيقي', (tester) async {
    var openedProducts = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerSlider(
            onExploreProducts: () {
              openedProducts = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('اكتشف المنتجات المتاحة لمتجرك'), findsOneWidget);

    expect(find.text('استكشف المنتجات'), findsOneWidget);

    await tester.tap(find.text('استكشف المنتجات'));

    await tester.pump();

    expect(openedProducts, isTrue);
  });
}
