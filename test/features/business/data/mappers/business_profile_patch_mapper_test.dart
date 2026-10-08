import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/business/data/mappers/business_profile_patch_mapper.dart';
import 'package:talbatiyk/features/business/domain/entities/business_profile_update.dart';

void main() {
  test('patch payload preserves explicit null and omits absent fields', () {
    const update = BusinessProfileUpdate(
      legalName: PatchField<String>.present(null),
      description: PatchField<String>.present('وصف محدث'),
    );

    final payload = BusinessProfilePatchMapper.toJson(update);

    expect(payload.containsKey('name'), isFalse);

    expect(payload.containsKey('legal_name'), isTrue);
    expect(payload['legal_name'], isNull);

    expect(payload['description'], 'وصف محدث');
  });

  test('patch payload sends only explicitly changed fields', () {
    const update = BusinessProfileUpdate(name: 'متجر طلبيتك');

    final payload = BusinessProfilePatchMapper.toJson(update);

    expect(payload, <String, Object?>{'name': 'متجر طلبيتك'});
  });
}
