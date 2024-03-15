import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/constants.dart';
import 'friend_profile.dart';
import 'videos/video_file.dart';

class SwapDetail extends StatefulWidget {
  final String userid;
  final List<dynamic> image;
  final String description;
  final String createdBy;
  final String style;
  final String profile;
  final String likes;
  final String dislikes;
  final String mylike;
   bool? addMeInFashionWeek;

   SwapDetail({Key? key, required this.image, required this.description, required this.createdBy, required this.style, required this.profile, required this.likes, required this.dislikes, required this.userid, required this.mylike,   this.addMeInFashionWeek}) : super(key: key);

  @override
  State<SwapDetail> createState() => _SwapDetailState();
}

class _SwapDetailState extends State<SwapDetail> {
  bool like = false;
  bool dislike = false;
  final CarouselController _carouselController = CarouselController();
  int _current=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print(widget.image[2]);
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
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        backgroundColor: primary,
        title: const Text("Posts",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: ListView(
        children: [

          WidgetAnimator(
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
              // color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                      id: widget.userid,
                      username: widget.createdBy,
                    )));
                  },
                  child: Row(
                    children: [
                         Row(
                           children: [
                             CircleAvatar(
                                 child: ClipRRect(
                                   borderRadius: const BorderRadius.all(Radius.circular(50)),
                                   child: widget.profile == null ?Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 40,height: 40,):CachedNetworkImage(
                                     imageUrl: widget.profile,
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
                                     placeholder: (context, url) => Center(child: SpinKitCircle(color: primary,size: 10,)),
                                     errorWidget: (context, url, error) => ClipRRect(
                                         borderRadius: const BorderRadius.all(Radius.circular(50)),
                                         child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 40,height: 40,)
                                     ),
                                   ),
                                 )),
                             const SizedBox(width: 10,),
                             Text(widget.createdBy,style: const TextStyle(color: ascent,fontSize: 15,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),)
                           ],
                         ),
                      ],
                  ),
                ),
              ),
            )
          ),
          WidgetAnimator(
            Row(
              children: [
                Container(
                  color: dark1,
                  height: 320,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: 320.0,
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.99,
                      aspectRatio: 2.0,
                      initialPage: 0,
                      enableInfiniteScroll:  widget.image.length>1,
                        onPageChanged: (ind,reason){
                          setState(() {
                            _current = ind;
                          });
                        }

                     ),
                    items: widget.image.map((i) {
                      print(i);
                      return i["type"] == "video" ? UsingVideoControllerExample(
                        path: i["video"],
                      ) : Builder(
                        builder: (BuildContext context) {
                          return CachedNetworkImage(
                            imageUrl: i["image"],
                            imageBuilder: (context, imageProvider) => Container(
                              height:MediaQuery.of(context).size.height ,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => SpinKitCircle(color: primary,size: 60,),
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
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),


              ],
            ),



          ),
          widget.image.length == 1 ?
          const SizedBox() : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.image.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black.withOpacity(_current == entry.key ? 0.9 : 0.4))
                  ),
                ),
              );
            }).toList(),
          ),
          // const SizedBox(height: 10,),
          WidgetAnimator(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        like = true;
                        dislike = false;
                      });
                    },
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                widget.likes=="0"?
                                const SizedBox():
                                Text("${widget.likes}",style: TextStyle(fontFamily: 'Montserrat',color: primary),),
                              ],
                            ),
                            const SizedBox(width: 10,),
                            Row(
                              children: [
                                widget.addMeInFashionWeek==true?
                                Icon(widget.mylike == "like" ? Icons.favorite_border : Icons.favorite ,color: Colors.red,):
                                Icon(widget.mylike == "like" ? Icons.star_border : Icons.star ,color: Colors.orange,)
                              ],
                            ),
                            const SizedBox(width: 5,),
                            // Row(
                            //   children: [
                            //     Text("Likes",style: TextStyle(
                            //         color: primary,
                            //         fontFamily: 'Montserrat'
                            //     ),)
                            //   ],
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          WidgetAnimator(
              Row(
                children: [
                  const SizedBox(width: 15),
                  Container(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 20.0,
                        maxWidth: 365.0,
                        minHeight: 20.0,
                        maxHeight: 300.0,
                      ),
                      child: AutoSizeText(
                        widget.description,
                         style: const TextStyle(fontSize: 10.0,fontFamily: 'Montserrat'),
                      ),
                    ),
                  ),
                ],
              )
          ),
          const SizedBox(height: 50,),
        ],
      ),
    );
  }
}

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
//


