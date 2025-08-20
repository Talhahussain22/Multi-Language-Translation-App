import 'dart:async';

import 'package:ai_text_to_speech/screen/Dashboard.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Timer(Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard()));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Text('LangRush',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w800,color: Color.fromRGBO(
                  148, 28, 28, 1.0)),),
            ),
            SizedBox(height: 300,width:300,child: Image.asset('assets/booklogo.png',fit: BoxFit.fill,)),
            
          ],
        ),
      ),
    );
  }
}
