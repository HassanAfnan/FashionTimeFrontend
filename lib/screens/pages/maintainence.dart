import 'package:flutter/material.dart';

class MaintainenceScreen extends StatefulWidget {
  const MaintainenceScreen({super.key});

  @override
  State<MaintainenceScreen> createState() => _MaintainenceScreenState();
}

class _MaintainenceScreenState extends State<MaintainenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("This App is currently in maintaince")
            ],
          )
        ],
      ),
    );
  }
}
