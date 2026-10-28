import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

/// Registration follows RegisterRequest.php. It never handles access tokens.
/// Only shop and supplier accounts are supported by this mobile registration screen.
final class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

enum _AccountKind { shop, supplier }

enum _Step { kind, account, personal, business, location, review }

final class _RegisterPageState extends ConsumerState<RegisterPage> {
  static const String _deviceName = 'talbatiyk-flutter-app';

  final Map<_Step, GlobalKey<FormState>> _forms = {
    for (final step in _Step.values) step: GlobalKey<FormState>(),
  };

  final _username = TextEditingController();
  final _displayName = TextEditingController();
  final _contact = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _nationality = TextEditingController();
  final _birthDate = TextEditingController();
  final _businessName = TextEditingController();
  final _legalName = TextEditingController();
  final _description = TextEditingController();
  final _businessContact = TextEditingController();
  final _businessContactLabel = TextEditingController();
  final _locationName = TextEditingController();
  final _country = TextEditingController(text: 'YE');
  final _timezone = TextEditingController(text: 'Asia/Aden');
  final _administrativeArea = TextEditingController();
  final _locality = TextEditingController();
  final _district = TextEditingController();
  final _streetAddress = TextEditingController();
  final _addressNotes = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _scrollController = ScrollController();

  _AccountKind _kind = _AccountKind.shop;
  String _contactType = 'phone';
  String _businessContactType = 'phone';
  String? _categoryId;
  String? _locationType;
  List<({String id, String name})> _categories = [];
  bool _loadingCategories = false;
  bool _categoriesLoaded = false;
  String? _categoriesError;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  int _index = 0;

  /// Server errors are hidden for a field as soon as that field is edited.
  final Set<String> _editedServerFields = <String>{};

  static const List<_Step> _steps = [
    _Step.kind,
    _Step.account,
    _Step.personal,
    _Step.business,
    _Step.location,
    _Step.review,
  ];

