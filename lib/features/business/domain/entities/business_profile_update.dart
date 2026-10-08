final class PatchField<T> {
  const PatchField.absent() : isPresent = false, value = null;

  const PatchField.present(this.value) : isPresent = true;

  final bool isPresent;
  final T? value;
}

final class BusinessProfileUpdate {
  const BusinessProfileUpdate({
    this.name,
    this.legalName = const PatchField<String>.absent(),
    this.description = const PatchField<String>.absent(),
  });

  final String? name;
  final PatchField<String> legalName;
  final PatchField<String> description;

  bool get isEmpty =>
      name == null && !legalName.isPresent && !description.isPresent;
}
