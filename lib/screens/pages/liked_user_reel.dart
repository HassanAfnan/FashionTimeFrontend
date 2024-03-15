import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class LikedUserReelScreen extends StatefulWidget {
  const LikedUserReelScreen({super.key});

  @override
  State<LikedUserReelScreen> createState() => _LikedUserReelScreenState();
}

class _LikedUserReelScreenState extends State<LikedUserReelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  appBar: AppBar(
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
        "Users",
        style: TextStyle(fontFamily: 'Montserrat'),
      ),
    ),
    body: ListView(
      children: [],
    ),);
  }
}
