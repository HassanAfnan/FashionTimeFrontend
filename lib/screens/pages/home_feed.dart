import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:FashionTime/screens/pages/post_like_user.dart';
import 'package:FashionTime/screens/pages/story/stories.dart';
import 'package:FashionTime/screens/pages/story/upload_story.dart';
import 'package:FashionTime/screens/pages/story/story_media_selection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:FashionTime/models/post_model.dart';
import 'package:FashionTime/screens/pages/fashionComments/comment_screen.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/settings_pages/report_screen.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:FashionTime/screens/pages/videos/video_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../helpers/database_methods.dart';
import '../../models/comment.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import 'message_screen.dart';
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
  List<Story>storyList=[];
  String nextPageUrl = "";
  bool loading = false;
  bool isExpanded = true;
  bool isRefresh = true;
  Stream? chatRooms;
  int paginationPost=1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();
  TextEditingController description = TextEditingController();
  bool updateBool = false;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  Set<int> storyIdSet = {};
  Set<String> storyImgSet = {};

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
    getPosts(1);
    getStory();
  }
  getUserInfogetChats() async {
    DatabaseMethods().getUserChats(name!).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${name!}");
      });
    });
  }
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
    print(name);
    debugPrint("token in home feed is========>$token");
    initBannerAd();
    getUserInfogetChats();

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
      if (difference.inDays == 1) {
        return '1 day ago';
      } else {
        return '${difference.inDays} days ago';
      }
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
  getStory(){
    print("function callleddddddddd");
    const apiUrl="$serverUrl/apiStory/";
    try{
      https.get(
       Uri.parse(apiUrl), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }
      ).then((value) {
        if(value.statusCode==200){
          print("statussssss 200");
          final Map<String, dynamic> response = jsonDecode(value.body);
          final List<dynamic> results = response['results'];

          for (var result in results) {
            final int Id = result["user"]['id'];
            final String userimg = result['user']['pic'] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w";
            final int checkID = 0;
            if (!storyIdSet.contains(Id) && checkID!=Id) {
              storyIdSet.add(Id);
              storyImgSet.add(userimg);
              print("THIS IS I==========>${storyIdSet.toString()}");
              print("IMG OF USER${storyImgSet.toString()}");
            }

            if(result['is_close_friend']==false){
              if (result.containsKey('upload')) {
                if (result['upload'] != null && result['upload'].containsKey('media')) {
                  final media = result['upload']['media'];
                  if (media is List && media.isNotEmpty) {
                    final String url = media[0]['image'] ?? media[0]['video'];
                    final String mediaTypeString = media[0]['type'];
                    if (mediaTypeString != null) {
                      final MediaType mediaType = mediaTypeString == 'image' ? MediaType.image : MediaType.video;
                      final duration=formatTimeDifference(result['created']);
                      final User user = User(
                          name: result['user']['name'],
                          profileImageUrl: result['user']['pic'] ?? '',
                          id: result['user']['id'].toString()
                      );

                      final Story story = Story(
                          url: url,
                          media: mediaType,
                          user: user,
                          viewedBy: result['viewed_by'],
                          storyId: result['id'],
                          duration: duration,
                          uploadObject: result['upload'],
                          closeFriend: result['is_close_friend'],
                          viewed_users: result['viewed_users']
                      );

                      storyList.add(story);
                    } else {
                      debugPrint("Error: 'type' property missing in media object");
                    }
                  } else {
                    // Handle case where 'media' is not a list or is empty
                    debugPrint("Error: 'media' property is not a non-empty list");
                  }
                } else {
                  // Handle case where media content is absent and text is present
                  final duration=formatTimeDifference(result['created']);
                  final User user = User(
                      name: result['user']['name'],
                      profileImageUrl: result['user']['pic'] ?? '',
                      id: result['user']['id'].toString()
                  );
                      print("HERE IS ID====> ${result['user']['id'].toString()}");
                      print("HERE IS ID====> ${result['user']['name'].toString()}");
                  final Story story = Story(
                      url: result['text'], // No media URL
                      media: MediaType.text, // Text content
                      user: user,
                      viewedBy: result['viewed_by'],
                      storyId: result['id'],
                      duration: duration,
                      uploadObject: result['upload'],
                      closeFriend: result['is_close_friend'],
                      viewed_users: result['viewed_users']
                  );

                  storyList.add(story);
                }
              }
              debugPrint("the story list is=======>${storyIdSet}");
              debugPrint("the story len=======>${storyIdSet.length}");
            }
            else if (result['is_close_friend'] == true) {
              if (result['user']['friends'] != null && result['user']['friends'].any((friend) => friend['id'].toString() == id&&friend['is_close_friend']==true)) {
                if (result.containsKey('upload')) {
                  if (result['upload'] != null && result['upload'].containsKey('media')) {
                    final media = result['upload']['media'];
                    if (media is List && media.isNotEmpty) {
                      final String url = media[0]['image'] ?? media[0]['video'];
                      final String mediaTypeString = media[0]['type'];
                      if (mediaTypeString != null) {
                        final MediaType mediaType = mediaTypeString == 'image' ? MediaType.image : MediaType.video;
                        final duration = formatTimeDifference(result['created']);
                        final User user = User(
                          name: result['user']['name'],
                          profileImageUrl: result['user']['pic'] ?? '',
                          id: result['user']['id'].toString(),
                        );

                        final Story story = Story(
                          url: url,
                          media: mediaType,
                          user: user,
                          viewedBy: result['viewed_by'],
                          storyId: result['id'],
                          duration: duration,
                          uploadObject: result['upload'],
                            closeFriend: result['is_close_friend'],
                            viewed_users: result['viewed_users']
                        );

                        storyList.add(story);
                      } else {
                        debugPrint("Error: 'type' property missing in media object");
                      }
                    } else {
                      debugPrint("Error: 'media' property is not a non-empty list");
                    }
                  } else {
                    final duration = formatTimeDifference(result['created']);
                    final User user = User(
                      name: result['user']['name'],
                      profileImageUrl: result['user']['pic'] ?? '',
                      id: result['user']['id'].toString(),
                    );

                    final Story story = Story(
                      url: result['text'], // No media URL
                      media: MediaType.text, // Text content
                      user: user,
                      viewedBy: result['viewed_by'],
                      storyId: result['id'],
                      duration: duration,
                      uploadObject: result['upload'],
                        closeFriend: result['is_close_friend'],
                        viewed_users: result['viewed_users']
                    );
                    storyList.add(story);
                  }
                }
              }
            }
             else {
              debugPrint("Error: 'upload' property missing in result object");
            }
          }


          debugPrint("the story list is=======>${storyList.length}");
        }
        else{
          debugPrint("error received while getting stories=========>${value.statusCode}");
        }
      });
    }
    catch(e){
      debugPrint("Error received========>${e.toString()}");
    }
  }
  String formatHashtags(var hashtags) {
    List<dynamic> formattedHashtags = hashtags.map((tag) => "#${tag['name']}").toList();
    return formattedHashtags.join(' '); // Use ', ' if you prefer commas
  }
  getPosts(int pagination) {
    posts.clear();
    setState(() {
      loading = true;
    });

    try {
      https.get(Uri.parse("$serverUrl/fashionUpload/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        setState(() {
          loading = false;
        });

        Map<String, dynamic> response = jsonDecode(value.body);
        List<dynamic> results = response["results"];
        if(pagination>1){
          print("pagination api response========>${value.body.toString()}");
        }
        results.forEach((result) {
          var upload = result["upload"];
          if(response["next"]==null){
            paginationPost=0;
          }

          var media = upload != null ? upload["media"] : null;
          if(result['hashtags']!=[]){

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
                result["eventData"],
                result["topBadge"] == null ?{"badge":null}: result["topBadge"],
                addMeInFashionWeek: result["addMeInWeekFashion"],
                isCommentEnabled: result["isCommentOff"],
                hashtags: result['hashtags']));
            //print("Posts ==> ${posts.length} ${result[]}");

            debugPrint(
                "value of add me in next fashion week is ${result["addMeInWeekFashion"]}");
            debugPrint("value of isCommentEnabled is ${result["isCommentOff"]} ${posts.length}");
          }
          else{
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
                result["eventData"],
                result["topBadge"] == null ?{"badge":null}: result["topBadge"],
                addMeInFashionWeek: result["addMeInWeekFashion"],
                isCommentEnabled: result["isCommentOff"],
                hashtags: result['hashtags']));
            //print("Posts ==> ${posts.length} ${result}");
            debugPrint(
                "value of add me in next fashion week is ${result["addMeInWeekFashion"]}");
            debugPrint("value of isCommentEnabled is ${result["isCommentOff"]} ${posts.length}");
          }
          //print("Posts ==> ${posts.length} ${posts}");
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }
  createLike(fashionId) async {

    try {

      Map<String, dynamic> body = {
        "likeEmoji": "1",
        "fashion": fashionId,
        "user": id
      };
      https.post(Uri.parse("$serverUrl/fashionLikes/"),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
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
        .patch(Uri.parse("$serverUrl/fashionUpload/$postId/"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: json.encode({"description": description.text}))
        .then((value) {
      print(value.body.toString());
      setState(() {
        updateBool = false;
      });
      Navigator.pop(context);
      getPosts(paginationPost);
    });
  }
  void _showFriendsList(imageLink,postId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StreamBuilder(
          stream: chatRooms,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(), // Use your loading indicator
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"), // Handle error
              );
            }
            else if (snapshot.data == null) { // Add null check here
              return const Center(
                child: Text("No data available"), // Or display an appropriate message
              );
            }
            else {
              final chatData = snapshot.data.docs;

              return  ListView.builder(
                itemCount: ( chatData.length).toInt(),
                itemBuilder: (context, index) {

                    // Render individual chat tile
                    final individualChatIndex = index ;
                    final chat = chatData[individualChatIndex].data();
                    return ChatRoomsTile(
                      name: name,
                      chatRoomId: chat["chatRoomId"],
                      userData: chat["userData"],
                      friendData: chat["friendData"],
                      isBlocked: chat["isBlock"],
                      postId: postId,
                      share: imageLink,
                    );
                  }
                ,
              ) ;
            }
          },
        );
      },
    );
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
      https.post(Uri.parse("$serverUrl/fashionSaved/"),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
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
  String handleEmojis(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading == true
          ? SpinKitCircle(
              color: primary,
              size: 50,
            )
          : (posts.isEmpty
              ? Column(
                children: [
                  RefreshIndicator(
        onRefresh: () async {
          await getPosts(1);
        },
        color: primary,
        child: Column(
          children: [
            const SizedBox(height: 14,),
            storyList.isNotEmpty?
            SizedBox(
              height: 100,
              child: ListView.builder(
                    itemCount: storyIdSet.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      print("FIRST IMG ==> ${storyImgSet.toList()[index]}");
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final Story tappedStory=storyList.removeAt(index);
                                  storyList.insert(0, tappedStory);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StoryScreen(stories: storyList),
                                      ));
                                },
                                child:
                                storyList[index].viewedBy==false && storyList[index].closeFriend==false?
                                Container(

                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 3.5,
                                          color:
                                          Colors.transparent)
                                      ,
                                      gradient:
                                      LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.topRight,
                                          stops: const [0.0, 0.7],
                                          tileMode: TileMode.clamp,
                                          colors: <Color>[
                                            secondary,
                                            primary,
                                          ])
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: storyImgSet.toList()[index],
                                    imageBuilder: (context,
                                        imageProvider) =>
                                        CircleAvatar(
                                          maxRadius: 40,
                                          backgroundImage:
                                          NetworkImage(
                                                storyImgSet.toList()[index].toString()),
                                          child: index == 0
                                              ? Align(
                                            alignment: Alignment
                                                .bottomRight,
                                            child: SizedBox(
                                              height: 18,
                                              width: 18,
                                              child:
                                              FloatingActionButton(
                                                onPressed:
                                                    () {},
                                                backgroundColor:
                                                primary,
                                                mini: true,
                                                child: const Icon(Icons.add,size: 14),
                                              ),
                                            ),
                                          )
                                              : const SizedBox(),),
                                    placeholder: (context, url) =>
                                        CircleAvatar(
                                            maxRadius: 40,
                                            backgroundColor:
                                            Colors.grey,
                                            child: index == 0
                                                ? Align(
                                              alignment: Alignment
                                                  .bottomRight,
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                FloatingActionButton(
                                                  onPressed:
                                                      () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                  },
                                                  backgroundColor:
                                                  primary,
                                                  mini: true,
                                                  child: const Icon(Icons.add,size: 14),
                                                ),
                                              ),
                                            )
                                                : const SizedBox() // Placeholder color
                                        ),
                                    errorWidget: (context, url,
                                        error) =>
                                        CircleAvatar(
                                            maxRadius: 40,
                                            backgroundImage:
                                            NetworkImage(
                                                storyList[index].user.profileImageUrl.toString()),
                                            child: index == 0
                                                ? Align(
                                              alignment: Alignment
                                                  .bottomRight,
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                FloatingActionButton(
                                                  onPressed:
                                                      () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                  },
                                                  backgroundColor:
                                                  primary,
                                                  foregroundColor: ascent,
                                                  mini: true,
                                                  child:  const Icon(Icons.add,size: 14),
                                                ),
                                              ),
                                            )
                                                : const SizedBox()),
                                  ),
                                ):storyList[index].closeFriend==true&&storyList[index].viewedBy==false?
                      Container(

                      decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                      width: 3.5,
                      color:
                      Colors.transparent)
                      ,
                      gradient:
                      const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      stops: [0.0, 0.99],
                      tileMode: TileMode.clamp,
                      colors: <Color>[
                      Colors.lightGreenAccent,
                        Colors.lightGreenAccent,
                      ])
                      ),
                      child: CachedNetworkImage(
                      imageUrl: storyList[index].user.profileImageUrl.toString(),
                      imageBuilder: (context,
                      imageProvider) =>
                      CircleAvatar(
                      maxRadius: 40,
                      backgroundImage:
                      NetworkImage(
                      storyList[index].user.profileImageUrl.toString()),
                      child: index == 0
                      ? Align(
                      alignment: Alignment
                          .bottomRight,
                      child: SizedBox(
                      height: 18,
                      width: 18,
                      child:
                      FloatingActionButton(
                      onPressed:
                      () {},
                      backgroundColor:
                      primary,
                      mini: true,
                      child: const Icon(Icons.add,size: 14),
                      ),
                      ),
                      )
                          : const SizedBox(),),
                      placeholder: (context, url) =>
                      CircleAvatar(
                      maxRadius: 40,
                      backgroundColor:
                      Colors.grey,
                      child: index == 0
                      ? Align(
                      alignment: Alignment
                          .bottomRight,
                      child: SizedBox(
                      height: 18,
                      width: 18,
                      child:
                      FloatingActionButton(
                      onPressed:
                      () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                      },
                      backgroundColor:
                      primary,
                      mini: true,
                      child: const Icon(Icons.add,size: 14),
                      ),
                      ),
                      )
                          : const SizedBox() // Placeholder color
                      ),
                      errorWidget: (context, url,
                      error) =>
                      CircleAvatar(
                      maxRadius: 40,
                      backgroundImage:
                      NetworkImage(
                      storyList[index].user.profileImageUrl.toString()),
                      child: index == 0
                      ? Align(
                      alignment: Alignment
                          .bottomRight,
                      child: SizedBox(
                      height: 18,
                      width: 18,
                      child:
                      FloatingActionButton(
                      onPressed:
                      () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                      },
                      backgroundColor:
                      primary,
                      foregroundColor: ascent,
                      mini: true,
                      child:  const Icon(Icons.add,size: 14),
                      ),
                      ),
                      )
                          : const SizedBox()),
                      ),
                      )
                                :Container(

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 3.5,
                                        color:
                                        Colors.transparent)
                                    ,
                                    // add condition to change color once story is viewed
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: storyList[index].user.profileImageUrl.toString(),
                                    imageBuilder: (context,
                                        imageProvider) =>
                                        CircleAvatar(
                                            maxRadius: 40,
                                            backgroundImage:
                                            NetworkImage(
                                                storyList[index].user.profileImageUrl.toString()),
                                            child: index == 0
                                                ? Align(
                                              alignment: Alignment
                                                  .bottomRight,
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                FloatingActionButton(
                                                  onPressed:
                                                      () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                  },
                                                  backgroundColor:
                                                  primary,
                                                  mini: true,
                                                  child: const Icon(Icons.add,size: 14),
                                                ),
                                              ),
                                            )
                                                : const SizedBox()),
                                    placeholder: (context, url) =>
                                        CircleAvatar(
                                            maxRadius: 40,
                                            backgroundColor:
                                            Colors.grey,
                                            child: index == 0
                                                ? Align(
                                              alignment: Alignment
                                                  .bottomRight,
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                FloatingActionButton(
                                                  onPressed:
                                                      () {},
                                                  backgroundColor:
                                                  primary,
                                                  mini: true,
                                                  child: const Icon(Icons.add,size: 14),
                                                ),
                                              ),
                                            )
                                                : const SizedBox() // Placeholder color
                                        ),
                                    errorWidget: (context, url,
                                        error) =>
                                        CircleAvatar(
                                            maxRadius: 40,
                                            backgroundImage:
                                            const NetworkImage(
                                                "https://www.w3schools.com/howto/img_avatar2.png"),
                                            child: index == 0
                                                ? Align(
                                              alignment: Alignment
                                                  .bottomRight,
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                FloatingActionButton(
                                                  onPressed:
                                                      () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                  },
                                                  backgroundColor:
                                                  primary,
                                                  foregroundColor: ascent,
                                                  mini: true,
                                                  child:  const Icon(Icons.add,size: 14),
                                                ),
                                              ),
                                            )
                                                : const SizedBox()),
                                  ),
                                )
                                ,
                              ),
                            ],
                          ),
                          SizedBox(
                              width:
                              MediaQuery.of(context).size.width *
                                  0.02),
                        ],
                      );
                    },
              ),
            ):
            CircleAvatar(
                  maxRadius: 40,
                  backgroundColor: Colors.grey,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 130),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: FloatingActionButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                              },
                              backgroundColor: primary,
                              mini: true,
                              child: const Icon(Icons.add, size: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
             const Padding(
                   padding: EdgeInsets.only(top: 300),
                   child: Center(
                    child: Text(
                      "Add idols/friends to see more posts.",
                      style: TextStyle(fontFamily: "Montserrat"),
                    ),
            ),
             ),
          ],
        ),
      ),
                ],
              )

          : RefreshIndicator(
                  color: primary,
                  onRefresh: () async {
                    getPosts(1);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 80,
                          child:
                          storyList.isNotEmpty?
                          ListView.builder(
                            itemCount: storyIdSet.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                             // print("FIRST IMG ==> ${storyImgSet.toList()[index]}");
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final Story tappedStory=storyList.removeAt(index);
                                          storyList.insert(0, tappedStory);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                     StoryScreen(stories: storyList),
                                              ));
                                        },
                                        child:
                                            storyList[index].viewedBy==false&& storyList[index].closeFriend==false?
                                        Container(

                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 3.5,
                                                  color:
                                                      Colors.transparent)
                                            ,
                                              gradient:
                                          LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.topRight,
                                              stops: const [0.0, 0.7],
                                              tileMode: TileMode.clamp,
                                              colors: <Color>[
                                                secondary,
                                                primary,
                                              ])// add condition to change color once story is viewed
                                              ),
                                          child: CachedNetworkImage(
                                            imageUrl: storyImgSet.toList()[index],
                                            imageBuilder: (context,
                                                    imageProvider) =>
                                                CircleAvatar(
                                                    maxRadius: 40,
                                                    backgroundImage:
                                                         NetworkImage(
                                                              storyImgSet.toList()[index].toString()),
                                                    child: index == 0
                                                        ? Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: SizedBox(
                                                              height: 18,
                                                              width: 18,
                                                              child:
                                                                  FloatingActionButton(
                                                                onPressed:
                                                                    () {
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                                    },
                                                                backgroundColor:
                                                                    primary,
                                                                mini: true,
                                                                    child: const Icon(Icons.add,size: 14),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),),
                                            placeholder: (context, url) =>
                                                CircleAvatar(
                                                    maxRadius: 40,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    child: index == 0
                                                        ? Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: SizedBox(
                                                              height: 18,
                                                              width: 18,
                                                              child:
                                                                  FloatingActionButton(
                                                                onPressed:
                                                                    () {
                                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                                    },
                                                                backgroundColor:
                                                                    primary,
                                                                mini: true,
                                                                    child: const Icon(Icons.add,size: 14),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox() // Placeholder color
                                                    ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                CircleAvatar(
                                                    maxRadius: 40,
                                                    backgroundImage:
                                                         NetworkImage(
                                                             storyImgSet.toList()[index].toString()),
                                                    child: index == 0
                                                        ? Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: SizedBox(
                                                              height: 18,
                                                              width: 18,
                                                              child:
                                                                  FloatingActionButton(
                                                                onPressed:
                                                                    () {
                                                                   Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                                    },
                                                                backgroundColor:
                                                                    primary,
                                                                    foregroundColor: ascent,
                                                                mini: true,
                                                                    child:  const Icon(Icons.add,size: 14),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox()),
                                          ),
                                        ):
                                            storyList[index].closeFriend==true&&storyList[index].viewedBy==false?
                                            Container(

                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 3.5,
                                                      color:
                                                      Colors.transparent)
                                                  ,
                                                  gradient:
                                                  const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.topRight,
                                                      stops: [0.0, 0.99],
                                                      tileMode: TileMode.clamp,
                                                      colors: <Color>[
                                                        Colors.lightGreenAccent,
                                                        Colors.lightGreenAccent,
                                                      ])
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: storyImgSet.toList()[index].toString(),
                                                imageBuilder: (context,
                                                    imageProvider) =>
                                                    CircleAvatar(
                                                      maxRadius: 40,
                                                      backgroundImage:
                                                      NetworkImage(
                                                          storyImgSet.toList()[index].toString()),
                                                      child: index == 0
                                                          ? Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: SizedBox(
                                                          height: 18,
                                                          width: 18,
                                                          child:
                                                          FloatingActionButton(
                                                            onPressed:
                                                                () {},
                                                            backgroundColor:
                                                            primary,
                                                            mini: true,
                                                            child: const Icon(Icons.add,size: 14),
                                                          ),
                                                        ),
                                                      )
                                                          : const SizedBox(),),
                                                placeholder: (context, url) =>
                                                    CircleAvatar(
                                                        maxRadius: 40,
                                                        backgroundColor:
                                                        Colors.grey,
                                                        child: index == 0
                                                            ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                            FloatingActionButton(
                                                              onPressed:
                                                                  () {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                              },
                                                              backgroundColor:
                                                              primary,
                                                              mini: true,
                                                              child: const Icon(Icons.add,size: 14),
                                                            ),
                                                          ),
                                                        )
                                                            : const SizedBox() // Placeholder color
                                                    ),
                                                errorWidget: (context, url,
                                                    error) =>
                                                    CircleAvatar(
                                                        maxRadius: 40,
                                                        backgroundImage:
                                                        NetworkImage(
                                                            storyImgSet.toList()[index].toString()),
                                                        child: index == 0
                                                            ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                            FloatingActionButton(
                                                              onPressed:
                                                                  () {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                              },
                                                              backgroundColor:
                                                              primary,
                                                              foregroundColor: ascent,
                                                              mini: true,
                                                              child:  const Icon(Icons.add,size: 14),
                                                            ),
                                                          ),
                                                        )
                                                            : const SizedBox()),
                                              ),
                                            ):
                                            Container(

                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 3.5,
                                                      color:
                                                      Colors.transparent)
                                                  ,
                                                // add condition to change color once story is viewed
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: storyList[index].user.profileImageUrl.toString(),
                                                imageBuilder: (context,
                                                    imageProvider) =>
                                                    CircleAvatar(
                                                        maxRadius: 40,
                                                        backgroundImage:
                                                         NetworkImage(
                                                             storyImgSet.toList()[index].toString()),
                                                        child: index == 0
                                                            ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                            FloatingActionButton(
                                                              onPressed:
                                                                  () {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                                  },
                                                              backgroundColor:
                                                              primary,
                                                              mini: true,
                                                              child: const Icon(Icons.add,size: 14),
                                                            ),
                                                          ),
                                                        )
                                                            : const SizedBox()),
                                                placeholder: (context, url) =>
                                                    CircleAvatar(
                                                        maxRadius: 40,
                                                        backgroundColor:
                                                        Colors.grey,
                                                        child: index == 0
                                                            ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                            FloatingActionButton(
                                                              onPressed:
                                                                  () {},
                                                              backgroundColor:
                                                              primary,
                                                              mini: true,
                                                              child: const Icon(Icons.add,size: 14),
                                                            ),
                                                          ),
                                                        )
                                                            : const SizedBox() // Placeholder color
                                                    ),
                                                errorWidget: (context, url,
                                                    error) =>
                                                    CircleAvatar(
                                                        maxRadius: 40,
                                                        backgroundImage:
                                                        const NetworkImage(
                                                            "https://www.w3schools.com/howto/img_avatar2.png"),
                                                        child: index == 0
                                                            ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: SizedBox(
                                                            height: 18,
                                                            width: 18,
                                                            child:
                                                            FloatingActionButton(
                                                              onPressed:
                                                                  () {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                                              },
                                                              backgroundColor:
                                                              primary,
                                                              foregroundColor: ascent,
                                                              mini: true,
                                                              child:  const Icon(Icons.add,size: 14),
                                                            ),
                                                          ),
                                                        )
                                                            : const SizedBox()),
                                              ),
                                            )
                                        ,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                ],
                              );
                            },
                          ):
                            CircleAvatar(
                              maxRadius: 40,
                              backgroundColor:
                              Colors.grey,
                              child:
                                  Align(
                                alignment: Alignment
                                    .bottomRight,
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                  FloatingActionButton(
                                    onPressed:
                                        () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StoryMediaScreen(),));
                                    },
                                    backgroundColor:
                                    primary,
                                    mini: true,
                                    child: const Icon(Icons.add,size: 14),
                                  ),
                                ),
                              )
                              // Placeholder color
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                            separatorBuilder: (context, index) {
                              if (index % 5 == 0) {
                                return SizedBox(
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
                              if (index == posts.length - 1) {
                                // If we reach the last item, fetch next page of posts
                                return isRefresh
                                    ? GestureDetector(
                                        onTap: () {
                                          paginationPost++;
                                          getPosts(paginationPost);
                                        },
                                        child: Icon(
                                          Icons.refresh,
                                          color: primary,
                                        ))
                                    : const SizedBox();
                              }
                              return Card(
                                elevation: 10,
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: posts[index].addMeInFashionWeek ==
                                              true ? Border.all(color: Colors.yellowAccent,width: 4): null,
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.topRight,
                                              stops: const [0.0, 0.99],
                                              tileMode: TileMode.clamp,
                                              colors: <Color>[
                                                secondary,
                                                primary,
                                              ])),
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
                                                  // if (posts[index].userid !=
                                                  //     id)
                                                  //   PopupMenuItem(
                                                  //     value: 2,
                                                  //     child: Row(
                                                  //       children: const [
                                                  //         Icon(Icons.save),
                                                  //         SizedBox(
                                                  //           width: 10,
                                                  //         ),
                                                  //         Text(
                                                  //           "Save Post",
                                                  //           style: TextStyle(
                                                  //               fontFamily:
                                                  //                   'Montserrat'),
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                ];
                                              })
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                      },
                                      child: InteractiveViewer(
                                        panEnabled: true,
                                        minScale: 1,
                                        maxScale: 3,
                                        child: SizedBox(
                                          height: 450,
                                          width: double.infinity,
                                          child: Expanded(
                                            child: CarouselSlider(
                                              carouselController: _controller,
                                              options: CarouselOptions(
                                                  viewportFraction: 1,
                                                  enableInfiniteScroll: false,
                                                  height: 450.0,
                                                  autoPlay: false,
                                                  enlargeCenterPage: true,
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
                                                                  .width * 2,
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
                                                            ),
                                                  posts[index].likeCount == "0"
                                                      ?
                                                      const SizedBox()
                                                      : Text(posts[index]
                                                          .likeCount),
                                                  posts[index].isCommentEnabled ==
                                                          true
                                                      ? IconButton(
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                                isScrollControlled: true,
                                                                context: context,
                                                                builder: (ctx) {
                                                                  return Container(
                                                                    height: MediaQuery.of(context).size.height * 0.8,
                                                                    child: CommentScreen(
                                                                        id: posts[index]
                                                                            .id,
                                                                        pic: posts[index]
                                                                            .userPic),
                                                                  );
                                                                });
                                                            // Navigator.push(
                                                            //     context,
                                                            //     MaterialPageRoute(
                                                            //         builder: (context) => CommentScreen(
                                                            //             id: posts[index]
                                                            //                 .id,
                                                            //             pic: posts[index]
                                                            //                 .userPic)));
                                                          },
                                                          icon: const Icon(
                                                            FontAwesomeIcons
                                                                .comment,
                                                            size: 20,
                                                          ))
                                                      : const SizedBox(),
                                                  IconButton(
                                                      onPressed: () async {

                                                        showModalBottomSheet(
                                                            context: context,
                                                            builder: (BuildContext bc) {
                                                              return Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading:  SizedBox(
                                                                  width: 28,
                                                                  height:28 ,
                                                                  child: Image.asset("assets/shareIcon.png",)),
                                                                    title: const Text(
                                                                      'Share with friends',
                                                                      style: TextStyle(fontFamily: 'Montserrat'),
                                                                    ),
                                                                    onTap: () {
                                                                      String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                                                                        Navigator.pop(context);
                                                                        _showFriendsList(imageUrl,posts[index].id);

                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading: const Icon(Icons.share),
                                                                    title: const Text(
                                                                      'Others',
                                                                      style: TextStyle(fontFamily: 'Montserrat'),
                                                                    ),
                                                                    onTap: () async{
                                                                      String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                                                                      debugPrint("image link to share: $imageUrl");
                                                                      await Share.share("${posts[index].description.toString()}\n\n https://fashiontime-28e3a.web.app/details/${posts[index].id}"
                                                                          );
                                                                    },
                                                                  ),

                                                                ],
                                                              );
                                                            });
                                                      },
                                                      icon: const Icon(
                                                        FontAwesomeIcons.share,
                                                        size: 20,
                                                      )
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      saveStyle(posts[index].id);
                                                    },
                                                      child: Padding(
                                                        padding: EdgeInsets.only(right: 2),
                                                        child: Image.asset('assets/Frame1.png', height: 28),
                                                      ))
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
                                                                createLike(
                                                                    posts[index]
                                                                        .id);
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
                                                  IconButton(
                                                      onPressed: () async {

                                                        showModalBottomSheet(
                                                            context: context,
                                                            builder: (BuildContext bc) {
                                                              return Wrap(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    leading: SizedBox(
                                                                      width: 28,
                                                                        height:28 ,
                                                                        child: Image.asset("assets/shareIcon.png",)),
                                                                    title: const Text(
                                                                      'Share with friends',
                                                                      style: TextStyle(fontFamily: 'Montserrat'),
                                                                    ),
                                                                    onTap: () {
                                                                      String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                                                                      Navigator.pop(context);
                                                                      _showFriendsList(imageUrl,posts[index].id);

                                                                    },
                                                                  ),
                                                                  ListTile(
                                                                    leading: const Icon(Icons.share),
                                                                    title: const Text(
                                                                      'Others',
                                                                      style: TextStyle(fontFamily: 'Montserrat'),
                                                                    ),
                                                                    onTap: () async{
                                                                      String imageUrl = posts[index].images[0]['image']==null?posts[index].images[0]['video'].toString():posts[index].images[0]['image'].toString();
                                                                      debugPrint("image link to share: $imageUrl");
                                                                      await Share.share("${posts[index].description.toString()}\n\n https://fashiontime-28e3a.web.app/details/${posts[index].id}"
                                                                      );
                                                                    },
                                                                  ),

                                                                ],
                                                              );
                                                            });
                                                      },
                                                      icon: const Icon(
                                                        FontAwesomeIcons.share,
                                                        size: 20,
                                                      )
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                      onTap: () {
                                                        saveStyle(posts[index].id);
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.only(right: 2),
                                                        child: Image.asset('assets/Frame1.png', height: 28),
                                                      ))
                                                ],
                                              )
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
                                                    .length +formatHashtags(posts[index].hashtags).length>
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
                                                                "${posts[index]
                                                                        .userName}${handleEmojis( posts[index]
                                                                       .description)} ${formatHashtags(posts[index].hashtags)}",
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
                                                         "${handleEmojis( posts[index]
                                                             .description)} ${formatHashtags(posts[index].hashtags)}",//hashtagwork
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
                                    posts[index].addMeInFashionWeek ==
                                        true ? Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text("Event - ${posts[index].event["title"]}")
                                      ],
                                    ): SizedBox(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        posts[index].commentCount == "0"
                                            ?
                                        const SizedBox()
                                            : GestureDetector(
                                             onTap:(){
                                               showModalBottomSheet(
                                                   isScrollControlled: true,
                                                   context: context,
                                                   builder: (ctx) {
                                                     return Container(
                                                       height: MediaQuery.of(context).size.height * 0.8,
                                                       child: CommentScreen(
                                                           id: posts[index]
                                                               .id,
                                                           pic: posts[index]
                                                               .userPic),
                                                     );
                                                   });
                                             },
                                            child: Text("View all ${posts[index].commentCount} comments")),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )),
    );
  }
}
class ChatRoomsTile extends StatelessWidget {
  final String? name;
  final String? chatRoomId;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> friendData;
  final bool isBlocked;
  final String share;
  final String postId;

