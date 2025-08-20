import 'package:flutter/material.dart';

class Customtextfield_Homepage extends StatelessWidget {
  final TextEditingController controller;
  String hintext;
  bool? isreadOnly;
  Function(String)? onChanged;
  Customtextfield_Homepage({super.key,required this.controller,required this.hintext,this.isreadOnly,this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: controller,
      readOnly: isreadOnly??false,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hintext,
        hintStyle: TextStyle(color: Colors.black38),
        border: OutlineInputBorder(
          borderSide: BorderSide.none
        )
      ),
    );
  }
}
