/*
|--------------------------------------------------------------------------
| Network Providers
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - توفير GeneratedApiClient على مستوى التطبيق.
| - إنشاء نسخة واحدة من عميل OpenAPI لكل ProviderScope.
| - مشاركة نفس Dio وBearer Token بين جميع الميزات.
|
| تستخدمه الميزات مثل:
| - Auth
| - Businesses
| - Business Locations
| - Business Contacts
|
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'generated_api_client.dart';

/// يوفر عميل OpenAPI المشترك على مستوى التطبيق.
///
/// عنوان API يتم أخذه من ApiEnvironment عبر:
/// --dart-define=API_BASE_URL=...
final generatedApiClientProvider = Provider<GeneratedApiClient>((ref) {
  return GeneratedApiClient.create();
});
