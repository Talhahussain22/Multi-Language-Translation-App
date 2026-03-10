import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintext;
  final TextInputType? type;
  const CustomTextField({super.key, required this.controller, required this.hintext, this.type});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hintext,
        hintStyle: TextStyle(color: Colors.black12,fontSize: 14,letterSpacing: 0,wordSpacing: 1),
        filled: true,
        fillColor:Colors.white54 ,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black26 )
        ),
        focusedBorder:OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black54 )
        ),
      ),
    );
  }
}
