import 'package:FashionTime/models/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/constants.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
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
        title: Text("Results",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context,index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(
                  results[index].pic,
                cacheHeight: 50,
                cacheWidth: 50,
              ),
              title: Text(results[index].title),
            ),
          )
      ),
    );
  }
}
