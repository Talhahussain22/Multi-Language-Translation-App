import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter/material.dart';

class FlashCardWidget extends StatefulWidget {
  String frontText;
  String backText;
  String fromLanguage;
  String toLanguage;

  FlashCardWidget({super.key, required this.frontText, required this.backText,required this.fromLanguage,required this.toLanguage});

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  FlipCardController controller = FlipCardController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        controller.flipcard();
      },
      child: FlipCard(
        frontWidget: _buildCard(widget.frontText, true,widget.fromLanguage,widget.toLanguage),
        backWidget: _buildCard(widget.backText, false,widget.fromLanguage,widget.toLanguage),
        controller: controller,
        rotateSide: RotateSide.left,
        axis: FlipAxis.vertical,
      ),
    );
  }

  Widget _buildCard(String text,bool isfront,String fromLanguage,String toLanguage) {
    return Container(
      width: 200,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
        gradient: isfront?LinearGradient(
          colors: [
            Color.fromRGBO(10, 25, 49, 1.0),    // Very dark blue
            Color.fromRGBO(25, 118, 210, 1.0),  // Blue 700
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ):LinearGradient(
          colors: [
            Color.fromRGBO(124, 77, 255, 1.0), // Deep Purple A400
            Color.fromRGBO(68, 138, 255, 1.0), // Blue A200
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        )
      ),
      child: isfront?Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text('Translated Language[${toLanguage}]',style: TextStyle(fontSize: 15,color: Colors.white70),)
        ],
      )
    :Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 20,color: Colors.white),
    ));
  }
}
