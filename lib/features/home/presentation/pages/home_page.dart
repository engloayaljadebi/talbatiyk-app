import 'package:flutter/material.dart';
import 'package:talbatiyk/features/home/presentation/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const HomeAppBar(),

      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: const [

            SliverToBoxAdapter(
              child: HomeSearchBar(),
            ),

            SliverToBoxAdapter(
              child: BannerSlider(),
            ),

            SliverToBoxAdapter(
              child: CategoriesSection(),
            ),

            SliverToBoxAdapter(
              child: FeaturedProductsSection(),
            ),

            SliverToBoxAdapter(
              child: LatestProductsSection(),
            ),

            SliverToBoxAdapter(
              child: CartSummary(),
            ),

            SliverPadding(
              padding: EdgeInsets.only(bottom: 24),
            ),

          ],
        ),
      ),
    );
  }
}