import 'package:ai_text_to_speech/screen/FavouritePage.dart';
import 'package:ai_text_to_speech/screen/HistoryPage.dart';
import 'package:ai_text_to_speech/screen/Homepage.dart';
import 'package:ai_text_to_speech/screen/Summary.dart';
import 'package:ai_text_to_speech/screen/TestPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 2;

  final List<IconData> icons = [
    Icons.psychology,
    Icons.summarize,
    Icons.translate,
    Icons.favorite_border,
    Icons.history, // History


  ];

  final List<String> labels = [
    "Test",
    "Summary",
    "",
    "Favourite",
    "History",

  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    // You can navigate or do something here
  }
  List<Widget> pages=[TestPage(),SummaryPage(),HomePage(),Favouritepage(),HistoryPage(),];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12))

            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(pages.length, (index) {
                bool isCenter = index == 2;
                return GestureDetector(
                  onTap: () => onItemTapped(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: isCenter
                            ? BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color.fromRGBO(0, 91, 192, 1),
                            Color.fromRGBO(0, 51, 102, 1)
                          ]),
                          shape: BoxShape.circle,
                        )
                            : null,
                        padding: EdgeInsets.all(isCenter ? 12 : 0),
                        child: Icon(
                          icons[index],
                          color: isCenter
                              ? Colors.white
                              : (index == selectedIndex ? Colors.deepOrange: Colors.black),
                          size: isCenter ? 28 : 24,
                        ),
                      ),
                      if (!isCenter)
                        SizedBox(height: 5),
                      if (!isCenter)
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: index == selectedIndex ? Colors.deepOrange : Colors.black,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}