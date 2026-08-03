import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

class CartItemEntity {
  const CartItemEntity({required this.product, required this.quantity});

  final ProductEntity product;
  final int quantity;

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({ProductEntity? product, int? quantity}) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
