import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/models/post_model.dart';
import 'package:FashionTime/screens/pages/swap_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../animations/bottom_animation.dart';
import '../../utils/constants.dart';

class OtherLikesScreen extends StatefulWidget {
  const OtherLikesScreen({Key? key}) : super(key: key);

  @override
  State<OtherLikesScreen> createState() => _OtherLikesScreenState();
}

class _OtherLikesScreenState extends State<OtherLikesScreen> {
  String id = "";
  String token = "";
  bool loading3 = false;
  List<PostModel> likedPost = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(token);
    getLikedPosts();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getLikedPosts(){
    setState(() {
      loading3 = true;
    });
    try{
      https.get(
          Uri.parse("${serverUrl}/fashionUpload/my-liked-fashions-by-others/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }
      ).then((value){
        //print("Test "+jsonDecode(value.body).toString());
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
                    value["user"]["pic"],
                    false,
                    value["likesCount"].toString(),
                    value["disLikesCount"].toString(),
                    value["commentsCount"].toString(),
                    value["created"],value1!,
                    value["user"]["id"].toString(),
                    value["myLike"] == null ? "like" : value["myLike"]
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
                  value["user"]["pic"],
                  false,
                  value["likesCount"].toString(),
                  value["disLikesCount"].toString(),
                  value["commentsCount"].toString(),
                  value["created"],"",
                  value["user"]["id"].toString(),
                  value["myLike"] == null ? "like" : value["myLike"]
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
        title: Text("Likes",style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat'
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading3 == true ? SpinKitCircle(color: primary,size: 50,) : (likedPost.length <= 0 ? Center(child: Text("No Posts")) : GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: likedPost.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10
          ),
          itemBuilder: (BuildContext context, int index){
            return WidgetAnimator(
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SwapDetail(
                    userid:likedPost[index].userid,
                    image: likedPost[index].images,
                    description:  likedPost[index].description,
                    style: "Fashion Style 2",
                    createdBy: likedPost[index].userName,
                    profile: likedPost[index].userPic,
                    likes: likedPost[index].likeCount,
                    dislikes: likedPost[index].dislikeCount,
                    mylike: likedPost[index].mylike,
                  )));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child:  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: likedPost[index].images[0]["type"] == "video"? Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(likedPost[index].thumbnail))
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ) :ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: likedPost[index].images[0]["image"],
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
                ),
              ),
            );
          },
        )),
      ),
    );
  }
}
