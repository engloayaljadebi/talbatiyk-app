import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:talbatiyk/app.dart';
import 'package:talbatiyk/core/router/app_router.dart';
import 'package:talbatiyk/features/users/presentation/pages/users_page.dart';
import 'package:talbatiyk/features/voice/presentation/pages/voice_page.dart';
import 'package:talbatiyk/features/wallet/presentation/pages/wallet_page.dart';

void main() {
  testWidgets(
    'TalbatiykApp exposes Arabic locale and Arabic material localization',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              final locale = Localizations.localeOf(context);
              final textDirection = Directionality.of(context);

              return Scaffold(
                body: Text(
                  '${locale.languageCode}|${textDirection.name}',
                  textDirection: TextDirection.ltr,
                ),
              );
            },
          ),
        ],
      );

      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appRouterProvider.overrideWithValue(router)],
          child: const TalbatiykApp(),
        ),
      );

      await tester.pump();

      expect(find.text('ar|rtl'), findsOneWidget);
    },
  );

  testWidgets('placeholder feature pages expose Arabic labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            Expanded(child: UsersPage()),
            Expanded(child: VoicePage()),
            Expanded(child: WalletPage()),
          ],
        ),
      ),
    );

    expect(find.text('المستخدمون'), findsOneWidget);
    expect(find.text('الصوت'), findsOneWidget);
    expect(find.text('المحفظة'), findsOneWidget);

    expect(find.text('Users Page'), findsNothing);
    expect(find.text('Voice Page'), findsNothing);
    expect(find.text('Wallet Page'), findsNothing);
  });
}
