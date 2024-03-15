import 'package:FashionTime/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_box/video_box.dart';
import 'package:shimmer/shimmer.dart';

class MyReelScreen extends StatefulWidget {
  final VideoPlayerController? controller;
  const MyReelScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<MyReelScreen> createState() => _MyReelScreenState();
}

class _MyReelScreenState extends State<MyReelScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller!;
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Container(
      alignment: Alignment.topCenter,
      child: VideoPlayer(_controller),
    )
        : Shimmer.fromColors(
        baseColor: primary,
        highlightColor: ascent,
        child: Stack(children: const [
          Center(
            child: Text(
              "FashionTime",
              style: TextStyle(
                  decoration: TextDecoration.none, fontFamily: 'Monserrat'),
            ),
          )
        ]));

  }
}
