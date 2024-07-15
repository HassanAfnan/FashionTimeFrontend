import 'dart:convert';
import 'dart:io';

import 'package:FashionTime/screens/pages/friend_fan.dart';
import 'package:FashionTime/screens/pages/friend_idol.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/screens/pages/edit_profile.dart';
import 'package:FashionTime/screens/pages/settings_pages/report_screen.dart';
import 'package:FashionTime/screens/pages/styles_screen.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../helpers/database_methods.dart';
import '../../models/post_model.dart';
import 'fans.dart';
import 'followers_screen.dart';
import 'likes_screen.dart';

class FriendProfileScreen extends StatefulWidget {
  final String id;
  final String username;
  const FriendProfileScreen({Key? key, required this.id, required this.username}) : super(key: key);

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> with SingleTickerProviderStateMixin {
  String id = "";
  String token = "";
  bool loading = false;
  Map<String,dynamic> data = {};
  bool requestLoader = false;
  bool requestLoader1 = false;
  bool isGetRequest = false;
  String requestID = "";
  String fanId = "";
  bool loading1 = false;
  bool loading2 = false;
  bool loading3 = false;
  bool blockStatus=false;
  List<PostModel> myPosts = [];
  List<PostModel> commentedPost = [];
  List<PostModel> likedPost = [];
  List<String> BadgeList = [];
  late List<int>rankingOrders=[];
   String lowestRankingOrderDocument="";
  List<String>mediaLink=[];
  List<PostModel> medalPostsModel = [];
  String name = "";
  String fcm='';
  String UserFcm="";

  late TabController tabController;

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
    fcm=preferences.getString("fcm_token")!;
    print("cached data with fcm is {$fcm}");
    getMyFriends(widget.id);
    ClickedUserData(widget.id);
    print("my id is ${widget.id}");
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    getCashedData();
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

  getMyFriends(id){
    setState(() {
      loading = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/user/api/allUsers/$id"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        print("Data ==> ${data.toString()}");
        setState(() {
          data = jsonDecode(value.body);
        });
        print("Friend data "+data.toString());
        print(jsonDecode(value.body).toString());
        commentedPost.clear();
        matchFriendReques(widget.id);
      });
    }catch(e){
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }
  ClickedUserData(id){
    setState(() {
      loading = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/user/api/allUsers/$id"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        print("Data ==> ${data.toString()}");
        setState(() {
          data = jsonDecode(value.body);
          UserFcm=data["fcmToken"];
        });
        print("Clicked user data"+data.toString());
        print("Clicked user fcm $UserFcm");
        print(jsonDecode(value.body).toString());
      });
    }catch(e){
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }
  matchFriendReques(id1){
    print("Match Friend id");
    try{
      https.get(
          Uri.parse("$serverUrl/followRequests/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        print(id);
        jsonDecode(value.body).forEach((request){
          // print("${request["from_user"].toString()} == ${id1} && ${request["to_user"]} == ${id}");
          if(request["from_user"].toString() == id1.toString() && request["to_user"].toString() == id.toString()){
            setState(() {
              loading = false;
              isGetRequest = true;
              requestID = request["id"].toString();
            });
            print(isGetRequest.toString());
            print(requestID.toString());
          }
          else if(request["from_user"].toString() == id.toString() && request["to_user"].toString() == id1.toString()){
            setState(() {
              loading = false;
            });
            requestID = request["id"].toString();
          }
          else{
            setState(() {
              loading = false;
            });
            print(isGetRequest.toString());
          }
        });
        setState(() {
          loading = false;
        });
        print(jsonDecode(value.body).toString());
        getMyPosts();
      });
    }catch(e){
      setState(() {
        loading = false;
      });
      debugPrint("Error --> $e");
    }
  }

  bool grid = true;
  bool profile = false;
  bool styles = false;

  getMyPosts(){
    setState(() {
      loading1 = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/fashionuser/savedFashion/${widget.id}/saved-posts/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        print(jsonDecode(value.body).toString());
        if(jsonDecode(value.body).length <= 0){
          setState(() {
            loading1 = false;
          });
          print("No data");
        }
        else {
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
                  myPosts.add(PostModel(
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
                      value["myLike"] == null ? "like" : value["myLike"].toString(),
                      value["eventData"],
                     {}
                  ));
                });
              });
            }
            else {
              setState(() {
                myPosts.add(PostModel(
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
                    value["myLike"] == null ? "like" : value["myLike"].toString(),
                  value["eventData"],
                  {}
                ));
              });
            }
          });
        }
      });
      getCommentedPosts();
      getBadges();
      getBadgesHistory();
     // getPostsWithMedal();
    }catch(e){
      setState(() {
        loading1 = false;
      });
      print("Error --> $e");
    }
  }
  getCommentedPosts(){
    setState(() {
      loading2 = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/fashionuser/commentedFashion/${widget.id}/commented-posts/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        print(jsonDecode(value.body));
        setState(() {
          loading2 = false;
        });
        jsonDecode(value.body).forEach((value){
          if(value["upload"]["media"][0]["type"] == "video"){
            VideoThumbnail.thumbnailFile(
              video: value["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
              quality: 25,
            ).then((value1){
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
                    value["created"],value1!,
                    value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"].toString(),
                  value["eventData"],
                  {}
                ));
              });
            });
          }
          else{
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
                  value["created"],"",
                  value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"].toString(),
                value["eventData"],
                {}
              ));
            });
          }
        });
      });
      getLikedPosts();
    }catch(e){
      setState(() {
        loading2 = false;
      });
      print("Error --> $e");
    }
  }
  getLikedPosts(){
    setState(() {
      loading3 = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/fashionuser/likedFashion/${widget.id}/liked-posts/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        print(jsonDecode(value.body));
        setState(() {
          loading3 = false;
        });
        jsonDecode(value.body).forEach((value){
          if(value["upload"]["media"][0]["type"] == "video"){
            VideoThumbnail.thumbnailFile(
              video: value["upload"]["media"][0]["video"],
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
              quality: 25,
            ).then((value1){
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
                    value["created"],value1!,
                    value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"].toString(),
                    value["eventData"],
                  {}
                ));
              });
            });
          }
          else{
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
                  value["created"],"",
                  value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"].toString(),
                value["eventData"],
                {}
              ));
            });
          }
        });
      });
    }catch(e){
      setState(() {
        loading3 = false;
      });
      print("Error --> $e");
    }
  }

  sendRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_send_request/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      print(value.body.toString());
      getMyFriends(userid);
      sendNotification(widget.username!,"You have received a friend request",UserFcm);
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      print(value);
    });
  }
  acceptRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_accept_request/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      print(value.body.toString());
      getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      print(value);
    });
  }
  rejectRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_reject_request/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      print(value.body.toString());
      getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      print(value);
    });
  }
  unfriendRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_remove/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      print("Unfriend response ==> ${value.body.toString()}");
      getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      print(value);
    });
  }
  cancelRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_request_remove/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      print("Request remove response ==> ${value.body.toString()}");
      getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      print(value);
    });
  }

  addFan(from,to){
    setState(() {
      requestLoader1 = true;
    });
    https.post(
      Uri.parse("$serverUrl/fansRequests/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "from_user": from,
        "to_user": to
      }),
    ).then((value){
      setState(() {
        requestLoader1 = false;
      });
      print(value.body.toString());
      getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader1 = false;
      });
      print(value);
    });
  }
  removeFan(fanId){
    setState(() {
      requestLoader1 = true;
    });
    https.delete(
      Uri.parse("$serverUrl/fansfansRequests/$fanId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).then((value){
      setState(() {
        requestLoader1 = false;
      });
      print(value.body.toString());
      getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader1 = false;
      });
      print(value);
    });
  }

  blockUser(user,user1,user2){
    https.post(
      Uri.parse("$serverUrl/user/api/BlockUser/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "user": id,
        "blocked_by": user
      }),
    ).then((value){
      print(value.body.toString());
      DatabaseMethods().blockChat(user1, user2);
      Navigator.pop(context);
      setState(() {
        blockStatus=true;
      });
     // Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerScreen(),));
    }).catchError((e){
      print(e);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }
  getBadges()async{
    final response = await https.get(Uri.parse('https://fashion-time-backend-1dc9be6bb298.herokuapp.com/user/api/Badge/'));

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse = (json.decode(response.body) as List).cast<Map<String, dynamic>>();

      BadgeList = jsonResponse.map((entry) => entry['document']as String).toList();

      // Print the result
      print("all badges$BadgeList");
    } else {
      // Handle the error if the request was not successful
      print('Error: ${response.statusCode}');
    }
  }
  getBadgesHistory()async{
    final response=await https.get(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        Uri.parse("$serverUrl/user/api/badgehistory/"));
    if(response.statusCode==200){
      List<Map<String,dynamic>> jsonResponse=(json.decode(response.body)as List).cast<Map<String,dynamic>>();
      rankingOrders = jsonResponse.map<int>((item) => item['badge']['ranking_order'] as int).toList();
      List<Map<String, dynamic>> rankingAndDocuments = jsonResponse.map<Map<String, dynamic>>((item) {
        return {
          'ranking_order': item['badge']['ranking_order'] as int,
          'document': item['badge']['document'] as String,
        };
      }).toList();

      // Find the item with the lowest ranking order
      Map<String, dynamic>? lowestRankingOrderItem = rankingAndDocuments.reduce((min, current) =>
      min['ranking_order'] < current['ranking_order'] ? min : current);

      if (lowestRankingOrderItem != null) {
        // Access the document field associated with the lowest ranking order
        lowestRankingOrderDocument = lowestRankingOrderItem['document'] as String;

        print('Lowest ranking order document: $lowestRankingOrderDocument');
      } else {
        print('No items in the list');
      }
      print('Ranking Orders: $rankingOrders');
    }
    else{
      print('Error in badge history: ${response.statusCode}');
    }
  }
  // getPostsWithMedal() {
  //   setState(() {
  //     loading = true;
  //   });
  //   try {
  //     https.get(Uri.parse("$serverUrl/fashionUpload/top-trending/"),
  //         headers: {
  //           "Content-Type": "application/json",
  //           "Authorization": "Bearer $token"
  //         }).then((value) {
  //       mediaLink.clear();
  //       print("Timer ==> " + jsonDecode(value.body).toString());
  //       setState(() {
  //         //myDuration = Duration(seconds: int.parse(jsonDecode(value.body)["result"]["time_remaining"].));
  //         loading = false;
  //       });
  //       jsonDecode(value.body)["result"].forEach((value) {
  //         if(value['user']['id'].toString()==id.toString()){
  //           if (value["upload"]["media"][0]["type"] == "video") {
  //             VideoThumbnail.thumbnailFile(
  //               video: value["upload"]["media"][0]["video"],
  //               imageFormat: ImageFormat.JPEG,
  //               maxWidth:
  //               128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
  //               quality: 25,
  //             ).then((value1) {
  //               setState(() {
  //                 medalPostsModel.add(PostModel(
  //                     value["id"].toString(),
  //                     value["description"],
  //                     value["upload"]["media"],
  //                     value["user"]["username"],
  //                     value["user"]["pic"] == null
  //                         ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
  //                         : value["user"]["pic"],
  //                     false,
  //                     value["likesCount"].toString(),
  //                     value["disLikesCount"].toString(),
  //                     value["commentsCount"].toString(),
  //                     value["created"],
  //                     value1!,
  //                     value["user"]["id"].toString(),
  //                     value["myLike"] == null
  //                         ? "like"
  //                         : value["myLike"].toString()));
  //
  //               });
  //               mediaLink.add(value['upload']['media'][0]['video'].toString());
  //               print("imageslinks is ${mediaLink.toString()}");
  //               print("current user data is ${medalPostsModel.toString()}");
  //             });
  //           } else {
  //             setState(() {
  //               medalPostsModel.add(PostModel(
  //                   value["id"].toString(),
  //                   value["description"],
  //                   value["upload"]["media"],
  //                   value["user"]["username"],
  //                   value["user"]["pic"] == null
  //                       ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
  //                       : value["user"]["pic"],
  //                   false,
  //                   value["likesCount"].toString(),
  //                   value["disLikesCount"].toString(),
  //                   value["commentsCount"].toString(),
  //                   value["created"],
  //                   "",
  //                   value["user"]["id"].toString(),
  //                   value["myLike"] == null
  //                       ? "like"
  //                       : value["myLike"].toString()));
  //             });
  //             mediaLink.add(value['upload']['media'][0]['image'].toString());
  //             print("imageslinks is ${mediaLink.toString()}");
  //             print("current user data is ${medalPostsModel.toString()}");
  //           }
  //         }});
  //     });
  //   } catch (e) {
  //     setState(() {
  //       loading = false;
  //     });
  //     print("Error --> $e");
  //   }
  // }
  sendNotification(String name,String message,String token) async {
    print("Entered");
    print("1- "+name);
    //print("2- "+widget.person_name!.toString());
    var body = jsonEncode(<String, dynamic>{
      "to": token,
      "notification": {
        "title": name,
        "body": message,
        "mutable_content": true,
        "sound": "Tri-tone"
      },
      "data": {
        "url": "https://www.w3schools.com/w3images/avatar2.png",
        "dl": "<deeplink action on tap of notification>"
      }
    });

    https.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAIgQSOH0:APA91bGZExBIg_hZuaqTYeCMB2ulE_iiRXY8kTYH6MqEpimm6WIshqH6GAhoor1MGnGl2dDbvJqWNRzEGBm_17Kd6-vS-BHZD31HZu_EFCKs5cOQh8EJzpKP2ayJicozOU4csM528EBy',
      },
      body: body,
    ).then((value1){
      print("notification data${value1.body.toString()}");
    });
  }
  unBlockUser(user,user1,user2){
    setState(() {
      loading1 = true;
    });

    https.delete(
        Uri.parse("${serverUrl}/user/api/BlockUser/${user}/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token}"
        }
    ).then((value){
      print(value.body.toString());
      setState(() {
        loading1 = false;
        blockStatus=false;
      });
      DatabaseMethods().unBlockChat(user1, user2);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: primary,
          title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
          content: const Text("User unblocked successfully.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
          actions: [
            TextButton(
              child: const Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
              onPressed:  () {

                setState(() {
                  Navigator.pop(context);
                   Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      );
    }).catchError((){
      setState(() {
        loading1 = false;
      });
      Navigator.pop(context);
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
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
                  ])
          ),),
        title: Text(widget.username,style: const TextStyle(fontFamily: 'Montserrat'),),
        actions: [
          PopupMenuButton(
              icon:const Icon(Icons.more_horiz),
              onSelected: (value) {
                if (value == 0 && blockStatus==false) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: primary,
                      title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
                      content: const Text("Do you want to block this user?",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
                      actions: [
                        TextButton(
                          child: const Text("Yes",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                          onPressed:  () {
                            //print(data["id"].toString());
                            blockUser(data["id"].toString(),name,data["name"]);
                          },
                        ),
                        TextButton(
                          child: const Text("No",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                          onPressed:  () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }
                if (value == 0 && blockStatus==true) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: primary,
                      title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
                      content: const Text("Do you want to unblock this user?",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
                      actions: [
                        TextButton(
                          child: const Text("Yes",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                          onPressed:  () {
                            //print(data["id"].toString());
                           // blockUser(data["id"].toString(),name,data["name"]);
                            unBlockUser(data["id"].toString(),name,data["name"]);
                          },
                        ),
                        TextButton(
                          child: const Text("No",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                          onPressed:  () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }
                if (value == 1){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen(reportedID: id)));
                }
                // setState(() {
                // });
                // print(value);
                //Navigator.pushNamed(context, value.toString());
              }, itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children:  [
                    const Icon(Icons.block),
                    const SizedBox(width: 10,),
                    blockStatus?const Text("Unblock",style: TextStyle(fontFamily: 'Montserrat'),):
                    const Text("Block",style: TextStyle(fontFamily: 'Montserrat'),),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.report),
                    SizedBox(width: 10,),
                    Text("Report",style: TextStyle(fontFamily: 'Montserrat'),),
                  ],
                ),
              ),
            ];
          })
        ],
      ),
      body: loading == true ? SpinKitCircle(color: primary,size: 50,) : SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.5,
          child: Column(
            children: [
              const SizedBox(height: 20,),
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
                            SizedBox(height: MediaQuery.of(context).size.height*0.008,),
                            Padding(
                                padding:const EdgeInsets.only(right: 20),
                                child: Text((data['likesCount']['likes_week_fashion'].toString()),
                                ))
                          ],
                        ),
                        CircleAvatar(
                          radius: 100,
                          child: Container(
                            decoration: data["badge"] == null ? const BoxDecoration() : BoxDecoration(
                                border: Border.all(
                                    width: 5,
                                    color:(
                                        // data["badge"]["id"] == 10
                                        //     || data["badge"]["id"] == 11
                                        // data["badge"]["id"] == 12
                                            data["badge"]["id"] == 13
                                            || data["badge"]["id"] == 14
                                            || data["badge"]["id"] == 15
                                            || data["badge"]["id"] == 16
                                            || data["badge"]["id"] == 17
                                            || data["badge"]["id"] == 18
                                            || data["badge"]["id"] == 19
                                        //  rankingOrders.contains(1)==true
                                    ) ?primary :
                                    data["badge"]["id"] == 12?Colors.orange:
                                    data['badge']['id']==10? gold:
                                    data['badge']['id']==11?silver: Colors.transparent),
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: const BorderRadius.all(Radius.circular(120))
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                              child: CachedNetworkImage(
                                imageUrl: data["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                imageBuilder: (context, imageProvider) => Container(
                                  height:MediaQuery.of(context).size.height * 0.7,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => SpinKitCircle(color: primary,size: 60,),
                                errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: MediaQuery.of(context).size.width * 0.9,height: MediaQuery.of(context).size.height * 0.9,)
                                ),
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
                            SizedBox(height: MediaQuery.of(context).size.height*0.008,),
                            Padding(
                              padding:const EdgeInsets.only(left: 21),
                              child: Text(data['likesCount']['likes_non_week_fashion'].toString()),
                            )
                          ],
                        ),
                      ],
                    ),

                    data["badge"] == null ? const SizedBox() : Positioned(
                        bottom: 1,
                        right: 80,
                        child: GestureDetector(
                            onTap: (){
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen()));
                            },
                            child:
                            // Image.network(data["badge"]["document"],height: 80,width: 80,errorBuilder: (context, error, stackTrace) {
                            //   return SizedBox();
                            // }
                            // )
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                              child: CachedNetworkImage(
                                imageUrl: data['badge']['document'],
                                imageBuilder: (context, imageProvider) => Container(
                                  height:80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(120)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => SpinKitCircle(color: primary,size: 20,),
                                errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    child: Image.network(lowestRankingOrderDocument,width: 80,height: 80,fit: BoxFit.contain,)
                                ),
                              ),
                            )
                        )),

                  ],
                ),
              ),

              const SizedBox(height: 20,),
              WidgetAnimator(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // GestureDetector(
                    //   onTap: (){
                    //     //Navigator.push(context, MaterialPageRoute(builder: (context) => LikesScreen()));
                    //   },
                    //   child: Column(
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Text(data["likesCount"].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                    //         ],
                    //       ),
                    //       Row(
                    //         children: [
                    //           Text("Likes",style: TextStyle(
                    //               color: primary,
                    //               fontFamily: 'Montserrat'
                    //           ),)
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => StylesScreen()));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(data["stylesCount"].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Styles",style: TextStyle(
                                  color: primary,
                                  fontFamily: 'Montserrat'
                              ),)
                            ],
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsFans(friendId: widget.id)));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(data["fansCount"].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Fans",style: TextStyle(
                                  color: primary,
                                  fontFamily: 'Montserrat'
                              ),)
                            ],
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => StylesScreen()));
                         Navigator.push(context, MaterialPageRoute(builder: (context) =>  FriendsIdols(friendId: widget.id.toString())));
                      },
                      child: Column(
                        children: [
                          Row(
                            children:  [
                              Text(data["idolsCount"].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Idols",style: TextStyle(
                                  color: primary,
                                  fontFamily: 'Montserrat'
                              ),)
                            ],
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerScreen()));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(data["friendsCount"].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Friends",style: TextStyle(
                                  color: primary,
                                  fontFamily: 'Montserrat'
                              ),)
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WidgetAnimator(SizedBox(
                    height: 80,
                    child: WidgetAnimator(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: data["isFollow"] == true ? (){
                                print("unfried request");
                                print("isGranted ==> $isGetRequest");
                                print("Follow Status ==> ${data["follow_status"]}");
                                unfriendRequest(widget.id);
                              }:(){
                                if(isGetRequest == true){
                                  print("open popup");
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext bc){
                                        return Container(
                                          child: new Wrap(
                                            children: <Widget>[
                                              new ListTile(
                                                  leading: new Icon(Icons.check,color: Colors.green,),
                                                  title: new Text('Accept',style: const TextStyle(fontFamily: 'Montserrat',color:Colors.green),),
                                                  onTap: (){
                                                    Navigator.pop(context);
                                                    acceptRequest(requestID);
                                                  }
                                              ),
                                              new ListTile(
                                                leading: new Icon(Icons.close,color: Colors.red,),
                                                title: new Text('Reject',style: const TextStyle(fontFamily: 'Montserrat',color: Colors.red),),
                                                onTap: (){
                                                  Navigator.pop(context);
                                                  rejectRequest(requestID);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  );
                                }
                                else if(data["follow_status"] == null && isGetRequest == false){
                                  print("follow status null request");
                                  commentedPost.clear();
                                  sendRequest(widget.id);

                                }
                                else if(isGetRequest == false){
                                  print("isGetRequest request");
                                  setState(() {
                                    requestLoader = false;
                                  });
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext bc){
                                        return Container(
                                          child: new Wrap(
                                            children: <Widget>[
                                              new ListTile(
                                                leading: new Icon(Icons.close,color: Colors.red,),
                                                title: new Text('Cancel Request',style: const TextStyle(fontFamily: 'Montserrat',color: Colors.red),),
                                                onTap: (){
                                                  print("Request Id ==> $requestID");
                                                  Navigator.pop(context);
                                                  cancelRequest(widget.id);
                                                  //rejectRequest(requestID);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  );
                                  //sendRequest(widget.id);
                                }
                                else {
                                  print("send request");
                                }
                              },
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15))
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.topRight,
                                          stops: const [0.0, 0.99],
                                          tileMode: TileMode.clamp,
                                          colors: data["isFollow"] == true ||data["follow_status"] != null ? [
                                            Colors.grey,
                                            Colors.grey
                                          ] : <Color>[
                                            secondary,
                                            primary,
                                          ]),
                                      borderRadius: const BorderRadius.all(Radius.circular(12))
                                  ),
                                  child:requestLoader == true ? const SpinKitCircle(color: ascent,size: 30,) : (data["isFollow"] == true ? const Text('Unfriend',style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat'
                                  ),) : Text(data["follow_status"] == null ? 'Add Friend':isGetRequest == false?"Pending":'Acc./Rej.',style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat'
                                  ),)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            GestureDetector(
                              onTap: () {
                                if(data["isFan"] == false){
                                  commentedPost.clear();
                                  addFan(id,widget.id);

                                }else if(data["isFan"] == true) {
                                  commentedPost.clear();
                                  removeFan(widget.id);
                                }
                                //Navigator.push(context,MaterialPageRoute(builder: (context) => EditProfile()));
                              },
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15))
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.topRight,
                                          stops: const [0.0, 0.99],
                                          tileMode: TileMode.clamp,
                                          colors: data["isFan"] == true ? [
                                            Colors.grey,
                                            Colors.grey
                                          ] : <Color>[
                                            secondary,
                                            primary,
                                          ]),
                                      borderRadius: const BorderRadius.all(Radius.circular(12))
                                  ),
                                  child: requestLoader1 == true ? const SpinKitCircle(color: ascent, size: 20,) : Text(data["isFan"] == true ? 'Unfan' :'Fan',style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat'
                                  ),),
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 10,),
              WidgetAnimator(
                  Padding(
                    padding: const EdgeInsets.only(left:30.0,right:30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data["name"].toString(), style: TextStyle(
                            color:primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat'
                        ),),
                        // GestureDetector(
                        //     onTap: (){
                        //       showDialog(
                        //         context: context,
                        //         builder: (context) => AlertDialog(
                        //           backgroundColor: primary,
                        //           title: Text("Fashion Time",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
                        //           content: Text("Do you want to block this user.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
                        //           actions: [
                        //             TextButton(
                        //               child: Text("Yes",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                        //               onPressed:  () {
                        //                 print(data["id"].toString());
                        //                 blockUser(data["id"].toString());
                        //               },
                        //             ),
                        //             TextButton(
                        //               child: Text("No",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                        //               onPressed:  () {
                        //                 setState(() {
                        //                   Navigator.pop(context);
                        //                 });
                        //               },
                        //             ),
                        //           ],
                        //         ),
                        //       );
                        //     },
                        //     child: Icon(Icons.block,color: Colors.red,)),
                      ],
                    ),
                  )
              ),
              const SizedBox(height: 5,),
              // WidgetAnimator(
              //     Row(
              //       children: [
              //         SizedBox(width: 25),
              //         Text("@${data["username"].toString()}", style: TextStyle(
              //             color: primary,
              //             fontWeight: FontWeight.bold,
              //             fontFamily: 'Montserrat'
              //         ),)
              //       ],
              //     )
              // ),
              const SizedBox(height: 5,),
              data["description"] == null ||  data["description"] == "" ? const SizedBox() : WidgetAnimator(
                  Row(
                    children: [
                      const SizedBox(width: 25),
                      Container(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 300.0,
                            maxWidth: 300.0,
                            minHeight: 10.0,
                            maxHeight: 50.0,
                          ),
                          child: AutoSizeText(
                            data["description"] ?? "",
                            style: const TextStyle(fontSize: 16.0,fontFamily: 'Montserrat'),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              const SizedBox(height: 5,),
              SizedBox(
                height: 50,
                child: TabBar(
                  controller: tabController,
                  tabs:  [
                    //Tab(icon: Icon(Icons.favorite, color: _getTabIconColor(context))),
                    Tab(icon: Icon(Icons.grid_on, color: _getTabIconColor(context))),
                    Tab(
                      icon: ColorFiltered(
                        colorFilter: _getImageColorFilter(context),
                        child: Image.asset('assets/bagde.png', height: 28),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: GridTab(tabController: tabController, loading1: loading1, myPosts: myPosts, loading2: loading2, commentedPost: commentedPost, loading3: loading3, likedPost: likedPost,badges: mediaLink,)),
            ],
          ),
        ),
      ),
    );
  }
}

class GridTab extends StatelessWidget {
  const GridTab({
    super.key,
    required this.tabController,
    required this.loading1,
    required this.myPosts,
    required this.loading2,
    required this.commentedPost,
    required this.loading3,
    required this.likedPost,
    required this.badges
  });

  final TabController tabController;
  final bool loading1;
  final List<PostModel> myPosts;
  final bool loading2;
  final List<PostModel> commentedPost;
  final bool loading3;
  final List<PostModel> likedPost;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    Color _getTabIconColor(BuildContext context) {

      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;


      return isDarkMode ? Colors.white : primary;
    }
    return TabBarView(
      controller: tabController,
      children: <Widget>[
        // loading1 == true ? SpinKitCircle(color: primary,size: 50,) : (myPosts.length <= 0 ? Center(child: Text("No Posts")) :
        // GridView.builder(
        //   physics: NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: myPosts.length,
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 3,
        //     //mainAxisSpacing: 10
        //   ),
        //   itemBuilder: (BuildContext context, int index){
        //     return WidgetAnimator(
        //       GestureDetector(
        //         onTap: (){
        //           Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
        //             userid:myPosts[index].userid,
        //             image: myPosts[index].images,
        //             description:  myPosts[index].description,
        //             style: "Fashion Style 2",
        //             createdBy: myPosts[index].userName,
        //             profile: myPosts[index].userPic,
        //             likes: myPosts[index].likeCount,
        //             dislikes: myPosts[index].dislikeCount,
        //             mylike: myPosts[index].mylike,
        //           )));
        //         },
        //         child: Padding(
        //           padding: const EdgeInsets.all(1.0),
        //           child: Stack(
        //             children: [
        //               Container(
        //                 child: myPosts[index].images[0]["type"] == "video"? Container(
        //                   decoration: BoxDecoration(
        //                     image: DecorationImage(
        //                         fit: BoxFit.cover,
        //                         image: FileImage(File(myPosts[index].thumbnail))
        //                     ),
        //                     // borderRadius: BorderRadius.all(Radius.circular(10)),
        //                   ),
        //                 ) :CachedNetworkImage(
        //                   imageUrl: myPosts[index].images[0]["image"],
        //                   fit: BoxFit.fill,
        //                   height: 820,
        //                   width: 200,
        //                   placeholder: (context, url) => Center(
        //                     child: SizedBox(
        //                       width: 20.0,
        //                       height: 20.0,
        //                       child: SpinKitCircle(color: primary,size: 20,),
        //                     ),
        //                   ),
        //                   errorWidget: (context, url, error) => Container(
        //                     height:MediaQuery.of(context).size.height * 0.84,
        //                     width: MediaQuery.of(context).size.width,
        //                     decoration: BoxDecoration(
        //                       image: DecorationImage(
        //                           image: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image,
        //                           fit: BoxFit.cover
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               Positioned(
        //                   right:10,
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(top:8.0),
        //                     child:myPosts[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
        //                   ))
        //             ],
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // )
        // ),
        loading2 == true ? SpinKitCircle(color: primary,size: 50,) : (commentedPost.length <= 0 ? Column(
          children: const [
            SizedBox(height: 40,),
            Text("No Posts",textAlign: TextAlign.center,),
          ],
        ) : GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: commentedPost.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            // mainAxisSpacing: 10
          ),
          itemBuilder: (BuildContext context, int index){
            return WidgetAnimator(
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
                    userid:commentedPost[index].userid,
                    image: commentedPost[index].images,
                    description:  commentedPost[index].description,
                    style: "Fashion Style 2",
                    createdBy: commentedPost[index].userName,
                    profile: commentedPost[index].userPic,
                    likes: commentedPost[index].likeCount,
                    dislikes: commentedPost[index].dislikeCount,
                    mylike: commentedPost[index].mylike,
                  )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Stack(
                    children: [
                      Container(
                        child: commentedPost[index].images[0]["type"] == "video"? Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(commentedPost[index].thumbnail))
                            ),
                            //borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ) :CachedNetworkImage(
                          imageUrl: commentedPost[index].images[0]["image"],
                          fit: BoxFit.fill,
                          height: 820,
                          width: 200,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: SpinKitCircle(color: primary,size: 20,),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height:MediaQuery.of(context).size.height * 0.84,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image,
                                  fit: BoxFit.cover
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          right:10,
                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child:commentedPost[index].images[0]["type"] == "video" ?const Icon(Icons.video_camera_back) : const Icon(Icons.image),
                          ))
                    ],
                  ),
                ),
              ),
            );
          },
        )),
        loading3 == true ? SpinKitCircle(color: primary,size: 50,) : (badges.length <= 0 ? Column(
          children: const [
            SizedBox(height: 40,),
            Text("No Posts"),
          ],
        ) :
        SingleChildScrollView(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              // mainAxisSpacing: 10
            ),
            itemBuilder: (BuildContext context, int index){
              return WidgetAnimator(
                GestureDetector(
                  // onTap: (){
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
                  //     userid:likedPost[index].userid,
                  //     image: likedPost[index].images,
                  //     description:  likedPost[index].description,
                  //     style: "Fashion Style 2",
                  //     createdBy: likedPost[index].userName,
                  //     profile: likedPost[index].userPic,
                  //     likes: likedPost[index].likeCount,
                  //     dislikes: likedPost[index].dislikeCount,
                  //     mylike: likedPost[index].mylike,
                  //   )));
                  // },
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Stack(
                      children: [
                        Container(

                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: badges.isNotEmpty? Container(
                            height: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(badges[index]),


                              ),
                              //borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ) :CachedNetworkImage(
                            imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',
                            fit: BoxFit.cover,
                            height: 820,
                            width: 200,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: SpinKitCircle(color: primary,size: 20,),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height:MediaQuery.of(context).size.height * 0.84,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image,
                                    fit: BoxFit.cover
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            right:10,
                            child: Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child:Image.asset('assets/bagde.png',height: 28,color:_getTabIconColor(context) ),
                            ))
                        // Positioned(
                        //     right:10,
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(top:8.0),
                        //       child:likedPost[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
                        //     ))
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
            // GridView.builder(
            //   physics: NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: likedPost.length,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 3,
            //     // mainAxisSpacing: 10
            //   ),
            //   itemBuilder: (BuildContext context, int index){
            //     return WidgetAnimator(
            //       GestureDetector(
            //         onTap: (){
            //           Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
            //             userid:likedPost[index].userid,
            //             image: likedPost[index].images,
            //             description:  likedPost[index].description,
            //             style: "Fashion Style 2",
            //             createdBy: likedPost[index].userName,
            //             profile: likedPost[index].userPic,
            //             likes: likedPost[index].likeCount,
            //             dislikes: likedPost[index].dislikeCount,
            //             mylike: likedPost[index].mylike,
            //           )));
            //         },
            //         child: Padding(
            //           padding: const EdgeInsets.all(1.0),
            //           child: Stack(
            //             children: [
            //               Container(
            //                 decoration: BoxDecoration(
            //                   // borderRadius: BorderRadius.all(Radius.circular(10)),
            //                 ),
            //                 child: likedPost[index].images[0]["type"] == "video"? Container(
            //                   decoration: BoxDecoration(
            //                     image: DecorationImage(
            //                         fit: BoxFit.cover,
            //                         image: FileImage(File(likedPost[index].thumbnail))
            //                     ),
            //                     //borderRadius: BorderRadius.all(Radius.circular(10)),
            //                   ),
            //                 ) :ClipRRect(
            //                   // borderRadius: BorderRadius.circular(10),
            //                   child: CachedNetworkImage(
            //                     imageUrl: likedPost[index].images[0]["image"],
            //                     fit: BoxFit.fill,
            //                     height: 820,
            //                     width: 200,
            //                     placeholder: (context, url) => Center(
            //                       child: SizedBox(
            //                         width: 20.0,
            //                         height: 20.0,
            //                         child: SpinKitCircle(color: primary,size: 20,),
            //                       ),
            //                     ),
            //                     errorWidget: (context, url, error) => Container(
            //                       height:MediaQuery.of(context).size.height * 0.84,
            //                       width: MediaQuery.of(context).size.width,
            //                       decoration: BoxDecoration(
            //                         image: DecorationImage(
            //                             image: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png").image,
            //                             fit: BoxFit.cover
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               // Positioned(
            //               //     right:10,
            //               //     child: Padding(
            //               //       padding: const EdgeInsets.only(top:8.0),
            //               //       child:likedPost[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
            //               //     ))
            //             ],
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // )
        ),
      ],
    );
  }
}