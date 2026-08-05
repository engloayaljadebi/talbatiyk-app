import 'package:flutter/material.dart';
import 'package:talbatiyk/features/home/presentation/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onViewProducts});

  final VoidCallback onViewProducts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: HomeSearchBar()),
            const SliverToBoxAdapter(child: BannerSlider()),
            const SliverToBoxAdapter(child: CategoriesSection()),
            SliverToBoxAdapter(
              child: FeaturedProductsSection(onViewAll: onViewProducts),
            ),
            SliverToBoxAdapter(
              child: LatestProductsSection(onViewAll: onViewProducts),
            ),
            const SliverToBoxAdapter(child: CartSummary()),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
