import 'package:flutter/material.dart';

/// زر إضافة المنتج مع عرض حالته الحالية داخل السلة.
class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    super.key,
    required this.onPressed,
    this.quantity = 0,
    this.isProcessing = false,
  });

  final VoidCallback? onPressed;
  final int quantity;
  final bool isProcessing;

  bool get _isInCart => quantity > 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon: isProcessing
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                _isInCart
                    ? Icons.shopping_cart_rounded
                    : Icons.shopping_cart_outlined,
                size: 18,
              ),
        label: Text(
          isProcessing
              ? 'جاري الإضافة...'
              : _isInCart
              ? 'في السلة ($quantity)'
              : 'إضافة',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isInCart
              ? Colors.green.shade700
              : const Color(0xFFE53935),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
