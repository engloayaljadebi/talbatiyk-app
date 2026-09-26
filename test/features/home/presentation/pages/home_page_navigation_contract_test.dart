import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/home/presentation/pages/home_page.dart';

void main() {
  test(
    'HomePage exposes products cart and notifications navigation callbacks',
    () {
      var productsOpened = false;
      var cartOpened = false;
      var notificationsOpened = false;

      final page = HomePage(
        onViewProducts: () {
          productsOpened = true;
        },
        onOpenCart: () {
          cartOpened = true;
        },
        onOpenNotifications: () {
          notificationsOpened = true;
        },
      );

      page.onViewProducts();
      page.onOpenCart();
      page.onOpenNotifications();

      expect(productsOpened, isTrue);
      expect(cartOpened, isTrue);
      expect(notificationsOpened, isTrue);
    },
  );
}
