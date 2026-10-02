import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key, required this.onExploreProducts});

  final VoidCallback onExploreProducts;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Material(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onExploreProducts,
            child: SizedBox(
              height: 142,
              child: Stack(
                children: [
                  // النص يبدأ من اليمين في الواجهة العربية.
                  PositionedDirectional(
                    start: 18,
                    top: 23,
                    bottom: 18,
                    child: SizedBox(
                      width: 175,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اكتشف المنتجات المتاحة لمتجرك',
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FilledButton(
                              onPressed: onExploreProducts,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 35),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFE53935),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'استكشف المنتجات',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // الشعار يبقى في الجهة المقابلة: اليسار.
                  PositionedDirectional(
                    end: 18,
                    top: 18,
                    bottom: 18,
                    child: Opacity(
                      opacity: 0.96,
                      child: Image.asset(
                        'assets/icon/logo.png',
                        width: 82,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.storefront_outlined,
                          size: 52,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
