import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/business_profile_update.dart';
import '../providers/business_profile_provider.dart';
import '../providers/business_provider.dart';

final class BusinessProfileEditPage extends ConsumerStatefulWidget {
  const BusinessProfileEditPage({required this.business, super.key});

  final BusinessEntity business;

  @override
  ConsumerState<BusinessProfileEditPage> createState() =>
      _BusinessProfileEditPageState();
}

final class _BusinessProfileEditPageState
    extends ConsumerState<BusinessProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _legalNameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.business.name);

    _legalNameController = TextEditingController(
      text: widget.business.legalName ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.business.description ?? '',
    );

    _nameController.addListener(_onChanged);
    _legalNameController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onChanged)
      ..dispose();

    _legalNameController
      ..removeListener(_onChanged)
      ..dispose();

    _descriptionController
      ..removeListener(_onChanged)
      ..dispose();

    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _nullableTrimmed(String value) {
    final normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }

  BusinessProfileUpdate _buildUpdate() {
    final current = widget.business;

    final name = _nameController.text.trim();

    final legalName = _nullableTrimmed(_legalNameController.text);

    final description = _nullableTrimmed(_descriptionController.text);

    return BusinessProfileUpdate(
      name: name == current.name ? null : name,
      legalName: legalName == current.legalName
          ? const PatchField<String>.absent()
          : PatchField<String>.present(legalName),
      description: description == current.description
          ? const PatchField<String>.absent()
          : PatchField<String>.present(description),
    );
  }

  bool get _hasChanges => !_buildUpdate().isEmpty;

  String? _validateName(String? value) {
    final normalized = value?.trim() ?? '';

    if (normalized.length < 2) {
      return 'اسم النشاط يجب أن يكون حرفين على الأقل';
    }

    if (normalized.length > 200) {
      return 'اسم النشاط يجب ألا يتجاوز 200 حرف';
    }

    return null;
  }

  String? _validateLegalName(String? value) {
    if ((value?.trim().length ?? 0) > 250) {
      return 'الاسم القانوني يجب ألا يتجاوز 250 حرفًا';
    }

    return null;
  }

  String? _validateDescription(String? value) {
    if ((value?.trim().length ?? 0) > 5000) {
      return 'الوصف يجب ألا يتجاوز 5000 حرف';
    }

    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final update = _buildUpdate();

    if (update.isEmpty) {
      return;
    }

    final controller = ref.read(
      businessProfileControllerProvider(widget.business),
    );

    final updated = await controller.save(update);

    if (!mounted || updated == null) {
      return;
    }

    ref.read(businessControllerProvider).replaceBusiness(updated);

    Navigator.of(context).pop<BusinessEntity>(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final profileController = ref.watch(
      businessProfileControllerProvider(widget.business),
    );

    final state = profileController.state;

    return PopScope(
      canPop: !state.isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text('بيانات النشاط'), centerTitle: true),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.storefront_rounded,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الهوية الأساسية',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'هذه البيانات تظهر للمستخدمين '
                              'وتعرّف نشاطك داخل طلبيتك.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  key: const ValueKey<String>('business-profile-name'),
                  controller: _nameController,
                  enabled: !state.isSaving,
                  maxLength: 200,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                  decoration: const InputDecoration(
                    labelText: 'اسم النشاط',
                    hintText: 'مثال: مؤسسة طلبيتك التجارية',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const ValueKey<String>('business-profile-legal-name'),
                  controller: _legalNameController,
                  enabled: !state.isSaving,
                  maxLength: 250,
                  textInputAction: TextInputAction.next,
                  validator: _validateLegalName,
                  decoration: const InputDecoration(
                    labelText: 'الاسم القانوني',
                    hintText: 'اختياري — كما يظهر في السجل التجاري',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const ValueKey<String>('business-profile-description'),
                  controller: _descriptionController,
                  enabled: !state.isSaving,
                  maxLength: 5000,
                  minLines: 4,
                  maxLines: 8,
                  validator: _validateDescription,
                  decoration: const InputDecoration(
                    labelText: 'وصف النشاط',
                    hintText: 'عرّف العملاء بنشاطك ومنتجاتك وخدماتك',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colors.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(color: colors.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            key: const ValueKey<String>('business-profile-save'),
            onPressed: state.isSaving || !_hasChanges ? null : _save,
            icon: state.isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(state.isSaving ? 'جارٍ الحفظ...' : 'حفظ التغييرات'),
          ),
        ),
      ),
    );
  }
}
