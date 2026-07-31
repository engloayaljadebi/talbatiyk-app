import 'package:flutter/material.dart';

import '../controllers/products_controller.dart';
import '../widgets/filter_button.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_list.dart';
import '../widgets/view_toggle.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage({super.key});

  final ProductsController controller = ProductsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('المنتجات'),

            actions: [
              ViewToggle(
                isGrid: state.isGrid,
                onChanged: controller.changeView,
              ),

              FilterButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: Text('فلترة المنتجات')),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.products.isEmpty
              ? const Center(child: Text('لا توجد منتجات'))
              : state.isGrid
              ? ProductGrid(products: state.products)
              : ProductList(products: state.products),
        );
      },
    );
  }
}
