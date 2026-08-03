import 'package:flutter/material.dart';
import 'package:talbatiyk/features/home/presentation/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: const [
            SliverToBoxAdapter(child: HomeSearchBar()),
            SliverToBoxAdapter(child: BannerSlider()),
            SliverToBoxAdapter(child: CategoriesSection()),
            SliverToBoxAdapter(child: FeaturedProductsSection()),
            SliverToBoxAdapter(child: LatestProductsSection()),
            SliverToBoxAdapter(child: CartSummary()),
            SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
