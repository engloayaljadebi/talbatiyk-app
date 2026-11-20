import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'cart_share_data.dart';

Future<Uint8List> buildCartSharePdf(CartShareData data) async {
  final font = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Amiri-Regular.ttf'),
  );
  final document = pw.Document();
  final totalPrice = data.totalPrice;
  final totalQuantity = data.items.fold<int>(
    0,
    (total, item) => total + item.quantity,
  );
  final date = DateTime.now().toIso8601String().split('T').first;

  // Table cells are supplied in physical left-to-right order.
  // Each Arabic cell lays out its text right-to-left.
  final headers = [
    if (totalPrice != null) ...['إجمالي الصنف', 'سعر الوحدة'],
    'الملاحظة',
    'الكمية',
    'اسم الصنف',
    'رقم',
  ];
  final widths = [
    if (totalPrice != null) ...[1.25, 1.15],
    2.3,
    1.15,
    2.5,
    0.55,
  ];

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      textDirection: pw.TextDirection.ltr,
      theme: pw.ThemeData.withFont(base: font),
      maxPages: 100,
      footer: (context) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 10),
        alignment: pw.Alignment.center,
        child: _text('صفحة ${context.pageNumber} من ${context.pagesCount}'),
      ),
      build: (_) => [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _text('طلب عرض سعر', size: 22),
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _text('تاريخ إعداد المستند: $date'),
        ),
        pw.SizedBox(height: 14),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            for (final (index, width) in widths.indexed)
              index: pw.FlexColumnWidth(width),
          },
          children: [
            pw.TableRow(
              repeat: true,
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [for (final header in headers) _cell(header)],
            ),
            for (final (index, item) in data.items.indexed)
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: index.isEven ? PdfColors.white : PdfColors.grey100,
                ),
                children: [
                  if (totalPrice != null) ...[
                    _cell(_money(item.price!.lineTotal)),
                    _cell(_money(item.price!.unitPrice)),
                  ],
                  _cell(item.note ?? '—', align: pw.TextAlign.right),
                  _cell(
                    item.unit?.trim().isNotEmpty ?? false
                        ? '${item.quantity} ${item.unit}'
                        : '${item.quantity}',
                  ),
                  _cell(item.name, align: pw.TextAlign.right),
                  _cell('${index + 1}'),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _text('عدد الأصناف: ${data.items.length}'),
              _text('إجمالي الكمية: $totalQuantity'),
              if (totalPrice != null)
                _text('الإجمالي المالي: ${_money(totalPrice)}'),
            ],
          ),
        ),
      ],
    ),
  );

  return document.save();
}

pw.Widget _cell(String value, {pw.TextAlign align = pw.TextAlign.center}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    child: _text(value, align: align),
  );
}

pw.Widget _text(
  String value, {
  double size = 11,
  pw.TextAlign align = pw.TextAlign.right,
}) {
  return pw.Text(
    value,
    textDirection: pw.TextDirection.rtl,
    textAlign: align,
    style: pw.TextStyle(fontSize: size),
  );
}

String _money(double value) => '${value.toStringAsFixed(2)} ر.ي';
