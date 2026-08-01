import 'package:flutter/material.dart';

import '../../domain/entities/products_entity.dart';

import 'add_to_cart_button.dart';
import 'product_image.dart';
import 'product_price.dart';
import 'quantity_selector.dart';


class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });


  final ProductEntity product;

  final int quantity;

  final VoidCallback onAdd;

  final VoidCallback onRemove;


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),


      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children: [


          SizedBox(
            height: 120,

            width: double.infinity,

            child: ProductImage(
              imageUrl: product.imageUrl,
            ),
          ),



          Padding(
            padding: const EdgeInsets.all(10),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              mainAxisSize:
              MainAxisSize.min,


              children: [


                Text(
                  product.name,

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),



                const SizedBox(
                  height: 4,
                ),



                Text(
                  product.brand,

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),



                const SizedBox(
                  height: 6,
                ),



                ProductPrice(
                  price: product.price,
                ),



                const SizedBox(
                  height: 8,
                ),



                SizedBox(
                  height: 36,

                  child: quantity == 0

                      ? AddToCartButton(
                    onPressed: onAdd,
                  )

                      : QuantitySelector(
                    quantity: quantity,
                    onAdd: onAdd,
                    onRemove: onRemove,
                  ),
                ),


              ],
            ),
          ),


        ],
      ),
    );
  }
}