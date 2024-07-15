import 'dart:convert';

import 'package:FashionTime/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../models/story_model.dart';
import 'package:http/http.dart' as https;

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  var isViewed;
  StoryScreen({super.key, required this.stories, this.isViewed});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late VideoPlayerController _videoController;
  late int _currentIndex = 0;
  String token = '';
  String id = '';
  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    debugPrint("length========>${widget.stories.length}");
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.stories[0].url))
          ..initialize().then((value) => setState(() {}));
    _videoController.play();
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            debugPrint("All stories viewed. Popping to previous screen.");
            Navigator.pop(context);
          }
        });
      }
    });

    getCashedData();
    super.initState();
  }

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
  }

  viewStory(int storyId) {
    const url = "$serverUrl/apiViewStory/";
    var body = jsonEncode({'user': int.parse(id), 'view': storyId});
    try {
      https
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token"
              },
              body: body)
          .then((value) {
        if (value.statusCode == 201) {
          debugPrint("story viewed by user================>");
        } else {
          debugPrint("error received===========>${value.statusCode}");
        }
      });
    } catch (e) {
      debugPrint("Error received===========>${e.toString()}");
    }
  }
  pinStory(var uploadObject){
    const url = "$serverUrl/apiPinnedStory/";
    var body = jsonEncode({'upload': uploadObject, 'text': "","view_count":3,"viewed_by":3,'user':int.parse(id)});
    try {
      https
          .post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: body)
          .then((value) {
        if (value.statusCode == 201||value.statusCode==200) {
          debugPrint("story ======>${value.body}");
        } else {
          debugPrint("error received===========>${value.statusCode} with error${value.body.toString()}");
        }
      });
    } catch (e) {
      debugPrint("Error received===========>${e.toString()}");
    }

  }
  pinTextStory(var text){
    const url = "$serverUrl/apiPinnedStory/";
    var body = jsonEncode({'upload': {}, 'text': text.toString(),"view_count":3,"viewed_by":3,'user':int.parse(id)
    });
    try {
      https
          .post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: body)
          .then((value) {
        if (value.statusCode == 201||value.statusCode==200) {
          debugPrint("story ======>${value.body}");
        } else {
          debugPrint("error received===========>${value.statusCode} with error${value.body.toString()}");
        }
      });
    } catch (e) {
      debugPrint("Error received===========>${e.toString()}");
    }

  }
  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[_currentIndex];
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: (details) => _onTapDown(details, story),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.stories.length,
                itemBuilder: (context, i) {
                  final Story story = widget.stories[i];
                  debugPrint("is viewed=======>${story.viewedBy}");
                  i == 0 ? null : viewStory(story.storyId);
                  print("All stories viewers "+story.viewed_users.toString());
                  switch (story.media) {
                    case MediaType.image:
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 50, left: 5),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${story.user.name} ${story.duration}",
                                        style: const TextStyle(
                                            color: ascent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: "Montserrat"),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: (){
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (builder){
                                                    return new Container(
                                                      height: 350.0,
                                                      color: Colors.transparent, //could change this to Color(0xFF737373),
                                                      //so you don't have to change MaterialApp canvasColor
                                                      child: new Container(
                                                          height: 350.0,
                                                          width: 400,
                                                          decoration: new BoxDecoration(
                                                            //color: Colors.white,
                                                              borderRadius: new BorderRadius.only(
                                                                  topLeft: const Radius.circular(10.0),
                                                                  topRight: const Radius.circular(10.0))),
                                                          child:story.viewed_users.length <= 0 ? Center(
                                                            child: Text("No Viewers",style: TextStyle(color: Colors.white),),
                                                          ) : StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Padding(
                                                                  padding: const EdgeInsets.all(20.0),
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(height: 20,),
                                                                      Row(
                                                                        children: [
                                                                          Text("${story.viewed_users.length} Viewers",style: TextStyle(color: Colors.white),)
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 20,),
                                                                      Expanded(
                                                                        child: ListView.builder(
                                                                            itemCount: story.viewed_users.length,
                                                                            itemBuilder:(context,index){
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                      height:50,
                                                                                      width: 50,
                                                                                      child: ClipRRect(
                                                                                        borderRadius:
                                                                                        const BorderRadius.all(
                                                                                            Radius.circular(120)),
                                                                                        child: CachedNetworkImage(
                                                                                          imageUrl: (
                                                                                              story.viewed_users[index] == null ||
                                                                                                  story.viewed_users[index]["user"] == null ||
                                                                                                  story.viewed_users[index]["user"]["pic"] == null
                                                                                          ) ?
                                                                                          "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w":
                                                                                          story.viewed_users[index]["user"]["pic"],
                                                                                          imageBuilder:
                                                                                              (context, imageProvider) =>
                                                                                              Container(
                                                                                                height: MediaQuery.of(context)
                                                                                                    .size
                                                                                                    .height *
                                                                                                    0.7,
                                                                                                width: MediaQuery.of(context)
                                                                                                    .size
                                                                                                    .width,
                                                                                                decoration: BoxDecoration(
                                                                                                  image: DecorationImage(
                                                                                                    image: imageProvider,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                          placeholder: (context, url) =>
                                                                                              SpinKitCircle(
                                                                                                color: primary,
                                                                                                size: 60,
                                                                                              ),
                                                                                          errorWidget: (context, url,
                                                                                              error) =>
                                                                                              ClipRRect(
                                                                                                  borderRadius:
                                                                                                  const BorderRadius
                                                                                                      .all(
                                                                                                      Radius.circular(
                                                                                                          50)),
                                                                                                  child: Image.network(
                                                                                                    "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                                                    width: MediaQuery.of(
                                                                                                        context)
                                                                                                        .size
                                                                                                        .width *
                                                                                                        0.9,
                                                                                                    height: MediaQuery.of(
                                                                                                        context)
                                                                                                        .size
                                                                                                        .height *
                                                                                                        0.9,
                                                                                                  )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: 20,),
                                                                                    Column(
                                                                                      children: [
                                                                                        Text(
                                                                                          (
                                                                                              story.viewed_users[index] == null ||
                                                                                                  story.viewed_users[index]["user"] == null ||
                                                                                                  story.viewed_users[index]["user"]["name"] == null
                                                                                          ) ? "No Name" :
                                                                                          story.viewed_users[index]["user"]["name"],style: TextStyle(color: Colors.white),),
                                                                                        Text(
                                                                                          (
                                                                                              story.viewed_users[index] == null ||
                                                                                                  story.viewed_users[index]["user"] == null ||
                                                                                                  story.viewed_users[index]["user"]["username"] == null
                                                                                          ) ? "No Username" :
                                                                                          story.viewed_users[index]["user"]["username"],style: TextStyle(color: Colors.white),)
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }
                                                          )
                                                      ),
                                                    );
                                                  }
                                              );
                                              //Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.remove_red_eye),
                                          ),
                                          GestureDetector(onTap: ()async {
                                            //pinStory(story.uploadObject);
                                            return await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: primary,
                                                title: const Text(
                                                  "FashionTime",
                                                  style: TextStyle(
                                                      color: ascent,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                content: const Text(
                                                  "Do you want to pin this story?",
                                                  style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("Yes",
                                                        style: TextStyle(
                                                            color: ascent, fontFamily: 'Montserrat')),
                                                    onPressed: () {
                                                      pinStory(story.uploadObject);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text("No",
                                                        style: TextStyle(
                                                            color: ascent, fontFamily: 'Montserrat')),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                              child: Icon(Icons.push_pin,color: Colors.white)),
                                          IconButton(
                                            onPressed: (){
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl: story.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      );
                    case MediaType.text:
                      return SizedBox(
                        height:MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 50, left: 5),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${story.user.name} ${story.duration}",
                                        style: const TextStyle(
                                            color: ascent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: "Montserrat"),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: (){
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (builder){
                                                    return new Container(
                                                      height: 350.0,
                                                      color: Colors.transparent, //could change this to Color(0xFF737373),
                                                      //so you don't have to change MaterialApp canvasColor
                                                      child: new Container(
                                                          height: 350.0,
                                                          width: 400,
                                                          decoration: new BoxDecoration(
                                                              //color: Colors.white,
                                                              borderRadius: new BorderRadius.only(
                                                                  topLeft: const Radius.circular(10.0),
                                                                  topRight: const Radius.circular(10.0))),
                                                          child:story.viewed_users.length <= 0 ? Center(
                                                            child: Text("No Viewers",style: TextStyle(color: Colors.white),),
                                                          ) : StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Padding(
                                                                  padding: const EdgeInsets.all(20.0),
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(height: 20,),
                                                                      Row(
                                                                        children: [
                                                                          Text("${story.viewed_users.length} Viewers",style: TextStyle(color: Colors.white),)
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 20,),
                                                                      Expanded(
                                                                        child: ListView.builder(
                                                                            itemCount: story.viewed_users.length,
                                                                            itemBuilder:(context,index){
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                      height:50,
                                                                                      width: 50,
                                                                                      child: ClipRRect(
                                                                                        borderRadius:
                                                                                        const BorderRadius.all(
                                                                                            Radius.circular(120)),
                                                                                        child: CachedNetworkImage(
                                                                                          imageUrl: (
                                                                                                      story.viewed_users[index] == null ||
                                                                                                      story.viewed_users[index]["user"] == null ||
                                                                                                      story.viewed_users[index]["user"]["pic"] == null
                                                                                          ) ?
                                                                                          "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w":
                                                                                          story.viewed_users[index]["user"]["pic"],
                                                                                          imageBuilder:
                                                                                              (context, imageProvider) =>
                                                                                              Container(
                                                                                                height: MediaQuery.of(context)
                                                                                                    .size
                                                                                                    .height *
                                                                                                    0.7,
                                                                                                width: MediaQuery.of(context)
                                                                                                    .size
                                                                                                    .width,
                                                                                                decoration: BoxDecoration(
                                                                                                  image: DecorationImage(
                                                                                                    image: imageProvider,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                          placeholder: (context, url) =>
                                                                                              SpinKitCircle(
                                                                                                color: primary,
                                                                                                size: 60,
                                                                                              ),
                                                                                          errorWidget: (context, url,
                                                                                              error) =>
                                                                                              ClipRRect(
                                                                                                  borderRadius:
                                                                                                  const BorderRadius
                                                                                                      .all(
                                                                                                      Radius.circular(
                                                                                                          50)),
                                                                                                  child: Image.network(
                                                                                                    "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                                                    width: MediaQuery.of(
                                                                                                        context)
                                                                                                        .size
                                                                                                        .width *
                                                                                                        0.9,
                                                                                                    height: MediaQuery.of(
                                                                                                        context)
                                                                                                        .size
                                                                                                        .height *
                                                                                                        0.9,
                                                                                                  )),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: 20,),
                                                                                    Column(
                                                                                      children: [
                                                                                        Text(
                                                                                          (
                                                                                                  story.viewed_users[index] == null ||
                                                                                                  story.viewed_users[index]["user"] == null ||
                                                                                                  story.viewed_users[index]["user"]["name"] == null
                                                                                          ) ? "No Name" :
                                                                                          story.viewed_users[index]["user"]["name"],style: TextStyle(color: Colors.white),),
                                                                                        Text(
                                                                                          (
                                                                                              story.viewed_users[index] == null ||
                                                                                                  story.viewed_users[index]["user"] == null ||
                                                                                                  story.viewed_users[index]["user"]["username"] == null
                                                                                          ) ? "No Username" :
                                                                                          story.viewed_users[index]["user"]["username"],style: TextStyle(color: Colors.white),)
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }
                                                          )
                                                      ),
                                                    );
                                                  }
                                              );
                                              //Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.remove_red_eye),
                                          ),
                                          GestureDetector(onTap: () async{
                                            //pinStory(story.uploadObject);
                                            return await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: primary,
                                                title: const Text(
                                                  "FashionTime",
                                                  style: TextStyle(
                                                      color: ascent,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                content: const Text(
                                                  "Do you want to pin this story?",
                                                  style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("Yes",
                                                        style: TextStyle(
                                                            color: ascent, fontFamily: 'Montserrat')),
                                                    onPressed: () {
                                                      pinTextStory(story.url.toString());
                                                      // pinStory(story.uploadObject);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text("No",
                                                        style: TextStyle(
                                                            color: ascent, fontFamily: 'Montserrat')),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                              child: Icon(Icons.push_pin,color: Colors.white,)),
                                          IconButton(
                                            onPressed: (){
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                            Expanded(
                              child: Container(
                                color: secondary,
                                child: Center(
                                  child: Text(
                                    story.url.toString(),
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 35,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    case MediaType.video:
                      if (_videoController.value.isInitialized) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50, left: 5),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${story.user.name} ${story.duration}",
                                          style: const TextStyle(
                                              color: ascent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: "Montserrat"),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: (){
                                                showModalBottomSheet(
                                                    context: context,
                                                    builder: (builder){
                                                      return new Container(
                                                        height: 350.0,
                                                        color: Colors.transparent, //could change this to Color(0xFF737373),
                                                        //so you don't have to change MaterialApp canvasColor
                                                        child: new Container(
                                                            height: 350.0,
                                                            width: 400,
                                                            decoration: new BoxDecoration(
                                                              //color: Colors.white,
                                                                borderRadius: new BorderRadius.only(
                                                                    topLeft: const Radius.circular(10.0),
                                                                    topRight: const Radius.circular(10.0))),
                                                            child:story.viewed_users.length <= 0 ? Center(
                                                              child: Text("No Viewers",style: TextStyle(color: Colors.white),),
                                                            ) : StatefulBuilder(
                                                                builder: (BuildContext context, StateSetter setState) {
                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(20.0),
                                                                    child: Column(
                                                                      children: [
                                                                        SizedBox(height: 20,),
                                                                        Row(
                                                                          children: [
                                                                            Text("${story.viewed_users.length} Viewers",style: TextStyle(color: Colors.white),)
                                                                          ],
                                                                        ),
                                                                        SizedBox(height: 20,),
                                                                        Expanded(
                                                                          child: ListView.builder(
                                                                              itemCount: story.viewed_users.length,
                                                                              itemBuilder:(context,index){
                                                                                return Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Container(
                                                                                        height:50,
                                                                                        width: 50,
                                                                                        child: ClipRRect(
                                                                                          borderRadius:
                                                                                          const BorderRadius.all(
                                                                                              Radius.circular(120)),
                                                                                          child: CachedNetworkImage(
                                                                                            imageUrl: (
                                                                                                story.viewed_users[index] == null ||
                                                                                                    story.viewed_users[index]["user"] == null ||
                                                                                                    story.viewed_users[index]["user"]["pic"] == null
                                                                                            ) ?
                                                                                            "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w":
                                                                                            story.viewed_users[index]["user"]["pic"],
                                                                                            imageBuilder:
                                                                                                (context, imageProvider) =>
                                                                                                Container(
                                                                                                  height: MediaQuery.of(context)
                                                                                                      .size
                                                                                                      .height *
                                                                                                      0.7,
                                                                                                  width: MediaQuery.of(context)
                                                                                                      .size
                                                                                                      .width,
                                                                                                  decoration: BoxDecoration(
                                                                                                    image: DecorationImage(
                                                                                                      image: imageProvider,
                                                                                                      fit: BoxFit.cover,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                            placeholder: (context, url) =>
                                                                                                SpinKitCircle(
                                                                                                  color: primary,
                                                                                                  size: 60,
                                                                                                ),
                                                                                            errorWidget: (context, url,
                                                                                                error) =>
                                                                                                ClipRRect(
                                                                                                    borderRadius:
                                                                                                    const BorderRadius
                                                                                                        .all(
                                                                                                        Radius.circular(
                                                                                                            50)),
                                                                                                    child: Image.network(
                                                                                                      "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                                                      width: MediaQuery.of(
                                                                                                          context)
                                                                                                          .size
                                                                                                          .width *
                                                                                                          0.9,
                                                                                                      height: MediaQuery.of(
                                                                                                          context)
                                                                                                          .size
                                                                                                          .height *
                                                                                                          0.9,
                                                                                                    )),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(width: 20,),
                                                                                      Column(
                                                                                        children: [
                                                                                          Text(
                                                                                            (
                                                                                                story.viewed_users[index] == null ||
                                                                                                    story.viewed_users[index]["user"] == null ||
                                                                                                    story.viewed_users[index]["user"]["name"] == null
                                                                                            ) ? "No Name" :
                                                                                            story.viewed_users[index]["user"]["name"],style: TextStyle(color: Colors.white),),
                                                                                          Text(
                                                                                            (
                                                                                                story.viewed_users[index] == null ||
                                                                                                    story.viewed_users[index]["user"] == null ||
                                                                                                    story.viewed_users[index]["user"]["username"] == null
                                                                                            ) ? "No Username" :
                                                                                            story.viewed_users[index]["user"]["username"],style: TextStyle(color: Colors.white),)
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }
                                                            )
                                                        ),
                                                      );
                                                    }
                                                );
                                                //Navigator.pop(context);
                                              },
                                              icon: Icon(Icons.remove_red_eye),
                                            ),
                                            IconButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(Icons.close),
                                            ),
                                            GestureDetector(onTap: ()async {
                                              return await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: primary,
                                                  title: const Text(
                                                    "FashionTime",
                                                    style: TextStyle(
                                                        color: ascent,
                                                        fontFamily: 'Montserrat',
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  content: const Text(
                                                    "Do you want to pin this story?",
                                                    style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("Yes",
                                                          style: TextStyle(
                                                              color: ascent, fontFamily: 'Montserrat')),
                                                      onPressed: () {
                                                        pinStory(story.uploadObject);
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text("No",
                                                          style: TextStyle(
                                                              color: ascent, fontFamily: 'Montserrat')),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                              // pinStory(story.uploadObject);
                                            },
                                                child: Icon(Icons.push_pin,color: Colors.white))
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _videoController.value.size.width,
                                    height: _videoController.value.size.height,
                                    child: VideoPlayer(_videoController),
                                  ), // Sized Box
                                ),
                              ),
                            ],
                          ),
                        ); // FittedBox
                      }
                  }
                  return const SizedBox.shrink();
                },
              ),
              Positioned(
                top: 40.0,
                left: 10.0,
                right: 10.0,
                child: Row(
                  children: widget.stories
                      .asMap()
                      .map((i, e) {
                        return MapEntry(
                          i,
                          AnimatedBar(
                            animController: _animController,
                            position: i,
                            currentIndex: _currentIndex,
                          ),
                        ); // MapEntry
                      })
                      .values
                      .toList(),
                ),
              ),
            ],
          ),
        )); // Scaffold
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          debugPrint("All stories viewed. Popping to previous screen.");
          Navigator.pop(context);
        }
      });
    } else {
      if (story.media == MediaType.video) {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
          _animController.stop();
        } else {
          _videoController.play();
          _animController.forward();
        }
      }
    }
  }


  void _loadStory({required Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    switch (story.media) {
      case MediaType.image:
        _animController.duration = const Duration(seconds: 5);
        _animController.forward();
        break;
      case MediaType.video:
        _videoController != null;
        _videoController.dispose();
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(story.url))
              ..initialize().then((_) {
                setState(() {});
                if (_videoController.value.isInitialized) {
                  _animController.duration = _videoController.value.duration;
                  _videoController.play();
                  _animController.forward();
                }
              });
        break;
    }
    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;
  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              _buildContainer(
                double.infinity,
                position < currentIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
              position == currentIndex
                  ? AnimatedBuilder(
                      animation: animController,
                      builder: (context, child) {
                        return _buildContainer(
                          constraints.maxWidth * animController.value,
                          Colors.white,
                        );
                      },
                    )
                  : const SizedBox.shrink()
            ],
          );
        },
      ),
    ));
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ), // Border.all
        borderRadius: BorderRadius.circular(3.0),
      ), // BoxDecoration
    ); // Container
  }
}
