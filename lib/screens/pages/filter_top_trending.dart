import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart'as https;
import '../../animations/bottom_animation.dart';
import '../../utils/constants.dart';

class TopTrendingFilterScreen extends StatefulWidget {
  const TopTrendingFilterScreen({super.key});

  @override
  State<TopTrendingFilterScreen> createState() =>
      _TopTrendingFilterScreenState();
}
List<dynamic> responseData = [];
List<String>items=[];

class _TopTrendingFilterScreenState extends State<TopTrendingFilterScreen> {
  getAllEvents() async {
    try {
      final response =
      await https.get(Uri.parse("$serverUrl/fashionEvents/"));
      if (response.statusCode == 200) {
        responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          debugPrint("get all events data $responseData");
          setState(() {
            items =
                responseData.map<String>((event) => event["title"]).toList();
            debugPrint("total events====>${items.length}");
          });


        }
      } else {
        debugPrint("Error in all event api:${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" all events api didn't hit $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllEvents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                    ])),
          ),
          centerTitle: true,
          title: const Text(
            "Filter on trending styles",
            style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
          ),
        ),
        body: Center(
            child: ListView(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          WidgetAnimator(
            Padding(
              padding: const EdgeInsets.only(
                  left: 18.0, right: 18.0, top: 5, bottom: 15),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Select event year",
                    style: TextStyle(
                        color: primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat'),
                  )
                ],
              ),
            ),
          ),
          WidgetAnimator(
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 15,
                ),

              ],
            ),
          ),
              WidgetAnimator(
                Padding(
                  padding: const EdgeInsets.only(
                      left: 18.0, right: 18.0, top: 25, bottom: 18),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Select fashion event",
                        style: TextStyle(
                            color: primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Montserrat'),
                      )
                    ],
                  ),
                ),
              ),
              WidgetAnimator(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DropdownButton<String>(

                      dropdownColor: primary,
                      menuMaxHeight: MediaQuery.of(context).size.width*0.4,
                      borderRadius: BorderRadius.circular(15),

                      style: const TextStyle(fontFamily: 'Montserrat'),
                      items: items.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (_) {},
                    ),
                  )
              ),

        ])));
  }
}
