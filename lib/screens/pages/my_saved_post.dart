import 'dart:convert';

import 'package:FashionTime/screens/pages/videos/video_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart'as https;
import '../../models/post_model.dart';
import '../../utils/constants.dart';
import 'fashionComments/comment_screen.dart';
class MySavedPosts extends StatefulWidget {
  const MySavedPosts({super.key});

  @override
  State<MySavedPosts> createState() => _MySavedPostsState();
}
String id = "";
String token = "";
List<PostModel> myPosts = [];
bool loading=false;
bool loading1=false;
bool isExpanded = true;
int _current = 0;
final CarouselController _controller = CarouselController();


class _MySavedPostsState extends State<MySavedPosts> {
  getCashedData() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    getLikedPosts();
    debugPrint(token);
  }
  Future<void> getLikedPosts() async {
    setState(() {
      loading = true;
    });

    try {
      https.Response response = await https.get(
        Uri.parse("$serverUrl/fashionLikes/my-liked-fashions/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        for (var item in responseData) {
          if (item["upload"]["media"][0]["type"] == "video") {
            String? thumbnail = await VideoThumbnail.thumbnailFile(
              video: item["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128,
              quality: 25,
            );
            setState(() {
              myPosts.add(PostModel(
                item["id"].toString(),
                item["description"],
                List<Map<String, dynamic>>.from(item["upload"]["media"]),
                item["user"]["name"],
                item["user"]["pic"] ?? "default_user_pic_url",
                false, // Adjust this based on your logic
                item["likesCount"].toString(),
                item["disLikesCount"].toString(),
                item["commentsCount"].toString(),
                item["created"],
                thumbnail!,
                addMeInFashionWeek: item["addMeInWeekFashion"],
                item["user"]["id"].toString(),
                item["myLike"] == null ? "like" : item["myLike"].toString(),
                {},
                {}
              ));
            });
          } else {
            setState(() {
              myPosts.add(PostModel(
                item["id"].toString(),
                item["description"],
                List<Map<String, dynamic>>.from(item["upload"]["media"]),
                item["user"]["name"],
                item["user"]["pic"] ?? "default_user_pic_url",
                false, // Adjust this based on your logic
                item["likesCount"].toString(),
                item["disLikesCount"].toString(),
                item["commentsCount"].toString(),
                item["created"],
                "", // No thumbnail for images
                item["user"]["id"].toString(),
                item["myLike"] == null ? "like" : item["myLike"].toString(),
                {},
                {}
              ));
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("Error --> $e");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    getCashedData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                  ])),
        ),
        backgroundColor: primary,
        title: const Text(
          "Posts",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body:
      loading1?
      SpinKitCircle(
        color: primary,
        size: 50,
      ):
      ListView.builder(
        itemCount: myPosts.length,
        itemBuilder: (context, index) {
          return
            Card(
              color: Colors.transparent,
              elevation: 10,
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
                              // myPosts[index].userName == name
                              //     ? Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             MyProfileScreen(
                              //               id: myPosts[index]
                              //                   .userid,
                              //               username:
                              //               myPosts[index]
                              //                   .userName,
                              //             )))
                              //     : Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             FriendProfileScreen(
                              //               id: myPosts[index]
                              //                   .userid,
                              //               username:
                              //               myPosts[index]
                              //                   .userName,
                              //             )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
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
                                          const BorderRadius.all(
                                              Radius.circular(
                                                  50)),
                                          child: myPosts[index]
                                              .userPic ==
                                              null
                                              ? Image.network(
                                            "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                            width: 40,
                                            height: 40,
                                          )
                                              : CachedNetworkImage(
                                            imageUrl: myPosts[
                                            index]
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
                                                      color:
                                                      primary,
                                                      size: 10,
                                                    )),
                                            errorWidget: (context,
                                                url,
                                                error) =>
                                                ClipRRect(
                                                    borderRadius:
                                                    const BorderRadius.all(Radius.circular(
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
                                      myPosts[index].userName,
                                      style: const TextStyle(
                                          fontFamily:
                                          'Montserrat',
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
                                  // debugPrint("=================>delete button");
                                  // debugPrint("=================>fashion id is ${myPosts[index].id}");
                                  // deleteFashionPost(myPosts[index].id);
                                }
                                if (value == 1) {
                                  // description.text =
                                  //     myPosts[index].description;
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (context) =>
                                  //       StatefulBuilder(builder:
                                  //           (context, setState) {
                                  //         updateBool = false;
                                  //         return AlertDialog(
                                  //           backgroundColor: primary,
                                  //           title: const Text(
                                  //             "Edit Description",
                                  //             style: TextStyle(
                                  //                 color: ascent,
                                  //                 fontFamily:
                                  //                 'Montserrat',
                                  //                 fontWeight:
                                  //                 FontWeight
                                  //                     .bold),
                                  //           ),
                                  //           content: SizedBox(
                                  //             width: MediaQuery.of(
                                  //                 context)
                                  //                 .size
                                  //                 .width
                                  //             ,
                                  //             child: TextField(
                                  //               maxLines: 5,
                                  //               controller:
                                  //               description,
                                  //               style: const TextStyle(
                                  //                   color: ascent,
                                  //                   fontFamily:
                                  //                   'Montserrat'),
                                  //               decoration:
                                  //               const InputDecoration(
                                  //                   hintStyle: TextStyle(
                                  //                       color:
                                  //                       ascent,
                                  //                       fontSize:
                                  //                       17,
                                  //                       fontWeight:
                                  //                       FontWeight
                                  //                           .w400,
                                  //                       fontFamily:
                                  //                       'Montserrat'),
                                  //                   enabledBorder:
                                  //                   UnderlineInputBorder(
                                  //                     borderSide:
                                  //                     BorderSide(
                                  //                         color:
                                  //                         ascent),
                                  //                   ),
                                  //                   focusedBorder:
                                  //                   UnderlineInputBorder(
                                  //                     borderSide:
                                  //                     BorderSide(
                                  //                         color:
                                  //                         ascent),
                                  //                   ),
                                  //                   //enabledBorder: InputBorder.none,
                                  //                   errorBorder:
                                  //                   InputBorder
                                  //                       .none,
                                  //                   //disabledBorder: InputBorder.none,
                                  //                   alignLabelWithHint:
                                  //                   true,
                                  //                   hintText:
                                  //                   "Email or Username"),
                                  //               cursorColor:
                                  //               Colors.pink,
                                  //             ),
                                  //           ),
                                  //           actions: [
                                  //             updateBool == true
                                  //                 ? const SpinKitCircle(
                                  //               color: ascent,
                                  //               size: 20,
                                  //             )
                                  //                 : TextButton(
                                  //               child: const Text(
                                  //                   "Save",
                                  //                   style: TextStyle(
                                  //                       color:
                                  //                       ascent,
                                  //                       fontFamily:
                                  //                       'Montserrat')),
                                  //               onPressed: () {
                                  //                 setState(() {
                                  //                   updateBool =
                                  //                   true;
                                  //                 });
                                  //                 // updatePost(
                                  //                 //     myPosts[index]
                                  //                 //         .id);
                                  //               },
                                  //             ),
                                  //           ],
                                  //         );
                                  //       }),
                                  // );
                                }
                                if (value == 2) {
                                  // saveStyle(myPosts[index].id);
                                }
                                print(value);
                                //Navigator.pushNamed(context, value.toString());
                              },
                              itemBuilder: (BuildContext bc) {
                                return [
                                  PopupMenuItem(
                                    value: 0,
                                    child: Row(
                                      children: const[
                                        Icon(Icons.report),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                              fontFamily:
                                              'Montserrat'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (myPosts[index].userid == id)
                                    PopupMenuItem(
                                      value: 1,
                                      child: Row(
                                        children: const[
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

                                ];
                              })
                        ],
                      ),
                    ),
                  ),

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
                        child: SizedBox(
                          height: 320,
                          width:
                          MediaQuery.of(context).size.width*0.97,
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
                            items: myPosts[index].images.map((i) {
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

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(myPosts[index].images.length.toString()),
                  ),
                  myPosts[index].images.length == 1
                      ? const SizedBox()
                      : Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: myPosts[index]
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
                              vertical: 8.0,
                              horizontal: 4.0),
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
                      child: myPosts[index].userid == id
                          ? Row(
                        children: [
                          myPosts[index].addMeInFashionWeek ==
                              true
                              ? myPosts[index].mylike != "like"
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
                              : myPosts[index].mylike != "like"
                              ? IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 24,
                              ))
                              :
                          GestureDetector(
                            onDoubleTap: () {


                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.star_border_outlined,size: 24,color: Colors.orange),
                            ),

                          )

                          ,
                          myPosts[index].likeCount == "0"
                              ?

                          const SizedBox()
                              : Text(
                              myPosts[index].likeCount.toString()),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CommentScreen(
                                                id: myPosts[
                                                index]
                                                    .id,
                                                pic: myPosts[
                                                index]
                                                    .userPic)));
                              },
                              icon: const Icon(
                                FontAwesomeIcons.comment,
                                size: 20,
                              )),
                          Padding(
                              padding:
                              const EdgeInsets.only(left: 100),
                              child: Text(
                                DateFormat.yMMMEd().format(
                                    DateTime.parse(
                                        myPosts[index].date.toString())),
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12),
                              )),
                        ],
                      )
                          :
                      Row(
                        children: [
                          myPosts[index].addMeInFashionWeek ==
                              true
                              ? myPosts[index].mylike != "like"
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
                              : myPosts[index].mylike != "like"
                              ? IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 24,
                              ))
                              : GestureDetector(onDoubleTap: () {
                            // createLike(posts[index].id);
                          },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons
                                    .star_border_outlined,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),),
                          myPosts[index].likeCount == "0"
                              ?

                          SizedBox()
                              : Text(
                              myPosts[index].likeCount.toString()),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CommentScreen(
                                                id: myPosts[
                                                index]
                                                    .id,
                                                pic: myPosts[
                                                index]
                                                    .userPic)));
                              },
                              icon: const Icon(
                                FontAwesomeIcons.comment,
                                size: 20,
                              )),
                          Padding(
                              padding:
                              const EdgeInsets.only(left: 100),
                              child: Text(
                                DateFormat.yMMMEd().format(
                                    DateTime.parse(
                                        myPosts[index].date.toString())),
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12),
                              )),
                        ],
                      )

                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      myPosts[index].description.toString().length >
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
                                    ? Text(
                                  "${myPosts[index].description.substring(0, 14)}...",
                                  style: const TextStyle(
                                    fontFamily:
                                    'Montserrat',
                                    fontSize: 12,
                                  ),
                                  textAlign:
                                  TextAlign.start,
                                )
                                    : Text(
                                    myPosts[index]
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
                              Text(
                                myPosts[index].description,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12),
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
        },),
    );
  }
}
