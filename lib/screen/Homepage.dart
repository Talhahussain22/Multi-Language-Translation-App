import 'package:ai_text_to_speech/bloc/on_favourite/on_favourite_bloc.dart';
import 'package:ai_text_to_speech/bloc/on_translate/on_translate_bloc.dart';
import 'package:ai_text_to_speech/data/languagedata.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/model/saved_language.dart';
import 'package:ai_text_to_speech/screen/components/CustomTextFeild.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IconData icon=Icons.favorite_border;
  Map<String, String>? fromselectedLanguage;
  Map<String, String>? toselectedLanguage;
  final TextEditingController tofeildcontroller = TextEditingController();
  final TextEditingController fromfeildcontroller = TextEditingController();
  String? fromLanguage;
  String? toLanguage;


  void setLanguages()
  {
    final hivebox=Hive.box<SavedLanguage>('saved_lang');
    fromLanguage=hivebox.get('from')?.fromLanguage?['label']??LanguageProvider.LANGUAGES.first['label'];
    fromselectedLanguage=LanguageProvider.LANGUAGES.firstWhere((item)=>item['label']==fromLanguage);

    toLanguage=hivebox.get('to')?.toLanguage?['label']??LanguageProvider.LANGUAGES[20]['label'];
    toselectedLanguage=LanguageProvider.LANGUAGES.firstWhere((item)=>item['label']==toLanguage);

  }

  @override
  void initState() {
    setLanguages();
    super.initState();
  }

  @override
  void dispose() {
    fromfeildcontroller.dispose();
    tofeildcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Language Translator',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<OnTranslateBloc, OnTranslateState>(
        listener: (context, state) {

          if (state is OnTranslateFailureState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is OnTranslateSuccessState) {
            tofeildcontroller.text = state.data;
            setState(() {

              icon=state.isfavourite!?Icons.favorite:Icons.favorite_outline;
            });

          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is OnTranslateLoadingState,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          height: 50,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(103, 80, 164, 0.05),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [BoxShadow(color: Colors.grey.shade100)],
                          ),
                          foregroundDecoration: BoxDecoration(
                            color: Color(0x0D6750A4),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: DropdownButton<Map<String, String>>(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    underline: Container(),
                                    isExpanded: true,
                                    value: fromselectedLanguage,
                                    items:
                                    LanguageProvider.LANGUAGES
                                        .map(
                                          (
                                          Map<String, String> each,
                                          ) => DropdownMenuItem<
                                          Map<String, String>
                                      >(
                                        value: each,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${each['flag']} ${each['label']} ",
                                                style: TextStyle(
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                ),

                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: (Map<String, String>? val) {
                                      setState(() {
                                        final hivebox=Hive.box<SavedLanguage>('saved_lang');
                                        final SavedLanguage obj=SavedLanguage(fromLanguage: val!);
                                        hivebox.put('from',obj);
                                        setLanguages();
                                      });
                                    },
                                    icon: SizedBox(),
                                    menuWidth: 250,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      final hivebox=Hive.box<SavedLanguage>('saved_lang');
                                      final SavedLanguage fromobj=SavedLanguage(fromLanguage: toselectedLanguage);
                                      final SavedLanguage toobj=SavedLanguage(toLanguage: fromselectedLanguage);

                                      hivebox.put('from', fromobj);
                                      hivebox.put('to', toobj);
                                      tofeildcontroller.text = '';
                                      fromfeildcontroller.text = '';
                                      setLanguages();
                                    });
                                  },
                                  icon: Icon(
                                    CupertinoIcons.arrow_right_arrow_left,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),

                                Expanded(
                                  child: DropdownButton<Map<String, String>>(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    underline: Container(),
                                    isExpanded: true,
                                    value: toselectedLanguage,
                                    items:
                                        LanguageProvider.LANGUAGES
                                            .map(
                                              (
                                                Map<String, String> each,
                                              ) => DropdownMenuItem<
                                                Map<String, String>
                                              >(
                                                value: each,
                                                child: Row(

                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "${each['flag']} ${each['label']} ",
                                                        style: TextStyle(
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),

                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (Map<String, String>? val) {
                                      setState(() {
                                        final hivebox=Hive.box<SavedLanguage>('saved_lang');
                                        final SavedLanguage obj=SavedLanguage(toLanguage: val!);
                                        hivebox.put('to',obj);
                                        setLanguages();
                                      });
                                    },
                                    icon: SizedBox(),
                                    menuWidth: 250,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(103, 80, 164, 0.05),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.grey.shade100)],
                        ),
                        foregroundDecoration: BoxDecoration(
                          color: Color(0x0D6750A4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fromLanguage!,
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 51, 102, 1),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      fromfeildcontroller.text = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Customtextfield_Homepage(
                              controller: fromfeildcontroller,
                              hintext: 'Enter to Translate',
                              onChanged:tofeildcontroller.text.isEmpty?null: (_){
                                tofeildcontroller.text='';
                              },

                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    context.read<OnTranslateBloc>().add(
                                      OnTranslateButtonClicked(
                                        text:
                                            fromfeildcontroller.text
                                                .toString(),
                                        fromLanguage: fromLanguage!,
                                        toLanguage: toLanguage!,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 102, 0, 1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      'Translate',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    BlocConsumer<OnFavouriteBloc,OnFavouriteState>(
                      listener: (context,state){
                        if (state is OnFavouriteSuccess) {
                        setState(() {
                        icon = state.isFavourited
                        ? Icons.favorite
                            : Icons.favorite_outline;
                        });
                        }
                      },
                      builder: (context,state) {

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(103, 80, 164, 0.05),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.grey.shade100)],
                            ),
                            foregroundDecoration: BoxDecoration(
                              color: Color(0x0D6750A4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      toLanguage!,
                                      style: TextStyle(
                                        color: Color.fromRGBO(0, 51, 102, 1),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Customtextfield_Homepage(controller: tofeildcontroller, hintext:'',isreadOnly: true,),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: tofeildcontroller.text,
                                            ),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Copied to clipboard'),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy_rounded,
                                          color: Color.fromRGBO(0, 51, 102, 1),
                                          size: 25,
                                        ),
                                      ),
                                      SizedBox(width: 3),
                                      IconButton(
                                        onPressed: () {
                                          if(fromfeildcontroller.text.isEmpty || tofeildcontroller.text.isEmpty)
                                            {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error:Either Word or Translation is Empty')));
                                              return;
                                            }
                                          if(fromfeildcontroller.text.trim().contains(' '))
                                            {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Only words can be add to Favourite(not sentence)')));
                                              return;
                                            }
                                          context.read<OnFavouriteBloc>().add(
                                            OnFavouriteButtonClicked(
                                              favoriteWord: FavoriteWord(
                                                word:
                                                    fromfeildcontroller.text
                                                        .toString(),
                                                translation:
                                                    tofeildcontroller.text.toString(),
                                                fromLanguage: fromLanguage!,
                                                toLanguage: toLanguage!,
                                              ),
                                            ),
                                          );
                                        },
                                        icon:Icon(
                                          icon,
                                          color: Colors.red,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
