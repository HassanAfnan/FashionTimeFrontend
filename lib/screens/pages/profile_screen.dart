import 'dart:convert';
import 'dart:io';

import 'package:FashionTime/screens/pages/hundred_posts.dart';
import 'package:FashionTime/screens/pages/my_idols.dart';
import 'package:FashionTime/screens/pages/my_posts.dart';
import 'package:FashionTime/screens/pages/my_reels/my_reel_interface.dart';
import 'package:FashionTime/screens/pages/my_saved_post.dart';
import 'package:FashionTime/screens/pages/pinnedStories/pin_stories.dart';
import 'package:FashionTime/screens/pages/post_scroll_to_next/PostScrollToNext.dart';
import 'package:FashionTime/screens/pages/post_scroll_to_next/PostToMedals.dart';
import 'package:FashionTime/screens/pages/post_scroll_to_next/PostToStar.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/models/post_model.dart';
import 'package:FashionTime/screens/pages/edit_profile.dart';
import 'package:FashionTime/screens/pages/followers_screen.dart';

import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/saved_post_model.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import 'fans.dart';

class ProfileScreen extends StatefulWidget {
  final bool type;
  const ProfileScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool grid = true;
  bool profile = false;
  bool styles = false;
  String id = "";
  String token = "";
  bool loading = false;
  bool loading1 = false;
  bool loading2 = false;
  bool loading3 = false;
  bool loading4=false;
  List<Story>storyList=[];
  Map<String, dynamic> data = {};
  List<SavedPostModel> myPosts = [];
  List<PostModel> commentedPost = [];
  List<PostModel> likedPost = [];
  late List<String> BadgeList = [];
  late List<int> rankingOrders = [];
  List<PostModel> medalPostsModel = [];
  List<String> medalsPosts = [];
  late String lowestRankingOrderDocument = "";
  List<String> mediaLink = [];
  List<String> videoUrls = [];
  int index = 0;

