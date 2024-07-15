import 'dart:convert';

import 'package:FashionTime/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../models/story_model.dart';
import 'package:http/http.dart' as https;

class PinnedStoryScreen extends StatefulWidget {
  final List<Story> stories;

  PinnedStoryScreen({super.key, required this.stories});

  @override
  State<PinnedStoryScreen> createState() => _PinnedStoryScreenState();
}

class _PinnedStoryScreenState extends State<PinnedStoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late VideoPlayerController _videoController;
  late int _currentIndex = 0;
  String token = '';
  String id = '';
  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    debugPrint("length========>${widget.stories.length}");
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.stories[0].url))
          ..initialize().then((value) => setState(() {}));
    _videoController.play();
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            debugPrint("All stories viewed. Popping to previous screen.");
            Navigator.pop(context);
          }
          // else {
          //   _currentIndex = 0;
          //   _loadStory(story: widget.stories[_currentIndex]);
          // }
        });
      }
    });
    getCashedData();
    super.initState();
  }

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
  }

  viewStory(int storyId) {
    const url = "$serverUrl/apiViewStory/";
    var body = jsonEncode({'user': int.parse(id), 'view': storyId});
    try {
      https
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token"
              },
              body: body)
          .then((value) {
        if (value.statusCode == 201) {
          debugPrint("story viewed by user================>");
        } else {
          debugPrint("error received===========>${value.statusCode}");
        }
      });
    } catch (e) {
      debugPrint("Error received===========>${e.toString()}");
    }
  }
  pinStory(var uploadObject){
    const url = "$serverUrl/apiPinnedStory/";
    var body = jsonEncode({'upload': uploadObject, 'text': "","view_count":3,"viewed_by":3,'user':int.parse(id)});
    try {
      https
          .post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: body)
          .then((value) {
        if (value.statusCode == 201||value.statusCode==200) {
          debugPrint("story ======>${value.body}");
        } else {
          debugPrint("error received===========>${value.statusCode} with error${value.body.toString()}");
        }
      });
    } catch (e) {
      debugPrint("Error received===========>${e.toString()}");
    }

  }
  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[_currentIndex];
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: (details) => _onTapDown(details, story),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.stories.length,
                itemBuilder: (context, i) {
                  final Story story = widget.stories[i];
                  debugPrint("is viewed=======>${story.viewedBy}");
                  i == 0 ? null : viewStory(story.storyId);
                  switch (story.media) {
                    case MediaType.image:
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 50, left: 5),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${story.user.name} ${story.duration}",
                                        style: const TextStyle(
                                            color: ascent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: "Montserrat"),
                                      ),

                                    ],
                                  )),
                            ),
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl: story.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      );

                    case MediaType.text:
                      return SizedBox(
                        height:MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 50, left: 5),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${story.user.name} ${story.duration}",
                                        style: const TextStyle(
                                            color: ascent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: "Montserrat"),
                                      ),
                                    ],
                                  )),
                            ),
                            Expanded(
                              child: Container(
                                color: secondary,
                                child: Center(
                                  child: Text(
                                    story.url.toString(),
                                    style: const TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 35,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    case MediaType.video:
                      if (_videoController.value.isInitialized) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50, left: 5),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${story.user.name} ${story.duration}",
                                          style: const TextStyle(
                                              color: ascent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: "Montserrat"),
                                        ),
                                      ],
                                    )),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _videoController.value.size.width,
                                    height: _videoController.value.size.height,
                                    child: VideoPlayer(_videoController),
                                  ), // Sized Box
                                ),
                              ),
                            ],
                          ),
                        ); // FittedBox
                      }
                  }
                  return const SizedBox.shrink();
                },
              ),
              Positioned(
                top: 40.0,
                left: 10.0,
                right: 10.0,
                child: Row(
                  children: widget.stories
                      .asMap()
                      .map((i, e) {
                        return MapEntry(
                          i,
                          AnimatedBar(
                            animController: _animController,
                            position: i,
                            currentIndex: _currentIndex,
                          ),
                        ); // MapEntry
                      })
                      .values
                      .toList(),
                ),
              )
            ],
          ),
        )); // Scaffold
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          _currentIndex = 0;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else {
      if (story.media == MediaType.video) {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
          _animController.stop();
        } else {
          _videoController.play();
          _animController.forward();
        }
      }
    }
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    switch (story.media) {
      case MediaType.image:
        _animController.duration = const Duration(seconds: 5);
        _animController.forward();
        break;
      case MediaType.video:
        _videoController != null;
        _videoController.dispose();
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(story.url))
              ..initialize().then((_) {
                setState(() {});
                if (_videoController.value.isInitialized) {
                  _animController.duration = _videoController.value.duration;
                  _videoController.play();
                  _animController.forward();
                }
              });
        break;
    }
    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;
  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              _buildContainer(
                double.infinity,
                position < currentIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
              position == currentIndex
                  ? AnimatedBuilder(
                      animation: animController,
                      builder: (context, child) {
                        return _buildContainer(
                          constraints.maxWidth * animController.value,
                          Colors.white,
                        );
                      },
                    )
                  : const SizedBox.shrink()
            ],
          );
        },
      ),
    ));
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ), // Border.all
        borderRadius: BorderRadius.circular(3.0),
      ), // BoxDecoration
    ); // Container
  }
}
