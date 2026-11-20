import 'cart_share_data.dart';

String buildCartShareText(CartShareData data) {
  final text = StringBuffer('اصناف الطلبية');

  for (final (index, item) in data.items.indexed) {
    text
      ..writeln()
      ..writeln()
      ..write('${index + 1}. ${item.name}')
      ..writeln()
      ..write('الكمية: ${item.quantity}');

    final unit = item.unit;
    if (unit != null && unit.trim().isNotEmpty) {
      text.write(' $unit');
    }

    final note = item.note;
    if (note != null && note.trim().isNotEmpty) {
      text
        ..writeln()
        ..write('ملاحظة: $note');
    }

    final price = item.price;
    if (price != null) {
      text
        ..writeln()
        ..writeln('سعر الوحدة: ${_formatPrice(price.unitPrice)} ر.ي')
        ..write('إجمالي الصنف: ${_formatPrice(price.lineTotal)} ر.ي');
    }
  }

  final totalPrice = data.totalPrice;
  if (totalPrice != null) {
    text
      ..writeln()
      ..writeln()
      ..write('إجمالي السلة: ${_formatPrice(totalPrice)} ر.ي');
  }

  return text.toString();
}

String _formatPrice(double price) {
  return price == price.truncateToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
}
