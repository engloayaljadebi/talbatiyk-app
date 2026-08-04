import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// مسؤولة عن اختيار صورة المنتج وحفظ نسخة دائمة داخل مساحة التطبيق.
class ProductImageStorage {
  ProductImageStorage({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  /// يختار صورة من معرض الجهاز ثم يحفظها داخل مجلد التطبيق.
  Future<String?> pickFromGallery() {
    return _pickAndSave(ImageSource.gallery);
  }

  /// يلتقط صورة بالكاميرا ثم يحفظها داخل مجلد التطبيق.
  Future<String?> takePhoto() {
    return _pickAndSave(ImageSource.camera);
  }

  /// ينفذ اختيار الصورة ويقلل حجمها قبل حفظها.
  Future<String?> _pickAndSave(ImageSource source) async {
    final selectedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    /// إرجاع null يعني أن المستخدم أغلق نافذة الاختيار دون اختيار صورة.
    if (selectedImage == null) {
      return null;
    }

    return _copyToPermanentDirectory(selectedImage.path);
  }

  /// ينسخ الصورة من مسارها المؤقت إلى مجلد دائم خاص بالتطبيق.
  Future<String> _copyToPermanentDirectory(String sourcePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory(
      path.join(documentsDirectory.path, 'product_images'),
    );

    /// ينشئ مجلد صور المنتجات إذا لم يكن موجودًا.
    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final originalExtension = path.extension(sourcePath).toLowerCase();

    /// بعض الصور لا تحتوي على امتداد، لذلك نستخدم jpg كقيمة آمنة.
    final extension = originalExtension.isEmpty ? '.jpg' : originalExtension;

    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}$extension';

    final destinationPath = path.join(imagesDirectory.path, fileName);

    final savedImage = await File(sourcePath).copy(destinationPath);

    return savedImage.path;
  }
}
