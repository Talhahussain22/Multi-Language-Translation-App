
import 'package:ai_text_to_speech/data/languagedata.dart';
import 'package:ai_text_to_speech/screen/GeneralWordQuizScreen.dart';
import 'package:ai_text_to_speech/screen/components/CustomDropDown.dart';
import 'package:flutter/material.dart';

class GeneralTestScreen extends StatefulWidget {
  const GeneralTestScreen({super.key});

  @override
  State<GeneralTestScreen> createState() => _GeneralTestScreenState();
}

class _GeneralTestScreenState extends State<GeneralTestScreen> {
  List<String> items = [];
  late String selectedfromLanguage;
  late String selectedtoLanguage;
  String selecteddifficultyLevel = 'Easy';
  String selectedMcqsCount = '10';
  List<String> difficultyLevel = ['Easy', 'Low Medium', 'Medium', 'High'];
  List<String> mcqsCount = ['10', '20', '30', '40', '50'];

  @override
  void initState() {
    items =
        LanguageProvider.LANGUAGES.map((item) => item['label'] ?? '').toList();
    selectedfromLanguage = items.first;
    selectedtoLanguage = items[20];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'General Words',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              'From Language',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0,
              ),
            ),
            CustomDropDown(
              color: Color.fromRGBO(0, 51, 102, 1),
              dropdowniconcolor: Colors.white,
              textcolor: Colors.white,
              dropdownColor: Color(0xFF2C2C3C),
              items: items,
              onChanged: (String? val) {
                setState(() {
                  selectedfromLanguage = val!;
                });
              },
              selectedValue: selectedfromLanguage,
            ),
            const SizedBox(height: 15),
            Text(
              'To Language',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0,
              ),
            ),
            CustomDropDown(
              color: Color.fromRGBO(0, 51, 102, 1),
              dropdowniconcolor: Colors.white,
              textcolor: Colors.white,
              dropdownColor: Color(0xFF2C2C3C),

              items: items,
              onChanged: (String? val) {
                setState(() {
                  selectedtoLanguage = val!;
                });
              },
              selectedValue: selectedtoLanguage,
            ),
            const SizedBox(height: 15),
            Text(
              'Difficulty Level',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0,
              ),
            ),
            CustomDropDown(
              color: Color.fromRGBO(0, 51, 102, 1),
              dropdowniconcolor: Colors.white,
              textcolor: Colors.white,
              dropdownColor: Color(0xFF2C2C3C),

              items: difficultyLevel,
              onChanged: (String? val) {
                setState(() {
                  selecteddifficultyLevel = val!;
                });
              },
              selectedValue: selecteddifficultyLevel,
            ),
            const SizedBox(height: 15),
            Text(
              'Number of Quiz',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0,
              ),
            ),
            CustomDropDown(
              color: Color.fromRGBO(0, 51, 102, 1),
              dropdowniconcolor: Colors.white,
              textcolor: Colors.white,
              dropdownColor: Color(0xFF2C2C3C),
              items: mcqsCount,
              onChanged: (String? val) {
                setState(() {
                  selectedMcqsCount = val!;
                });
              },
              selectedValue: selectedMcqsCount,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, right: 5),
        child: GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => GeneralWordQuizScreen(
                      selectedfromLanguage: selectedfromLanguage,
                      selectedtoLanguage: selectedtoLanguage,
                      selecteddifficultyLevel: selecteddifficultyLevel,
                      selectedMcqsCount: selectedMcqsCount,
                    ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 51, 102, 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                'Start Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
