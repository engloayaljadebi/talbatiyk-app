import '../../models/product_model.dart';

class ProductsLocalDataSource {
  List<ProductModel> getProducts() {
    return const [
      ProductModel(
        id: '1',
        name: 'شاحن سامسونج وكالة',
        price: 4500,
        imageUrl: '',
        category: 'شواحن',
        brand: 'Samsung',
        isAvailable: true,
        description: 'ضمان سنة',
        colors: ['أبيض', 'أسود'],
      ),
      ProductModel(
        id: '2',
        name: 'سماعة AirPods',
        price: 15000,
        imageUrl: '',
        category: 'سماعات',
        brand: 'Apple',
        isAvailable: true,
        description: 'نسخة أصلية',
        colors: ['أبيض'],
      ),
      ProductModel(
        id: '3',
        name: 'رأس شاحن Type-C',
        price: 2500,
        imageUrl: '',
        category: 'شواحن',
        brand: 'Anker',
        isAvailable: false,
      ),
    ];
  }
}
