import 'dart:convert';
import 'dart:io';

import 'package:FashionTime/screens/pages/my_posts.dart';
import 'package:FashionTime/screens/pages/my_reels/my_reel_interface.dart';
import 'package:FashionTime/screens/pages/reelsInterface.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/models/post_model.dart';
import 'package:FashionTime/screens/pages/edit_profile.dart';
import 'package:FashionTime/screens/pages/followers_screen.dart';
import 'package:FashionTime/screens/pages/likes_screen.dart';
import 'package:FashionTime/screens/pages/result_screen.dart';
import 'package:FashionTime/screens/pages/styles_screen.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/saved_post_model.dart';
import 'fans.dart';
import 'other_like.dart';

class ProfileScreen extends StatefulWidget {
  final bool type;
  const ProfileScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool grid = true;
  bool profile = false;
  bool styles = false;
  String id = "";
  String token = "";
  bool loading = false;
  bool loading1 = false;
  bool loading2 = false;
  bool loading3 = false;
  Map<String,dynamic> data = {};
  List<SavedPostModel> myPosts = [];
  List<PostModel> commentedPost = [];
  List<PostModel> likedPost = [];
  late List<String> BadgeList = [];
  late List<int>rankingOrders=[];
  List<PostModel> medalPostsModel = [];
  List<String>medalsPosts=[];
  late String lowestRankingOrderDocument="";
  List<String>mediaLink=[];
  int index = 0;

  late TabController tabController;

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(preferences.getString("fcm_token"));
    print("user id is----->>>${preferences.getString("id")}");
    getProfile();
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