  ChatRoomsTile({
    this.name,
    this.chatRoomId,
    required this.userData,
    required this.friendData,
    required this.isBlocked, required this.share, required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageScreen(
                    friendId: friendData["id"],
                    chatRoomId: chatRoomId!,
                    email: (chatRoomId!.split("_")[0] == name)
                        ? friendData["username"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["username"]
                        : ""),
                    name: (chatRoomId!.split("_")[0] == name)
                        ? friendData["name"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["name"]
                        : ""),
                    pic: (chatRoomId!.split("_")[0] == name)
                        ? friendData["pic"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["pic"]
                        : ""),
                    fcm: (chatRoomId!.split("_")[0] == name)
                        ? friendData["token"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["token"]
                        : ""),
                    isBlocked: isBlocked,
                share: share,
                postId: postId,)));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfileScreen(
                          //   id: posts[index].userid,
                          //   username: friendData["username"],
                          // )));
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(120))),
                          child: ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(120)),
                            child: CachedNetworkImage(
                              imageUrl: (chatRoomId!.split("_")[0] == name)
                                  ? friendData["pic"]
                                  : (chatRoomId!.split("_")[1] == name
                                  ? userData["pic"]
                                  : ""),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(120)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) => SpinKitCircle(
                                color: primary,
                                size: 20,
                              ),
                              errorWidget: (context, url, error) => ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  child: Image.network(
                                    "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                    width: 50,
                                    height: 50,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                (chatRoomId!.split("_")[0] == name)
                                    ? friendData["name"]
                                    : (chatRoomId!.split("_")[1] == name
                                    ? userData["name"]
                                    : ""),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Montserrat"),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                (chatRoomId!.split("_")[0] == name)
                                    ? friendData["username"]
                                    : (chatRoomId!.split("_")[1] == name
                                    ? userData["username"]
                                    : ""),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500,fontFamily: "Montserrat"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
