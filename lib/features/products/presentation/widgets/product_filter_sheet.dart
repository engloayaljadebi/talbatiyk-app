import 'package:flutter/material.dart';

import '../state/products_state.dart';

class ProductFilterResult {
  const ProductFilterResult({
    required this.category,
    required this.brand,
    required this.availability,
    required this.minPrice,
    required this.maxPrice,
  });

  final String category;
  final String brand;
  final ProductAvailabilityFilter availability;
  final double minPrice;
  final double maxPrice;
}

class ProductFilterSheet extends StatefulWidget {
  const ProductFilterSheet({
    super.key,
    required this.categories,
    required this.brands,
    required this.selectedCategory,
    required this.selectedBrand,
    required this.selectedAvailability,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.selectedMinPrice,
    required this.selectedMaxPrice,
  });

  final List<String> categories;
  final List<String> brands;

  final String selectedCategory;
  final String selectedBrand;
  final ProductAvailabilityFilter selectedAvailability;

  final double minimumPrice;
  final double maximumPrice;
  final double? selectedMinPrice;
  final double? selectedMaxPrice;

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late String _category;
  late String _brand;
  late ProductAvailabilityFilter _availability;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();

    _category = widget.selectedCategory;
    _brand = widget.selectedBrand;
    _availability = widget.selectedAvailability;

    final start = widget.selectedMinPrice ?? widget.minimumPrice;
    final end = widget.selectedMaxPrice ?? widget.maximumPrice;

    _priceRange = RangeValues(
      start <= end ? start : widget.minimumPrice,
      start <= end ? end : widget.maximumPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canChangePrice = widget.maximumPrice > widget.minimumPrice;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'فلترة المنتجات',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('كل الفئات')),
                  ...widget.categories.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _brand,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'الشركة',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('كل الشركات')),
                  ...widget.brands.map(
                    (brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _brand = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'حالة التوفر',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _availabilityChip(
                    label: 'الكل',
                    value: ProductAvailabilityFilter.all,
                  ),
                  _availabilityChip(
                    label: 'متوفر',
                    value: ProductAvailabilityFilter.available,
                  ),
                  _availabilityChip(
                    label: 'غير متوفر',
                    value: ProductAvailabilityFilter.unavailable,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'نطاق السعر',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${_formatPrice(_priceRange.start)} ر.ي'),
                  const Spacer(),
                  Text('${_formatPrice(_priceRange.end)} ر.ي'),
                ],
              ),
              if (canChangePrice)
                RangeSlider(
                  values: _priceRange,
                  min: widget.minimumPrice,
                  max: widget.maximumPrice,
                  activeColor: const Color(0xFFE53935),
                  labels: RangeLabels(
                    _formatPrice(_priceRange.start),
                    _formatPrice(_priceRange.end),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _priceRange = value;
                    });
                  },
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('مسح الفلاتر'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _applyFilters,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('عرض النتائج'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _availabilityChip({
    required String label,
    required ProductAvailabilityFilter value,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _availability == value,
      selectedColor: const Color(0xFFFFCDD2),
      onSelected: (_) {
        setState(() {
          _availability = value;
        });
      },
    );
  }

  void _clearFilters() {
    Navigator.pop(
      context,
      ProductFilterResult(
        category: '',
        brand: '',
        availability: ProductAvailabilityFilter.all,
        minPrice: widget.minimumPrice,
        maxPrice: widget.maximumPrice,
      ),
    );
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      ProductFilterResult(
        category: _category,
        brand: _brand,
        availability: _availability,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0);
  }
}