  _Step get _step => _steps[_index];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadCategories);
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _username,
      _displayName,
      _contact,
      _password,
      _confirmation,
      _nationality,
      _birthDate,
      _businessName,
      _legalName,
      _description,
      _businessContact,
      _businessContactLabel,
      _locationName,
      _country,
      _timezone,
      _administrativeArea,
      _locality,
      _district,
      _streetAddress,
      _addressNotes,
      _latitude,
      _longitude,
    ]) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  String? _required(String? value, {int min = 2, int max = 160}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (text.length < min || text.length > max) {
      return 'يجب أن يكون بين $min و$max حرفًا';
    }
    return null;
  }

  String? _optional(String? value, {int max = 160}) {
    if ((value ?? '').trim().length > max) {
      return 'الحد الأقصى $max حرفًا';
    }
    return null;
  }

  Widget _field({
    required String keyName,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool enabled = true,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
    TextCapitalization capitalization = TextCapitalization.none,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        key: ValueKey('register-$keyName'),
        controller: controller,
        enabled: enabled,
        onChanged: (_) => _markServerFieldEdited(keyName),
        textCapitalization: capitalization,
        keyboardType: keyboard,
        inputFormatters: formatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          errorText: _serverError(keyName),
          hintText: hint,
          helperText: hint == null ? null : ' ',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final localError = validator == null
              ? _required(value)
              : validator(value);
          return localError ?? _serverError(keyName);
        },
      ),
    );
  }

  String? _serverError(String field) {
    if (_editedServerFields.contains(field)) {
      return null;
    }
    return ref.read(authProvider).state.registrationFieldErrors[field];
  }

  void _markServerFieldEdited(String field) {
    if (_serverError(field) != null) {
      setState(() => _editedServerFields.add(field));
    }
  }

  int _firstErrorStep(Map<String, String> errors) {
    const account = <String>{
      'username',
      'display_name',
      'contact_type',
      'contact_value',
      'password',
      'password_confirmation',
    };
    const personal = <String>{'nationality_country_code', 'birth_date'};
    const business = <String>{
      'name',
      'legal_name',
      'description',
      'category_id',
      'business_contact_type',
      'business_contact_value',
      'business_contact_label',
    };
    const location = <String>{
      'location_name',
      'location_type',
      'country_code',
      'timezone',
      'administrative_area',
      'locality',
      'district',
      'street_address',
      'address_notes',
      'latitude',
      'longitude',
    };
    final keys = errors.keys.toSet();
    if (keys.contains('account_type')) {
      return _steps.indexOf(_Step.kind);
    }
    if (keys.intersection(account).isNotEmpty) {
      return _steps.indexOf(_Step.account);
    }
    if (keys.intersection(personal).isNotEmpty) {
      return _steps.indexOf(_Step.personal);
    }
    if (keys.intersection(business).isNotEmpty) {
      return _steps.indexOf(_Step.business);
    }
    if (keys.intersection(location).isNotEmpty) {
      return _steps.indexOf(_Step.location);
    }
    return _steps.indexOf(_Step.review);
  }

  Widget _heading(String title, {String? note}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _typeTile(
    _AccountKind kind,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final selected = _kind == kind;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _editedServerFields.add('account_type');
              _kind = kind;
              _locationType = null;
            });
            if (!_categoriesLoaded && !_loadingCategories) {
              _loadCategories();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(selected ? Icons.check_circle : Icons.circle_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kindFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        'نوع الحساب التجاري',
        note:
            'اختر متجرًا أو موردًا؛ كلا النوعين يتطلب فئة نشاط وموقعًا رئيسيًا.',
      ),
      if (_serverError('account_type') != null)
        Text(
          _serverError('account_type')!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      _typeTile(
        _AccountKind.shop,
        'متجر',
        'تسجيل نشاط للبيع بعد الموافقة',
        Icons.storefront_outlined,
      ),
      _typeTile(
        _AccountKind.supplier,
        'مورد',
        'تسجيل نشاط لتوريد المنتجات بعد الموافقة',
        Icons.local_shipping_outlined,
      ),
    ],
  );

  Widget _accountFields(bool busy) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        'بيانات الحساب',
        note: 'اسم المستخدم فريد، ويمكن كتابته بالإنجليزية أو بالأرقام فقط.',
      ),
      _field(
        keyName: 'username',
        label: 'اسم المستخدم',
        controller: _username,
        enabled: !busy,
        validator: (value) =>
            RegExp(r'^[A-Za-z0-9]{3,50}$').hasMatch((value ?? '').trim())
            ? null
            : '3–50 حرفًا إنجليزيًا أو رقمًا فقط',
      ),
      _field(
        keyName: 'display_name',
        label: 'الاسم الشخصي',
        controller: _displayName,
        enabled: !busy,
        validator: (v) => _required(v, min: 2, max: 160),
      ),
      DropdownButtonFormField<String>(
        key: const ValueKey('register-contact-type'),
        initialValue: _contactType,
        decoration: InputDecoration(
          labelText: 'وسيلة الدخول الأساسية',
          border: const OutlineInputBorder(),
          errorText: _serverError('contact_type'),
        ),
        items: const [
          DropdownMenuItem(value: 'phone', child: Text('رقم هاتف')),
          DropdownMenuItem(value: 'email', child: Text('بريد إلكتروني')),
        ],
        onChanged: busy
            ? null
            : (v) {
                if (v != null) {
                  setState(() {
                    _contactType = v;
                    _contact.clear();
                    _editedServerFields.add('contact_type');
                    _editedServerFields.add('contact_value');
                  });
                }
              },
      ),
      const SizedBox(height: 14),
      _field(
        keyName: 'contact_value',
        label: _contactType == 'phone'
            ? 'رقم الجوال — 9 أرقام'
            : 'البريد الإلكتروني',
        controller: _contact,
        enabled: !busy,
        keyboard: _contactType == 'phone'
            ? TextInputType.phone
            : TextInputType.emailAddress,
        formatters: _contactType == 'phone'
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ]
            : null,
        validator: (v) {
          final value = (v ?? '').trim();
          if (_contactType == 'phone') {
            return RegExp(r'^[0-9]{9}$').hasMatch(value)
                ? null
                : 'يجب إدخال 9 أرقام بالضبط';
          }
          return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value) &&
                  value.length <= 320
              ? null
              : 'أدخل بريدًا إلكترونيًا صحيحًا';
        },
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: const ValueKey('register-password'),
          controller: _password,
          onChanged: (_) => _markServerFieldEdited('password'),
          enabled: !busy,
          obscureText: _hidePassword,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            border: const OutlineInputBorder(),
            errorText: _serverError('password'),
            suffixIcon: IconButton(
              tooltip: _hidePassword
                  ? 'إظهار كلمة المرور'
                  : 'إخفاء كلمة المرور',
              onPressed: busy
                  ? null
                  : () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (v) {
            final value = v ?? '';
            if (value.length < 8) {
              return 'كلمة المرور لا تقل عن 8 أحرف';
            }
            if (utf8.encode(value).length > 72) {
              return 'كلمة المرور لا تزيد عن 72 بايت';
            }
            return _serverError('password');
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: const ValueKey('register-password-confirmation'),
          controller: _confirmation,
          onChanged: (_) => _markServerFieldEdited('password_confirmation'),
          enabled: !busy,
          obscureText: _hideConfirmation,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: 'تأكيد كلمة المرور',
            border: const OutlineInputBorder(),
            errorText: _serverError('password_confirmation'),
            suffixIcon: IconButton(
              tooltip: _hideConfirmation ? 'إظهار التأكيد' : 'إخفاء التأكيد',
              onPressed: busy
                  ? null
                  : () =>
                        setState(() => _hideConfirmation = !_hideConfirmation),
              icon: Icon(
                _hideConfirmation
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (v) => v == _password.text
              ? _serverError('password_confirmation')
              : 'كلمتا المرور غير متطابقتين',
        ),
      ),
    ],
  );

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (!mounted || date == null) {
      return;
    }
    setState(() {
      _birthDate.text =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      _editedServerFields.add('birth_date');
    });
  }

  Widget _personalFields(bool busy) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        'بيانات شخصية إضافية',
        note: 'هذه البيانات اختيارية، ويمكنك تركها فارغة.',
      ),
      _field(
        keyName: 'nationality_country_code',
        label: 'رمز الجنسية (اختياري — مثال YE)',
        controller: _nationality,
        enabled: !busy,
        capitalization: TextCapitalization.characters,
        formatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
          LengthLimitingTextInputFormatter(2),
        ],
        validator: (v) {
          final value = (v ?? '').trim().toUpperCase();
          if (value.isEmpty || RegExp(r'^[A-Z]{2}$').hasMatch(value)) {
            return null;
          }
          return 'أدخل رمز دولة من حرفين';
        },
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: const ValueKey('register-birth-date'),
          controller: _birthDate,
          readOnly: true,
          enabled: !busy,
          onTap: _pickBirthDate,
          decoration: InputDecoration(
            labelText: 'تاريخ الميلاد (اختياري)',
            border: const OutlineInputBorder(),
            errorText: _serverError('birth_date'),
            suffixIcon: IconButton(
              tooltip: 'اختيار التاريخ',
              onPressed: busy ? null : _pickBirthDate,
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          validator: (_) => _serverError('birth_date'),
        ),
      ),
      Text(
        'لا يتم طلب صور الهوية أو المستندات هنا؛ رفعها يحتاج مسار API خاصًا وموثقًا.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );

  Future<void> _loadCategories() async {
    if (_loadingCategories) {
      return;
    }
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });
    try {
      final categories = await ref
          .read(authProvider)
          .fetchRegistrationCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = categories;
        _categoriesLoaded = true;
        _categoryId = categories.any((c) => c.id == _categoryId)
            ? _categoryId
            : null;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingCategories = false;
        _categoriesError =
            'تعذر جلب فئات النشاط. تحقق من الاتصال وحاول مرة أخرى.';
      });
    }
  }

  Widget _businessFields(bool busy) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(
        'بيانات النشاط التجاري',
        note: 'يُسمح بفئة نهائية واحدة فقط لكل نشاط.',
      ),
      _field(
        keyName: 'name',
        label: 'اسم النشاط',
        controller: _businessName,
        enabled: !busy,
        validator: (v) => _required(v, min: 2, max: 200),
      ),
      _field(
        keyName: 'legal_name',
        label: 'الاسم القانوني (اختياري)',
        controller: _legalName,
        enabled: !busy,
        validator: (v) => _optional(v, max: 250),
      ),
      _field(
        keyName: 'description',
        label: 'وصف النشاط (اختياري)',
        controller: _description,
        enabled: !busy,
        maxLines: 3,
        validator: (v) => _optional(v, max: 5000),
      ),
      if (_loadingCategories)
        const Center(child: CircularProgressIndicator())
      else if (_categoriesError != null) ...[
        Text(
          _categoriesError!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        TextButton.icon(
          onPressed: busy ? null : _loadCategories,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة محاولة جلب الفئات'),
        ),
      ] else if (_categories.isEmpty) ...[
        const Text('لا توجد فئات نشطة متاحة حاليًا.'),
        TextButton(
          onPressed: busy ? null : _loadCategories,
          child: const Text('تحديث الفئات'),
        ),
      ] else ...[
        DropdownButtonFormField<String>(
          key: ValueKey('register-category-${_categoryId ?? 'empty'}'),
          initialValue: _categoryId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'فئة النشاط (مطلوب)',
            border: const OutlineInputBorder(),
            errorText: _serverError('category_id'),
          ),
          items: [
            for (final category in _categories)
              DropdownMenuItem(
                value: category.id,
                child: Text(category.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: busy
              ? null
              : (v) => setState(() {
                  _categoryId = v;
                  _editedServerFields.add('category_id');
                }),
          validator: (v) =>
              v == null ? 'اختر فئة النشاط' : _serverError('category_id'),
        ),
      ],
      const SizedBox(height: 18),
      _heading('وسيلة اتصال النشاط (اختيارية)'),
      DropdownButtonFormField<String>(
        key: const ValueKey('register-business-contact-type'),
        initialValue: _businessContactType,
        decoration: InputDecoration(
          labelText: 'نوع الاتصال',
          border: const OutlineInputBorder(),
          errorText: _serverError('business_contact_type'),
        ),
        items: const [
          DropdownMenuItem(value: 'phone', child: Text('هاتف دولي')),
          DropdownMenuItem(value: 'whatsapp', child: Text('واتساب دولي')),
          DropdownMenuItem(value: 'email', child: Text('بريد إلكتروني')),
          DropdownMenuItem(value: 'website', child: Text('موقع إلكتروني')),
        ],
        onChanged: busy
            ? null
            : (v) {
                if (v != null) {
                  setState(() {
                    _businessContactType = v;
                    _businessContact.clear();
                    _editedServerFields.add('business_contact_type');
                    _editedServerFields.add('business_contact_value');
                  });
                }
              },
      ),
      const SizedBox(height: 14),
      _field(
        keyName: 'business_contact_value',
        label: 'قيمة وسيلة اتصال النشاط (اختياري)',
        hint:
            _businessContactType == 'phone' ||
                _businessContactType == 'whatsapp'
            ? 'مثال +967777123456'
            : null,
        controller: _businessContact,
        enabled: !busy,
        keyboard: _businessContactType == 'email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        validator: (v) {
          final value = (v ?? '').trim();
          if (value.isEmpty) {
            return null;
          }
          if (value.length > 500) {
            return 'الحد الأقصى 500 حرف';
          }
          switch (_businessContactType) {
            case 'phone':
            case 'whatsapp':
              return RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(value)
                  ? null
                  : 'أدخل الرقم بالصيغة الدولية مثل +967777123456';
            case 'email':
              return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)
                  ? null
                  : 'أدخل بريدًا إلكترونيًا صحيحًا';
            case 'website':
              final uri = Uri.tryParse(value);
              return uri != null &&
                      (uri.scheme == 'http' || uri.scheme == 'https') &&
                      uri.host.isNotEmpty
                  ? null
                  : 'أدخل رابطًا يبدأ بـ https:// أو http://';
          }
          return null;
        },
      ),
      _field(
        keyName: 'business_contact_label',
        label: 'وصف وسيلة الاتصال (اختياري)',
        controller: _businessContactLabel,
        enabled: !busy,
        validator: (v) {
          final error = _optional(v, max: 120);
          if (error != null) {
            return error;
          }
          if ((v ?? '').trim().isNotEmpty &&
              _businessContact.text.trim().isEmpty) {
            return 'أدخل وسيلة الاتصال أولًا';
          }
          return null;
        },
      ),
    ],
  );

  String? _coordinateValidator(String? input, {required bool latitude}) {
    final value = (input ?? '').trim();
    final partner = (latitude ? _longitude : _latitude).text.trim();
    if (value.isEmpty && partner.isEmpty) {
      return null;
    }
    if (value.isEmpty) {
      return 'يجب إدخال الإحداثيين معًا';
    }
    final number = double.tryParse(value);
    if (number == null ||
        !number.isFinite ||
        number.abs() > (latitude ? 90 : 180)) {
      return latitude ? 'خط العرض بين -90 و90' : 'خط الطول بين -180 و180';
    }
    return null;
  }

  Widget _locationFields(bool busy) {
    final selectedType =
        _locationType ??
        (_kind == _AccountKind.supplier ? 'warehouse' : 'store');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(
          'الموقع الرئيسي للنشاط',
          note: 'هذه البيانات ستُستخدم لإنشاء أول موقع للنشاط.',
        ),
        _field(
          keyName: 'location_name',
          label: 'اسم الموقع',
          controller: _locationName,
          enabled: !busy,
          validator: (v) => _required(v, min: 2, max: 160),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
            key: ValueKey('register-location-type-$selectedType'),
            initialValue: selectedType,
            decoration: InputDecoration(
              labelText: 'نوع الموقع',
              border: const OutlineInputBorder(),
              errorText: _serverError('location_type'),
            ),
            items: const [
              DropdownMenuItem(value: 'store', child: Text('متجر')),
              DropdownMenuItem(value: 'warehouse', child: Text('مستودع')),
              DropdownMenuItem(value: 'office', child: Text('مكتب')),
              DropdownMenuItem(value: 'branch', child: Text('فرع')),
            ],
            onChanged: busy
                ? null
                : (v) => setState(() {
                    _locationType = v;
                    _editedServerFields.add('location_type');
                  }),
          ),
        ),
        _field(
          keyName: 'country_code',
          label: 'رمز الدولة',
          controller: _country,
          enabled: !busy,
          capitalization: TextCapitalization.characters,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
            LengthLimitingTextInputFormatter(2),
          ],
          validator: (v) => RegExp(r'^[A-Za-z]{2}$').hasMatch((v ?? '').trim())
              ? null
              : 'أدخل رمز الدولة من حرفين',
        ),
        _field(
          keyName: 'administrative_area',
          label: 'المحافظة / المنطقة الإدارية',
          controller: _administrativeArea,
          enabled: !busy,
          validator: (v) => _required(v, min: 2, max: 160),
        ),
        _field(
          keyName: 'locality',
          label: 'المدينة / المديرية',
          controller: _locality,
          enabled: !busy,
          validator: (v) => _required(v, min: 2, max: 160),
        ),
        _field(
          keyName: 'district',
          label: 'الحي (اختياري)',
          controller: _district,
          enabled: !busy,
          validator: (v) => _optional(v, max: 160),
        ),
        _field(
          keyName: 'street_address',
          label: 'الشارع والعنوان (اختياري)',
          controller: _streetAddress,
          enabled: !busy,
          validator: (v) => _optional(v, max: 300),
        ),
        _field(
          keyName: 'address_notes',
          label: 'ملاحظات الوصول (اختياري)',
          controller: _addressNotes,
          enabled: !busy,
          maxLines: 2,
          validator: (v) => _optional(v, max: 2000),
        ),
        _field(
          keyName: 'timezone',
          label: 'المنطقة الزمنية',
          controller: _timezone,
          enabled: !busy,
          validator: (v) => _required(v, min: 1, max: 64),
        ),
        _heading(
          'الإحداثيات (اختيارية)',
          note: 'إذا أدخلت خط العرض، فأدخل خط الطول أيضًا.',
        ),
        _field(
          keyName: 'latitude',
          label: 'خط العرض',
          controller: _latitude,
          enabled: !busy,
          keyboard: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          validator: (v) => _coordinateValidator(v, latitude: true),
        ),
        _field(
          keyName: 'longitude',
          label: 'خط الطول',
          controller: _longitude,
          enabled: !busy,
          keyboard: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          validator: (v) => _coordinateValidator(v, latitude: false),
        ),
      ],
    );
  }

  Widget _reviewItem(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(title, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Text(value.isEmpty ? '—' : value)),
      ],
    ),
  );

  Widget _reviewFields(bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(
          'مراجعة البيانات',
          note: 'راجع البيانات قبل إنشاء الحساب. لا تُعرض كلمة المرور.',
        ),
        _reviewItem('نوع الحساب', switch (_kind) {
          _AccountKind.shop => 'متجر',
          _AccountKind.supplier => 'مورد',
        }),
        _reviewItem('اسم المستخدم', _username.text.trim()),
        _reviewItem('الاسم الشخصي', _displayName.text.trim()),
        _reviewItem('وسيلة الاتصال', _contact.text.trim()),
        _reviewItem('الجنسية', _nationality.text.trim().toUpperCase()),
        _reviewItem('تاريخ الميلاد', _birthDate.text.trim()),
        const Divider(),
        _reviewItem('النشاط', _businessName.text.trim()),
        _reviewItem('الفئة', _categoryName()),
        _reviewItem('اسم الموقع', _locationName.text.trim()),
        _reviewItem('المحافظة', _administrativeArea.text.trim()),
        _reviewItem('المدينة', _locality.text.trim()),
        const SizedBox(height: 12),
        const Text(
          'سيُنشأ طلب اعتماد للنشاط، وتبقى صلاحياته التجارية بانتظار قرار الإدارة.',
        ),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  String _categoryName() {
    for (final category in _categories) {
      if (category.id == _categoryId) {
        return category.name;
      }
    }
    return 'لم تُحدد';
  }

  Widget _buildStep(bool busy) => switch (_step) {
    _Step.kind => _kindFields(),
    _Step.account => _accountFields(busy),
    _Step.personal => _personalFields(busy),
    _Step.business => _businessFields(busy),
    _Step.location => _locationFields(busy),
    _Step.review => _reviewFields(busy),
  };

  Future<void> _next() async {
    if (ref.read(authProvider).state.isRegistering) {
      return;
    }
    final valid = _forms[_step]!.currentState?.validate() ?? true;
    if (!valid) {
      return;
    }
    if (_step == _Step.business &&
        (_loadingCategories ||
            _categoriesError != null ||
            _categoryId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر فئة نشاط متاحة قبل المتابعة.')),
      );
      return;
    }
    if (_index + 1 < _steps.length) {
      _goToStep(_index + 1);
    }
  }

  void _goToStep(int nextIndex) {
    if (nextIndex < 0 || nextIndex >= _steps.length) {
      return;
    }
    setState(() => _index = nextIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Map<String, Object?> _payload() {
    final payload = <String, Object?>{
      'username': _username.text.trim(),
      'display_name': _displayName.text.trim(),
      'contact_type': _contactType,
      'contact_value': _contact.text.trim(),
      'password': _password.text,
      'password_confirmation': _confirmation.text,
      'device_name': _deviceName,
    };
    final nationality = _trimmedOrNull(_nationality);
    final birthDate = _trimmedOrNull(_birthDate);
    if (nationality != null) {
      payload['nationality_country_code'] = nationality.toUpperCase();
    }
    if (birthDate != null) {
      payload['birth_date'] = birthDate;
    }

    payload.addAll({
      'account_type': _kind == _AccountKind.shop ? 'shop' : 'supplier',
      'name': _businessName.text.trim(),
      'category_id': _categoryId,
      'location_name': _locationName.text.trim(),
      'location_type':
          _locationType ??
          (_kind == _AccountKind.supplier ? 'warehouse' : 'store'),
      'country_code': _country.text.trim().toUpperCase(),
      'timezone': _timezone.text.trim(),
      'administrative_area': _administrativeArea.text.trim(),
      'locality': _locality.text.trim(),
    });
    for (final entry in <String, TextEditingController>{
      'legal_name': _legalName,
      'description': _description,
      'district': _district,
      'street_address': _streetAddress,
      'address_notes': _addressNotes,
    }.entries) {
      final value = _trimmedOrNull(entry.value);
      if (value != null) {
        payload[entry.key] = value;
      }
    }
    final contactValue = _trimmedOrNull(_businessContact);
    if (contactValue != null) {
      payload['business_contact_type'] = _businessContactType;
      payload['business_contact_value'] = contactValue;
      final label = _trimmedOrNull(_businessContactLabel);
      if (label != null) {
        payload['business_contact_label'] = label;
      }
    }
    if (_latitude.text.trim().isNotEmpty && _longitude.text.trim().isNotEmpty) {
      payload['latitude'] = double.parse(_latitude.text.trim());
      payload['longitude'] = double.parse(_longitude.text.trim());
    }
    return payload;
  }

  Future<void> _submit() async {
    if (ref.read(authProvider).state.isRegistering) {
      return;
    }
    if (_categoryId == null || !_categories.any((c) => c.id == _categoryId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر فئة نشاط صحيحة أولًا.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final success = await ref.read(authProvider).registerFromMobile(_payload());
    if (!mounted || success) {
      return;
    }

    final fieldErrors = ref.read(authProvider).state.registrationFieldErrors;
    if (fieldErrors.isNotEmpty) {
      _editedServerFields.clear();
      _goToStep(_firstErrorStep(fieldErrors));
    }
    // Authentication state drives GoRouter on success. Validation failures
    // navigate to the earliest step containing a server-rejected field.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider).state;
    final busy = state.isRegistering;
    final steps = _steps;
    final step = _step;
    final isLast = _index == steps.length - 1;
    const titles = <_Step, String>{
      _Step.kind: 'النوع',
      _Step.account: 'الحساب',
      _Step.personal: 'الشخصية',
      _Step.business: 'النشاط',
      _Step.location: 'الموقع',
      _Step.review: 'المراجعة',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'المرحلة ${_index + 1} من ${steps.length} — ${titles[step]}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 9),
                      LinearProgressIndicator(
                        value: (_index + 1) / steps.length,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('register-scroll'),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    child: Form(
                      key: _forms[step],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStep(busy),
                          if (state.registrationErrorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.registrationErrorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_index > 0) ...[
                        OutlinedButton.icon(
                          onPressed: busy ? null : () => _goToStep(_index - 1),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('السابق'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('register-continue'),
                          onPressed: busy ? null : (isLast ? _submit : _next),
                          icon: busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  isLast
                                      ? Icons.check_circle_outline
                                      : Icons.arrow_back,
                                ),
                          label: Text(isLast ? 'إنشاء الحساب' : 'التالي'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
