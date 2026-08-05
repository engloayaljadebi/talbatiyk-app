import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/product_image_storage.dart';
import '../../domain/entities/products_entity.dart';
import '../providers/products_provider.dart';

/// شاشة واحدة تُستخدم لإضافة منتج جديد أو تعديل منتج موجود.
class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({
    super.key,
    this.product,

    // قيم مؤقتة حتى نربط تسجيل الدخول وحساب المورد.
    this.supplierId = 'local-supplier',
    this.supplierName = 'المورد الحالي',
  });

  /// إذا كانت القيمة null فالصفحة في وضع الإضافة.
  /// وإذا احتوت على منتج فالصفحة في وضع التعديل.
  final ProductEntity? product;

  final String supplierId;
  final String supplierName;

  /// يحدد هل الصفحة تعدّل منتجًا موجودًا.
  bool get isEditing => product != null;

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();

  /// الخدمة المسؤولة عن اختيار الصورة وحفظها داخل الجهاز.
  final _imageStorage = ProductImageStorage();

  String? _selectedImagePath;

  /// يحتفظ برابط الصورة السحابية القديمة عند تعديل المنتج.
  String _remoteImageUrl = '';

  bool _isAvailable = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    // في وضع الإضافة تبقى الحقول فارغة بالقيم الافتراضية.
    if (product == null) {
      return;
    }

    // في وضع التعديل نملأ الحقول تلقائيًا ببيانات المنتج الحالية.
    _nameController.text = product.name;
    _categoryController.text = product.category;
    _brandController.text = product.brand;
    _priceController.text = product.price.toString();
    _quantityController.text = product.quantity.toString();
    _descriptionController.text = product.description;
    _selectedImagePath = product.localImagePath;
    _remoteImageUrl = product.imageUrl;
    _isAvailable = product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// يفتح خيارات اختيار الصورة من المعرض أو الكاميرا.
  Future<void> _openImageOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('اختيار صورة من المعرض'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _pickImage(fromCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('التقاط صورة بالكاميرا'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _pickImage(fromCamera: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// يختار الصورة ويحفظ مسار النسخة الدائمة داخل حالة الصفحة.
  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      final imagePath = fromCamera
          ? await _imageStorage.takePhoto()
          : await _imageStorage.pickFromGallery();

      if (!mounted || imagePath == null) {
        return;
      }

      setState(() {
        _selectedImagePath = imagePath;

        // الصورة المحلية الجديدة ستحل محل رابط الصورة القديمة بعد المزامنة.
        _remoteImageUrl = '';
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر اختيار الصورة، حاول مرة أخرى.')),
      );
    }
  }

  /// يتحقق من الحقول ثم ينشئ المنتج أو يحفظ تعديلاته محليًا.
  Future<void> _saveProduct() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving) {
      return;
    }

    final price = double.parse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    final quantity = int.parse(_quantityController.text.trim());
    final now = DateTime.now();
    final existingProduct = widget.product;

    final product = ProductEntity(
      // عند التعديل نحافظ على المعرف، وعند الإضافة ننشئ UUID جديدًا.
      id: existingProduct?.id ?? const Uuid().v4(),

      // نحافظ على صاحب المنتج الأصلي عند التعديل.
      supplierId: existingProduct?.supplierId ?? widget.supplierId,
      supplierName: existingProduct?.supplierName ?? widget.supplierName,
      name: _nameController.text.trim(),
      price: price,

      // نبقي الصورة الحالية ما لم يختر المورد صورة أخرى أو يحذفها.
      imageUrl: _remoteImageUrl,
      localImagePath: _selectedImagePath,
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim(),
      isAvailable: _isAvailable,
      description: _descriptionController.text.trim(),
      quantity: quantity,

      // نحافظ على الحقول التي لا يعدلها النموذج الحالي.
      colors: existingProduct?.colors ?? const [],
      discount: existingProduct?.discount ?? 0,
      rating: existingProduct?.rating ?? 0,

      // المصدر المحلي يحدد pendingCreate أو pendingUpdate تلقائيًا.
      syncStatus:
          existingProduct?.syncStatus ?? ProductSyncStatus.pendingCreate,
      syncError: null,
      createdAt: existingProduct?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(productsProvider);

      // نستخدم الإنشاء للمنتج الجديد والتعديل للمنتج الموجود.
      final savedProduct = widget.isEditing
          ? await controller.updateProduct(product)
          : await controller.createProduct(product);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      final message = widget.isEditing
          ? 'تم حفظ تعديلات المنتج وستُزامن عند توفر الإنترنت.'
          : 'تم حفظ المنتج وسيُرفع عند توفر الإنترنت.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // نعيد النسخة المحفوظة إلى الصفحة السابقة.
      Navigator.of(context).pop(savedProduct);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      final action = widget.isEditing ? 'تعديل' : 'حفظ';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر $action المنتج: $error')));
    }
  }

  /// يتحقق من أن الحقل النصي غير فارغ.
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    return null;
  }

  /// يتحقق من صحة السعر.
  String? _priceValidator(String? value) {
    final normalizedValue = value?.trim().replaceAll(',', '.') ?? '';
    final price = double.tryParse(normalizedValue);

    if (price == null || price <= 0) {
      return 'أدخل سعرًا صحيحًا أكبر من صفر';
    }

    return null;
  }

  /// يتحقق من أن الكمية رقم صحيح وليست سالبة.
  String? _quantityValidator(String? value) {
    final quantity = int.tryParse(value?.trim() ?? '');

    if (quantity == null || quantity < 0) {
      return 'أدخل كمية صحيحة';
    }

    return null;
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// يعرض الصورة المحلية أو السحابية الحالية للمنتج.
  Widget _buildImagePreview() {
    final localPath = _selectedImagePath;
    final remoteUrl = _remoteImageUrl.trim();

    if (localPath == null && remoteUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (localPath != null)
          Image.file(
            File(localPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          )
        else
          Image.network(
            remoteUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton.filled(
            tooltip: 'حذف الصورة',
            onPressed: () {
              setState(() {
                // نحذف اختيار الصورة المحلية ورابط الصورة السحابية.
                _selectedImagePath = null;
                _remoteImageUrl = '';
              });
            },
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  /// يظهر عندما لا توجد صورة للمنتج.
  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 54, color: Colors.grey),
        SizedBox(height: 10),
        Text('اضغط لإضافة صورة المنتج'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text(widget.isEditing ? 'تعديل المنتج' : 'إضافة منتج'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // يعرض اسم المورد صاحب المنتج.
            Card(
              elevation: 0,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.storefront_outlined),
                ),
                title: const Text('صاحب المنتج'),
                subtitle: Text(
                  widget.product?.supplierName ?? widget.supplierName,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // معاينة الصورة المحلية أو السحابية قبل الحفظ.
            GestureDetector(
              onTap: _openImageOptions,
              child: Container(
                height: 210,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              validator: _requiredValidator,
              decoration: _inputDecoration(
                label: 'اسم المنتج',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              validator: _requiredValidator,
              decoration: _inputDecoration(
                label: 'الفئة',
                icon: Icons.category_outlined,
                hint: 'مثال: شواحن',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandController,
              decoration: _inputDecoration(
                label: 'الشركة أو العلامة التجارية',
                icon: Icons.business_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              validator: _priceValidator,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _inputDecoration(
                label: 'السعر',
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              validator: _quantityValidator,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                label: 'الكمية المتوفرة',
                icon: Icons.inventory_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                label: 'وصف المنتج',
                icon: Icons.description_outlined,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              title: const Text('المنتج متوفر حاليًا'),
              subtitle: const Text('يمكن تعديل حالة التوفر لاحقًا'),
              secondary: const Icon(Icons.check_circle_outline),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveProduct,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    widget.isEditing
                        ? Icons.edit_outlined
                        : Icons.save_outlined,
                  ),
            label: Text(
              _isSaving
                  ? 'جارٍ الحفظ...'
                  : widget.isEditing
                  ? 'حفظ التعديلات'
                  : 'حفظ المنتج',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
