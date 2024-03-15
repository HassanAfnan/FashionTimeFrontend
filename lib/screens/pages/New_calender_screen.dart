import 'dart:convert';

import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/models/fashion_week_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as https;
import '../../utils/constants.dart';
class AllFashionWeeks extends StatefulWidget {
  const AllFashionWeeks({super.key});

  @override
  State<AllFashionWeeks> createState() => _AllFashionWeeksState();
}
List<FashionEvent> events = [];
getAllEvents(){
  const String url='$serverUrl/fashionEvents/';
  try{
    https.get(Uri.parse(url) ).then((value) {
      debugPrint("the body of response is=========> ${value.body}");
      List<dynamic> eventData = json.decode(value.body);
      List<FashionEvent> eventsList = eventData.map((event) {
        return FashionEvent(
          id: event['id'],
          title: event['title'],
          eventStartDate: event['eventStartDate'],
          eventEndDate: event['eventEndDate'],
        );
      }).toList();
      events=eventsList;
      debugPrint("events length is ${events.length}");

    });


  }
  catch(e){
    debugPrint("error received while getting events");
  }
}



class _AllFashionWeeksState extends State<AllFashionWeeks> {
  @override
  void initState() {

    super.initState();
    getAllEvents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primary,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  stops: const [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        title: const Text('Events',style: TextStyle(
          fontFamily: 'Montserrat',
        ),),
      ),
      body:
          events.isEmpty?
              Text("No events"):
      ListView.builder(
        itemCount: events.length,
        reverse: false,
        itemBuilder:(context, index){
          return WidgetAnimator(Card(
            color: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            child: ListTile(

              title:
              Row(
                children: [
                  Text("Week ${index+1}: ",style:const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat'
                      )),
                  Flexible(
                    child: Text(events[index].title,style:const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat'
                    )),
                  )
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(events[index].eventStartDate,style:const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat'
                  )),
                ],
              ),
            ),
          ));
      },),
    );
  }
}
