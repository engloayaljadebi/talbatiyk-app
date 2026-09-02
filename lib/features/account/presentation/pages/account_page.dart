// محتوى الملف:
// - تعريف أنواع حسابات المستخدمين.
// - عرض بيانات المستخدم والنشاط التجاري.
// - عرض إعدادات الحساب والدعم.
// - تجهيز أزرار التعديل والإعدادات وتسجيل الخروج.
// - عرض رسالة مؤقتة للإجراءات غير المرتبطة بالـ API بعد.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../business/presentation/pages/business_workspace_page.dart';
import '../../../business/presentation/providers/business_provider.dart';

/// أنواع الحسابات المدعومة داخل تطبيق طلبيتك.
enum AccountType { supplier, shopOwner }

/// خصائص العرض الخاصة بنوع الحساب.
extension AccountTypePresentation on AccountType {
  /// الاسم العربي الذي يظهر للمستخدم.
  String get label {
    return switch (this) {
      AccountType.supplier => 'عضو نشاط تجاري',
      AccountType.shopOwner => 'عميل',
    };
  }

  /// الأيقونة المناسبة لنوع الحساب.
  IconData get icon {
    return switch (this) {
      AccountType.supplier => Icons.local_shipping_outlined,
      AccountType.shopOwner => Icons.storefront_outlined,
    };
  }
}

/// صفحة الحساب الرئيسية.
///
/// تستقبل البيانات من الخارج حتى يسهل لاحقًا ربطها
/// بمزود الحالة والـ API دون إعادة بناء الواجهة.
class AccountPage extends ConsumerWidget {
  const AccountPage({
    super.key,
    this.displayName = 'مستخدم طلبيتك',
    this.businessName = 'لم تتم إضافة اسم النشاط',
    this.phoneNumber = 'غير مضاف',
    this.accountType = AccountType.shopOwner,
    this.onEditProfile,
    this.onOpenSettings,
    this.onLogout,
  });

  /// اسم المستخدم.
  final String displayName;

  /// اسم النشاط التجاري.
  final String businessName;

  /// رقم هاتف المستخدم.
  final String phoneNumber;

  /// نوع الحساب: مورد أو صاحب محل.
  final AccountType accountType;

  /// يعمل عند طلب تعديل البيانات.
  final VoidCallback? onEditProfile;

  /// يعمل عند فتح الإعدادات.
  final VoidCallback? onOpenSettings;

  /// يعمل عند تسجيل الخروج.
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessController = ref.watch(businessControllerProvider);
    final businessState = businessController.state;
    final authController = ref.watch(authProvider);
    final user = authController.state.user;

    final String resolvedDisplayName =
        user?.displayName.trim().isNotEmpty == true
        ? user!.displayName.trim()
        : displayName;

    final phoneContacts = user?.contacts.where(
      (contact) => contact.type.trim().toLowerCase() == 'phone',
    );

    final phoneContact = phoneContacts == null || phoneContacts.isEmpty
        ? null
        : phoneContacts.first;

    final String resolvedPhoneNumber =
        phoneContact?.value.trim().isNotEmpty == true
        ? phoneContact!.value.trim()
        : phoneNumber;

    final String resolvedProfileSubtitle;

    if (businessState.hasBusinesses) {
      resolvedProfileSubtitle = businessState.businesses.length == 1
          ? businessState.businesses.first.name
          : '${businessState.businesses.length} أنشطة تجارية';
    } else if (user?.username.trim().isNotEmpty == true) {
      resolvedProfileSubtitle = '@${user!.username.trim()}';
    } else {
      resolvedProfileSubtitle = businessName;
    }

