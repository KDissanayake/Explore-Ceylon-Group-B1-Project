import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchBarComponent extends StatelessWidget {
  const SearchBarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 20,
          spreadRadius: 0.1,
        )
      ]),
      child: TextField(
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(top: 5, left: 30, right: 30, bottom: 5),
            filled: true,
            fillColor: Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
            hintText: "Search here",
            hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.2),
                fontWeight: FontWeight.w100),

            //padding the search icon
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/icons/bx-search.svg',
              ),
            ),
            suffixIcon: Container(
              width: 50,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VerticalDivider(
                      color: Colors.black.withOpacity(0.2),
                      indent: 5,
                      endIndent: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SvgPicture.asset(
                        'assets/icons/more.svg',
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.srcATop),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none)),
      ),
    );
  }
}
