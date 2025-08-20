import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  List<String> items;
  dynamic Function(String?) onChanged;
  String? selectedValue;
  Color color;
  Color dropdowniconcolor;
  Color textcolor;
  Color dropdownColor;
  CustomDropDown({super.key, required this.items, required this.onChanged,required this.selectedValue,required this.color,required this.dropdowniconcolor,required this.textcolor,required this.dropdownColor});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items:
          items
              .map(
                (String item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(10),
      padding: EdgeInsets.symmetric(horizontal: 10),

      decoration: InputDecoration(
        filled: true,
        fillColor: color,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black26),

        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color:Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black26, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: Icon(Icons.arrow_drop_down, color: dropdowniconcolor),

      style: TextStyle(color: textcolor, fontSize: 16),
      dropdownColor: dropdownColor,


    );
  }
}
