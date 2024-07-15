import 'dart:convert';
import 'package:FashionTime/screens/pages/liked_reels/liked_reel_interface.dart';
import 'package:FashionTime/screens/pages/post_like_user.dart';
import 'package:FashionTime/screens/pages/settings_pages/report_screen.dart';
import 'package:FashionTime/screens/pages/videos/video_file.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/post_model.dart';
import 'fashionComments/comment_screen.dart';
import 'friend_profile.dart';
import 'myProfile.dart';

class MyHundredLikedPost extends StatefulWidget {
  const MyHundredLikedPost({super.key});
  @override
  State<MyHundredLikedPost> createState() => _MyHundredLikedPostState();
}

class _MyHundredLikedPostState extends State<MyHundredLikedPost> {
  String id = "";
  String token = "";
  String name = '';
  List <PostModel>posts = [];
  List fashionReels = [];
  bool loading = true;
  bool updateBool = false;
  int _current = 0;
  TextEditingController description = TextEditingController();
  bool isExpanded = true;
  final CarouselController _controller = CarouselController();
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
    debugPrint("your token ==============>$token");
    getLikedPost();
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
  String handleEmojis(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }
  getLikedPost() {
    String url = "$serverUrl/fashionapi/hundred-liked/";
    try {
      https.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        if (value.statusCode == 200) {
          setState(() {
            loading = false;
            Map<String, dynamic> response = jsonDecode(value.body);
            List<dynamic> results = response["results"]['fashion_styles'];
            for (var result in results) {
              var upload = result["upload"];
              if(response["next"]==null){
              }

              var media = upload != null ? upload["media"] : null;

              posts.add(PostModel(
                  result["id"].toString(),
                  result["description"],
                  media ?? [],
                  result["user"]["name"],
                  result["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                  false,
                  result["likesCount"].toString(),
                  result["disLikesCount"].toString(),
                  result["commentsCount"].toString(),
                  result["created"],
                  "",
                  result["user"]["id"].toString(),
                  result["myLike"] == null ? "like" : result["myLike"].toString(),
                  {},
                  {},
                  addMeInFashionWeek: result["addMeInWeekFashion"],
                  isCommentEnabled: result["isCommentOff"]));

              debugPrint(
                  "value of add me in next fashion week is ${result["addMeInWeekFashion"]}");
              debugPrint("value of isCommentEnabled is ${result["isCommentOff"]}");
            }
            fashionReels = response['results']['fashion_reels'];
          });
          debugPrint(
              "response from get api ==========>${value.body.toString()}");

          debugPrint(
              "length of fashion styles and fashion reels is ========>${posts.length}&${fashionReels.length}");
        }
      });
    } catch (e) {
      debugPrint("Error received while fetching api========> ${e.toString()}");
    }
  }

  @override
  void initState() {
    getCashedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
          backgroundColor: primary,
          title: const Text("100 Liked Posts",style: TextStyle(fontFamily: 'Montserrat'),),
          actions: [IconButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyLikedReelsInterfaceScreen(),));
          }, icon:  Image.asset('assets/flicksProfileIcon.png', height: 28,color: ascent,))],
        ),
        body: loading
            ? Center(
                child: SpinKitCircle(
                  color: primary,
                ),
              )
            : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
              return Card(
                elevation: 10,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10,
                            top: 5,
                            bottom: 5),
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
                                              id: posts[
                                              index]
                                                  .userid,
                                              username: posts[
                                              index]
                                                  .userName,
                                            )))
                                    : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FriendProfileScreen(
                                              id: posts[
                                              index]
                                                  .userid,
                                              username: posts[
                                              index]
                                                  .userName,
                                            )));
                              },
                              child: Padding(
                                padding:
                                const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 150,
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      CircleAvatar(
                                          backgroundColor:
                                          dark1,
                                          child: ClipRRect(
                                            borderRadius:
                                            const BorderRadius
                                                .all(
                                                Radius
                                                    .circular(
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
                                              imageUrl: posts[
                                              index]
                                                  .userPic,
                                              imageBuilder:
                                                  (context,
                                                  imageProvider) =>
                                                  Container(
                                                    height: MediaQuery.of(context)
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
                                                        color:
                                                        primary,
                                                        size: 10,
                                                      )),
                                              errorWidget: (context,
                                                  url,
                                                  error) =>
                                                  ClipRRect(
                                                      borderRadius:
                                                      const BorderRadius.all(Radius.circular(50)),
                                                      child: Image.network(
                                                        "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                        width: 40,
                                                        height: 40,
                                                      )),
                                            ),
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        posts[index].userName,
                                        style: const TextStyle(
                                            fontFamily:
                                            'Montserrat',
                                            color: ascent,
                                            fontWeight:
                                            FontWeight
                                                .bold),
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
                                                    reportedID:
                                                    posts[index]
                                                        .userid)));
                                  }
                                  if (value == 1) {
                                    description.text =
                                        posts[index]
                                            .description;
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          StatefulBuilder(
                                              builder: (context,
                                                  setState) {
                                                updateBool = false;
                                                return AlertDialog(
                                                  backgroundColor:
                                                  primary,
                                                  title: const Text(
                                                    "Edit Description",
                                                    style: TextStyle(
                                                        color: ascent,
                                                        fontFamily:
                                                        'Montserrat',
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  content: SizedBox(
                                                    width:
                                                    MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width,
                                                    child: TextField(
                                                      maxLines: 5,
                                                      controller:
                                                      description,
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
                                                              fontWeight: FontWeight
                                                                  .w400,
                                                              fontFamily:
                                                              'Montserrat'),
                                                          enabledBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                            BorderSide(color: ascent),
                                                          ),
                                                          focusedBorder:
                                                          UnderlineInputBorder(
                                                            borderSide:
                                                            BorderSide(color: ascent),
                                                          ),
                                                          //enabledBorder: InputBorder.none,
                                                          errorBorder:
                                                          InputBorder
                                                              .none,
                                                          //disabledBorder: InputBorder.none,
                                                          alignLabelWithHint:
                                                          true,
                                                          hintText:
                                                          "Description "),
                                                      cursorColor:
                                                      Colors.pink,
                                                    ),
                                                  ),
                                                  actions: [
                                                    updateBool == true
                                                        ? const SpinKitCircle(
                                                      color:
                                                      ascent,
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
                                                      onPressed:
                                                          () {
                                                        setState(
                                                                () {
                                                              updateBool =
                                                              true;
                                                            });
                                                        // updatePost(
                                                        //     posts[index]
                                                        //         .id);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }),
                                    );
                                  }
                                  if (value == 2) {
                                    // saveStyle(posts[index].id);
                                  }
                                  print(value);
                                  //Navigator.pushNamed(context, value.toString());
                                },
                                itemBuilder: (BuildContext bc) {
                                  return [
                                    PopupMenuItem(
                                      value: 0,
                                      child: Row(
                                        children: const [
                                          Icon(Icons.report),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Report",
                                            style: TextStyle(
                                                fontFamily:
                                                'Montserrat'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (posts[index].userid ==
                                        id)
                                      PopupMenuItem(
                                        value: 1,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.edit),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Edit Description",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Montserrat'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (posts[index].userid !=
                                        id)
                                      PopupMenuItem(
                                        value: 2,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.save),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
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
                      mainAxisAlignment:
                      MainAxisAlignment.center,
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
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 1,
                            maxScale: 3,
                            child: SizedBox(
                              height: 450,
                              width: MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.97,
                              child: CarouselSlider(
                                carouselController: _controller,
                                options: CarouselOptions(
                                    enableInfiniteScroll: false,
                                    height: 450.0,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    viewportFraction: 0.99,
                                    aspectRatio: 2.0,
                                    initialPage: 0,
                                    onPageChanged:
                                        (ind, reason) {
                                      setState(() {
                                        _current = ind;
                                      });
                                    }),
                                items: posts[index]
                                    .images
                                    .map((i) {
                                  return i["type"] == "video"
                                      ? Container(
                                      color: Colors.black,
                                      child:
                                      UsingVideoControllerExample(
                                        path: i["video"],
                                      ))
                                      : InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1,
                                    maxScale: 3,
                                    child: Builder(
                                      builder:
                                          (BuildContext
                                      context) {
                                        return CachedNetworkImage(
                                          imageUrl:
                                          i["image"],
                                          imageBuilder:
                                              (context,
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
                                                    fit: BoxFit
                                                        .cover,
                                                  ),
                                                ),
                                              ),
                                          placeholder: (context,
                                              url) =>
                                              SpinKitCircle(
                                                color:
                                                primary,
                                                size: 60,
                                              ),
                                          errorWidget: (context,
                                              url,
                                              error) =>
                                              Container(
                                                height: MediaQuery.of(
                                                    context)
                                                    .size
                                                    .height *
                                                    0.9,
                                                width: MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width,
                                                decoration:
                                                BoxDecoration(
                                                  image: DecorationImage(
                                                      image: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png")
                                                          .image,
                                                      fit: BoxFit
                                                          .fill),
                                                ),
                                              ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(posts[index]
                    //       .images
                    //       .length
                    //       .toString()),
                    // ),
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
                            margin: const EdgeInsets
                                .symmetric(
                                vertical: 8.0,
                                horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context)
                                    .brightness ==
                                    Brightness
                                        .dark
                                    ? Colors.white
                                    : Colors.black)
                                    .withOpacity(
                                    _current ==
                                        entry.key
                                        ? 0.9
                                        : 0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // const Divider(
                    //   height: 2,
                    //   thickness: 2,
                    // ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, right: 0.0),
                        child: posts[index].userid == id
                            ? Row(
                          children: [
                            posts[index].addMeInFashionWeek ==
                                true
                                ? posts[index].mylike !=
                                "like"
                                ? IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.favorite,
                                  size: 20,

                                ))
                                : IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                            PostLikeUserScreen(fashionId: posts[index].id),
                                      ));
                                },
                                icon: const Icon(
                                  FontAwesomeIcons
                                      .heart,
                                  color: Colors.red,
                                  size: 20,
                                ))
                                : posts[index].mylike !=
                                "like"
                                ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                            PostLikeUserScreen(fashionId: posts[index].id),
                                      ));
                                },
                                child: const Icon(
                                  Icons.star,
                                  color: Colors
                                      .orange,
                                  size: 24,
                                ))
                                : GestureDetector(
                              onDoubleTap:
                                  () {},
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                          PostLikeUserScreen(fashionId: posts[index].id),
                                    ));
                              },
                              child:
                              const Padding(
                                padding:
                                EdgeInsets
                                    .all(
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
                                : Text(posts[index]
                                .likeCount),
                            posts[index].isCommentEnabled ==
                                true
                                ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CommentScreen(
                                              id: posts[index]
                                                  .id,
                                              pic: posts[index]
                                                  .userPic)));
                                },
                                icon: const Icon(
                                  FontAwesomeIcons
                                      .comment,
                                  size: 20,
                                ))
                                : const SizedBox(),
                            // IconButton(
                            //     onPressed: () async {
                            //
                            //       showModalBottomSheet(
                            //           context: context,
                            //           builder: (BuildContext bc) {
                            //             return Wrap(
                            //               children: <Widget>[
                            //                 ListTile(
                            //                   leading:  SizedBox(
                            //                       width: 28,
                            //                       height:28 ,
                            //                       child: Image.asset("assets/shareIcon.png",)),
                            //                   title: const Text(
                            //                     'Share with friends',
                            //                     style: TextStyle(fontFamily: 'Montserrat'),
                            //                   ),
                            //                   onTap: () {
                            //                     String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                            //                     Navigator.pop(context);
                            //                     _showFriendsList(imageUrl,posts[index].id);
                            //
                            //                   },
                            //                 ),
                            //                 ListTile(
                            //                   leading: const Icon(Icons.share),
                            //                   title: const Text(
                            //                     'Others',
                            //                     style: TextStyle(fontFamily: 'Montserrat'),
                            //                   ),
                            //                   onTap: () async{
                            //                     String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                            //                     debugPrint("image link to share: $imageUrl");
                            //                     await Share.share("${posts[index].description.toString()}\n\n https://fashiontime-28e3a.web.app/details/${posts[index].id}"
                            //                     );
                            //                   },
                            //                 ),
                            //
                            //               ],
                            //             );
                            //           });
                            //     },
                            //     icon: const Icon(
                            //       FontAwesomeIcons.share,
                            //       size: 20,
                            //     )
                            // )


                            // Padding(
                            //     padding:  EdgeInsets.only(
                            //         left:
                            //         posts[index].isCommentEnabled==true?
                            //         MediaQuery.of(context).size.width*0.35: MediaQuery.of(context).size.width*0.5),
                            //     child: Text(
                            //       // DateFormat.yMMMEd().format(
                            //       //     DateTime.parse(
                            //       //         posts[index].date)),
                            //       formatTimeDifference(posts[index].date),
                            //       style: const TextStyle(
                            //           fontFamily: 'Montserrat',
                            //           fontSize: 12),
                            //     )),
                          ],
                        )
                            : Row(
                          children: [
                            posts[index].addMeInFashionWeek ==
                                true
                                ? posts[index].mylike !=
                                "like"
                                ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                            PostLikeUserScreen(fashionId: posts[index].id),
                                      ));
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: Colors.red,
                                ))
                                : IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                            PostLikeUserScreen(fashionId: posts[index].id),
                                      ));
                                },
                                icon: const Icon(
                                  FontAwesomeIcons
                                      .heart,
                                  size: 20,
                                  color: Colors.red,
                                ))
                                : posts[index].mylike !=
                                "like"
                                ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                            PostLikeUserScreen(fashionId: posts[index].id),
                                      ));
                                },
                                child:
                                const Padding(
                                  padding: EdgeInsets
                                      .only(
                                      left:
                                      4),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors
                                        .orange,
                                    size: 24,
                                  ),
                                ))
                                : GestureDetector(
                              onDoubleTap: () {
                                // createLike(
                                //     posts[index]
                                //         .id);
                              },
                              onTap: () {
                                debugPrint(
                                    "pressed");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                          PostLikeUserScreen(fashionId: posts[index].id),
                                    ));
                              },
                              child:
                              const Padding(
                                padding:
                                EdgeInsets
                                    .all(
                                    8.0),
                                child: Icon(
                                  Icons
                                      .star_border_outlined,
                                  color: Colors
                                      .orange,
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
                                :
                            Text(posts[index]
                                .likeCount),
                            posts[index].isCommentEnabled ==
                                true
                                ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CommentScreen(
                                              id: posts[index]
                                                  .id,
                                              pic: posts[index]
                                                  .userPic)));
                                },
                                icon: const Icon(
                                  FontAwesomeIcons
                                      .comment,
                                  size: 20,
                                ))
                                : const SizedBox(),
                            // IconButton(
                            //     onPressed: () async {
                            //
                            //       showModalBottomSheet(
                            //           context: context,
                            //           builder: (BuildContext bc) {
                            //             return Wrap(
                            //               children: <Widget>[
                            //                 ListTile(
                            //                   leading: SizedBox(
                            //                       width: 28,
                            //                       height:28 ,
                            //                       child: Image.asset("assets/shareIcon.png",)),
                            //                   title: const Text(
                            //                     'Share with friends',
                            //                     style: TextStyle(fontFamily: 'Montserrat'),
                            //                   ),
                            //                   onTap: () {
                            //                     String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                            //                     Navigator.pop(context);
                            //                     _showFriendsList(imageUrl,posts[index].id);
                            //
                            //                   },
                            //                 ),
                            //                 ListTile(
                            //                   leading: const Icon(Icons.share),
                            //                   title: const Text(
                            //                     'Others',
                            //                     style: TextStyle(fontFamily: 'Montserrat'),
                            //                   ),
                            //                   onTap: () async{
                            //                     String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                            //                     debugPrint("image link to share: $imageUrl");
                            //                     await Share.share("${posts[index].description.toString()}\n\n https://fashiontime-28e3a.web.app/details/${posts[index].id}"
                            //                     );
                            //                   },
                            //                 ),
                            //
                            //               ],
                            //             );
                            //           });
                            //     },
                            //     icon: const Icon(
                            //       FontAwesomeIcons.share,
                            //       size: 20,
                            //     )
                            // )
                            // Padding(
                            //     padding:  EdgeInsets.only(
                            //         left: MediaQuery.of(context).size.width*0.3),
                            //     child: Text(
                            //       // DateFormat.yMMMEd().format(
                            //       //     DateTime.parse(
                            //       //         posts[index].date)),
                            //       formatTimeDifference(posts[index].date),
                            //       style: const TextStyle(
                            //           fontFamily: 'Montserrat',
                            //           fontSize: 12),
                            //     )),
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
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        posts[index]
                            .description
                            .toString()
                            .length >
                            50
                            ? Expanded(
                          child: Padding(
                              padding:
                              const EdgeInsets.all(
                                  8.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
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
                                            fontSize:
                                            12,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${handleEmojis(posts[index].description.substring(0, 7))}...",
                                        style:
                                        const TextStyle(
                                          fontFamily:
                                          'Montserrat',
                                          fontSize:
                                          12,
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
                                          handleEmojis( posts[index]
                                              .description),
                                      style: const TextStyle(
                                          fontFamily:
                                          'Montserrat',
                                          fontSize:
                                          12)),
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
                                                  .primaryColor))),
                                ],
                              )),
                        )
                            : Padding(
                            padding:
                            const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                                          FontWeight
                                              .bold),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      handleEmojis( posts[index]
                                          .description),
                                      style: const TextStyle(
                                          fontFamily:
                                          'Montserrat',
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.01,
                                ),
                                Align(
                                  alignment:
                                  Alignment.topLeft,
                                  child: Text(
                                    // DateFormat.yMMMEd().format(
                                    //     DateTime.parse(
                                    //         posts[index].date)),
                                    formatTimeDifference(
                                        posts[index].date),
                                    style: const TextStyle(
                                        fontFamily:
                                        'Montserrat',
                                        fontSize: 12),
                                  ),
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

            },));
  }
}
