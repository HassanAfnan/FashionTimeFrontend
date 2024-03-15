import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:FashionTime/models/post_model.dart';
import 'package:FashionTime/screens/pages/comment_screen.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/settings_pages/report_screen.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:FashionTime/screens/pages/videos/video_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../models/comment.dart';
import '../../utils/constants.dart';
import 'myProfile.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  bool like = false;
  bool dislike = false;
  bool vote = false;
  String id = "";
  String token = "";
  String name = "";
  List<PostModel> posts = [];
  bool loading = false;
  bool isExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();
  TextEditingController description = TextEditingController();
  bool updateBool = false;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid == true
            ? "ca-app-pub-5248449076034001/6687962197"
            : "ca-app-pub-5248449076034001/8921636030",
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          //print("${ad.adUnitId} Error ==> ${error.message}");
        }),
        request: const AdRequest());
    _bannerAd.load();
    getPosts();
  }

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
    print(name);
    initBannerAd();
  }

  // getPosts() {
  //   posts.clear();
  //   setState(() {
  //     loading = true;
  //   });
  //   try {
  //     https.get(Uri.parse("${serverUrl}/fashionUpload/"), headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer ${token}"
  //     }).then((value) {
  //       setState(() {
  //         loading = false;
  //       });
  //       print("Post data ====> " + jsonDecode(value.body).toString());
  //       jsonDecode(value.body).forEach((value) {
  //         setState(() {
  //           var upload = value["upload"];
  //           var media = upload != null ? upload["media"] : null;
  //           posts.add(PostModel(
  //             value["id"].toString(),
  //             value["description"],
  //             media != null ? media : [],
  //             value["user"]["name"],
  //             value["user"]["pic"] == null
  //                 ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
  //                 : value["user"]["pic"],
  //             false,
  //             value["likesCount"].toString(),
  //             value["disLikesCount"].toString(),
  //             value["commentsCount"].toString(),
  //             value["created"],
  //             "",
  //             value["user"]["id"].toString(),
  //             value["myLike"] == null ? "like" : value["myLike"].toString(),
  //             addMeInFashionWeek: value["addMeInWeekFashion"],
  //           ));
  //           print(
  //               "value of add me in next fashion week is ${value["addMeInWeekFashion"]}");
  //         });
  //       });
  //     });
  //   } catch (e) {
  //     setState(() {
  //       loading = false;
  //     });
  //     print("Error --> ${e}");
  //   }
  // }
  getPosts() {
    posts.clear();
    setState(() {
      loading = true;
    });

    try {
      https.get(Uri.parse("${serverUrl}/fashionUpload/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token}"
      }).then((value) {
        setState(() {
          loading = false;
        });

        Map<String, dynamic> response = jsonDecode(value.body);

        int count = response["count"];
        List<dynamic> results = response["results"];

        results.forEach((result) {
          var upload = result["upload"];
          var media = upload != null ? upload["media"] : null;

          posts.add(PostModel(
            result["id"].toString(),
            result["description"],
            media != null ? media : [],
            result["user"]["name"],
            result["user"]["pic"] == null
                ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                : result["user"]["pic"],
            false,
            result["likesCount"].toString(),
            result["disLikesCount"].toString(),
            result["commentsCount"].toString(),
            result["created"],
            "",
            result["user"]["id"].toString(),
            result["myLike"] == null ? "like" : result["myLike"].toString(),
            addMeInFashionWeek: result["addMeInWeekFashion"],
            isCommentEnabled: result["isCommentOff"]
          ));

          debugPrint(
              "value of add me in next fashion week is ${result["addMeInWeekFashion"]}");
          debugPrint(
              "value of isCommentEnabled is ${result["isCommentOff"]}");
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
  }

  createLike(fashionId) async {
    // setState(() {
    //
    // });
    try {
      // setState(() {
      //
      // });
      Map<String, dynamic> body = {
        "likeEmoji": "1",
        "fashion": fashionId,
        "user": id
      };
      https.post(Uri.parse("${serverUrl}/fashionLikes/"),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }).then((value) {
        print("Response ==> ${value.body}");
        setState(() {
          Fluttertoast.showToast(msg: "Post liked.", backgroundColor: primary);
        });
      }).catchError((error) {
        setState(() {});
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: const Text(
              "Fashion Time",
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
      });
    } catch (e) {
      setState(() {});
      print(e);
    }
  }

  updatePost(postId) {
    setState(() {
      updateBool = true;
    });
    https
        .patch(Uri.parse("${serverUrl}/fashionUpload/${postId}/"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${token}"
            },
            body: json.encode({"description": description.text}))
        .then((value) {
      print(value.body.toString());
      setState(() {
        updateBool = false;
      });
      Navigator.pop(context);
      getPosts();
    });
  }

  saveStyle(fashionId) async {
    setState(() {
      loading = true;
    });
    try {
      setState(() {
        loading = true;
      });
      Map<String, dynamic> body = {
        "fashion": fashionId,
        "user": id,
      };
      https.post(Uri.parse("${serverUrl}/fashionSaved/"),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }).then((value) {
        print("Response ==> ${value.body}");
        print("Response ==> ${value.statusCode}");
        setState(() {
          loading = false;
        });
        if (value.statusCode == 400) {
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
                "You have already saved this fashion.Do you wish to unsave it?",
                style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
              ),
              actions: [
                TextButton(
                  child: const Text("Yes",
                      style:
                          TextStyle(color: ascent, fontFamily: 'Montserrat')),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: const Text("No",
                      style:
                          TextStyle(color: ascent, fontFamily: 'Montserrat')),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ),
          );
        } else {
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
                "Style Saved Successfully.",
                style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
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
        }

        //controller.swipeTop();
      }).catchError((error) {
        setState(() {
          loading = false;
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
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading == true
          ? SpinKitCircle(
              color: primary,
              size: 50,
            )
          : (posts.length <= 0
              ? const Center(child: Text("No Posts"))
              : RefreshIndicator(
                  color: primary,
                  onRefresh: () async {
                    getPosts();
                  },
                  child: ListView.separated(
                      separatorBuilder: (context, index) {
                        if (index % 5 == 0) {
                          return Container(
                            height: _bannerAd.size.height.toDouble(),
                            width: _bannerAd.size.width.toDouble(),
                            child: AdWidget(
                              ad: _bannerAd,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.topRight,
                                        stops: [0.0, 0.99],
                                        tileMode: TileMode.clamp,
                                        colors: <Color>[
                                          secondary,
                                          primary,
                                        ])),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10, top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          posts[index].userName == name
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyProfileScreen(
                                                            id: posts[index]
                                                                .userid,
                                                            username:
                                                                posts[index]
                                                                    .userName,
                                                          )))
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FriendProfileScreen(
                                                            id: posts[index]
                                                                .userid,
                                                            username:
                                                                posts[index]
                                                                    .userName,
                                                          )));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            width: 150,
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                CircleAvatar(
                                                    backgroundColor: dark1,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  50)),
                                                      child: posts[index]
                                                                  .userPic ==
                                                              null
                                                          ? Image.network(
                                                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                              width: 40,
                                                              height: 40,
                                                            )
                                                          : CachedNetworkImage(
                                                              imageUrl:
                                                                  posts[index]
                                                                      .userPic,
                                                              imageBuilder:
                                                                  (context,
                                                                          imageProvider) =>
                                                                      Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.7,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
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
                                                                      url,
                                                                      error) =>
                                                                  ClipRRect(
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              50)),
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                      )),
                                                            ),
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  posts[index].userName,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      color: ascent,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton(
                                          icon: const Icon(
                                            Icons.more_horiz,
                                            color: ascent,
                                          ),
                                          onSelected: (value) {
                                            if (value == 0) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportScreen(
                                                              reportedID: posts[
                                                                      index]
                                                                  .userid)));
                                            }
                                            if (value == 1) {
                                              description.text =
                                                  posts[index].description;
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    StatefulBuilder(builder:
                                                        (context, setState) {
                                                  updateBool = false;
                                                  return AlertDialog(
                                                    backgroundColor: primary,
                                                    title: const Text(
                                                      "Edit Description",
                                                      style: TextStyle(
                                                          color: ascent,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    content: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: TextField(
                                                        maxLines: 5,
                                                        controller: description,
                                                        style: const TextStyle(
                                                            color: ascent,
                                                            fontFamily:
                                                                'Montserrat'),
                                                        decoration:
                                                            const InputDecoration(
                                                                hintStyle: TextStyle(
                                                                    color:
                                                                        ascent,
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        'Montserrat'),
                                                                enabledBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              ascent),
                                                                ),
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              ascent),
                                                                ),
                                                                //enabledBorder: InputBorder.none,
                                                                errorBorder:
                                                                    InputBorder
                                                                        .none,
                                                                //disabledBorder: InputBorder.none,
                                                                alignLabelWithHint:
                                                                    true,
                                                                hintText:
                                                                    "Email or Username"),
                                                        cursorColor:
                                                            Colors.pink,
                                                      ),
                                                    ),
                                                    actions: [
                                                      updateBool == true
                                                          ? const SpinKitCircle(
                                                              color: ascent,
                                                              size: 20,
                                                            )
                                                          : TextButton(
                                                              child: const Text(
                                                                  "Save",
                                                                  style: TextStyle(
                                                                      color:
                                                                          ascent,
                                                                      fontFamily:
                                                                          'Montserrat')),
                                                              onPressed: () {
                                                                setState(() {
                                                                  updateBool =
                                                                      true;
                                                                });
                                                                updatePost(
                                                                    posts[index]
                                                                        .id);
                                                              },
                                                            ),
                                                    ],
                                                  );
                                                }),
                                              );
                                            }
                                            if (value == 2) {
                                              saveStyle(posts[index].id);
                                            }
                                            print(value);
                                            //Navigator.pushNamed(context, value.toString());
                                          },
                                          itemBuilder: (BuildContext bc) {
                                            return [
                                              PopupMenuItem(
                                                value: 0,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.report),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    const Text(
                                                      "Report",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (posts[index].userid == id)
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.edit),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                        "Edit Description",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (posts[index].userid != id)
                                                PopupMenuItem(
                                                  value: 2,
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.save),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                        "Save Post",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ];
                                          })
                                    ],
                                  ),
                                ),
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Text(DateFormat.yMMMEd().format(DateTime.parse(posts[index].date)),style: TextStyle(fontFamily: 'Montserrat',fontSize: 12),),
                              //     ),
                              //     SizedBox(width: 10,)
                              //   ],
                              // ),

                              // const SizedBox(
                              //   height: 10,
                              // ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
                                      //   userid:posts[index].userid,
                                      //   image: posts[index].images,
                                      //   description:  posts[index].description,
                                      //   style: "Fashion Style 2",
                                      //   createdBy: posts[index].userName,
                                      //   profile: posts[index].userPic,
                                      //   likes: posts[index].likeCount,
                                      //   dislikes: posts[index].dislikeCount,
                                      //   mylike: posts[index].mylike,
                                      // )));
                                    },
                                    child: Container(
                                      height: 320,
                                      width: MediaQuery.of(context).size.width *
                                          0.97,
                                      child: CarouselSlider(
                                        carouselController: _controller,
                                        options: CarouselOptions(
                                            enableInfiniteScroll: false,
                                            height: 320.0,
                                            autoPlay: false,
                                            enlargeCenterPage: true,
                                            viewportFraction: 0.99,
                                            aspectRatio: 2.0,
                                            initialPage: 0,
                                            onPageChanged: (ind, reason) {
                                              setState(() {
                                                _current = ind;
                                              });
                                            }),
                                        items: posts[index].images.map((i) {
                                          return i["type"] == "video"
                                              ? Container(
                                                  color: Colors.black,
                                                  child:
                                                      UsingVideoControllerExample(
                                                    path: i["video"],
                                                  ))
                                              : Builder(
                                                  builder:
                                                      (BuildContext context) {
                                                    return CachedNetworkImage(
                                                      imageUrl: i["image"],
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
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
                                                      placeholder:
                                                          (context, url) =>
                                                              SpinKitCircle(
                                                        color: primary,
                                                        size: 60,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.84,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        decoration:
                                                            BoxDecoration(
                                                          image: DecorationImage(
                                                              image: Image.network(
                                                                      "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png")
                                                                  .image,
                                                              fit: BoxFit.fill),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text(posts[index].images.length.toString()),
                              ),
                              posts[index].images.length == 1
                                  ? const SizedBox()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: posts[index]
                                          .images
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        return GestureDetector(
                                          onTap: () => _controller
                                              .animateToPage(entry.key),
                                          child: Container(
                                            width: 12.0,
                                            height: 12.0,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 4.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    .withOpacity(
                                                        _current == entry.key
                                                            ? 0.9
                                                            : 0.4)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                height: 2,
                                thickness: 2,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, right: 0.0),
                                  child: posts[index].userid == id
                                      ? Row(
                                          children: [
                                            posts[index].addMeInFashionWeek ==
                                                    true
                                                ? posts[index].mylike != "like"
                                                    ? IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          Icons.favorite,
                                                          size: 20,
                                                        ))
                                                    : IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          FontAwesomeIcons
                                                              .heart,
                                                          size: 20,
                                                        ))
                                                : posts[index].mylike != "like"
                                                    ? IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          Icons.star,
                                                          color: Colors.orange,
                                                          size: 24,
                                                        ))
                                                    : GestureDetector(
                                                        onDoubleTap: () {},
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                              Icons
                                                                  .star_border_outlined,
                                                              size: 24,
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                      )
                                            // IconButton(
                                            //             onPressed: () {
                                            //             },
                                            //
                                            //             icon: const Icon(
                                            //               Icons
                                            //                   .star_border_outlined,
                                            //               color: Colors.orange,
                                            //               size: 24,
                                            //             ))
                                            ,
                                            posts[index].likeCount == "0"
                                                ?
                                                // Text(
                                                //         "N/A",
                                                //         style: TextStyle(
                                                //             fontFamily:
                                                //                 'Montserrat',
                                                //             fontSize: 12,
                                                //             color: primary),
                                                //       )
                                                const SizedBox()
                                                : Text(posts[index].likeCount),
                                            posts[index].isCommentEnabled==true?
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CommentScreen(
                                                                  id: posts[
                                                                          index]
                                                                      .id,
                                                                  pic: posts[
                                                                          index]
                                                                      .userPic)));
                                                },
                                                icon: const Icon(
                                                  FontAwesomeIcons.comment,
                                                  size: 20,
                                                )):const SizedBox(),
                                            Padding(
                                                padding:  EdgeInsets.only(
                                                    left:
                                                    posts[index].isCommentEnabled==true?
                                                    MediaQuery.of(context).size.width*0.35: MediaQuery.of(context).size.width*0.5),
                                                child: Text(
                                                  DateFormat.yMMMEd().format(
                                                      DateTime.parse(
                                                          posts[index].date)),
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 12),
                                                )),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            posts[index].addMeInFashionWeek ==
                                                    true
                                                ? posts[index].mylike != "like"
                                                    ? IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          Icons.favorite,
                                                          size: 20,
                                                        ))
                                                    : IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          FontAwesomeIcons
                                                              .heart,
                                                          size: 20,
                                                        ))
                                                : posts[index].mylike != "like"
                                                    ? IconButton(
                                                        onPressed: () {},
                                                        icon: const Icon(
                                                          Icons.star,
                                                          color: Colors.orange,
                                                          size: 24,
                                                        ))
                                                    : GestureDetector(
                                                        onDoubleTap: () {
                                                          createLike(
                                                              posts[index].id);
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                            Icons
                                                                .star_border_outlined,
                                                            color:
                                                                Colors.orange,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                            posts[index].likeCount == "0"
                                                ?
                                                // Text(
                                                //   "N/A",
                                                //   style: TextStyle(
                                                //       fontFamily:
                                                //       'Montserrat',
                                                //       fontSize: 12,
                                                //       color: primary),
                                                // )
                                                const SizedBox()
                                                : Text(
                                                    "${posts[index].likeCount}"),
                                            posts[index].isCommentEnabled==true?
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CommentScreen(
                                                                  id: posts[
                                                                          index]
                                                                      .id,
                                                                  pic: posts[
                                                                          index]
                                                                      .userPic)));
                                                },
                                                icon: const Icon(
                                                  FontAwesomeIcons.comment,
                                                  size: 20,
                                                )):const SizedBox(),
                                            Padding(
                                                padding:  EdgeInsets.only(
                                                    left: MediaQuery.of(context).size.width*0.3),
                                                child: Text(
                                                  DateFormat.yMMMEd().format(
                                                      DateTime.parse(
                                                          posts[index].date)),
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 12),
                                                )),
                                          ],
                                        )
                                  // Row(
                                  //         children: [
                                  //           // posts[index].likeCount == "0" ? Text("N/A",style:TextStyle(fontFamily: 'Montserrat', fontSize: 12,color: primary) ,) : Text("${posts[index].likeCount}"),
                                  //           IconButton(
                                  //               onPressed: () {
                                  //                 Navigator.push(
                                  //                     context,
                                  //                     MaterialPageRoute(
                                  //                         builder: (context) =>
                                  //                             CommentScreen(
                                  //                                 id: posts[
                                  //                                         index]
                                  //                                     .id,
                                  //                                 pic: posts[
                                  //                                         index]
                                  //                                     .userPic)));
                                  //               },
                                  //               icon: Icon(
                                  //                 FontAwesomeIcons.comment,
                                  //                 size: 20,
                                  //               )),
                                  //           //posts[index].commentCount=="0"? Text("N/A",style:TextStyle(fontFamily: 'Montserrat', fontSize: 12,color: primary) ,) : Text("${posts[index].commentCount}"),
                                  //         ],
                                  //       ),
                                  ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  posts[index].description.toString().length >
                                          50
                                      ? Expanded(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  isExpanded
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                              posts[index]
                                                                  .userName,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "${posts[index].description.substring(0, 7)}...",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 12,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            )
                                                          ],
                                                        )
                                                      : Text(
                                                          posts[index]
                                                                  .userName +
                                                              posts[index]
                                                                  .description,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 12)),
                                                  TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          isExpanded =
                                                              !isExpanded;
                                                        });
                                                      },
                                                      child: Text(
                                                          isExpanded
                                                              ? "Show More"
                                                              : "Show Less",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor)))
                                                ],
                                              )),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    posts[index].userName,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    posts[index].description,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                )),
    );
  }
}

