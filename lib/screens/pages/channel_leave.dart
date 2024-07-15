import 'package:FashionTime/helpers/database_methods.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ChannelLeft extends StatefulWidget {
  final String? Channelname;
  const ChannelLeft({
    this.Channelname,
    super.key});

  @override
  State<ChannelLeft> createState() => _ChannelLeftState();
}

class _ChannelLeftState extends State<ChannelLeft> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
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
                  ]),
            ),
          ),
          backgroundColor: primary,
          title: const Text("Video Call Ended", style: TextStyle(fontFamily: 'Montserrat')),
        ),
        body: Center(
          child:Container(
            height: 300,
            width: 300,
            child:const Center(child: Text(
              "You left the Video Call",
              style: TextStyle(
                fontFamily: 'Montserrat', // Set the font family
                fontSize: 20, // Set the font size
                color: Colors.white, // Set the text color
              ),
            ),),
          )
        )
    );
  }
}
