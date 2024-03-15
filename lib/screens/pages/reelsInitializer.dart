import 'dart:convert';

import 'package:FashionTime/screens/pages/createReel.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/reel_comment.dart';
import 'package:FashionTime/screens/pages/reels.dart';
import 'package:FashionTime/screens/pages/report_reel.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as https;
import '../../utils/constants.dart';
import 'liked_user_reel.dart';

class ReelsInitializerScreen extends StatefulWidget {
  final String? videoLink;
  final String? name;
  final String? reelDescription;
  final int? likeCount;
  final int? reelId;
  final int? userId;
  final String? token;
  final int? myLikes;
  final VoidCallback? onLikeCreated;
  final VoidCallback? onDislikeCreated;
  final VoidCallback? refreshReel;
  final String userPic;
  final String friendId;
  final bool isCommentEnabled;
  // final String pic;
  const ReelsInitializerScreen({
    super.key,
    this.videoLink,
    this.name,
    this.reelDescription,
    this.likeCount,
    this.reelId,
    this.userId,
    this.token,
    this.myLikes,
    this.onLikeCreated,
    this.onDislikeCreated,
    this.refreshReel, required this.userPic, required this.friendId, required this.isCommentEnabled,
  });

  @override
  State<ReelsInitializerScreen> createState() => _ReelsInitializerScreenState();
}

class _ReelsInitializerScreenState extends State<ReelsInitializerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isPlaying = true;
  bool isLiked = false;
  bool heartIcon=false;

  @override
  void initState() {
    // TODO: implement initState
    // if(widget.videoLink.isNotEmpty){
    //   _videoPlayerController=VideoPlayerController.networkUrl(Uri.parse(widget.videoLink))..addListener(()=>setState(() {
    //
    //   }))..setLooping(true)..initialize().then((_)=>_videoPlayerController!.play());
    // }
    if (widget.videoLink!.isNotEmpty) {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoLink!))
            ..addListener(() => setState(() {}))
            ..setLooping(true)
            ..initialize().then((_) {
              if (isPlaying) {
                _videoPlayerController!.play();
              }
            });
    }

    super.initState();
    //initializePlayer();
  }

  // Future initializePlayer() async {
  //   _videoPlayerController =
  //       VideoPlayerController.networkUrl(Uri.parse(widget.videoLink),);
  //   await Future.wait([_videoPlayerController!.initialize()]);
  //   _chewieController = ChewieController(
  //       videoPlayerController: _videoPlayerController!, autoPlay: true,
  //
  //   looping: true,
  //   showControls: false,);
  //   setState(() {
  //
  //   });
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  showToast(Color bg, String toastMsg) {
    Fluttertoast.showToast(
      msg: toastMsg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: bg,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _togglePlayPause() {
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
    } else {
      _videoPlayerController!.play();
    }
    setState(() {
      isPlaying = !_videoPlayerController!.value.isPlaying;
    });
  }

  Future<void> createLike() async {
    heartIcon=true;
    const String apiUrl = '$serverUrl/fashionReelLikes/';
    final Map<String, dynamic> postLike = {
      'likeEmoji': 1,
      'reel': widget.reelId,
      'user': widget.userId
    };
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    try {
      final response = await https.post(Uri.parse(apiUrl),
          headers: headers, body: jsonEncode(postLike));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          debugPrint("like posted");
          isLiked = true;
          heartIcon=false;
          // showToast(primary, "Reel liked");
          if (widget.onLikeCreated != null) {
            widget.onLikeCreated!();
          }
        });
      }
      if (response.statusCode == 400) {
        setState(() {
          showToast(primary, "Reel already liked");
        });
      }
    } catch (e) {
      debugPrint("error posting like with exception ${e.toString()}");
    }
  }

  createDislike() async {
    String apiUrl = '$serverUrl/fashionReelLikes/${widget.myLikes}/';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    try {
      await https.delete(
        Uri.parse(apiUrl),
        headers: headers,
      );
      debugPrint("reel disliked");
      showToast(primary, "Reel disliked");
      if (widget.onDislikeCreated != null) {
        widget.onDislikeCreated!();
      }
    } catch (e) {
      debugPrint("error disliking reel ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _togglePlayPause();
      },
      onDoubleTap: () {
        createLike();
      },
      child: Stack(children: [
        ReelScreen(controller: _videoPlayerController),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Flicks",
                      style: TextStyle(
                          color: primary,
                          fontSize: 30,
                          fontFamily: 'Montserrat',
                          decoration: TextDecoration.none)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                        onTap: () {
                          _videoPlayerController!.pause();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateReelScreen(
                                  refreshReel: () {
                                    widget.refreshReel!();
                                  },
                                ),
                              ));
                        },
                        child: Icon(
                          Icons.add,
                          color: primary,
                          size: 40,
                        ),


                        // Image.asset(
                        //   "assets/reelIcon.png",
                        //   width: 30,
                        //   height: 30,
                        //   color: primary,
                        // )
                        ),
                  ),

                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(onPressed:() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReelReportScreen(reelId: widget.reelId!,userId: widget.userId!)));
                },  icon: Icon(Icons.report,color: primary,size: 30,)),
              ),
              const SizedBox(
                height: 70,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
               Center(child: Visibility(visible: heartIcon,child:  Icon(Icons.favorite,size: 60,color: primary,))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            child:
                                //     widget.pic!=null?
                                // Image.network(widget.pic,):
                                Icon(
                              Icons.person,
                              size: 26,
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                              onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>FriendProfileScreen(id: widget.friendId.toString(), username: widget.name!) ,));
                              },
                                child: Text(widget.name!,
                                    style: const TextStyle(
                                        color: ascent,
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        decoration: TextDecoration.none)),
                              ),
                              Text(
                                widget.reelDescription!,
                                style: const TextStyle(
                                  color: ascent,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  Column(
                    children: [

                      GestureDetector(
                          onTap: () {
                            widget.myLikes == null
                                ? createLike()
                                : createDislike();
                          },
                          child: widget.myLikes == null
                              ? Icon(
                                  Icons.favorite_border_outlined,
                                  color: primary,
                                  size: 30,
                                )
                              : Icon(
                                  Icons.favorite,
                                  color: primary,
                                  size: 30,
                                )),
                      GestureDetector(
                        onLongPress: () {
Navigator.push(context,MaterialPageRoute(builder: (context) => const LikedUserReelScreen(),));
                        },
                        child: Text("${widget.likeCount}",
                            style: const TextStyle(
                                color: ascent,
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                decoration: TextDecoration.none)),
                      ),
                      widget.isCommentEnabled==true?
                      GestureDetector(
                        onTap: () {
                          _videoPlayerController!.pause();
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  ReelCommentScreen(userPic: widget.userPic,reelId: widget.reelId!),));
                        },
                        child:Icon(
                          FontAwesomeIcons.comment,
                          color: primary,
                          size: 26,
                        ) ,
                      ):const SizedBox()
                    ],
                  )
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
