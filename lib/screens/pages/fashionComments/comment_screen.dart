import 'dart:convert';

import 'package:FashionTime/screens/pages/fashionComments/comment_reply.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/report_coment.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../animations/bottom_animation.dart';
import '../../../models/comment.dart';
import '../../../utils/constants.dart';
import '../message_screen.dart';

class CommentScreen extends StatefulWidget {
  final String id;
  final String pic;
  const CommentScreen({Key? key, required this.id, required this.pic})
      : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  String id = "";
  String token = "";
  String username = '';
  List<dynamic> comments = [];
  List<dynamic> myComments = [];
  bool loading = false;
  bool loading1 = false;
  bool isFilterOn = false;
  TextEditingController comment = TextEditingController();
  TextEditingController replyController = TextEditingController();
  TextEditingController editController=TextEditingController();
  GiphyGif? _gif;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getCashedData() async {
    print("post id ${widget.id}");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    username = preferences.getString('username')!;

    print(token);
    getComments(widget.id);
    // getMyComments(widget.id);
  }

  getComments(id) {
    setState(() {
      loading = true;
      comments.clear();
    });
    https.get(Uri.parse("$serverUrl/fashionComments/$id"), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).then((value) {
      setState(() {
        loading = false;
      });
      print("all comments ${value.body}");
      json.decode(value.body)["results"].forEach((data) {
        setState(() {
          comments.add(data);
        });
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      print(error.toString());
    });
  }
  getMyComments(id) {
    setState(() {
      loading = true;
      comments.clear();
    });
    https.get(Uri.parse("$serverUrl/fashionComments/$id"), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).then((value) {
      setState(() {
        loading = false;
      });
      print(value.body.toString());
      json.decode(value.body)["results"].forEach((data) {
        if (data["user"]["username"] == username) {
          setState(() {
            myComments.add(data);
            print("my comments ${myComments.toString()}");
            print("my comments length is ${myComments.length}");
          });
        } else {
          print("no comments");
        }
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      print(error.toString());
    });
  }
  createComment() async {
    setState(() {
      loading1 = true;
    });
    try {
      if (comment.text == ""&& _gif==null) {
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
      } else if(_gif!=null) {
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": _gif?.images.original?.url.toString(),
          "fashion": widget.id,
          "user": id
        };
        https.post(Uri.parse("$serverUrl/fashionComments/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          print("Response ==> ${value.body}");
          setState(() {
            loading1 = false;
            comment.clear();
          });
          getComments(widget.id);
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
      else{
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": comment.text,
          "fashion": widget.id,
          "user": id
        };
        https.post(Uri.parse("$serverUrl/fashionComments/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          print("Response ==> ${value.body}");
          setState(() {
            loading1 = false;
            comment.clear();
          });
          getComments(widget.id);
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
      print(e);
    }
  }
  bool isCommentEdited(String created, String updated) {
    DateTime createdDateTime = DateTime.parse(created);
    DateTime updatedDateTime = DateTime.parse(updated);

    // Truncate the microseconds and nanoseconds
    DateTime createdWithoutMicroseconds = DateTime(
      createdDateTime.year,
      createdDateTime.month,
      createdDateTime.day,
      createdDateTime.hour,
      createdDateTime.minute,
      createdDateTime.second,
    );

    DateTime updatedWithoutMicroseconds = DateTime(
      updatedDateTime.year,
      updatedDateTime.month,
      updatedDateTime.day,
      updatedDateTime.hour,
      updatedDateTime.minute,
      updatedDateTime.second,
    );

    // Compare the truncated DateTime objects
    return createdWithoutMicroseconds != updatedWithoutMicroseconds;
  }
  editMyComment(fashionCommentId,fashionId) async {
    setState(() {
      loading1 = true;
    });
    try {
      if (editController.text == ""&& _gif==null) {
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
      } else if(_gif!=null) {
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": _gif?.images.original?.url.toString(),
          "fashion": int.parse(fashionCommentId),
          "user": id
        };
        https.patch(Uri.parse("$serverUrl/fashionComments/$fashionCommentId/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          print("Response ==> ${value.body}");
          setState(() {
            loading1 = false;
            myComments.clear();
          });
          getMyComments(widget.id);
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
      else{
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": editController.text,
          "fashion": fashionId,
          "user": id
        };
        https.patch(Uri.parse("$serverUrl/fashionComments/$fashionCommentId/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          print("Response ==> ${value.body}");
          setState(() {
            loading1 = false;
            myComments.clear();
          });
          getMyComments(widget.id);
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
      print(e);
    }
  }
  editComment(fashionCommentId,fashionId) async {
    setState(() {
      loading1 = true;
    });
    try {
      if (editController.text == ""&& _gif==null) {
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
      } else if(_gif!=null) {
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": _gif?.images.original?.url.toString(),
          "fashion": int.parse(fashionCommentId),
          "user": id
        };
        https.patch(Uri.parse("$serverUrl/fashionComments/$fashionCommentId/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          print("Response ==> ${value.body}");
          setState(() {
            loading1 = false;
            myComments.clear();
          });
          getComments(widget.id);
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
      else{
        setState(() {
          loading1 = true;
        });
        Map<String, dynamic> body = {
          "comment": editController.text,
          "fashion": fashionId,
          "user": id
        };
        https.patch(Uri.parse("$serverUrl/fashionComments/$fashionCommentId/"),
            body: json.encode(body),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            }).then((value) {
          print("Response ==> ${value.body}");
          setState(() {
            loading1 = false;
            comments.clear();
          });
          getComments(widget.id);
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
      print(e);
    }
  }
  String formatTimeDifference(String dateString) {
    DateTime createdAt = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    Duration difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  deleteComment(commentId)async{
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
          "Are you sure you want to delete your comment?",
          style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            child: const Text("yes",
                style: TextStyle(color: ascent, fontFamily: 'Montserrat')),
            onPressed: () {
              setState(() {
                try{
                  https.delete(Uri.parse("$serverUrl/fashionComments/$commentId/"),headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token"
                  }).then((value) {
                    debugPrint("response====>${value.statusCode}");
                    debugPrint("comment id is==========>$commentId");
                    if(value.statusCode==204){
                      debugPrint("comment id is==========>$commentId");
                      Fluttertoast.showToast(msg: "comment deleted",backgroundColor: primary);
                      Navigator.pop(context);
                      myComments.clear();
                      getMyComments(widget.id);
                      comments.clear();
                      getComments(widget.id);
                    }
                  });
                }catch(e){
                  Fluttertoast.showToast(msg: "error received",backgroundColor: Colors.red);
                }

              });
            },
          ), TextButton(
            child: const Text("no",
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
  }
  createCommentReply(int commentId) async {
    Map<String, dynamic> body = {
      "comment": replyController.text,
      "comment_id": commentId,
      "user": id
    };
    https.post(Uri.parse("$serverUrl/fashionReplyComments/"),
        body: json.encode(body),
        headers: {"Content-Type": "application/json"}).then((value) {
      debugPrint("reply posted with ${value.body}");
    });
  }
  String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }
  likeComment(int commentId){
    String url='$serverUrl/fashionLikeComments/';
    Map<String,dynamic> requestBody={
      "likeEmoji":"heart",
      "fashionComment":commentId,
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
          "Comments",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: const [
          // IconButton(onPressed: (){}, icon: Icon(Icons.settings))
        ],
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
                  print("filter clicked");
                  myComments.clear();
                  isFilterOn = !isFilterOn;
                  comments.clear();
                  getMyComments(widget.id);
                  if (isFilterOn == false) {
                    myComments.clear();
                    getComments(widget.id);
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
              : comments.isEmpty
                  ?
                  //Expanded(child: Center(child: Text("No comments")))
                  (Expanded(
                      child: AnimationLimiter(
                        child: ListView.builder(
                            itemCount: myComments.length,
                            itemBuilder: (context, index) {
                              bool isEdited = isCommentEdited(myComments[index]['created'], myComments[index]['updated']);
                              String commentText = utf8convert(myComments[index]['comment']) +
                                  (isEdited ? " (edited)" : "");
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
                                          onLongPress: () {
                                            deleteComment(myComments[index]['id']);
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
                                              GestureDetector(
                                            onLongPress: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReportCommentScreen(commentId:myComments[index]['id'] ),));
                                            }
                                                ,
                                                child:  myComments[index]['comment'].toString().startsWith("https://media")?

                                                buildGifWidget(context, myComments[index]['comment'].toString())
                                                    :
                                                Flexible(
                                                  child: Text(
                                                    // comments[index]["comment"],
                                                    isEdited?
                                                    utf8convert(commentText):
                                                    utf8convert(commentText),
                                                    style: const TextStyle(
                                                        fontFamily: "Montserrat"),
                                                  ),
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
                                                                          'Edit this comment.', style: TextStyle(
                                                                          fontFamily: "Montserrat")),
                                                                    ),
                                                                  ],
                                                                ),
                                                                content:
                                                                    AutoSizeTextField(
                                                                     maxLength: 2500,

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
                                                                        createCommentReply(
                                                                            myComments[index]
                                                                                [
                                                                                'id']);
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
                                                  const SizedBox(width: 4,),
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
                                                                          'Edit this comment.', style: TextStyle(
                                                                          fontFamily: "Montserrat")),
                                                                    ),
                                                                  ],
                                                                ),
                                                                content:
                                                                AutoSizeTextField(
                                                                  maxLength: 2500,

                                                                  onChanged:
                                                                      (value) {
                                                                    setState(() {});
                                                                  },
                                                                  controller:
                                                                  editController,
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
                                                                        editMyComment(
                                                                            myComments[index]
                                                                            [
                                                                            'id'],myComments[index]['fashion']);
                                                                        editController
                                                                            .clear();
                                                                      });
                                                                    },
                                                                  ),

                                                                ],
                                                              );
                                                            });
                                                      },
                                                      child: Text(
                                                        "edit",
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
                                                  const SizedBox(width: 4,),
                                                  myComments[index]["replyCommentsCount"]<=0?const SizedBox():InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CommentReplyScreen(
                                                                    commentId: myComments[index]
                                                                    ['id'],
                                                                    userId: int.parse(id),
                                                                    userPic: widget.pic,
                                                                    commentName: myComments[index]["user"]
                                                                    ["username"] ,
                                                                    fashionId:myComments[index]['fashion'].toString()

                                                                  ),
                                                            ));
                                                      },
                                                      child: Text("${myComments[index]["replyCommentsCount"]} more replies"))
                                                ],
                                              ),

                                            ],
                                          ),
                                          trailing:
                                          // Text(DateFormat.jm().format(
                                          //     DateTime.parse(myComments[index]
                                          //             ["created"])
                                          //         .toLocal())),
                                          Text(formatTimeDifference(myComments[index]['created']),style: const TextStyle(
                                            fontFamily:  "Montserrat",
                                            fontSize: 12
                                          ),)
                                        ),
                                      ),
                                    ),
                                  ));
                            }),
                      ),
                    ))
                  :
          (Expanded(
                      child: AnimationLimiter(
                        child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              bool isEdited = isCommentEdited(comments[index]['created'], comments[index]['updated']);
                              String commentText = comments[index]['comment'] +
                                  (isEdited ? " (edited)" : "");
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
                                              id: comments[index]['user']['id'].toString(),
                                              username: comments[index]["user"]["username"],
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
                                          onLongPress: () {
                                            deleteComment(comments[index]['id']);
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
                                                child: comments[index]["user"]
                                                            ["pic"] ==
                                                        null
                                                    ? Image.network(
                                                        "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                        width: 40,
                                                        height: 40,
                                                      )
                                                    : CachedNetworkImage(
                                                        imageUrl:
                                                            comments[index]
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
                                          title: GestureDetector(
                                            onDoubleTap: () {
                                              likeComment(comments[index]['id']);
                                            },
                                            child: Text(
                                                comments[index]["user"]
                                                    ["username"],
                                                style: const TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontWeight: FontWeight.w400)),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onLongPress: () {
                                                  debugPrint("long pressssssssedddddddd");
                                                  Navigator.push(context,MaterialPageRoute(builder: (context) =>  ReportCommentScreen(commentId: comments[index]['id']),));
                                                },
                                                onDoubleTap: () {
                                                    likeComment(comments[index]['id']);
                                                  },
                                                  child:
                                                      comments[index]['comment'].toString().startsWith("https://media")?

                                                      buildGifWidget(context, comments[index]['comment'].toString())
                                                          :
                                                  Flexible(
                                                    child: Text(
                                                      // comments[index]["comment"],
                                                      isEdited?
                                                      utf8convert(commentText):
                                                      utf8convert(commentText),
                                                      style: const TextStyle(
                                                          fontFamily: "Montserrat"),
                                                    ),
                                                  )
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
                                                                            child: comments[index]["user"]
                                                                            ["pic"] ==
                                                                                null
                                                                                ? Image.network(
                                                                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                              width: 40,
                                                                              height: 40,
                                                                            )
                                                                                : CachedNetworkImage(
                                                                              imageUrl:
                                                                              comments[index]
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
                                                                      maxLength: 2500,
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
                                                                        createCommentReply(
                                                                            comments[index]
                                                                                [
                                                                                'id']);
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
                                                  const SizedBox(width: 4,),
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
                                                                            child: comments[index]["user"]
                                                                            ["pic"] ==
                                                                                null
                                                                                ? Image.network(
                                                                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                              width: 40,
                                                                              height: 40,
                                                                            )
                                                                                : CachedNetworkImage(
                                                                              imageUrl:
                                                                              comments[index]
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
                                                                  editController,
                                                                  decoration:
                                                                  const InputDecoration(
                                                                      hintText:
                                                                      "Write comment here.",labelStyle: TextStyle(fontFamily:  "Montserrat")),
                                                                  cursorColor: primary,
                                                                  maxLength: 2500,
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
                                                                        editComment(
                                                                            comments[index]
                                                                            [
                                                                            'id'],comments[index]['fashion']);
                                                                        editController
                                                                            .clear();
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      child: Text(
                                                        "edit",
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
                                                  const SizedBox(width: 4,),
                                                  comments[index]["replyCommentsCount"]<=0?const SizedBox():InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CommentReplyScreen(
                                                                    commentId: comments[index]
                                                                    ['id'],
                                                                    userId: int.parse(id),
                                                                    userPic: widget.pic,
                                                                    commentName:  comments[index]["user"]
                                                                    ["username"],
                                                                    fashionId:comments[index]['fashion'].toString()
                                                                  ),
                                                            ));
                                                      },
                                                      child: Text("${comments[index]["replyCommentsCount"]} more replies"))
                                                ],
                                              ),

                                            ],
                                          ),
                                          trailing: GestureDetector(
                                            onDoubleTap: () {
                                              likeComment(comments[index]['id']);
                                            },
                                            child:
                                            // Text(DateFormat.jm().format(
                                            //     DateTime.parse(comments[index]
                                            //             ["created"])
                                            //         .toLocal())),
                                            Text(formatTimeDifference(comments[index]['created']),style: const TextStyle(
                                                fontFamily:  "Montserrat",
                                              fontSize: 12
                                            ),)
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));

                            }),
                      ),
                    )),
          Container(
            height: 30,
            child: ListView(
                scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "😄";
                      });
                    },
                    child: Text("😄",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "😆";
                      });
                    },
                    child: Text("😆",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "🔥";
                      });
                    },
                    child: Text("🔥",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "💀";
                      });
                    },
                    child: Text("💀",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "😭";
                      });
                    },
                    child: Text("😭",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "😢";
                      });
                    },
                    child: Text("😢",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "❤️";
                      });
                    },
                    child: Text("❤️",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "🥰";
                      });
                    },
                    child: Text("🥰",style: TextStyle(fontSize: 25),)),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        comment.text = comment.text + " " + "😍";
                      });
                    },
                    child: Text("😍",style: TextStyle(fontSize: 25),)),
              ]
            ),
          ),
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
                            child: widget.pic == null
                                ? Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                              width: 40,
                              height: 40,
                            )
                                : CachedNetworkImage(
                              imageUrl: widget.pic,
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
                                  const Icon(Icons.person),
                            ),
                          )),
                      const SizedBox(width: 14,),
                      Expanded(
                          child: AutoSizeTextField(
                            textCapitalization: TextCapitalization.sentences,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter()
                            ],
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12,right: 16),
                        child: IconButton(
                          icon: const Icon(Icons.gif,size: 40),
                          onPressed: ()async {
                            final gif = await GiphyPicker.pickGif(
                              context: context,
                              apiKey: giphyKey,
                            );
                            if (gif != null) {
                              setState(() {
                                _gif = gif;
                                debugPrint("gif link==========>${_gif?.images.original?.url}");


                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: primary,
                                    title: const Text('GIF Selected'),
                                    content: _gif?.images.original?.url != null
                                        ? Image(image: NetworkImage(_gif!.images.original!.url!))
                                        : const Text('No GIF URL available'),
                                    actions: <Widget>[
                                      IconButton(icon: const Icon(Icons.send), onPressed: () { createComment();
                                      Navigator.of(context).pop();},),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          createComment();
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
Widget buildGifWidget(BuildContext context,String gifUrl) {
  debugPrint("gif link after sending msg========>$gifUrl");
  return Stack(
    alignment: Alignment.center,
    children: [
      Image.network(gifUrl),
      FutureBuilder(
        future: precacheImage(NetworkImage(gifUrl), context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          } else {
            return const SizedBox.shrink(); // Empty container when image is loaded
          }
        },
      ),
    ],
  );
}
