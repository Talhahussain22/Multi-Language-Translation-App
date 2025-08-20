import 'package:ai_text_to_speech/bloc/on_history_delete/on_history_delete_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {


  @override
  void initState() {
    context.read<OnHistoryDeleteBloc>().add(OnHistoryLoaded());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Translation History',
          style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            color: Colors.black,
            elevation: 7, // Shadow depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
              // Border
            ),

            constraints: BoxConstraints(maxHeight: 50),


            onSelected: (value) {
              if(value=='clear')
              {
                context.read<OnHistoryDeleteBloc>().add(OnHistoryClearButtonPress());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear',
                textStyle: TextStyle(color: Colors.red),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,color: Colors.red,),
                      SizedBox(width: 5),
                      Text('Clear History',style: TextStyle(color: Colors.red),),
                    ],
                  ),
                ),

              ),

            ],
            icon: Icon(Icons.more_vert,color: Colors.white,),
            // or use Icons.menu
          ),
        ],
      ),
      body: BlocBuilder<OnHistoryDeleteBloc,OnHistoryDeleteState>(
        builder: (context,state) {
          if(state is OnHistoryLoadedState)
            {
              final words=state.history;
              
              return words.isEmpty?Center(child: Image.asset('assets/data_unavailiable.png')):SingleChildScrollView(child: ListView.builder(shrinkWrap: true,physics: NeverScrollableScrollPhysics(),itemCount: words.length,itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    elevation: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                      Color.fromRGBO(10, 25, 49, 1.0),    // Very dark blue
                      Color.fromRGBO(25, 118, 210, 1.0),  // Blue 700
                      ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    ),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${words[index].fromLanguage}→${words[index].toLanguage}',style: TextStyle(color: Colors.white),),
                        PopupMenuButton<String>(
                          color: Colors.black,
                          elevation: 7, // Shadow depth
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                           // Border
                          ),

                         constraints: BoxConstraints(maxHeight: 50),


                          onSelected: (value) {
                            if(value=='delete')
                            {
                              context.read<OnHistoryDeleteBloc>().add(OnHistoryDeleteButtonPress(index: index));
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'delete',
                              textStyle: TextStyle(color: Colors.red),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outlined,color: Colors.red,),
                                    Text('Delete',style: TextStyle(color: Colors.red),),
                                  ],
                                ),
                              ),

                            ),

                          ],
                          icon: Icon(Icons.more_vert,color: Colors.white,),
                          // or use Icons.menu
                        ),

                            ],
                          ),
                          SizedBox(height: 5),
                          Text(words[index].word,style: TextStyle(overflow: TextOverflow.ellipsis,color: Colors.white,fontWeight: FontWeight.bold),maxLines: 2,),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            child: Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:Color.fromRGBO(230, 238, 245, 1.0)
                              ),
                              child: Text('[${words[index].toLanguage}] ${words[index].translation}',style: TextStyle(overflow: TextOverflow.ellipsis,),maxLines: 2,textDirection: TextDirection.rtl,),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }));
            }
          else
            {
              return Center(child: CircularProgressIndicator(),);
            }


        }
      ),
    );
  }
}