  late TabController tabController;

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(preferences.getString("fcm_token"));
    print("user id is----->>>${preferences.getString("id")}");
    getProfile();
    getMyPosts();
  }

  Color _getTabIconColor(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.white : primary;
  }

  ColorFilter _getImageColorFilter(BuildContext context) {
    // Check the current theme's brightness
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Return the appropriate color filter based on the theme
    return isDarkMode
        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
        : ColorFilter.mode(primary, BlendMode.srcIn);
  }

  getProfile() {
    // myPosts.clear();
    // commentedPost.clear();
    // likedPost.clear();
    https.get(Uri.parse("$serverUrl/user/api/profile/"), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).then((value) {
      print("Profile data ==> ${value.body.toString()}");
      setState(() {
        data = json.decode(value.body);
        myPosts.clear();
      });
    });
   // getMyPosts();
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
  unSaveFashion(fashionSaveID) {
    String url = "$serverUrl/fashionSaved/$fashionSaveID/";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: primary,
          content: const Text("Unsave Fashion?",
              style: TextStyle(color: ascent, fontFamily: 'Montserrat')),
          title: const Text("FashionTime",
              style: TextStyle(
                  color: ascent,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () {
                  try {
                    https.delete(Uri.parse(url), headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token"
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    debugPrint(
                        "error received while unsaving fashion ==========>${e.toString()}");
                  }
                },
                icon: const Text("Yes",
                    style: TextStyle(color: ascent, fontFamily: 'Montserrat'))),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Text("No",
                    style: TextStyle(color: ascent, fontFamily: 'Montserrat')))
          ],
        );
      },
    );
  }
  getPinStories(){
    String url='$serverUrl/apiPinnedStory';
    try{
      https.get(Uri.parse(url),headers:
      {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        if(value.statusCode==200){
          final List<dynamic> result = jsonDecode(value.body);
          for(var result in result){
            if (result.containsKey('upload')) {
              if (result['upload'] != null && result['upload'].containsKey('media')) {
                // Handle case where media content is present
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
                        viewed_users: []
                    );
                    setState(() {
                      storyList.add(story);
                    });
                    print("length of pinned stories is========>${storyList.length}");
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

                final Story story = Story(
                    url: result['text'], // No media URL
                    media: MediaType.text, // Text content
                    user: user,
                    viewedBy: result['viewed_by'],
                    storyId: result['id'],
                    duration: duration,
                    uploadObject: result['upload'],
                    viewed_users: []
                );

                storyList.add(story);
              }
          }

        else{
          debugPrint("error received with status code and body=======>${value.statusCode} && ${value.body.toString()}");
        }
      }}});
    }
    catch(e){
      debugPrint("error received=========>${e.toString()}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    getCashedData();
  }

  getMyPosts() {
    myPosts.clear();
    setState(() {
      loading1 = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/fashionSaved/my-saved-fashions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }).then((value) {
        print("Saved posts => " + jsonDecode(value.body).toString());
        if (jsonDecode(value.body).length <= 0) {
          setState(() {
            loading1 = false;
          });
          print("No data");
        } else {
          setState(() {
            loading1 = false;
          });
          jsonDecode(value.body).forEach((value) {
            if (value["upload"]["media"][0]["type"] == "video") {
              VideoThumbnail.thumbnailFile(
                video: value["upload"]["media"][0]["video"],
                imageFormat: ImageFormat.JPEG,
                maxWidth: 128,
                // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                quality: 25,
              ).then((value1) {
                setState(() {
                  myPosts.add(SavedPostModel(
                      value["id"].toString(),
                      value["description"],
                      value["upload"]["media"],
                      value["user"]["name"],
                      value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
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
                      value['mySaved']));
                  debugPrint("fashion save id is${value['mySaved']}");
                });
              });
            } else {
              setState(() {
                myPosts.add(SavedPostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["name"],
                    value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],
                    "",
                    value["user"]["id"].toString(),
                    value["myLike"] == null
                        ? "like"
                        : value["myLike"].toString(),
                    value['mySaved']));
                debugPrint("fashion save id is${value['mySaved']}");
              });
            }
          });
        }
      });
      getCommentedPosts();
      getBadges();
      getBadgesHistory();
      getPostsWithMedal();
      getAllReels();
      getPinStories();
    } catch (e) {
      setState(() {
        loading1 = false;
      });
      print("Error --> $e");
    }
  }
  Future<void> getAllReels() async {
    String apiUrl = '$serverUrl/fashionReel/my-reels/?id=$id';
    loading4=false;
    try {
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        reels.clear();
        final dynamic responseData = jsonDecode(response.body);
        if (responseData != null && responseData is Map<String, dynamic>) {
          final List<dynamic> results = responseData['results'] ?? [];

          setState(() {
            reels = List<Map<String, dynamic>>.from(results);
            debugPrint("all reel data ${reels.toString()}");
            debugPrint("reel data length ${reels.length}");
            setState(() {
              loading4=false;
            });
          });
          for (var result in results) {
            var upload = result['upload'];
            var media = upload != null ? (upload['media'] as List<dynamic>) : null;
            if (media != null && media.isNotEmpty) {
              var videoUrl = media.first['video'];
              String? videoThumbnail = await VideoThumbnail.thumbnailFile(
                video: videoUrl,
                imageFormat: ImageFormat.JPEG,
                maxWidth: 128,
                quality: 25,
              );
              if (videoUrl != null && videoUrl is String) {
                videoUrls.add(videoThumbnail!);
                debugPrint("Video URLs: $videoUrls");
              }
            }
          }
          debugPrint("Video URLs: length ${videoUrls.length}");
          setState(() {

          });

          final dynamic nextUrl = responseData['next'];
          if (nextUrl != null) {
            pageNumber++;
          }
          else{
          }
        } else {
          debugPrint("Unexpected data format or null value: $responseData");
        }
      } else {
        debugPrint('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error loading data: $error');
    }
  }
  getPostsWithMedal() {
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/fashionUpload/top-trending/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        mediaLink.clear();
        medalsPosts.clear();
        print("Timer ==> " + jsonDecode(value.body).toString());
        setState(() {
          //myDuration = Duration(seconds: int.parse(jsonDecode(value.body)["result"]["time_remaining"].));
          loading = false;
        });
        jsonDecode(value.body)["result"].forEach((value) {
          if (value['user']['id'].toString() == id.toString()) {
            print("condition is true");
            if (value["upload"]["media"][0]["type"] == "video") {
              VideoThumbnail.thumbnailFile(
                video: value["upload"]["media"][0]["video"],
                imageFormat: ImageFormat.JPEG,
                maxWidth:
                    128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                quality: 25,
              ).then((value1) {
                setState(() {
                  medalPostsModel.add(PostModel(
                      value["id"].toString(),
                      value["description"],
                      value["upload"]["media"],
                      value["user"]["username"],
                      value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
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
                     {},
                    {}
                  ));
                });
                mediaLink.add(value['upload']['media'][0]['video'].toString());
                print("imageslinks is ${mediaLink.toString()}");
                print("current user data is ${medalPostsModel.toString()}");
              });
            } else {
              setState(() {
                medalPostsModel.add(PostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["username"],
                    value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],
                    "",
                    value["user"]["id"].toString(),
                    value["myLike"] == null
                        ? "like"
                        : value["myLike"].toString(),
                    {},
                  {}
                ));
              });
              mediaLink.add(value['upload']['media'][0]['image'].toString());
              print("imageslinks is ${mediaLink.toString()}");
              print("current user data is ${medalPostsModel.toString()}");
            }
          } else {
            print("id mismatch");
          }
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }

  getCommentedPosts() {
    commentedPost.clear();
    setState(() {
      loading2 = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/fashionComments/my-commented-fashions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }).then((value) {
        print("Commented post ==> " + jsonDecode(value.body).length.toString());
        setState(() {
          loading2 = false;
        });
        jsonDecode(value.body).forEach((value) {
          if (value["upload"]["media"][0]["type"] == "video") {
            VideoThumbnail.thumbnailFile(
              video: value["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth:
                  128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
              quality: 25,
            ).then((value1) {
              setState(() {
                commentedPost.add(PostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["name"],
                    value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
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
                    {},
                  {}
                ));
              });
            });
          } else {
            setState(() {
              commentedPost.add(PostModel(
                  value["id"].toString(),
                  value["description"],
                  value["upload"]["media"],
                  value["user"]["name"],
                  value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],
                  "",
                  value["user"]["id"].toString(),
                  value["myLike"] == null
                      ? "like"
                      : value["myLike"].toString(),
                  {},
                {}
              ));
            });
          }
        });
      });
      getLikedPosts();
    } catch (e) {
      setState(() {
        loading2 = false;
      });
      print("Error --> $e");
    }
  }

  getLikedPosts() {
    likedPost.clear();
    setState(() {
      loading3 = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/fashionLikes/my-liked-fashions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }).then((value) {
        print(jsonDecode(value.body));
        setState(() {
          loading3 = false;
        });
        jsonDecode(value.body).forEach((value) {
          if (value["upload"]["media"][0]["type"] == "video") {
            VideoThumbnail.thumbnailFile(
              video: value["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth:
                  128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
              quality: 25,
            ).then((value1) {
              setState(() {
                likedPost.add(PostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["name"],
                    value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
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
                    {},
                  {}
                ));
              });
            });
          } else {
            setState(() {
              likedPost.add(PostModel(
                  value["id"].toString(),
                  value["description"],
                  value["upload"]["media"],
                  value["user"]["name"],
                  value["user"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],
                  "",
                  value["user"]["id"].toString(),
                  value["myLike"] == null
                      ? "like"
                      : value["myLike"].toString(),
                  {},
                {}
              ));
            });
          }
        });
      });
    } catch (e) {
      setState(() {
        loading3 = false;
      });
      print("Error --> $e");
    }
  }

  getBadges() async {
    final response = await https.get(Uri.parse('$serverUrl/user/api/Badge/'));

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse =
          (json.decode(response.body) as List).cast<Map<String, dynamic>>();

      BadgeList =
          jsonResponse.map((entry) => entry['document'] as String).toList();

      // Print the result
      print("all badges$BadgeList");
    } else {
      // Handle the error if the request was not successful
      print('Error: ${response.statusCode}');
    }
  }

  getBadgesHistory() async {
    final response = await https.get(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }, Uri.parse("$serverUrl/user/api/badgehistory/"));
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse =
          (json.decode(response.body) as List).cast<Map<String, dynamic>>();
      rankingOrders = jsonResponse
          .map<int>((item) => item['badge']['ranking_order'] as int)
          .toList();
      List<Map<String, dynamic>> rankingAndDocuments =
          jsonResponse.map<Map<String, dynamic>>((item) {
        return {
          'ranking_order': item['badge']['ranking_order'] as int,
          'document': item['badge']['document'] as String,
        };
      }).toList();

      // Find the item with the lowest ranking order
      Map<String, dynamic>? lowestRankingOrderItem = rankingAndDocuments.reduce(
          (min, current) =>
              min['ranking_order'] < current['ranking_order'] ? min : current);

      if (lowestRankingOrderItem != null) {
        // Access the document field associated with the lowest ranking order
        lowestRankingOrderDocument =
            lowestRankingOrderItem['document'] as String;

        print('Lowest ranking order document: $lowestRankingOrderDocument');
      } else {
        print('No items in the list');
      }
      print('Ranking Orders: $rankingOrders');
    } else {
      print('Error in badge history: ${response.statusCode}');
    }
  }

  String convertLikes(int likes) {
    if (likes > 999) {
      if (likes < 1000000) {
        return '${(likes / 1000).toStringAsFixed(0)}k';
      } else {
        return '${(likes / 1000000).toStringAsFixed(0)} million';
      }
    } else {
      return likes.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.type == true
            ? AppBar(
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
                  "Profile",
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                actions: const [
                  //IconButton(onPressed: (){}, icon: Icon(Icons.settings))
                ],
              )
            : null,
        body: data.keys.isEmpty
            ? SpinKitCircle(
                size: 50,
                color: primary,
              )
            : RefreshIndicator(
          color: primary,
              onRefresh: () {
                return getCashedData();
              },
              child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 1.5,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        WidgetAnimator(
                          Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Icons.favorite_outlined,
                                            color: Colors.red, size: 30),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.008,
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text(
                                            convertLikes(data['likesCount']
                                                ['likes_week_fashion']),
                                          ))
                                    ],
                                  ),
                                  data['badge'] == null
                                      ? CircleAvatar(
                                          radius: 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 5,
                                                    color: Colors.transparent),
                                                color:
                                                    Colors.black.withOpacity(0.6),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(120))),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(120)),
                                              child: CachedNetworkImage(
                                                imageUrl: data["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w",
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
                                        )
                                      : CircleAvatar(
                                          radius: 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 5,
                                                    color: (
                                                            // data["badge"]["id"] == 10
                                                            //     || data["badge"]["id"] == 11
                                                            // data["badge"]["id"] == 12
                                                            data["badge"]
                                                                        ["id"] ==
                                                                    13 ||
                                                                data["badge"]
                                                                        ["id"] ==
                                                                    14 ||
                                                                data["badge"]
                                                                        ["id"] ==
                                                                    15 ||
                                                                data["badge"]
                                                                        ["id"] ==
                                                                    16 ||
                                                                data["badge"]
                                                                        ["id"] ==
                                                                    17 ||
                                                                data["badge"]
                                                                        ["id"] ==
                                                                    18 ||
                                                                data["badge"]
                                                                        ["id"] ==
                                                                    19
                                                        //  rankingOrders.contains(1)==true
                                                        )
                                                        ? primary
                                                        : data["badge"]["id"] ==
                                                                12
                                                            ? Colors.orange
                                                            : data['badge']['id'] ==
                                                                    10
                                                                ? gold
                                                                : data['badge']['id'] ==
                                                                        11
                                                                    ? silver
                                                                    : Colors
                                                                        .transparent),
                                                color:
                                                    Colors.black.withOpacity(0.6),
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(120))),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(120)),
                                              child: CachedNetworkImage(
                                                imageUrl: data["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w",
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
                                        ),
                                  Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.008,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 21),
                                        child: Text(convertLikes(
                                            data['likesCount']
                                                ['likes_non_week_fashion'])),
                                      )
                                    ],
                                  ),
                                  // Text("hello"),
                                ],
                              ),
                              data["badge"] == null
                                  ? const SizedBox()
                                  : Positioned(
                                      bottom: 1,
                                      right: 80,
                                      child: GestureDetector(
                                          onTap: () {
                                            //Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen()));
                                          },
                                          child:
                                              // Image.network(data["badge"]["document"],height: 80,width: 80,
                                              //   errorBuilder: (context, error, stackTrace) {
                                              //     return SizedBox();
                                              //   }
                                              //   ,)
                                              ClipRRect(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(120)),
                                            child: CachedNetworkImage(
                                              imageUrl: data["badge"]["document"],
                                              //imageUrl: lowestRankingOrderDocument,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(120)),
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  SpinKitCircle(
                                                color: primary,
                                                size: 20,
                                              ),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                              Radius.circular(
                                                                  50)),
                                                      child: Image.network(
                                                        data["badge"]["document"],
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.contain,
                                                      )),
                                            ),
                                          ))),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        WidgetAnimator(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => StylesScreen()));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MyPostScreen()));
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data["stylesCount"].toString(),
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Styles",
                                          style: TextStyle(
                                              color: primary,
                                              fontFamily: 'Montserrat'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FanScreen()));
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data['fansCount'].toString(),
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Fans",
                                          style: TextStyle(
                                              color: primary,
                                              fontFamily: 'Montserrat'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => StylesScreen()));
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => const MyIdols()));
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data["idolsCount"].toString(),
                                          style:
                                              const TextStyle(fontFamily: 'Montserrat'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Idols",
                                          style: TextStyle(
                                              color: primary,
                                              fontFamily: 'Montserrat'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FollowerScreen()));
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data["friendsCount"].toString(),
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Friends",
                                          style: TextStyle(
                                              color: primary,
                                              fontFamily: 'Montserrat'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) =>
                              //             const MyHundredLikedPost()));
                              //   },
                              //   child:
                              //   Icon(Icons.history,color: primary,)
                              // ),
                              // GestureDetector(
                              //   onTap: (){
                              //
                              //   },
                              //   child: InkWell(
                              //     onTap: () {
                              //       Navigator.push(context, MaterialPageRoute(builder: (context) => const ReelsInterfaceScreen(),));
                              //     },
                              //       child: Icon(Icons.video_collection_rounded,color: primary,size: 28,)),
                              //   ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        WidgetAnimator(SizedBox(
                          height: 80,
                          child: WidgetAnimator(Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfile())).then((value) {
                                    commentedPost.clear();
                                    getProfile();
                                  });
                                },
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15))),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 35,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.topRight,
                                            stops: const [0.0, 0.99],
                                            tileMode: TileMode.clamp,
                                            colors: <Color>[
                                              secondary,
                                              primary,
                                            ]),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12))),
                                    child: const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                          color: ascent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                        )),
                        const SizedBox(
                          height: 5,
                        ),
                        WidgetAnimator(Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              "${data["name"] ?? "No name"}",
                              style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'),
                            )
                          ],
                        )),
                        const SizedBox(
                          height: 5,
                        ),
                        // WidgetAnimator(
                        //     Row(
                        //       children: [
                        //         SizedBox(width: 25),
                        //         Text("@${data["username"]}", style: TextStyle(
                        //             color: primary,
                        //             fontWeight: FontWeight.bold,
                        //             fontFamily: 'Montserrat'
                        //         ),)
                        //       ],
                        //     )
                        // ),
                        const SizedBox(
                          height: 5,
                        ),
                        data["description"] == null || data["description"] == ""
                            ? const SizedBox()
                            : WidgetAnimator(
                                ListView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: 300.0,
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                minHeight: 10.0,
                                                maxHeight: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                              ),
                                              child: AutoSizeText(
                                                data["description"] ?? "No description",
                                                style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Montserrat'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                        // const SizedBox(
                        //   height: 5,
                        // ),
                        storyList.isEmpty?const SizedBox():
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 70,
                            child: ListView.builder(
                              itemCount: storyList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return  GestureDetector(
                                  onTap: () {
                                    final Story tappedStory=storyList.removeAt(index);
                                    storyList.insert(0, tappedStory);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PinnedStoryScreen(stories: storyList),));
                                  },
                                  child:   CircleAvatar(

                                    backgroundImage:const AssetImage("assets/highlightIcon.png"),
                                    backgroundColor: primary,
                                    radius: 40,
                                    foregroundColor: ascent,
                                  ),
                                );
                              },),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: TabBar(
                            controller: tabController,
                            tabs: [
                              Tab(
                                  icon: Icon(Icons.star_border_purple500_outlined,
                                      color: _getTabIconColor(context))),
                              Tab(
                                icon: ColorFiltered(
                                  colorFilter: _getImageColorFilter(context),
                                  child:
                                      Image.asset('assets/bagde.png', height: 28),
                                ),
                              ),
                              Tab(
                                icon: ColorFiltered(
                                  colorFilter: _getImageColorFilter(context),
                                  child:
                                  Image.asset('assets/flicksProfileIcon.png', height: 28),
                                ),
                              ),
                              Tab(
                                icon: ColorFiltered(
                                  colorFilter: _getImageColorFilter(context),
                                  child:
                                  Image.asset('assets/Frame1.png', height: 28),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                            child: GridTab(
                          tabController: tabController,
                          loading1: loading1,
                          myPosts: myPosts,
                          loading2: loading2,
                          commentedPost: commentedPost,
                          loading3: loading3,
                          likedPost: likedPost,
                          badges: mediaLink,
                          unsaveFashion: unSaveFashion,
                              loading4: loading4,
                              flicks:videoUrls,
                                getMyPosts:getMyPosts,
                              medalsPosts: medalPostsModel,
                              getMedalsPosts: getPostsWithMedal,
                              getLikePosts: getLikedPosts,
                        )),
                      ],
                    ),
                  ),
                ),
            ));
  }
}

