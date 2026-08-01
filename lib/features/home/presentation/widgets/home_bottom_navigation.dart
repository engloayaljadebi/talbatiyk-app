import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;


  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Container(

        margin: const EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: 20,
        ),


        height: 70,


        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18),


          boxShadow: [

            BoxShadow(

              color:
              Colors.black.withOpacity(.08),

              blurRadius: 15,

              offset:
              const Offset(0, 5),

            ),

          ],

        ),


        child: ClipRRect(

          borderRadius:
          BorderRadius.circular(18),


          child: NavigationBar(

            selectedIndex: currentIndex,

            onDestinationSelected: onTap,


            backgroundColor:
            Colors.white,


            elevation: 0,


            height: 70,


            indicatorColor:
            AppColors.primary.withOpacity(.12),



            labelBehavior:
            NavigationDestinationLabelBehavior
                .alwaysShow,


            destinations: const [

              NavigationDestination(

                icon:
                Icon(Icons.home_outlined),

                selectedIcon:
                Icon(Icons.home_rounded),

                label: 'الرئيسية',

              ),


              NavigationDestination(

                icon:
                Icon(Icons.inventory_2_outlined),

                selectedIcon:
                Icon(Icons.inventory_2_rounded),

                label: 'المنتجات',

              ),


              NavigationDestination(

                icon:
                Icon(Icons.shopping_cart_outlined),

                selectedIcon:
                Icon(Icons.shopping_cart_rounded),

                label: 'السلة',

              ),


              NavigationDestination(

                icon:
                Icon(Icons.receipt_long_outlined),

                selectedIcon:
                Icon(Icons.receipt_long_rounded),

                label: 'الطلبات',

              ),


              NavigationDestination(

                icon:
                Icon(Icons.person_outline),

                selectedIcon:
                Icon(Icons.person_rounded),

                label: 'الحساب',

              ),

            ],
          ),
        ),
      ),
    );
  }
}