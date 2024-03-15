import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:FashionTime/screens/pages/settings_pages/report_screen.dart';
import 'package:FashionTime/screens/pages/videos/video_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/post_model.dart';
import '../../utils/constants.dart';
import 'comment_screen.dart';
import 'filter_screen.dart';
import 'filter_top_trending.dart';
import 'friend_profile.dart';
import 'myProfile.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  Timer? countdownTimer;
  Duration myDuration = const Duration(days: 7);
  String search = "";
  String id = "";
  String token = "";
  String gender = "";
  String option = "";
  String date = "";
  String name = '';
  late Timer _timer;
  late Duration _timeRemaining;
  int selectedFashionId = 0;
  List<PostModel> posts = [];
  List<PostModel> posts1 = [];
  List<PostModel> filteredPosts = [];
  List<PostModel> filteredItems = [];
  List<PostModel> filteredItems2 = [];
  bool loading = false;
  late TabController tabController;
  bool top10 = true;
  bool styles = false;
  bool isExpanded = false;
  bool updateBool = false;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  TextEditingController description = TextEditingController();
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;

    print("post plus token" + token);

    getPosts();
  }

  getCachedData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      token = preferences.getString("token")!;
      gender = preferences.getString("selectedGender")!;
      //date = preferences.getString("selectedDate")!;
      //  option = preferences.getString("selectedOption")!;
      // selectedFashionId = preferences.getInt("selectedFashionId")!;
      print("all filter data $gender $date $option $selectedFashionId");
    } catch (e) {
      print("Error retrieving cached data: $e");
      filteredPosts.clear();
      getPosts();
    }
  }

  getPosts() {
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("${serverUrl}/fashionUpload/top-trending/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }).then((value) {
        print("Timer ==> " + jsonDecode(value.body).toString());
        setState(() {
          //myDuration = Duration(seconds: int.parse(jsonDecode(value.body)["result"]["time_remaining"].));
          loading = false;
        });
        jsonDecode(value.body)["result"].forEach((value) {
          if (value["upload"]["media"][0]["type"] == "video" &&
              value['addMeInWeekFashion'] == true) {
            VideoThumbnail.thumbnailFile(
              video: value["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth:
                  128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
              quality: 25,
            ).then((value1) {
              setState(() {
                posts1.add(PostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["username"],
                    value["user"]["pic"] == null
                        ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                        : value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],
                    value1!,
                    value["user"]["id"].toString(),
                    value["myLike"] == null
                        ? "like"
                        : value["myLike"].toString()));
              });
            });
          } else if (value['addMeInWeekFashion'] == true) {
            setState(() {
              posts1.add(PostModel(
                  value["id"].toString(),
                  value["description"],
                  value["upload"]["media"],
                  value["user"]["username"],
                  value["user"]["pic"] == null
                      ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                      : value["user"]["pic"],
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],
                  "",
                  value["user"]["id"].toString(),
                  value["myLike"] == null
                      ? "like"
                      : value["myLike"].toString()));
            });
          }
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
    getPosts1();
  }

  getPosts1() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await https.get(Uri.parse("${serverUrl}/fashionUpload/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          });

      final responseData = jsonDecode(response.body);
      final List<dynamic> results = responseData['results'];

      setState(() {
        loading = false;
      });

      results.forEach((value) {
        if (value['addMeInWeekFashion'] == false) {
          if (value["upload"]["media"][0]["type"] == "video") {
            VideoThumbnail.thumbnailFile(
              video: value["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128,
              quality: 25,
            ).then((value1) {
              setState(() {
                posts.add(PostModel(
                  value["id"].toString(),
                  value["description"],
                  value["upload"]["media"],
                  value["user"]["username"],
                  value["user"]["pic"] == null
                      ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                      : value["user"]["pic"],
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],
                  value1!,
                  value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"].toString(),
                  addMeInFashionWeek: value["addMeInWeekFashion"],
                ));
              });
            });
          } else {
            setState(() {
              posts.add(PostModel(
                value["id"].toString(),
                value["description"],
                value["upload"]["media"],
                value["user"]["username"],
                value["user"]["pic"] == null
                    ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                    : value["user"]["pic"],
                false,
                value["likesCount"].toString(),
                value["disLikesCount"].toString(),
                value["commentsCount"].toString(),
                value["created"],
                "",
                value["user"]["id"].toString(),
                value["myLike"] == null ? "like" : value["myLike"].toString(),
                addMeInFashionWeek: value["addMeInWeekFashion"],
              ));
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
  }

  getPostsFiltered() {
    getCachedData();

    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("${serverUrl}/fashionUpload/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token}"
      }).then((value) {
        final List<dynamic> responseData = jsonDecode(value.body);
        print("post list $responseData");
        print(jsonDecode(value.body));
        setState(() {
          loading = false;
        });
        jsonDecode(value.body).forEach((value) {
          if (gender == value["gender"] && value['addMeInWeekFashion'] == false
              // &&date.substring(0,10)==value['created'].toString().substring(0,10)&& selectedFashionId==value['event']
              ) {
            if (value["upload"]["media"][0]["type"] == "video") {
              VideoThumbnail.thumbnailFile(
                video: value["upload"]["media"][0]["video"],
                imageFormat: ImageFormat.JPEG,
                maxWidth: 128,
                // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                quality: 25,
              ).then((value1) {
                setState(() {
                  filteredPosts.add(PostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["username"],
                    value["user"]["pic"] == null
                        ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                        : value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],
                    value1!,
                    value["user"]["id"].toString(),
                    value["myLike"] == null
                        ? "like"
                        : value["myLike"].toString(),
                    addMeInFashionWeek: value["addMeInWeekFashion"],
                  ));
                  print(" male filtered Posts ${filteredPosts.toString()}");
                });
              });
            } else if (value['addMeInWeekFashion'] == false) {
              setState(() {
                filteredPosts.add(PostModel(
                  value["id"].toString(),
                  value["description"],
                  value["upload"]["media"],
                  value["user"]["username"],
                  value["user"]["pic"] == null
                      ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                      : value["user"]["pic"],
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],
                  "",
                  value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"].toString(),
                  addMeInFashionWeek: value["addMeInWeekFashion"],
                ));

                print("all male filtered post ${filteredPosts.toString()}");
              });
            }
          } else {
            print("error in filter work");
          }
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
  }

  SearchUser(String query) {
    setState(
      () {
        search = query;
        filteredItems = posts
            .where(
              (item) => item.userName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      },
    );
  }

  searchViaDescription(String query) {
    setState(() {
      search = query;
      filteredItems = posts
          .where((element) =>
              element.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  searchViaDescriptionForFiltered(String query) {
    setState(() {
      search = query;
      filteredItems2 = filteredPosts
          .where((element) =>
              element.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  SearchFilteredUser(String query) {
    setState(
      () {
        search = query;
        filteredItems2 = filteredPosts
            .where(
              (item) => item.userName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCashedData();
    _initializeTimer();
    tabController = TabController(length: 2, vsync: this);
    // startTimer();
  }

  void _initializeTimer() {
    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the next Sunday 12 pm
    DateTime nextSunday = now.add(Duration(
        days: DateTime.sunday - now.weekday,
        hours: 12 - now.hour,
        minutes: -now.minute,
        seconds: -now.second));

    // Calculate the time remaining until the next Sunday 12 pm
    _timeRemaining = nextSunday.difference(now);

    // Start the timer to update the UI every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = _timeRemaining - const Duration(seconds: 1);

        // Check if it's Sunday 12 pm to reset the timer
        if (_timeRemaining.inSeconds <= 0) {
          _resetTimer();
        }
      });
    });
  }

  void _resetTimer() {
    // Cancel the existing timer
    _timer.cancel();

    // Initialize the timer again for the next week
    _initializeTimer();
  }

  // void startTimer() {
  //   // Calculate the duration until the next Monday
  //   Duration durationUntilMonday = calculateDurationUntilMonday();
  //
  //   countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  //
  //   // Set the initial duration
  //   myDuration = durationUntilMonday;
  //
  //   getCachedData();
  // }
  //
  // // Step 4
  // void stopTimer() {
  //   countdownTimer?.cancel();
  // }
  //
  // // Step 5
  // void resetTimer() {
  //   stopTimer();
  //   // Reset the timer to the duration until the next Monday
  //   myDuration = calculateDurationUntilMonday();
  //   startTimer();
  // }
  //
  // // Step 6
  // void setCountDown() {
  //   final reduceSecondsBy = 1;
  //   setState(() {
  //     final seconds = myDuration.inSeconds - reduceSecondsBy;
  //     if (seconds < 0) {
  //       // If the timer reaches zero, reset it
  //      // resetTimer();
  //     } else {
  //       myDuration = Duration(seconds: seconds);
  //     }
  //   });
  // }
  // Duration calculateDurationUntilMonday() {
  //   DateTime now = DateTime.now();
  //
  //   // Calculate the days until the next Monday (1: Monday, 2: Tuesday, ..., 7: Sunday)
  //   int daysUntilMonday = 7 - now.weekday;
  //
  //   // If today is Monday, set it to the next Monday
  //   if (daysUntilMonday == 1) {
  //     daysUntilMonday = 7;
  //   }
  //
  //   // Calculate the next Monday
  //   DateTime nextMonday = now.add(Duration(days: daysUntilMonday));
  //
  //   // Calculate the duration until the next Monday
  //   Duration durationUntilMonday = nextMonday.difference(now);
  //
  //   return durationUntilMonday;
  // }
  Color _getTabIconColor(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.white : primary;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // stopTimer();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    // final days = strDigits(myDuration.inDays);
    // final hours = strDigits(myDuration.inHours.remainder(24));
    // final minutes = strDigits(myDuration.inMinutes.remainder(60));
    // final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 50,
            child: TabBar(
              indicatorColor: primary,
              labelColor: primary,
              unselectedLabelColor: ascent,
              controller: tabController,
              tabs: const [
                Tab(
                  child: Text(
                    "All Styles",
                    style: TextStyle(
                        //color:  _getTabIconColor(context),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: Text(
                    "Event Styles",
                    style: TextStyle(
                        // color:_getTabIconColor(context) ,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.all(0),
                              child: TextField(
                                onChanged: (value) {
                                  if (posts.isNotEmpty) {
                                    SearchUser(value);
                                    searchViaDescription(value);
                                  } else {
                                    SearchFilteredUser(value);
                                    searchViaDescriptionForFiltered(value);
                                  }
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  // hintTextDirection: TextDirection.ltr,
                                  contentPadding:
                                      const EdgeInsets.only(top: 10),
                                  hintText: 'Search for Styles.',
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                  ),
                                  border: const OutlineInputBorder(),
                                  focusColor: primary,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 1, color: primary),
                                  ),
                                ),
                                cursorColor: primary,
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 13,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            filteredPosts.clear();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FilterScreen())).then((value) {
                              posts.clear();
                              posts1.clear();
                              print("list cleared ${filteredPosts.length}");
                              loading == false;
                              getPostsFiltered();
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.tune,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: loading == true
                            ? SpinKitCircle(
                                size: 50,
                                color: primary,
                              )
                            : (posts.length <= 0
                                ? (filteredPosts.length >= 0
                                    ? filteredItems2.isNotEmpty ||
                                            search.isNotEmpty
                                        ? (filteredItems2.isEmpty
                                            ? const Text("No Results Found")
                                            : GridView.builder(
                                                itemCount:
                                                    filteredItems2.length,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        mainAxisSpacing: 1.0,
                                                        crossAxisSpacing: 1),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return WidgetAnimator(
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SwapDetail(
                                                                          userid:
                                                                              filteredItems2[index].userid,
                                                                          image:
                                                                              filteredItems2[index].images,
                                                                          description:
                                                                              filteredItems2[index].description,
                                                                          style:
                                                                              "Fashion Style 2",
                                                                          createdBy:
                                                                              filteredItems2[index].userName,
                                                                          profile:
                                                                              filteredItems2[index].userPic,
                                                                          likes:
                                                                              filteredItems2[index].likeCount,
                                                                          dislikes:
                                                                              filteredItems2[index].dislikeCount,
                                                                          mylike:
                                                                              filteredItems2[index].mylike,
                                                                          addMeInFashionWeek:
                                                                              filteredItems2[index].addMeInFashionWeek,
                                                                        )));
                                                      },
                                                      child: Card(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          child: filteredItems2[
                                                                              index]
                                                                          .images[0]
                                                                      [
                                                                      "type"] ==
                                                                  "video"
                                                              ? Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: DecorationImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: FileImage(
                                                                            File(filteredItems2[index].thumbnail))),
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: filteredItems2[index]
                                                                            .images[0]
                                                                        [
                                                                        "image"],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            20.0,
                                                                        height:
                                                                            20.0,
                                                                        child:
                                                                            SpinKitCircle(
                                                                          color:
                                                                              primary,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Icon(
                                                                            Icons.error),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ))
                                        : filteredPosts.length <= 0
                                            ? const Center(
                                                child: Text(
                                                "No Posts",
                                                style: TextStyle(
                                                    fontFamily: "Montserrat"),
                                              ))
                                            : GridView.builder(
                                                itemCount: filteredPosts.length,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        mainAxisSpacing: 1.0,
                                                        crossAxisSpacing: 1.0),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return WidgetAnimator(
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SwapDetail(
                                                                          userid:
                                                                              filteredPosts[index].userid,
                                                                          image:
                                                                              filteredPosts[index].images,
                                                                          description:
                                                                              filteredPosts[index].description,
                                                                          style:
                                                                              "Fashion Style 2",
                                                                          createdBy:
                                                                              filteredPosts[index].userName,
                                                                          profile:
                                                                              filteredPosts[index].userPic,
                                                                          likes:
                                                                              filteredPosts[index].likeCount,
                                                                          dislikes:
                                                                              filteredPosts[index].dislikeCount,
                                                                          mylike:
                                                                              filteredPosts[index].mylike,
                                                                          addMeInFashionWeek:
                                                                              filteredPosts[index].addMeInFashionWeek,
                                                                        )));
                                                      },
                                                      child: Card(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          child: filteredPosts[
                                                                              index]
                                                                          .images[0]
                                                                      [
                                                                      "type"] ==
                                                                  "video"
                                                              ? Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: DecorationImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: FileImage(
                                                                            File(filteredPosts[index].thumbnail))),
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: filteredPosts[index]
                                                                            .images[0]
                                                                        [
                                                                        "image"],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            20.0,
                                                                        height:
                                                                            20.0,
                                                                        child:
                                                                            SpinKitCircle(
                                                                          color:
                                                                              primary,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Container(
                                                                      height: MediaQuery.of(context)
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
                                                                            image:
                                                                                Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image,
                                                                            fit: BoxFit.fill),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                    : const Text("No Results Found"))
                                : (filteredItems.isNotEmpty || search.isNotEmpty
                                    ? (filteredItems.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No Results Found',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          )
                                        : GridView.builder(
                                            itemCount: filteredItems.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 1.0,
                                                    crossAxisSpacing: 1.0),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return WidgetAnimator(
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    SwapDetail(
                                                                      userid: filteredItems[
                                                                              index]
                                                                          .userid,
                                                                      image: filteredItems[
                                                                              index]
                                                                          .images,
                                                                      description:
                                                                          filteredItems[index]
                                                                              .description,
                                                                      style:
                                                                          "Fashion Style 2",
                                                                      createdBy:
                                                                          filteredItems[index]
                                                                              .userName,
                                                                      profile: filteredItems[
                                                                              index]
                                                                          .userPic,
                                                                      likes: filteredItems[
                                                                              index]
                                                                          .likeCount,
                                                                      dislikes:
                                                                          filteredItems[index]
                                                                              .dislikeCount,
                                                                      mylike: filteredItems[
                                                                              index]
                                                                          .mylike,
                                                                      addMeInFashionWeek:
                                                                          filteredItems[index]
                                                                              .addMeInFashionWeek,
                                                                    )));
                                                  },
                                                  child: Card(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: filteredItems[
                                                                          index]
                                                                      .images[0]
                                                                  ["type"] ==
                                                              "video"
                                                          ? Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: FileImage(File(
                                                                        filteredItems[index]
                                                                            .thumbnail))),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                              ),
                                                            )
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: filteredItems[
                                                                            index]
                                                                        .images[
                                                                    0]["image"],
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
                                                                    child:
                                                                        SpinKitCircle(
                                                                      color:
                                                                          primary,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    new Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ))
                                    : posts.length <= 0
                                        ? const Text(
                                            "No posts",
                                            style: TextStyle(
                                                fontFamily: 'Montserrat'),
                                          )
                                        : GridView.builder(
                                            itemCount: posts.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 1.0,
                                                    crossAxisSpacing: 1.0),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return WidgetAnimator(
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    SwapDetail(
                                                                      userid: posts[
                                                                              index]
                                                                          .userid,
                                                                      image: posts[
                                                                              index]
                                                                          .images,
                                                                      description:
                                                                          posts[index]
                                                                              .description,
                                                                      style:
                                                                          "Fashion Style 2",
                                                                      createdBy:
                                                                          posts[index]
                                                                              .userName,
                                                                      profile: posts[
                                                                              index]
                                                                          .userPic,
                                                                      likes: posts[
                                                                              index]
                                                                          .likeCount,
                                                                      dislikes:
                                                                          posts[index]
                                                                              .dislikeCount,
                                                                      mylike: posts[
                                                                              index]
                                                                          .mylike,
                                                                      addMeInFashionWeek:
                                                                          posts[index]
                                                                              .addMeInFashionWeek,
                                                                    )));
                                                  },
                                                  child: Card(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child:
                                                          posts[index].images[0]
                                                                      [
                                                                      "type"] ==
                                                                  "video"
                                                              ? Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: DecorationImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: FileImage(
                                                                            File(posts[index].thumbnail))),
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: posts[index]
                                                                            .images[0]
                                                                        [
                                                                        "image"],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            20.0,
                                                                        height:
                                                                            20.0,
                                                                        child:
                                                                            SpinKitCircle(
                                                                          color:
                                                                              primary,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Container(
                                                                      height: MediaQuery.of(context)
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
                                                                            image:
                                                                                Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image,
                                                                            fit: BoxFit.fill),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ))),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Next top 10 styles in",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hourglass_top,
                          size: 15,
                          color: Colors.red,
                        ),
                        Text(
                          ' ${_timeRemaining.inDays} days ${_timeRemaining.inHours.remainder(24)} hours ${_timeRemaining.inMinutes.remainder(60)} minutes ${_timeRemaining.inSeconds.remainder(60)} seconds',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat'),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TopTrendingFilterScreen(),
                                  ));
                            },
                            icon: Icon(
                              Icons.tune,
                              color: primary,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: loading == true
                            ? SpinKitCircle(
                                size: 50,
                                color: primary,
                              )
                            : (posts1.length <= 0
                                ? const Center(child: Text("No Posts"))
                                : (filteredItems.isNotEmpty || search.isNotEmpty
                                    ? (filteredItems.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No Results Found',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          )
                                        : GridView.builder(
                                            itemCount: filteredItems.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 1.0,
                                                    crossAxisSpacing: 1.0),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return WidgetAnimator(
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    SwapDetail(
                                                                      userid: filteredItems[
                                                                              index]
                                                                          .userid,
                                                                      image: filteredItems[
                                                                              index]
                                                                          .images,
                                                                      description:
                                                                          filteredItems[index]
                                                                              .description,
                                                                      style:
                                                                          "Fashion Style 2",
                                                                      createdBy:
                                                                          filteredItems[index]
                                                                              .userName,
                                                                      profile: filteredItems[
                                                                              index]
                                                                          .userPic,
                                                                      likes: filteredItems[
                                                                              index]
                                                                          .likeCount,
                                                                      dislikes:
                                                                          filteredItems[index]
                                                                              .dislikeCount,
                                                                      mylike: filteredItems[
                                                                              index]
                                                                          .mylike,
                                                                      addMeInFashionWeek:
                                                                          filteredItems[index]
                                                                              .addMeInFashionWeek,
                                                                    )));
                                                  },
                                                  child: Card(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: filteredItems[
                                                                          index]
                                                                      .images[0]
                                                                  ["type"] ==
                                                              "video"
                                                          ? Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: FileImage(File(
                                                                        filteredItems[index]
                                                                            .thumbnail))),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                              ),
                                                            )
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: filteredItems[
                                                                            index]
                                                                        .images[
                                                                    0]["image"],
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 20.0,
                                                                    height:
                                                                        20.0,
                                                                    child:
                                                                        SpinKitCircle(
                                                                      color:
                                                                          primary,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ))
                                    : ListView.builder(
                                        itemCount: posts1.length,
                                        itemBuilder: (context, index) {
                                          return Card(
                                            elevation: 10,
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .topRight,
                                                          stops: const [
                                                            0.0,
                                                            0.99
                                                          ],
                                                          tileMode:
                                                              TileMode.clamp,
                                                          colors: <Color>[
                                                            secondary,
                                                            primary,
                                                          ])),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10,
                                                            top: 5,
                                                            bottom: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            posts1[index]
                                                                        .userName ==
                                                                    name
                                                                ? Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => MyProfileScreen(
                                                                              id: posts1[index].userid,
                                                                              username: posts1[index].userName,
                                                                            )))
                                                                : Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => FriendProfileScreen(
                                                                              id: posts1[index].userid,
                                                                              username: posts1[index].userName,
                                                                            )));
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Container(
                                                              width: 180,
                                                              child: Row(
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  CircleAvatar(
                                                                      backgroundColor:
                                                                          dark1,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(50)),
                                                                        child: posts1[index].userPic ==
                                                                                null
                                                                            ? Image.network(
                                                                                "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                                width: 35,
                                                                                height: 40,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: posts1[index].userPic,
                                                                                imageBuilder: (context, imageProvider) => Container(
                                                                                  height: MediaQuery.of(context).size.height * 0.7,
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  decoration: BoxDecoration(
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
                                                                                errorWidget: (context, url, error) => ClipRRect(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                                                                    child: Image.network(
                                                                                      "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                                                      width: 35,
                                                                                      height: 35,
                                                                                    )),
                                                                              ),
                                                                      )),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    posts1[index]
                                                                        .userName,
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                        color:
                                                                            ascent,
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
                                                            onSelected:
                                                                (value) {
                                                              if (value == 0) {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ReportScreen(reportedID: posts1[index].userid)));
                                                              }
                                                              if (value == 2) {}
                                                              print(value);
                                                              //Navigator.pushNamed(context, value.toString());
                                                            },
                                                            itemBuilder:
                                                                (BuildContext
                                                                    bc) {
                                                              return [
                                                                PopupMenuItem(
                                                                  value: 0,
                                                                  child: Row(
                                                                    children: const [
                                                                      Icon(Icons
                                                                          .report),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
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
                                                                if (posts1[index]
                                                                        .userid !=
                                                                    id)
                                                                  PopupMenuItem(
                                                                    value: 2,
                                                                    child: Row(
                                                                      children: const [
                                                                        Icon(Icons
                                                                            .save),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          "Save Post",
                                                                          style:
                                                                              TextStyle(fontFamily: 'Montserrat'),
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        height: 320,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.87,
                                                        child: CarouselSlider(
                                                          carouselController:
                                                              _controller,
                                                          options:
                                                              CarouselOptions(
                                                                  enableInfiniteScroll:
                                                                      false,
                                                                  height: 320.0,
                                                                  autoPlay:
                                                                      false,
                                                                  enlargeCenterPage:
                                                                      true,
                                                                  viewportFraction:
                                                                      0.99,
                                                                  aspectRatio:
                                                                      2.0,
                                                                  initialPage:
                                                                      0,
                                                                  onPageChanged:
                                                                      (ind,
                                                                          reason) {
                                                                    setState(
                                                                        () {
                                                                      _current =
                                                                          ind;
                                                                    });
                                                                  }),
                                                          items: posts1[index]
                                                              .images
                                                              .map((i) {
                                                            return i["type"] ==
                                                                    "video"
                                                                ? Container(
                                                                    color: Colors
                                                                        .black,
                                                                    child:
                                                                        UsingVideoControllerExample(
                                                                      path: i[
                                                                          "video"],
                                                                    ))
                                                                : Builder(
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return CachedNetworkImage(
                                                                        imageUrl:
                                                                            i["image"],
                                                                        imageBuilder:
                                                                            (context, imageProvider) =>
                                                                                Container(
                                                                          height: MediaQuery.of(context)
                                                                              .size
                                                                              .height,
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
                                                                              image: imageProvider,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                SpinKitCircle(
                                                                          color:
                                                                              primary,
                                                                          size:
                                                                              60,
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.84,
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(image: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image, fit: BoxFit.fill),
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(posts1[index]
                                                      .images
                                                      .length
                                                      .toString()),
                                                ),
                                                posts1[index].images.length == 1
                                                    ? const SizedBox()
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: posts1[index]
                                                            .images
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          return GestureDetector(
                                                            onTap: () => _controller
                                                                .animateToPage(
                                                                    entry.key),
                                                            child: Container(
                                                              width: 12.0,
                                                              height: 12.0,
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 8.0,
                                                                  horizontal:
                                                                      4.0),
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: (Theme.of(context).brightness ==
                                                                              Brightness
                                                                                  .dark
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black)
                                                                      .withOpacity(_current ==
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
                                                const Divider(
                                                  height: 2,
                                                  thickness: 2,
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 0.0,
                                                            right: 0.0),
                                                    child:
                                                        posts1[index].userid ==
                                                                id
                                                            ? Row(
                                                                children: [
                                                                  posts1[index]
                                                                              .addMeInFashionWeek ==
                                                                          true
                                                                      ? posts1[index].mylike !=
                                                                              "like"
                                                                          ? IconButton(
                                                                              onPressed: () {},
                                                                              icon: const Icon(
                                                                                Icons.favorite,
                                                                                size: 20,
                                                                              ))
                                                                          : IconButton(
                                                                              onPressed: () {},
                                                                              icon: const Icon(
                                                                                FontAwesomeIcons.heart,
                                                                                size: 20,
                                                                              ))
                                                                      : posts1[index].mylike != "like"
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
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Icon(Icons.star_border_outlined, size: 24, color: Colors.orange),
                                                                              ),
                                                                            ),
                                                                  posts1[index]
                                                                              .likeCount ==
                                                                          "0"
                                                                      ? const SizedBox()
                                                                      : Text(posts1[
                                                                              index]
                                                                          .likeCount),
                                                                  posts1[index]
                                                                              .isCommentEnabled ==
                                                                          true
                                                                      ? IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => CommentScreen(id: posts1[index].id, pic: posts1[index].userPic)));
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            FontAwesomeIcons.comment,
                                                                            size:
                                                                                20,
                                                                          ))
                                                                      : const SizedBox(),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: posts1[index].isCommentEnabled == true
                                                                              ? MediaQuery.of(context).size.width * 0.35
                                                                              : MediaQuery.of(context).size.width * 0.4),
                                                                      child: Text(
                                                                        DateFormat.yMMMEd()
                                                                            .format(DateTime.parse(posts1[index].date)),
                                                                        style: const TextStyle(
                                                                            fontFamily:
                                                                                'Montserrat',
                                                                            fontSize:
                                                                                12),
                                                                      )),
                                                                ],
                                                              )
                                                            : Row(
                                                                children: [
                                                                  posts1[index]
                                                                              .addMeInFashionWeek ==
                                                                          true
                                                                      ? posts1[index].mylike !=
                                                                              "like"
                                                                          ? IconButton(
                                                                              onPressed: () {},
                                                                              icon: const Icon(
                                                                                Icons.favorite,
                                                                                size: 20,
                                                                              ))
                                                                          : IconButton(
                                                                              onPressed: () {},
                                                                              icon: const Icon(
                                                                                FontAwesomeIcons.heart,
                                                                                size: 20,
                                                                              ))
                                                                      : posts1[index].mylike != "like"
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
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Icon(
                                                                                  Icons.star_border_outlined,
                                                                                  color: Colors.orange,
                                                                                  size: 24,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                  posts1[index]
                                                                              .likeCount ==
                                                                          "0"
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
                                                                          "${posts1[index].likeCount}"),
                                                                  posts1[index]
                                                                              .isCommentEnabled ==
                                                                          true
                                                                      ? IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: (context) => CommentScreen(id: posts1[index].id, pic: posts1[index].userPic)));
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            FontAwesomeIcons.comment,
                                                                            size:
                                                                                20,
                                                                          ))
                                                                      : const SizedBox(),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.3),
                                                                      child:
                                                                          Text(
                                                                        DateFormat.yMMMEd()
                                                                            .format(DateTime.parse(posts1[index].date)),
                                                                        style: const TextStyle(
                                                                            fontFamily:
                                                                                'Montserrat',
                                                                            fontSize:
                                                                                12),
                                                                      )),
                                                                ],
                                                              )),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    posts1[index]
                                                                .description
                                                                .toString()
                                                                .length >
                                                            50
                                                        ? Expanded(
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
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
                                                                                posts1[index].userName,
                                                                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.bold),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Text(
                                                                                "${posts1[index].description.substring(0, 7)}...",
                                                                                style: const TextStyle(
                                                                                  fontFamily: 'Montserrat',
                                                                                  fontSize: 12,
                                                                                ),
                                                                                textAlign: TextAlign.start,
                                                                              )
                                                                            ],
                                                                          )
                                                                        : Text(
                                                                            posts1[index].userName +
                                                                                posts1[index].description,
                                                                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12)),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            isExpanded =
                                                                                !isExpanded;
                                                                          });
                                                                        },
                                                                        child: Text(
                                                                            isExpanded
                                                                                ? "Show More"
                                                                                : "Show Less",
                                                                            style:
                                                                                TextStyle(color: Theme.of(context).primaryColor)))
                                                                  ],
                                                                )),
                                                          )
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      posts1[index]
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
                                                                      posts1[index]
                                                                          .description,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Montserrat',
                                                                          fontSize:
                                                                              12),
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
                                        },
                                      )
                                // GridView.builder(
                                //   itemCount: posts1.length,
                                //   gridDelegate:
                                //   const SliverGridDelegateWithFixedCrossAxisCount(
                                //       crossAxisCount: 3,
                                //       mainAxisSpacing: 1.0,
                                //       crossAxisSpacing: 1.0),
                                //   itemBuilder:
                                //       (BuildContext context, int index) {
                                //     return WidgetAnimator(
                                //       GestureDetector(
                                //         onTap: () {
                                //           Navigator.push(
                                //               context,
                                //               MaterialPageRoute(
                                //                   builder: (context) =>
                                //                       SwapDetail(
                                //                         userid:
                                //                         posts1[index]
                                //                             .userid,
                                //                         image: posts1[index]
                                //                             .images,
                                //                         description: posts1[
                                //                         index]
                                //                             .description,
                                //                         style:
                                //                         "Fashion Style 2",
                                //                         createdBy:
                                //                         posts1[index]
                                //                             .userName,
                                //                         profile:
                                //                         posts1[index]
                                //                             .userPic,
                                //                         likes: posts1[index]
                                //                             .likeCount,
                                //                         dislikes: posts1[
                                //                         index]
                                //                             .dislikeCount,
                                //                         mylike:
                                //                         posts1[index]
                                //                             .mylike,
                                //                         addMeInFashionWeek: posts1[index].addMeInFashionWeek,
                                //                       )));
                                //         },
                                //         child: Card(
                                //           shape: const RoundedRectangleBorder(
                                //               borderRadius:
                                //               BorderRadius.all(
                                //                   Radius.circular(10))),
                                //           child: Container(
                                //             decoration: const BoxDecoration(
                                //               borderRadius:
                                //               BorderRadius.all(
                                //                   Radius.circular(10)),
                                //             ),
                                //             child: posts1[index].images[0]
                                //             ["type"] ==
                                //                 "video"
                                //                 ? Container(
                                //               decoration:
                                //               BoxDecoration(
                                //                 image: DecorationImage(
                                //                     fit: BoxFit.cover,
                                //                     image: FileImage(
                                //                         File(posts1[
                                //                         index]
                                //                             .thumbnail))),
                                //                 borderRadius:
                                //                 const BorderRadius.all(
                                //                     Radius
                                //                         .circular(
                                //                         10)),
                                //               ),
                                //             )
                                //                 : ClipRRect(
                                //               borderRadius:
                                //               BorderRadius
                                //                   .circular(10),
                                //               child:
                                //               CachedNetworkImage(
                                //                 imageUrl:
                                //                 posts1[index]
                                //                     .images[0]
                                //                 ["image"],
                                //                 fit: BoxFit.cover,
                                //                 placeholder:
                                //                     (context, url) =>
                                //                     Center(
                                //                       child: SizedBox(
                                //                         width: 20.0,
                                //                         height: 20.0,
                                //                         child:
                                //                         SpinKitCircle(
                                //                           color: primary,
                                //                           size: 20,
                                //                         ),
                                //                       ),
                                //                     ),
                                //                 errorWidget: (context,
                                //                     url, error) =>
                                //                     Container(
                                //                       height: MediaQuery.of(
                                //                           context)
                                //                           .size
                                //                           .height *
                                //                           0.84,
                                //                       width:
                                //                       MediaQuery.of(
                                //                           context)
                                //                           .size
                                //                           .width,
                                //                       decoration:
                                //                       BoxDecoration(
                                //                         image: DecorationImage(
                                //                             image: Image.network(
                                //                                 "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png")
                                //                                 .image,
                                //                             fit: BoxFit
                                //                                 .fill),
                                //                       ),
                                //                     ),
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     );
                                //   },
                                // )
                                )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String? getThumbnail(imagePath) {
    VideoThumbnail.thumbnailFile(
      video: imagePath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    ).then((value) {
      return value;
    });
  }
}