class GridTab extends StatelessWidget {
  const GridTab(
      {super.key,
      required this.tabController,
      required this.loading1,
      required this.myPosts,
      required this.loading2,
      required this.commentedPost,
      required this.loading3,
      required this.likedPost,
      required this.badges,
      required this.unsaveFashion, required this.loading4, required this.flicks,
      required this.getMyPosts, required this.medalsPosts, required this.getMedalsPosts, required this.getLikePosts
      });

  final TabController tabController;
  final bool loading1;
  final List<SavedPostModel> myPosts;
  final bool loading2;
  final List<PostModel> commentedPost;
  final bool loading3;
  final List<PostModel> likedPost;
  final List<String> badges;
  final Function unsaveFashion;
  final bool loading4;
  final List<String> flicks;
  final List<PostModel> medalsPosts;
  final Function getMedalsPosts;
  final Function getMyPosts;
  final Function getLikePosts;

  @override
  Widget build(BuildContext context) {
    Color _getTabIconColor(BuildContext context) {
      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return isDarkMode ? Colors.white : primary;
    }

    return TabBarView(
      controller: tabController,
      children: <Widget>[
        loading1 == true
            ? SpinKitCircle(
                color: primary,
                size: 50,
              )
            : (likedPost.isEmpty
                ? Column(
                    children: const [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "No Starposts",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: likedPost.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        // mainAxisSpacing: 10
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return WidgetAnimator(
                          GestureDetector(
                          onLongPress: () {
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
                                  "Do you want to download this media?",
                                  style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Yes",
                                        style: TextStyle(
                                            color: ascent, fontFamily: 'Montserrat')),
                                    onPressed: () {
                                      FileDownloader.downloadFile(
                                        url: likedPost[index].toString(),
                                        name: likedPost[index].toString(),
                                        onDownloadCompleted: (String path) {
                                          debugPrint('IMAGE DOWNLOADED TO PATH: $path');
                                          Fluttertoast.showToast(msg: "File downloaded at $path",backgroundColor: primary);
                                        },
                                        onDownloadError: (String error) {
                                          debugPrint('DOWNLOAD ERROR: $error');
                                          Fluttertoast.showToast(msg: "Error while downloading file",backgroundColor:Colors.red);
                                        },
                                      );
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
                            onTap: () {
                              likedPost.insert(0,likedPost[index]);
                              likedPost.removeAt(index);
                              // myPosts.indexOf((e) => e.userid == myPosts[index].userid)
                              // var list = myPosts.insert(0, myPosts[myPosts.indexOf((e) => e.userid == myPosts[index].userid)]);
                              debugPrint("style clicked");
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PostScrollToStar(
                                  title: "Star Posts",
                                  posts: likedPost,
                                  index: index
                              ),)).then((value){
                                getLikePosts();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Stack(
                                children: [
                                  Container(
                                    child: likedPost[index].images[0]
                                                ["type"] ==
                                            "video"
                                        ? Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: FileImage(File(
                                                      likedPost[index]
                                                          .thumbnail))),
                                              //borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: likedPost[index]
                                                .images[0]["image"],
                                            height: 820,
                                            width: 200,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: SpinKitCircle(
                                                  color: primary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.84,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: Image.network(
                                                            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png")
                                                        .image,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                      right: 10,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: likedPost[index].images[0]
                                                    ["type"] ==
                                                "video"
                                            ? const Icon(
                                                Icons.video_camera_back)
                                            : const Icon(Icons.image),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
        loading3 == true
            ? SpinKitCircle(
                color: primary,
                size: 50,
              )
            : (badges.isEmpty
                ? Column(
                    children: const [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "No Eventposts",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: badges.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        // mainAxisSpacing: 10
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return WidgetAnimator(
                          GestureDetector(
                            onLongPress: () {
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
                                    "Do you want to download this media?",
                                    style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Yes",
                                          style: TextStyle(
                                              color: ascent, fontFamily: 'Montserrat')),
                                      onPressed: () {
                                        FileDownloader.downloadFile(
                                          url: badges[index].toString(),
                                          name: badges[index].toString(),
                                          onDownloadCompleted: (String path) {
                                            debugPrint('IMAGE DOWNLOADED TO PATH: $path');
                                            Fluttertoast.showToast(msg: "File downloaded at $path",backgroundColor: primary);
                                          },
                                          onDownloadError: (String error) {
                                            debugPrint('DOWNLOAD ERROR: $error');
                                            Fluttertoast.showToast(msg: "Error while downloading file",backgroundColor:Colors.red);
                                          },
                                        );
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
                            onTap: () {
                              medalsPosts.insert(0,medalsPosts[index]);
                              medalsPosts.removeAt(index);
                              // myPosts.indexOf((e) => e.userid == myPosts[index].userid)
                              // var list = myPosts.insert(0, myPosts[myPosts.indexOf((e) => e.userid == myPosts[index].userid)]);
                              debugPrint("style clicked");
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PostScrollToMedals(
                                  title: "Medals Posts",
                                  posts: medalsPosts,
                                  index: index
                              ),)).then((value){
                                getMedalsPosts();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        // borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                    child: badges.isNotEmpty
                                        ? Container(
                                            height: 120,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image:
                                                    NetworkImage(badges[index]),
                                              ),
                                              //borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl:
                                                'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',
                                            fit: BoxFit.cover,
                                            height: 820,
                                            width: 200,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: SpinKitCircle(
                                                  color: primary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.84,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: Image.network(
                                                            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png")
                                                        .image,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                      right: 10,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Image.asset(
                                          'assets/bagde.png',
                                          height: 28,
                                          color: _getTabIconColor(context),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
            ),
        loading4 == true
            ? SpinKitCircle(color: primary)
            : flicks == null || flicks.isEmpty
            ? Column(
          children: const [
            SizedBox(
              height: 40,
            ),
            Text(
              "No Flicks",
              textAlign: TextAlign.center,
            ),
          ],
        )
            : SingleChildScrollView(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: flicks.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              // mainAxisSpacing: 10
            ),
            itemBuilder: (BuildContext context, int index) {
              return WidgetAnimator(
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const MyReelsInterfaceScreen()));
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              // borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child:  Container(
                              height: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                  // NetworkImage( flicks[index]),
                                  FileImage(File(flicks[index]))
                                ),
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        loading2 == true
            ? Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                SpinKitCircle(
          color: primary,
          size: 50,
        ),
              ],
            )
            : (myPosts.isEmpty
            ? Column(
          children: const [
            SizedBox(
              height: 40,
            ),
            Text(
              "No Styles",
              textAlign: TextAlign.center,
            ),
          ],
        )
            : SingleChildScrollView(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: myPosts.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              //mainAxisSpacing: 10
            ),
            itemBuilder: (BuildContext context, int index) {
              return WidgetAnimator(
                GestureDetector(
                  onTap: () {
                    myPosts.insert(0,myPosts[index]);
                    myPosts.removeAt(index);
                    // myPosts.indexOf((e) => e.userid == myPosts[index].userid)
                    // var list = myPosts.insert(0, myPosts[myPosts.indexOf((e) => e.userid == myPosts[index].userid)]);
                    debugPrint("style clicked");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PostScrollToNext(
                      title: "Saved Styles",
                      posts: myPosts,
                      index: index
                    ),)).then((value){
                      getMyPosts();
                    });
                  },
                  onLongPress: () {
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
                          "Do you want to download this media?",
                          style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Yes",
                                style: TextStyle(
                                    color: ascent, fontFamily: 'Montserrat')),
                            onPressed: () {
                              FileDownloader.downloadFile(
                                url: myPosts[index].toString(),
                                name: myPosts[index].toString(),
                                onDownloadCompleted: (String path) {
                                  debugPrint('IMAGE DOWNLOADED TO PATH: $path');
                                  Fluttertoast.showToast(msg: "File downloaded at $path",backgroundColor: primary);
                                },
                                onDownloadError: (String error) {
                                  debugPrint('DOWNLOAD ERROR: $error');
                                  Fluttertoast.showToast(msg: "Error while downloading file",backgroundColor:Colors.red);
                                },
                              );
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
                  onDoubleTap: () {
                    unsaveFashion(myPosts[index].saveId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Stack(
                      children: [
                        Container(
                          child: myPosts[index].images[0]["type"] ==
                              "video"
                              ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(
                                      myPosts[index]
                                          .thumbnail))),
                              // borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          )
                              : CachedNetworkImage(
                            imageUrl: myPosts[index].images[0]
                            ["image"],
                            height: 820,
                            width: 200,
                            fit: BoxFit.fill,
                            placeholder: (context, url) =>
                                Center(
                                  child: SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: SpinKitCircle(
                                      color: primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) =>
                                Container(
                                  height: MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.84,
                                  width: MediaQuery.of(context)
                                      .size
                                      .width,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: Image.network(
                                            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png")
                                            .image,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                            right: 10,
                            child: Padding(
                              padding:
                              const EdgeInsets.only(top: 8.0),
                              child: myPosts[index].images[0]
                              ["type"] ==
                                  "video"
                                  ? const Icon(
                                  Icons.video_camera_back)
                                  : const Icon(Icons.image),
                            ))
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )),
      ],
    );
  }
}
