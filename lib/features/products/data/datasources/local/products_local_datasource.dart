import '../../models/products_model.dart';

class ProductsLocalDataSource {
  Future<List<ProductModel>> getProducts() async {
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
        rating: 4.8,
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
        rating: 4.7,
      ),
      ProductModel(
        id: '3',
        name: 'رأس شاحن Type-C',
        price: 2500,
        imageUrl: '',
        category: 'شواحن',
        brand: 'Anker',
        isAvailable: false,
        rating: 4.2,
      ),
    ];
  }
}
