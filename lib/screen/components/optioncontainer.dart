import 'package:flutter/material.dart';

class OptionsContainer extends StatelessWidget {
  Color color;
  String text;
  OptionsContainer({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical:20 ),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color
      ),
      child: Center(child: Text(text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
    ),
    );
  }
}
