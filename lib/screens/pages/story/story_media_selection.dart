import 'dart:convert';
import 'dart:developer';

import 'package:FashionTime/screens/pages/story/post_story.dart';
import 'package:FashionTime/screens/pages/story/stories.dart';
import 'package:FashionTime/screens/pages/story/text_story.dart';
import 'package:FashionTime/screens/pages/story/upload_story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/constants.dart';

class StoryMediaScreen extends StatefulWidget {
  const StoryMediaScreen({super.key});

  @override
  State<StoryMediaScreen> createState() => _StoryMediaScreenState();
}

String token = '';
String id = '';
int pageNumber = 1;
String username = '';
List<Map<String, dynamic>> users = [];
bool loading = true;

class _StoryMediaScreenState extends State<StoryMediaScreen> {
  getCachedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    username = preferences.getString('username')!;
  }



  @override
  void initState() {
    // TODO: implement initState
    getCachedData();
    super.initState();
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
          "Share Story ",
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: InkWell(onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TextStoryScreen(),));
                },child: Image.asset("assets/Font.png",height: 80,))),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     height: 37,
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(15.0),
            //         gradient: LinearGradient(
            //             begin: Alignment.topLeft,
            //             end: Alignment.topRight,
            //             stops: const [0.0, 0.99],
            //             tileMode: TileMode.clamp,
            //             colors: <Color>[
            //               secondary,
            //               primary,
            //             ])),
            //     child: ElevatedButton(
            //         style: ButtonStyle(
            //             shape: MaterialStateProperty.all<
            //                 RoundedRectangleBorder>(RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12.0),
            //             )),
            //             backgroundColor:
            //             MaterialStateProperty.all(Colors.transparent),
            //             shadowColor:
            //             MaterialStateProperty.all(Colors.transparent),
            //             padding: MaterialStateProperty.all(EdgeInsets.only(
            //                 top: 8,
            //                 bottom: 8,
            //                 left: MediaQuery.of(context).size.width * 0.28,
            //                 right:
            //                 MediaQuery.of(context).size.width * 0.29)),
            //             textStyle: MaterialStateProperty.all(
            //                 const TextStyle(
            //                     fontSize: 14,
            //                     color: Colors.white,
            //                     fontFamily: 'Montserrat'))),
            //         onPressed: () {
            //           Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateStoryScreen(),));
            //         },
            //         child: const Text(
            //           'Media',
            //           style: TextStyle(
            //               fontSize: 17,
            //               fontWeight: FontWeight.w700,
            //               fontFamily: 'Montserrat'),
            //         )),
            //   ),
            // ),
            SizedBox(width: MediaQuery.of(context).size.width*0.1,),
            Container(
                height: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: InkWell(onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateStoryScreen(),));
                },child: Image.asset("assets/Video Icon.png",height: 80,)))
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     height: 37,
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(15.0),
            //         gradient: LinearGradient(
            //             begin: Alignment.topLeft,
            //             end: Alignment.topRight,
            //             stops: const [0.0, 0.99],
            //             tileMode: TileMode.clamp,
            //             colors: <Color>[
            //               secondary,
            //               primary,
            //             ])),
            //     child: ElevatedButton(
            //         style: ButtonStyle(
            //             shape: MaterialStateProperty.all<
            //                 RoundedRectangleBorder>(RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12.0),
            //             )),
            //             backgroundColor:
            //             MaterialStateProperty.all(Colors.transparent),
            //             shadowColor:
            //             MaterialStateProperty.all(Colors.transparent),
            //             padding: MaterialStateProperty.all(EdgeInsets.only(
            //                 top: 8,
            //                 bottom: 8,
            //                 left: MediaQuery.of(context).size.width * 0.26,
            //                 right:
            //                 MediaQuery.of(context).size.width * 0.26)),
            //             textStyle: MaterialStateProperty.all(
            //                 const TextStyle(
            //                     fontSize: 14,
            //                     color: Colors.white,
            //                     fontFamily: 'Montserrat'))),
            //         onPressed: () {
            //           Navigator.push(context, MaterialPageRoute(builder: (context) => const TextStoryScreen(),));
            //         },
            //         child: const Text(
            //           'Text only',
            //           style: TextStyle(
            //               fontSize: 17,
            //               fontWeight: FontWeight.w700,
            //               fontFamily: 'Montserrat'),
            //         )),
            //   ),
            // ),
          ],
        ),
      )
    );
  }
}
