import 'package:FashionTime/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_box/video_box.dart';
import 'package:shimmer/shimmer.dart';

class ReelScreen extends StatefulWidget {
  final VideoPlayerController? controller;
  const ReelScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
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
    //     : const SizedBox(
    //   height: 200,
    //   child: Center(
    //     child: CircularProgressIndicator(),
    //   ),
    // );
  }
}