    final AccountType resolvedAccountType = businessState.hasBusinesses
        ? AccountType.supplier
        : AccountType.shopOwner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _ProfileCard(
            displayName: resolvedDisplayName,
            businessName: resolvedProfileSubtitle,
            accountType: resolvedAccountType,
            onEdit: () =>
                _executeOrNotify(context, onEditProfile, 'تعديل البيانات'),
          ),
          const SizedBox(height: 16),
          _AccountSection(
            title: 'بيانات الحساب',
            children: [
              _AccountOptionTile(
                icon: Icons.phone_outlined,
                title: 'رقم الهاتف',
                subtitle: resolvedPhoneNumber,
                showArrow: false,
              ),
              _AccountOptionTile(
                icon: resolvedAccountType.icon,
                title: 'نوع الحساب',
                subtitle: resolvedAccountType.label,
                showArrow: false,
              ),
              _AccountOptionTile(
                icon: Icons.person_outline_rounded,
                title: 'البيانات الشخصية',
                subtitle: 'الاسم ومعلومات النشاط',
                onTap: () =>
                    _executeOrNotify(context, onEditProfile, 'تعديل البيانات'),
              ),
            ],
          ),
          if (businessState.hasBusinesses) ...[
            const SizedBox(height: 16),
            _AccountSection(
              title: 'مساحة الأعمال',
              children: [
                _AccountOptionTile(
                  icon: Icons.storefront_outlined,
                  title: 'إدارة النشاط التجاري',
                  subtitle: businessState.businesses.length == 1
                      ? businessState.businesses.first.name
                      : '${businessState.businesses.length} أنشطة متاحة',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BusinessWorkspacePage(
                          businesses: businessState.businesses,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          if (businessState.hasFailure) ...[
            const SizedBox(height: 16),
            _AccountSection(
              title: 'مساحة الأعمال',
              children: [
                _AccountOptionTile(
                  icon: Icons.refresh_rounded,
                  title: 'تعذر تحميل الأنشطة',
                  subtitle:
                      businessState.errorMessage ?? 'اضغط لإعادة المحاولة',
                  onTap: () {
                    ref.read(businessControllerProvider).loadBusinesses();
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _AccountSection(
            title: 'الإعدادات',
            children: [
              _AccountOptionTile(
                icon: Icons.notifications_none_rounded,
                title: 'الإشعارات',
                subtitle: 'إدارة تنبيهات المنتجات والطلبات',
                onTap: () => _showComingSoon(context, 'إعدادات الإشعارات'),
              ),
              _AccountOptionTile(
                icon: Icons.settings_outlined,
                title: 'إعدادات التطبيق',
                subtitle: 'إدارة تفضيلات الحساب والتطبيق',
                onTap: () => _executeOrNotify(
                  context,
                  onOpenSettings,
                  'إعدادات التطبيق',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AccountSection(
            title: 'المساعدة والدعم',
            children: [
              _AccountOptionTile(
                icon: Icons.help_outline_rounded,
                title: 'مركز المساعدة',
                subtitle: 'الأسئلة الشائعة وطريقة استخدام التطبيق',
                onTap: () => _showComingSoon(context, 'مركز المساعدة'),
              ),
              _AccountOptionTile(
                icon: Icons.support_agent_outlined,
                title: 'تواصل معنا',
                subtitle: 'إرسال استفسار أو الإبلاغ عن مشكلة',
                onTap: () => _showComingSoon(context, 'التواصل مع الدعم'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LogoutButton(
            onPressed: () =>
                _executeOrNotify(context, onLogout, 'تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  /// ينفذ الإجراء إن كان مرتبطًا، وإلا يعرض رسالة مؤقتة.
  void _executeOrNotify(
    BuildContext context,
    VoidCallback? action,
    String featureName,
  ) {
    if (action != null) {
      action();
      return;
    }

    _showComingSoon(context, featureName);
  }

  /// يعرض تنبيهًا بأن الميزة ستعمل بعد ربط خدمات الحساب.
  void _showComingSoon(BuildContext context, String featureName) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$featureName ستتوفر بعد ربط الحساب بالـ API'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// بطاقة ملخص بيانات المستخدم.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.displayName,
    required this.businessName,
    required this.accountType,
    required this.onEdit,
  });

  final String displayName;
  final String businessName;
  final AccountType accountType;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _AccountTypeBadge(accountType: accountType),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تعديل البيانات',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// شارة توضح نوع حساب المستخدم.
class _AccountTypeBadge extends StatelessWidget {
  const _AccountTypeBadge({required this.accountType});

  final AccountType accountType;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(accountType.icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              accountType.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة تجمع مجموعة مترابطة من خيارات الحساب.
/// بطاقة تجمع مجموعة مترابطة من خيارات الحساب.
///
/// نستخدم Material بدل Container حتى تظهر تأثيرات الضغط
/// الخاصة بعناصر ListTile بصورة صحيحة.
class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.children});

  /// عنوان القسم.
  final String title;

  /// الخيارات المعروضة داخل القسم.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      // لون خلفية البطاقة.
      color: AppColors.surface,

      // شكل البطاقة وحدودها.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),

      // يمنع تأثير الضغط من الخروج عن الزوايا الدائرية.
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // إضافة الخيارات مع فواصل بينها.
          ..._withDividers(children),
        ],
      ),
    );
  }

  /// يضيف فاصلًا بين الخيارات دون إضافته بعد آخر عنصر.
  List<Widget> _withDividers(List<Widget> items) {
    return [
      for (int index = 0; index < items.length; index++) ...[
        items[index],
        if (index < items.length - 1)
          const Divider(height: 1, indent: 58, color: AppColors.border),
      ],
    ];
  }
}

/// خيار واحد داخل أقسام صفحة الحساب.
class _AccountOptionTile extends StatelessWidget {
  const _AccountOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 21, color: AppColors.textPrimary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: showArrow
          ? const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textHint,
            )
          : null,
    );
  }
}

/// زر تسجيل الخروج.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('تسجيل الخروج'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
