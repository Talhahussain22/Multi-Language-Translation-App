import 'package:ai_text_to_speech/screen/FavouriteWordTestScreen.dart';
import 'package:ai_text_to_speech/screen/GeneralTestScreen.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});
  
  int count=10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Vocabulary Test',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This page will ask about genral test or test from favourite etc
              // Next page for general mcqs with contain below things
              // 4 drop down (from language to language difficulty level and count of mcqs
              // final Start Quiz Button
              Center(child: Image.asset('assets/brain2.png',height: 150,)),
              Center(child: Text('Ready to challenge your brain?',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 0,color: Colors.grey.shade800),)),
              const SizedBox(height: 20),
              Text('Vocabulary Tests',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,letterSpacing: -0.5,color: Colors.grey.shade800),),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text('Practise your language skills with test based on your favourite words and general vocabulary.',style: TextStyle(letterSpacing: -0.5,color: Colors.grey.shade800),),
              ),
              const SizedBox(height: 20),
              Text('Available Tests',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,letterSpacing: 0,color: Colors.grey.shade800),),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FavouriteWordTestScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration:BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color.fromRGBO(10, 25, 49, 1.0),    // Very dark blue
                            Color.fromRGBO(25, 118, 210, 1.0),
                          ]),
                          borderRadius: BorderRadius.circular(10)
                        ) ,
                        child: Icon(Icons.menu_book,color: Colors.white,),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Favourite Words',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,letterSpacing: 0),),
                          Text('Reflective Learning',style: TextStyle(color: Colors.grey.shade800,letterSpacing: 0),)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GeneralTestScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration:BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color.fromRGBO(10, 25, 49, 1.0),    // Very dark blue
                            Color.fromRGBO(25, 118, 210, 1.0),
                          ]),
                          borderRadius: BorderRadius.circular(10)
                        ) ,
                        child: Icon(Icons.article,color: Colors.white,),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('General Words',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,letterSpacing: 0),),
                          Text('Vocabulary Booster',style: TextStyle(color: Colors.grey.shade800,letterSpacing: 0),)
                        ],
                      ),
                    ],
                  ),
                ),
              )
          
          
          
            ],
          ),
        ),
      ),
    );
  }
}
