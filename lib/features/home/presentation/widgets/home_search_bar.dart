import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.onFilterPressed,
    this.onVoicePressed,
  });

  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onVoicePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),

      height: 58,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),

            blurRadius: 20,

            spreadRadius: 1,

            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),


      child: Row(
        children: [

          Expanded(
            child: TextField(

              onChanged: onChanged,

              textDirection: TextDirection.rtl,

              textAlign: TextAlign.right,


              decoration: InputDecoration(

                hintText: 'ابحث عن منتج أو شركة...',

                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),


                prefixIcon: const Icon(
                  Icons.search,
                  size: 25,
                ),


                border: InputBorder.none,


                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 10,
                ),
              ),
            ),
          ),


          const SizedBox(
            width: 4,
          ),


          IconButton(
            tooltip: 'بحث صوتي',

            onPressed: onVoicePressed,

            icon: Icon(
              Icons.mic_none,
              color: Colors.grey.shade700,
            ),
          ),



          Container(

            height: 42,

            width: 42,


            decoration: BoxDecoration(

              color: Colors.red,

              borderRadius: BorderRadius.circular(14),

              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.25),

                  blurRadius: 10,

                  offset: const Offset(0, 5),
                ),
              ],
            ),


            child: IconButton(

              padding: EdgeInsets.zero,

              onPressed: onFilterPressed,


              icon: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),


          const SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }
}