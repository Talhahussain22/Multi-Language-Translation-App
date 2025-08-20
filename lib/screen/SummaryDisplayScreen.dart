import 'package:ai_text_to_speech/bloc/summary_fetch/summary_fetch_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SummaryDisplayScreen extends StatefulWidget {
  String topic;
  List<String> words;
  String targetLanguage;
  SummaryDisplayScreen({
    super.key,
    required this.topic,
    required this.words,
    required this.targetLanguage,
  });

  @override
  State<SummaryDisplayScreen> createState() => _SummaryDisplayScreenState();
}

class _SummaryDisplayScreenState extends State<SummaryDisplayScreen> {


  @override
  void initState() {

    context.read<SummaryFetchBloc>().add(
      SummaryFetchButtonPressed(
        topic: widget.topic,
        words: widget.words,
        targetLanguage: widget.targetLanguage,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text('Summary', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<SummaryFetchBloc, SummaryFetchState>(
        builder: (context, state) {
          if (state is SummaryFetchLoadingState) {
            return Center(
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    'Generating Summary',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                ],
                pause: Duration(milliseconds: 300),
              ),
            );
          }
          else if (state is SummaryFetchErrorState) {
            Fluttertoast.showToast(
              msg: state.error.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromRGBO(0, 51, 102, 1),
              textColor: Colors.white,
              fontSize: 16.0,
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            });
          }
          else if (state is SummaryFetchLoadedState) {
            final data = state.text;

            if (data != null) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(10, 25, 49, 1.0), // Very dark blue
                            Color.fromRGBO(25, 118, 210, 1.0), // Blue 700
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          data,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }
          return Container();


        },

      ),
    );
  }
}