// class VideoPlay extends StatefulWidget {
//   String? pathh;
//
//   @override
//   _VideoPlayState createState() => _VideoPlayState();
//
//   VideoPlay({
//     Key? key,
//     this.pathh, // Video from assets folder
//   }) : super(key: key);
// }
//
// class _VideoPlayState extends State<VideoPlay> {
//   ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
//   VideoPlayerController? controller;
//   late Future<void> futureController;
//
//   initVideo() {
//     controller = VideoPlayerController.network(widget.pathh!);
//
//     futureController = controller!.initialize();
//   }
//
//   @override
//   void initState() {
//     initVideo();
//     controller!.addListener(() {
//       if (controller!.value.isInitialized) {
//         currentPosition.value = controller!.value;
//       }
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     controller!.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: futureController,
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Padding(
//             padding: const EdgeInsets.all(135.0),
//             child: const CircularProgressIndicator(),
//           );
//         } else {
//           return SizedBox(
//             height: controller!.value.size.height,
//             width: double.infinity,
//             child: AspectRatio(
//                 aspectRatio: controller!.value.aspectRatio,
//                 child: Stack(children: [
//                   Positioned.fill(
//                       child: Container(
//                           foregroundDecoration: BoxDecoration(
//                             gradient: LinearGradient(
//                                 colors: [
//                                   Colors.black.withOpacity(.7),
//                                   Colors.transparent
//                                 ],
//                                 stops: [
//                                   0,
//                                   .3
//                                 ],
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter),
//                           ),
//                           child: VideoPlayer(controller!))),
//                   Positioned.fill(
//                     child: Column(
//                       children: [
//                         Expanded(
//                           flex: 8,
//                           child: Row(
//                             children: [
//                               // Expanded(
//                               //   flex: 3,
//                               //   child: GestureDetector(
//                               //     onDoubleTap: () async {
//                               //       Duration? position =
//                               //       await controller!.position;
//                               //       setState(() {
//                               //         controller!.seekTo(Duration(
//                               //             seconds: position!.inSeconds - 10));
//                               //       });
//                               //     },
//                               //     child: const Icon(
//                               //       Icons.fast_rewind_rounded,
//                               //       color: Colors.black,
//                               //       size: 40,
//                               //     ),
//                               //   ),
//                               // ),
//                               Expanded(
//                                   flex: 4,
//                                   child: IconButton(
//                                     icon: Icon(
//                                       controller!.value.isPlaying
//                                           ? Icons.pause
//                                           : Icons.play_arrow,
//                                       color: Colors.black,
//                                       size: 40,
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         if (controller!.value.isPlaying) {
//                                           controller!.pause();
//                                         } else {
//                                           controller!.play();
//                                         }
//                                       });
//                                     },
//                                   )),
//                               // Expanded(
//                               //   flex: 3,
//                               //   child: GestureDetector(
//                               //     onDoubleTap: () async {
//                               //       Duration? position =
//                               //       await controller!.position;
//                               //       setState(() {
//                               //         controller!.seekTo(Duration(
//                               //             seconds: position!.inSeconds + 10));
//                               //       });
//                               //     },
//                               //     child: const Icon(
//                               //       Icons.fast_forward_rounded,
//                               //       color: Colors.black,
//                               //       size: 40,
//                               //     ),
//                               //   ),
//                               // ),
//                             ],
//                           ),
//                         ),
//                         // Expanded(
//                         //     flex: 2,
//                         //     child: Align(
//                         //       alignment: Alignment.bottomCenter,
//                         //       child: ValueListenableBuilder(
//                         //           valueListenable: currentPosition,
//                         //           builder: (context,
//                         //               VideoPlayerValue? videoPlayerValue, w) {
//                         //             return Padding(
//                         //               padding: const EdgeInsets.symmetric(
//                         //                   horizontal: 20, vertical: 10),
//                         //               child: Row(
//                         //                 children: [
//                         //                   Text(
//                         //                     videoPlayerValue!.position
//                         //                         .toString()
//                         //                         .substring(
//                         //                         videoPlayerValue.position
//                         //                             .toString()
//                         //                             .indexOf(':') +
//                         //                             1,
//                         //                         videoPlayerValue.position
//                         //                             .toString()
//                         //                             .indexOf('.')),
//                         //                     style: const TextStyle(
//                         //                         color: Colors.white,
//                         //                         fontSize: 22),
//                         //                   ),
//                         //                   const Spacer(),
//                         //                   Text(
//                         //                     videoPlayerValue.duration
//                         //                         .toString()
//                         //                         .substring(
//                         //                         videoPlayerValue.duration
//                         //                             .toString()
//                         //                             .indexOf(':') +
//                         //                             1,
//                         //                         videoPlayerValue.duration
//                         //                             .toString()
//                         //                             .indexOf('.')),
//                         //                     style: const TextStyle(
//                         //                         color: Colors.white,
//                         //                         fontSize: 22),
//                         //                   ),
//                         //                 ],
//                         //               ),
//                         //             );
//                         //           }),
//                         //     ))
//                       ],
//                     ),
//                   ),
//                 ])),
//           );
//         }
//       },
//     );
//   }
// }

// class PlayVideoFromNetwork extends StatefulWidget {
//   final String path;
//   const PlayVideoFromNetwork({Key? key, required this.path}) : super(key: key);
//
//   @override
//   State<PlayVideoFromNetwork> createState() => _PlayVideoFromNetworkState();
// }
//
// class _PlayVideoFromNetworkState extends State<PlayVideoFromNetwork> {
//   late final PodPlayerController controller;
//
//   @override
//   void initState() {
//     controller = PodPlayerController(
//       playVideoFrom: PlayVideoFrom.network(
//         widget.path,
//       ),
//     )..initialise().then((value){
//       setState(() {
//         controller.pause();
//         controller.mute();
//       });
//     });
//     super.initState();
//   }
//
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PodVideoPlayer(
//         controller: controller);
//   }
// }
