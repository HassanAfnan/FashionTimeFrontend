import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../animations/bottom_animation.dart';
import '../../models/post_model.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as https;

class StylesScreen extends StatefulWidget {
  const StylesScreen({Key? key}) : super(key: key);

  @override
  State<StylesScreen> createState() => _StylesScreenState();
}

class _StylesScreenState extends State<StylesScreen> {
  String id = "";
  String token = "";
  bool loading1 = false;
  List<PostModel> myPosts = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(token);
    getMyPosts();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getMyPosts(){
    setState(() {
      loading1 = true;
    });
    try{
      https.get(
          Uri.parse("${serverUrl}/fashionUpload/my-fashions/?id=${id}"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }
      ).then((value){
        print(jsonDecode(value.body).toString());
        if(jsonDecode(value.body)["results"].length <= 0){
          setState(() {
            loading1 = false;
          });
          print("No data");
        }
        else {
          setState(() {
            loading1 = false;
          });
          jsonDecode(value.body)["results"].forEach((value) {
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
                      value["user"]["pic"]?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w":value["user"]["pic"],
                      false,
                      value["likesCount"].toString(),
                      value["disLikesCount"].toString(),
                      value["commentsCount"].toString(),
                      value["created"],
                      value1!,
                    value["user"]["id"].toString(),
                      value["myLike"] == null ? "like" : value["myLike"],
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
                    value["user"]["pic"] == null ?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w":value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],
                    "",
                  value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"],
                  value["eventData"],
                  {}
                ));
              });
            }
          });
        }
      });
    }catch(e){
      setState(() {
        loading1 = false;
      });
      print("Error --> ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        title: Text("Styles",style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat'
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading1 == true ? SpinKitCircle(color: primary,size: 50,) : (myPosts.length <= 0 ? Center(child: Text("No Posts")) : GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: myPosts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6
          ),
          itemBuilder: (BuildContext context, int index){
            return WidgetAnimator(
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
                    userid: myPosts[index].userid,
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
                child: Padding(
                  padding: const EdgeInsets.only(left:3.0,right:3.0),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: myPosts[index].images[0]["type"] == "video"? Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(myPosts[index].thumbnail))
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ) :ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: myPosts[index].images[0]["image"],
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
                                    fit: BoxFit.fill
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          right:10,
                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child:myPosts[index].images[0]["type"] == "video" ?Icon(Icons.video_camera_back) : Icon(Icons.image),
                          ))
                    ],
                  ),
                ),
              ),
            );
          },
        )),
      ),
    );
  }
}