  getProfile(){
    // myPosts.clear();
    // commentedPost.clear();
    // likedPost.clear();
    https.get(
        Uri.parse("${serverUrl}/user/api/profile/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
       print("Profile data ==> ${value.body.toString()}");
       setState(() {
         data = json.decode(value.body);
         myPosts.clear();
       });
    });
    getMyPosts();
  }
  unSaveFashion(fashionSaveID){
    String url="$serverUrl/fashionSaved/$fashionSaveID/";

      showDialog(context: context, builder: (context) {
        return  AlertDialog(
          backgroundColor: primary,
          content: const Text("Unsave Fashion?",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold)),actions: [
          IconButton(onPressed: () {
            try{
              https.delete(Uri.parse(url),headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token"
              });
              Navigator.pop(context);
            }
            catch(e){
              debugPrint("error received while unsaving fashion ==========>${e.toString()}");
            }
          }, icon: const Text("Yes",style: TextStyle(color: ascent,fontFamily: 'Montserrat'))),
          IconButton(onPressed: () {
            Navigator.pop(context);
          }, icon: const Text("No",style: TextStyle(color: ascent,fontFamily: 'Montserrat')))
        ],);
      },);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    getCashedData();
  }

  getMyPosts(){
    setState(() {
      loading1 = true;
    });
    try{
      https.get(
          Uri.parse("${serverUrl}/fashionSaved/my-saved-fashions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }
      ).then((value){
        print("Saved posts => "+jsonDecode(value.body).toString());
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
                  myPosts.add(SavedPostModel(
                      value["id"].toString(),
                      value["description"],
                      value["upload"]["media"],
                      value["user"]["name"],
                      value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w": value["user"]["pic"],
                      false,
                      value["likesCount"].toString(),
                      value["disLikesCount"].toString(),
                      value["commentsCount"].toString(),
                      value["created"],
                      value1!,
                    value["user"]["id"].toString(),
                      value["myLike"] == null ? "like" : value["myLike"].toString(),
                    value['mySaved']
                  ));
                  debugPrint("fashion save id is${value['mySaved']}");
                });
              });
            }
            else {
              setState(() {
                myPosts.add(SavedPostModel(
                    value["id"].toString(),
                    value["description"],
                    value["upload"]["media"],
                    value["user"]["name"],
                    value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w": value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],
                    "",
                  value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"].toString(),
                    value['mySaved']
                ));
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
    }catch(e){
      setState(() {
        loading1 = false;
      });
      print("Error --> ${e}");
    }
  }
  getPostsWithMedal() {
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("${serverUrl}/fashionUpload/top-trending/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }).then((value) {
            mediaLink.clear();
        print("Timer ==> " + jsonDecode(value.body).toString());
        setState(() {
          //myDuration = Duration(seconds: int.parse(jsonDecode(value.body)["result"]["time_remaining"].));
          loading = false;
        });
        jsonDecode(value.body)["result"].forEach((value) {
          if(value['user']['id'].toString()==id.toString()){
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
            mediaLink.add(value['upload']['media'][0]['image'].toString());
            print("imageslinks is ${mediaLink.toString()}");
            print("current user data is ${medalPostsModel.toString()}");
          }
        }
        else{
          print("id mismatch");
          }});
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
  }
  getCommentedPosts(){
    setState(() {
      loading2 = true;
    });
    try{
      https.get(
          Uri.parse("${serverUrl}/fashionComments/my-commented-fashions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }
      ).then((value){
        print("Commented post ==> "+jsonDecode(value.body).length.toString());
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
                    value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w":value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],value1!,
                  value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"].toString()
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
                  value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w":value["user"]["pic"],
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],"",
                value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"].toString()
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
      print("Error --> ${e}");
    }
  }
  getLikedPosts(){
    setState(() {
      loading3 = true;
    });
    try{
      https.get(
          Uri.parse("${serverUrl}/fashionLikes/my-liked-fashions/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
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
                    value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w": value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],value1!,
                  value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"].toString()
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
                  value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w": value["user"]["pic"],
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],"",
                value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"].toString()
              ));
            });
          }
        });
      });
    }catch(e){
      setState(() {
        loading3 = false;
      });
      print("Error --> ${e}");
    }
  }
  getBadges()async{
    final response = await https.get(
        Uri.parse('${serverUrl}/user/api/Badge/'));

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
          "Authorization": "Bearer ${token}"
        },
        Uri.parse("${serverUrl}/user/api/badgehistory/"));
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: widget.type == true ? AppBar(
        centerTitle: true,
        backgroundColor: primary,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        title: const Text("Profile",style: TextStyle(fontFamily: 'Montserrat'),),
        actions: [
          //IconButton(onPressed: (){}, icon: Icon(Icons.settings))
        ],
      ) : null,
      body: data.keys.length <= 0 ? SpinKitCircle(size: 50,color: primary,) :SingleChildScrollView(
        child: Container(
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

                        data['badge']==null?CircleAvatar(
                          radius: 100,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 5,
                                    color: Colors.transparent),
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: const BorderRadius.all(Radius.circular(120))
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                              child: CachedNetworkImage(
                                imageUrl: data["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w": data["pic"],
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
                        ):
                        CircleAvatar(
                          radius: 100,
                          child: Container(
                            decoration: BoxDecoration(
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
                                imageUrl: data["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w": data["pic"],
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
                        // Text("hello"),
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
                            // Image.network(data["badge"]["document"],height: 80,width: 80,
                            //   errorBuilder: (context, error, stackTrace) {
                            //     return SizedBox();
                            //   }
                            //   ,)
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                              child: CachedNetworkImage(
                               imageUrl: data["badge"]["document"],
                                //imageUrl: lowestRankingOrderDocument,
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
                                    child: Image.network(data["badge"]["document"],width: 80,height: 80,fit: BoxFit.contain,)

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
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OtherLikesScreen()));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              data['likesCount']==null?const Text('0',style: TextStyle(fontFamily: 'Montserrat')):
                              Text(data["likesCount"].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Likes",style: TextStyle(
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPostScreen()));
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReelsInterfaceScreen()));
                      },
                      child: Column(
                        children: [
                          Row(
                            children:  [
                               Text(data['reelsCount'].toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Flicks",style: TextStyle(
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FanScreen()));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(data["fansList"] == null ? "0" : data["fansList"].length.toString(),style: const TextStyle(fontFamily: 'Montserrat'),),
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
                        Navigator.push(context,MaterialPageRoute(builder: (context) => const FollowerScreen()));
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
                    ),
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
              const SizedBox(height: 10,),
              WidgetAnimator(Container(
                height: 80,
                child: WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => const EditProfile())).then((value){
                              commentedPost.clear();
                              getProfile();
                            });
                          },
                          child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15))
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: 35,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.topRight,
                                      stops: [0.0, 0.99],
                                      tileMode: TileMode.clamp,
                                      colors: <Color>[
                                        secondary,
                                        primary,
                                      ]),
                                  borderRadius: const BorderRadius.all(Radius.circular(12))
                              ),
                              child: const Text('Edit Profile',style: TextStyle(
                                  color: ascent,
                                  fontSize: 18,
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
              const SizedBox(height: 5,),
              WidgetAnimator(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Text("${data["name"] == null ?"No name": data["name"]}", style: TextStyle(
                        color: primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat'
                      ),)
                    ],
                  )
              ),
              const SizedBox(height: 5,),
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
              const SizedBox(height: 5,),
              data["description"] == null || data["description"] == "" ? const SizedBox() : WidgetAnimator(
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
                                maxWidth: MediaQuery.of(context).size.width * 0.9,
                                minHeight: 10.0,
                                maxHeight: MediaQuery.of(context).size.height * 0.3,
                              ),
                              child: AutoSizeText(
                                data["description"] == null ?"No description":data["description"],
                                style: const TextStyle(fontSize: 16.0,fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5,),
              // Align(
              //   widthFactor: 11,
              //   alignment: Alignment.centerRight,
              //     child: InkWell(
              //       onTap: () {
              //         //Navigator.push(context,MaterialPageRoute(builder: (context) => ,));
              //       },
              //         child: Icon(Icons.add_box_outlined))),
              Container(
                height: 50,
                child: TabBar(
                  controller: tabController,
                  tabs: [

                    Tab(icon: Icon(Icons.grid_on, color: _getTabIconColor(context))),
                    Tab(icon: Icon(Icons.favorite, color: _getTabIconColor(context))),
                    Tab(
                      icon: ColorFiltered(
                        colorFilter: _getImageColorFilter(context),
                        child: Image.asset('assets/bagde.png', height: 28),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(child: GridTab(tabController: tabController, loading1: loading1, myPosts: myPosts, loading2: loading2, commentedPost: commentedPost, loading3: loading3, likedPost: likedPost,badges: mediaLink,unsaveFashion: unSaveFashion,)),
            ],
          ),
        ),
      )
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
    required this.badges, required this.unsaveFashion
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

  @override
  Widget build(BuildContext context) {
    Color _getTabIconColor(BuildContext context) {

      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;


      return isDarkMode ? Colors.white : primary;
    }
    return TabBarView(
      controller: tabController,
      children: <Widget>[
        loading1 == true ? SpinKitCircle(color: primary,size: 50,) :
        (commentedPost.length <= 0 ? Column(
          children: [
            const SizedBox(height: 40,),
            const Text("No Posts",textAlign: TextAlign.center,),
          ],
        ) : SingleChildScrollView(
          child: GridView.builder(
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
                            height: 820,
                            width: 200,
                            fit: BoxFit.cover,
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
          ),
        ))
        // (myPosts.length <= 0 ? Center(
        //   child: Container(
        //       child: Text("No Posts")),
        // ) : SingleChildScrollView(
        //       child: GridView.builder(
        //   physics: NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: myPosts.length,
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       //mainAxisSpacing: 10
        //   ),
        //   itemBuilder: (BuildContext context, int index){
        //       return WidgetAnimator(
        //         GestureDetector(
        //           onTap: (){
        //             Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
        //               userid:myPosts[index].userid,
        //               image: myPosts[index].images,
        //               description:  myPosts[index].description,
        //               style: "Fashion Style 2",
        //               createdBy: myPosts[index].userName,
        //               profile: myPosts[index].userPic,
        //               likes: myPosts[index].likeCount,
        //               dislikes: myPosts[index].dislikeCount,
        //               mylike: myPosts[index].mylike,
        //             )));
        //           },
        //           child: Padding(
        //             padding: const EdgeInsets.all(1.0),
        //             child: Stack(
        //               children: [
        //                 Container(
        //                   child: myPosts[index].images[0]["type"] == "video"? Container(
        //                     decoration: BoxDecoration(
        //                       image: DecorationImage(
        //                           fit: BoxFit.cover,
        //                           image: FileImage(File(myPosts[index].thumbnail))
        //                       ),
        //                       // borderRadius: BorderRadius.all(Radius.circular(10)),
        //                     ),
        //                   ) :CachedNetworkImage(
        //                     imageUrl: myPosts[index].images[0]["image"],
        //                     height: 820,
        //                     width: 200,
        //                     fit: BoxFit.fill,
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
        //                 Positioned(
        //                     right:10,
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(top:8.0),
        //                       child:myPosts[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
        //                     ))
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //   },
        // ),
        //     ))
        ,
        loading2 == true ? SpinKitCircle(color: primary,size: 50,) :
        (myPosts.length <= 0 ? Column(
          children: [
            const SizedBox(height: 40,),
            const Text("No Posts",textAlign: TextAlign.center,),
          ],
        ) : SingleChildScrollView(
              child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: myPosts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              //mainAxisSpacing: 10
          ),
          itemBuilder: (BuildContext context, int index){
              return WidgetAnimator(
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
                      userid:myPosts[index].userid,
                      image: myPosts[index].images,
                      description:  myPosts[index].description,
                      style: "Fashion Style 2",
                      createdBy: myPosts[index].userName,
                      profile: myPosts[index].userPic,
                      likes: myPosts[index].likeCount,
                      dislikes: myPosts[index].dislikeCount,
                      mylike: myPosts[index].mylike,
                    )));
                  },
                  onLongPress: () {
              unsaveFashion(myPosts[index].saveId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Stack(
                      children: [
                        Container(
                          child: myPosts[index].images[0]["type"] == "video"? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(myPosts[index].thumbnail))
                              ),
                              // borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ) :CachedNetworkImage(
                            imageUrl: myPosts[index].images[0]["image"],
                            height: 820,
                            width: 200,
                            fit: BoxFit.fill,
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
                              child:myPosts[index].images[0]["type"] == "video" ?const Icon(Icons.video_camera_back) : const Icon(Icons.image),
                            ))
                      ],
                    ),
                  ),
                ),
              );
          },
        ),
            ))
        // (commentedPost.length <= 0 ? Center(child: Container(child: Text("No Posts"))) : SingleChildScrollView(
        //   child: GridView.builder(
        //     physics: NeverScrollableScrollPhysics(),
        //     shrinkWrap: true,
        //     itemCount: commentedPost.length,
        //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       // mainAxisSpacing: 10
        //     ),
        //     itemBuilder: (BuildContext context, int index){
        //       return WidgetAnimator(
        //         GestureDetector(
        //           onTap: (){
        //             Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
        //               userid:commentedPost[index].userid,
        //               image: commentedPost[index].images,
        //               description:  commentedPost[index].description,
        //               style: "Fashion Style 2",
        //               createdBy: commentedPost[index].userName,
        //               profile: commentedPost[index].userPic,
        //               likes: commentedPost[index].likeCount,
        //               dislikes: commentedPost[index].dislikeCount,
        //               mylike: commentedPost[index].mylike,
        //             )));
        //           },
        //           child: Padding(
        //             padding: const EdgeInsets.all(1.0),
        //             child: Stack(
        //               children: [
        //                 Container(
        //                   child: commentedPost[index].images[0]["type"] == "video"? Container(
        //                     decoration: BoxDecoration(
        //                       image: DecorationImage(
        //                           fit: BoxFit.cover,
        //                           image: FileImage(File(commentedPost[index].thumbnail))
        //                       ),
        //                       //borderRadius: BorderRadius.all(Radius.circular(10)),
        //                     ),
        //                   ) :CachedNetworkImage(
        //                     imageUrl: commentedPost[index].images[0]["image"],
        //                     height: 820,
        //                     width: 200,
        //                     fit: BoxFit.cover,
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
        //                 Positioned(
        //                     right:10,
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(top:8.0),
        //                       child:commentedPost[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
        //                     ))
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ))
        ,
        loading3 == true ? SpinKitCircle(color: primary,size: 50,) : (badges.length <= 0 ?Column(
          children: [
            const SizedBox(height: 40,),
            const Text("No Posts",textAlign: TextAlign.center,),
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
                                  fit: BoxFit.fill,
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
                              child:Image.asset('assets/bagde.png',height: 28,color: _getTabIconColor(context),),
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
        // SingleChildScrollView(
        //   child: GridView.builder(
        //     physics: NeverScrollableScrollPhysics(),
        //     shrinkWrap: true,
        //     itemCount: likedPost.length,
        //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       // mainAxisSpacing: 10
        //     ),
        //     itemBuilder: (BuildContext context, int index){
        //       return WidgetAnimator(
        //         GestureDetector(
        //           onTap: (){
        //             Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
        //               userid:likedPost[index].userid,
        //               image: likedPost[index].images,
        //               description:  likedPost[index].description,
        //               style: "Fashion Style 2",
        //               createdBy: likedPost[index].userName,
        //               profile: likedPost[index].userPic,
        //               likes: likedPost[index].likeCount,
        //               dislikes: likedPost[index].dislikeCount,
        //               mylike: likedPost[index].mylike,
        //             )));
        //           },
        //           child: Padding(
        //             padding: const EdgeInsets.all(1.0),
        //             child: Stack(
        //               children: [
        //                 Container(
        //                   decoration: BoxDecoration(
        //                     // borderRadius: BorderRadius.all(Radius.circular(10)),
        //                   ),
        //                   child: likedPost[index].images[0]["type"] == "video"? Container(
        //                     decoration: BoxDecoration(
        //                       image: DecorationImage(
        //                           fit: BoxFit.cover,
        //                           image: FileImage(File(likedPost[index].thumbnail))
        //                       ),
        //                       //borderRadius: BorderRadius.all(Radius.circular(10)),
        //                     ),
        //                   ) :CachedNetworkImage(
        //                     imageUrl: likedPost[index].images[0]["image"],
        //                     fit: BoxFit.cover,
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
        //                 Positioned(
        //                     right:10,
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(top:8.0),
        //                       child:likedPost[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
        //                     ))
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // )
        ),
      ],
    );
  }
}


