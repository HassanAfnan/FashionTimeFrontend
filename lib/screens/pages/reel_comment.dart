import 'dart:convert';

import 'package:FashionTime/screens/pages/reelsInterface.dart';
import 'package:FashionTime/screens/pages/report_reel_comment.dart';
import 'package:FashionTime/screens/pages/reel_comment_reply.dart';
import 'package:FashionTime/screens/pages/report_coment.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import '../../animations/bottom_animation.dart';

import '../../utils/constants.dart';
import 'friend_profile.dart';
class ReelCommentScreen extends StatefulWidget {
  final String userPic;
  final int reelId;
  const ReelCommentScreen({super.key, required this.userPic, required this.reelId});

  @override
  State<ReelCommentScreen> createState() => _ReelCommentScreenState();
}
String id = "";
String token = "";
String username = '';
// List<dynamic> comments = [];
List<dynamic> myComments = [];
bool loading = true;
bool loading1 = false;
bool isFilterOn = false;
TextEditingController comment = TextEditingController();
TextEditingController replyController = TextEditingController();
int reelCommentId=0;
String reelComment="";
String createdAt="";
String userName="";
String userPic="";
List<dynamic> results =[];

class _ReelCommentScreenState extends State<ReelCommentScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
    getReelComments(widget.reelId.toString());
  }
  getCashedData() async {
    // print("post id ${widget.id}");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    username = preferences.getString('username')!;

    debugPrint(token);
   // getComments(widget.id);
    // getMyComments(widget.id);
    getReelComments(widget.reelId.toString());
  }

  String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }
  createReelComment() async {
    setState(() {
      loading1 = true;
    });
    try {
      if (comment.text == "") {
        setState(() {
          loading1 = false;
        });
        showDialog(
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
              "Please fill all the fields",
              style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
            ),
            actions: [
              TextButton(
                child: const Text("Okay",
                    style: TextStyle(color: ascent, fontFamily: 'Montserrat')),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      } else {
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": comment.text,
          "reel": widget.reelId,
          "user": id
        };
        https.post(Uri.parse("$serverUrl/fashionReelComments/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          debugPrint("Response after commenting on reel==> ${value.body}");
          setState(() {
            loading1 = false;
            comment.clear();
          });
         // getComments(widget.id);
        }).catchError((error) {
          setState(() {
            loading1 = false;
          });
          showDialog(
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
              content: Text(
                error.toString(),
                style: const TextStyle(color: ascent, fontFamily: 'Montserrat'),
              ),
              actions: [
                TextButton(
                  child: const Text("Okay",
                      style:
                      TextStyle(color: ascent, fontFamily: 'Montserrat')),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        loading1 = false;
      });
      debugPrint(e.toString());
    }
  }
  getReelComments(String reelId){
  String url='$serverUrl/fashionReelComments/$reelId/';

  try{
    https.get(Uri.parse(url),headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).then((value) {
      if(value.statusCode==200){
        setState(() {
          loading=false;
        });
         results = json.decode(value.body)["results"];
        debugPrint("the response of reel comment is ======> ${value.body}");
        for(var result in results){
          reelCommentId=result['id']as int;
          reelComment=result['comment'].toString();
          createdAt=result["created"].toString();
          userName=result['user']['username'];
          userPic=result['user']['pic'];
        }
      }
      else{
        debugPrint("error received while getting reel comment=====> ${value.body}");
      }
    });
  }
  catch(e){
    debugPrint("error received while getting reel comment");
  }
  }
  getMyReelComments(String reelId){
    String url='$serverUrl/fashionReelComments/$reelId/';
    setState(() {
      loading=true;

    });
    try{
      https.get(Uri.parse(url),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        if(value.statusCode==200){
          setState(() {
            loading=false;
          });
          results = json.decode(value.body)["results"];
          myComments = results.where((element) => element['user']['username'] == username).toList();
          results.clear();
          debugPrint("the response of  my reel comment is ======> $myComments");
          for(var result in results){
            reelCommentId=result['id']as int;
            reelComment=result['comment'].toString();
            createdAt=result["created"].toString();
            userName=result['user']['username'];
            userPic=result['user']['pic'];
          }
        }
        else{
          debugPrint("error received while getting reel comment=====> ${value.body}");
        }
      });
    }
    catch(e){
      debugPrint("error received while getting reel comment");
    }
  }
  likeComment(int commentId){
    String url='$serverUrl/fashionLikeReelComments/';
    Map<String,dynamic> requestBody={
      "likeEmoji":"heart",
      "reelComment":commentId,
      "user":int.parse(id)
    };
    try{
      https.post(Uri.parse(url),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },body: jsonEncode(requestBody)).then((value) => {
        if(value.statusCode==201){
          Fluttertoast.showToast(msg: "Comment liked",backgroundColor: primary)
        }
        else{
          debugPrint("error received when posting like in comments ${value.body}${value.statusCode}")
        }
      });
    }
    catch(e){
      debugPrint("Exception caught while liking comment ${e.toString()}");
    }
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
                  ])),
        ),
        title: const Text(
          "Flick Comment",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
                label: const Text("Filter my comments",
                    style: TextStyle(fontFamily: "Montserrat")),
                onSelected: (value) {
                  debugPrint("filter clicked");
                  myComments.clear();
                  isFilterOn = !isFilterOn;
                  results.clear();
                  getMyReelComments(widget.reelId.toString());
                  if (isFilterOn == false) {
                    myComments.clear();
                    getReelComments(widget.reelId.toString());
                  }
                  else{
                    getMyReelComments(widget.reelId.toString());
                  }
                },
                backgroundColor: primary),
          ),
          loading == true
              ? Expanded(
              child: SpinKitCircle(
                color: primary,
                size: 50,
              ))
              : results.isEmpty
              ?
          //Expanded(child: Center(child: Text("No comments")))
          (Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                  itemCount: myComments.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                                    id: myComments[index]['user']['id'].toString(),
                                    username: myComments[index]["user"]["username"],
                                  )));
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           CommentReplyScreen(
                                  //         commentId: myComments[index]
                                  //             ['id'],
                                  //       ),
                                  //     ));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                leading: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      child: myComments[index]["user"]
                                      ["pic"] ==
                                          null
                                          ? Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                        width: 40,
                                        height: 40,
                                      )
                                          : CachedNetworkImage(
                                        imageUrl:
                                        myComments[index]
                                        ["user"]["pic"],
                                        imageBuilder: (context,
                                            imageProvider) =>
                                            Container(
                                              height: 100,
                                              width: 100,
                                              decoration:
                                              BoxDecoration(
                                                image:
                                                DecorationImage(
                                                  image:
                                                  imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        placeholder: (context,
                                            url) =>
                                            Center(
                                                child:
                                                SpinKitCircle(
                                                  color: primary,
                                                  size: 10,
                                                )),
                                        errorWidget: (context,
                                            url, error) =>
                                            ClipRRect(
                                              borderRadius:
                                              const BorderRadius.all(
                                                  Radius
                                                      .circular(
                                                      50)),
                                              child: Image.network(
                                                "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                width: 40,
                                                height: 40,
                                              ),
                                            ),
                                      ),
                                    )),
                                title:
                                Text(
                                    myComments[index]["user"]
                                    ["username"],
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w400)),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      utf8convert(myComments[index]['comment'])
                                      //myComments[index]["comment"],
                                      ,
                                      style: const TextStyle(
                                          fontFamily: "Montserrat"),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              showDialog(

                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(

                                                      backgroundColor: primary,
                                                      title: Row(
                                                        children: [
                                                          Flexible(
                                                            child: CircleAvatar(
                                                                backgroundColor: Colors.black,
                                                                child: ClipRRect(
                                                                  borderRadius: const BorderRadius.all(
                                                                      Radius.circular(50)),
                                                                  child: myComments[index]["user"]
                                                                  ["pic"] ==
                                                                      null
                                                                      ? Image.network(
                                                                    "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                    width: 40,
                                                                    height: 40,
                                                                  )
                                                                      : CachedNetworkImage(
                                                                    imageUrl:
                                                                    myComments[index]
                                                                    ["user"]["pic"],
                                                                    imageBuilder: (context,
                                                                        imageProvider) =>
                                                                        Container(
                                                                          height: 100,
                                                                          width: 100,
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            image:
                                                                            DecorationImage(
                                                                              image:
                                                                              imageProvider,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                    placeholder: (context,
                                                                        url) =>
                                                                        Center(
                                                                            child:
                                                                            SpinKitCircle(
                                                                              color: primary,
                                                                              size: 10,
                                                                            )),
                                                                    errorWidget: (context,
                                                                        url, error) =>
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                          const BorderRadius.all(
                                                                              Radius
                                                                                  .circular(
                                                                                  50)),
                                                                          child: Image.network(
                                                                            "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                            width: 40,
                                                                            height: 40,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                )),
                                                          ),
                                                          const SizedBox(width: 4,),
                                                          const Flexible(
                                                            child: Text(
                                                                'Reply to this comment.', style: TextStyle(
                                                                fontFamily: "Montserrat")),
                                                          ),
                                                        ],
                                                      ),
                                                      content:
                                                      TextField(
                                                        maxLength: 500,

                                                        onChanged:
                                                            (value) {
                                                          setState(() {});
                                                        },
                                                        controller:
                                                        replyController,
                                                        decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                            "Write comment here.",labelStyle: TextStyle(fontFamily: "Montserrat")),
                                                      ),
                                                      actions: <Widget>[
                                                        MaterialButton(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                                                          ),
                                                          color: ascent,
                                                          textColor:
                                                          ascent,
                                                          child:  Icon(
                                                              Icons.send,
                                                              color:
                                                              primary),
                                                          onPressed: () {
                                                            setState(() {
                                                              print(
                                                                  "comment content${replyController.text}");
                                                              Navigator.pop(
                                                                  context);
                                                              // createCommentReply(
                                                              //     myComments[index]
                                                              //     [
                                                              //     'id']);
                                                              replyController
                                                                  .clear();
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Text(
                                              "reply",
                                              style: TextStyle(
                                                  fontFamily:
                                                  "Montserrat",
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  color: primary,
                                                  decoration:
                                                  TextDecoration
                                                      .underline),
                                            )),
                                        const SizedBox(width: 8,),
                                        // myComments[index]["replyCommentsCount"]<=0?const SizedBox():InkWell(
                                        //     onTap: () {
                                        //       // Navigator.push(
                                        //       //     context,
                                        //       //     MaterialPageRoute(
                                        //       //       builder: (context) =>
                                        //       //           CommentReplyScreen(
                                        //       //             commentId: myComments[index]
                                        //       //             ['id'],
                                        //       //             userId: int.parse(id),
                                        //       //             userPic: widget.pic,
                                        //       //           ),
                                        //       //     ));
                                        //     },
                                        //     child: Align(
                                        //         alignment: Alignment.centerRight,
                                        //         child: Text("View ${myComments[index]["replyCommentsCount"]} more replies")))
                                      ],
                                    ),

                                  ],
                                ),
                                trailing: Text(DateFormat.jm().format(
                                    DateTime.parse(myComments[index]
                                    ["created"])
                                        .toLocal())),
                              ),
                            ),
                          ),
                        ));
                  }),
            ),
          ))
              : (Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                                    id: results[index]['user']['id'].toString(),
                                    username: results[index]["user"]["username"],
                                  )));
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           CommentReplyScreen(
                                  //         commentId: comments[index]
                                  //             ['id'],
                                  //       ),
                                  //     ));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                leading: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      child: results[index]["user"]
                                      ["pic"] ==
                                          null
                                          ? Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                        width: 40,
                                        height: 40,
                                      )
                                          : CachedNetworkImage(
                                        imageUrl:
                                        results[index]
                                        ["user"]["pic"],
                                        imageBuilder: (context,
                                            imageProvider) =>
                                            Container(
                                              height: 100,
                                              width: 100,
                                              decoration:
                                              BoxDecoration(
                                                image:
                                                DecorationImage(
                                                  image:
                                                  imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        placeholder: (context,
                                            url) =>
                                            Center(
                                                child:
                                                SpinKitCircle(
                                                  color: primary,
                                                  size: 10,
                                                )),
                                        errorWidget: (context,
                                            url, error) =>
                                            ClipRRect(
                                              borderRadius:
                                              const BorderRadius.all(
                                                  Radius
                                                      .circular(
                                                      50)),
                                              child: Image.network(
                                                "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                width: 40,
                                                height: 40,
                                              ),
                                            ),
                                      ),
                                    )),
                                title: Text(
                                    results[index]["user"]
                                    ["username"],
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w400)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>ReportReelCommentScreen(commentId: results[index]['id']) ,));
                                      },
                                      child: Text(
                                        // comments[index]["comment"],
                                        utf8convert(results[index]['comment']),
                                        style: const TextStyle(
                                            fontFamily: "Montserrat"),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      backgroundColor: primary,
                                                      title: Row(
                                                        children: [
                                                          Flexible(
                                                            child: CircleAvatar(
                                                                backgroundColor: Colors.black,
                                                                child: ClipRRect(
                                                                  borderRadius: const BorderRadius.all(
                                                                      Radius.circular(50)),
                                                                  child: results[index]["user"]
                                                                  ["pic"] ==
                                                                      null
                                                                      ? Image.network(
                                                                    "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                    width: 40,
                                                                    height: 40,
                                                                  )
                                                                      : CachedNetworkImage(
                                                                    imageUrl:
                                                                    results[index]
                                                                    ["user"]["pic"],
                                                                    imageBuilder: (context,
                                                                        imageProvider) =>
                                                                        Container(
                                                                          height: 100,
                                                                          width: 100,
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            image:
                                                                            DecorationImage(
                                                                              image:
                                                                              imageProvider,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                    placeholder: (context,
                                                                        url) =>
                                                                        Center(
                                                                            child:
                                                                            SpinKitCircle(
                                                                              color: primary,
                                                                              size: 10,
                                                                            )),
                                                                    errorWidget: (context,
                                                                        url, error) =>
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                          const BorderRadius.all(
                                                                              Radius
                                                                                  .circular(
                                                                                  50)),
                                                                          child: Image.network(
                                                                            "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                            width: 40,
                                                                            height: 40,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                )),
                                                          ),
                                                          const SizedBox(width: 4,),
                                                          const Flexible(
                                                            child: Text(
                                                                'Reply to this comment.', style: TextStyle(
                                                                fontFamily: "Montserrat")),
                                                          ),
                                                        ],
                                                      ),
                                                      content:
                                                      AutoSizeTextField(
                                                        onChanged:
                                                            (value) {
                                                          setState(() {});
                                                        },
                                                        controller:
                                                        replyController,
                                                        decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                            "Write comment here.",labelStyle: TextStyle(fontFamily:  "Montserrat")),
                                                        cursorColor: primary,
                                                        maxLength: 150,
                                                      ),
                                                      actions: <Widget>[
                                                        MaterialButton(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                                                          ),
                                                          color: ascent,
                                                          textColor:
                                                          ascent,

                                                          child:  Icon(
                                                              Icons.send,

                                                              color:
                                                              primary),
                                                          onPressed: () {
                                                            setState(() {
                                                              print(
                                                                  "comment content${replyController.text}");
                                                              Navigator.pop(
                                                                  context);
                                                              // createCommentReply(
                                                              //     comments[index]
                                                              //     [
                                                              //     'id']);
                                                              replyController
                                                                  .clear();
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Text(
                                              "reply",
                                              style: TextStyle(
                                                  fontFamily:
                                                  "Montserrat",
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  color: primary,
                                                  decoration:
                                                  TextDecoration
                                                      .underline),
                                            )),
                                        const SizedBox(width: 8,),
                                        results[index]["replyReelCommentsCount"]<=0?const SizedBox():InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReelCommentReplyScreen(
                                                          commentId: results[index]
                                                          ['id'],
                                                          userId: int.parse(id),
                                                          userPic: widget.userPic, commentName: results[index]["user"]['username'],
                                                        ),
                                                  ));
                                            },
                                            child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text("View ${results[index]["replyReelCommentsCount"]} more replies")))
                                      ],
                                    ),

                                  ],
                                ),
                                trailing: GestureDetector(
                                  onDoubleTap: () {
                                    likeComment(results[index]['id']);
                                  },
                                  child: Text(DateFormat.jm().format(
                                      DateTime.parse(results[index]
                                      ["created"])
                                          .toLocal())),
                                ),
                              ),
                            ),
                          ),
                        ));

                  }),
            ),
          )),

          // SizedBox(
          //   width: 16,
          // ),
          // Expanded(
          //     child: TextField(
          //   style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
          //   cursorColor: ascent,
          //   controller: comment,
          //   //style: simpleTextStyle(),
          //   decoration: InputDecoration(
          //       fillColor: ascent,
          //       hintText: "Comment here...",
          //       hintStyle: TextStyle(
          //         color: ascent,
          //         fontFamily: 'Montserrat',
          //         fontSize: 16,
          //       ),
          //       border: InputBorder.none),
          // )),
          // SizedBox(
          //   width: 16,
          // ),
          // GestureDetector(
          //   onTap: loading1 == false
          //       ? () {
          //           FocusScope.of(context).unfocus();
          //           createComment();
          //         }
          //       : () {
          //           print("Empty Text field");
          //         },
          //   child: loading1 == true
          //       ? SpinKitCircle(
          //           color: ascent,
          //           size: 20,
          //         )
          //       : Container(
          //           height: 40,
          //           width: 40,
          //           decoration: BoxDecoration(
          //               gradient: LinearGradient(
          //                   colors: [ascent, ascent],
          //                   begin: FractionalOffset.topLeft,
          //                   end: FractionalOffset.bottomRight),
          //               borderRadius: BorderRadius.circular(40)),
          //           padding: EdgeInsets.all(10),
          //           child: Icon(
          //             Icons.send,
          //             color: primary,
          //           )),
          // ),
          WidgetAnimator(
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[primary, primary]),
                  ),
                  child: Row(
                    children: [
                      // const SizedBox(width: 16,),
                      CircleAvatar(
                          backgroundColor: ascent,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            child: widget.userPic == null
                                ? Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                              width: 40,
                              height: 40,
                            )
                                : CachedNetworkImage(
                              imageUrl: widget.userPic,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) => Center(
                                  child: SpinKitCircle(
                                    color: primary,
                                    size: 10,
                                  )),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          )),
                      const SizedBox(width: 14,),
                      Expanded(
                          child: AutoSizeTextField(
                            textCapitalization: TextCapitalization.sentences,
                            // inputFormatters: <TextInputFormatter>[
                            //   UpperCaseTextFormatter()
                            // ],
                            maxLines: null,
                            onTap: (){
                              //_controller.jumpTo(_controller.position.maxScrollExtent);
                            },
                            style: const TextStyle(color: ascent,fontFamily: 'Montserrat'),
                            cursorColor: ascent,
                            controller: comment,
                            //style: simpleTextStyle(),
                            decoration: const InputDecoration(
                                fillColor: ascent,
                                hintText: "Comment ...",
                                hintStyle: TextStyle(
                                  color: ascent,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                ),
                                border: InputBorder.none
                            ),
                          )),
                      const SizedBox(width: 16,),
                      GestureDetector(
                        onTap: () {
                           createReelComment();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [
                                      ascent,
                                      ascent
                                    ],
                                    begin: FractionalOffset.topLeft,
                                    end: FractionalOffset.bottomRight
                                ),
                                borderRadius: BorderRadius.circular(40)
                            ),
                            padding: const EdgeInsets.only(left:4),
                            child: Center(child: Icon(Icons.send,color: primary,))
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
