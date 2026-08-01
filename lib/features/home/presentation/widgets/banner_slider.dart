import 'dart:async';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController();

  Timer? _timer;

  int _currentPage = 0;


  late final List<Widget> _banners = [

    _promoBanner(),


    _networkBanner(
      'https://yemenmobile.com.ye/uploads/images/202410/image_753x_67183d0a346a0.webp',
    ),


    _networkBanner(
      'https://yemenmobile.com.ye/uploads/images/202410/image_753x_67183ca456e19.webp',
    ),


    _networkBanner(
      'https://yemenmobile.com.ye/uploads/images/202410/image_753x_67183ce5b77c2.webp',
    ),

  ];



  Widget _promoBanner() {

    return Container(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),


      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),

        color: Colors.red,

      ),


      child: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [


            const Text(

              "أفضل العروض",

              style: TextStyle(

                color: Colors.white,

                fontSize: 24,

                fontWeight: FontWeight.bold,

              ),

            ),



            const SizedBox(

              height: 10,

            ),



            const Text(

              "منتجات أصلية بأسعار منافسة",

              style: TextStyle(

                color: Colors.white,

              ),

            ),



            const Spacer(),



            ElevatedButton(

              onPressed: () {},

              child: const Text(

                "تسوق الآن",

              ),

            ),


          ],

        ),

      ),

    );

  }




  Widget _networkBanner(String imageUrl) {


    return Container(

      margin: const EdgeInsets.symmetric(

        horizontal: 16,

      ),


      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),

        color: Colors.grey.shade100,

      ),


      child: ClipRRect(

        borderRadius: BorderRadius.circular(20),


        child: Image.network(

          imageUrl,


          width: double.infinity,

          height: 170,


          fit: BoxFit.contain,



          loadingBuilder: (
              context,
              child,
              loadingProgress,
              ) {


            if (loadingProgress == null) {

              return child;

            }


            return const Center(

              child: CircularProgressIndicator(),

            );


          },



          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {


            return const Center(

              child: Icon(

                Icons.image_not_supported,

                size: 40,

              ),

            );


          },


        ),

      ),

    );


  }




  @override
  void initState() {

    super.initState();


    _timer = Timer.periodic(

      const Duration(seconds: 4),


          (timer) {


        if (!_controller.hasClients) return;



        _currentPage++;



        if (_currentPage >= _banners.length) {

          _currentPage = 0;

        }



        _controller.animateToPage(

          _currentPage,


          duration: const Duration(

            milliseconds: 450,

          ),


          curve: Curves.easeInOut,


        );


      },


    );


  }





  @override
  void dispose() {


    _timer?.cancel();


    _controller.dispose();


    super.dispose();

  }





  @override
  Widget build(BuildContext context) {


    return SizedBox(


      height: 170,


      child: PageView.builder(


        controller: _controller,


        itemCount: _banners.length,



        itemBuilder: (context, index) {


          return _banners[index];


        },


      ),


    );


  }

}