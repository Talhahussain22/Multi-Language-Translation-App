import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TestResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalScore;
  const TestResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    final totalpercentage = ((correctAnswers / totalScore) * 100).round();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Test Result',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Container(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            totalpercentage >= 80
                ? Stack(
              alignment: Alignment.center,
                  children: [
                    Text('Congratulations',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                    Lottie.asset(
                      'assets/animations/congratulations.json',
                      height: 300,
                    ),
                  ],
                )
                : totalpercentage >= 50
                ? Lottie.asset('assets/animations/medium.json', height: 300)
                : Lottie.asset('assets/animations/low.json', height: 300),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              width: double.maxFinite,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromRGBO(0, 51, 102, 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${((correctAnswers / totalScore) * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Divider(height: 3, thickness: 1, color: Colors.black38),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Correct', style: TextStyle(color: Colors.black54)),
                SizedBox(width: 40),
                Text(
                  '$correctAnswers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 3, thickness: 1, color: Colors.black38),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Incorrect',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 30),
                Text(
                  '${totalScore - correctAnswers}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, right: 5),
        child: GestureDetector(
          onTap: () async {
            Navigator.pop(context);
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
                'Back to Homepage',
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
