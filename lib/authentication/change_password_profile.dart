import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../animations/bottom_animation.dart';
import '../utils/constants.dart';

class ChangePasswordViaProfileScreen extends StatefulWidget {
  const ChangePasswordViaProfileScreen({super.key});

  @override
  State<ChangePasswordViaProfileScreen> createState() => _ChangePasswordViaProfileScreenState();
}
bool loading=false;
bool eye1=false;
bool eye2=false;
class _ChangePasswordViaProfileScreenState extends State<ChangePasswordViaProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondary,
        image: const DecorationImage(
            image: AssetImage(
                "assets/background.jpg"
            ),
            fit: BoxFit.fill
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WidgetAnimator(
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                const SizedBox(height: 30,),
                WidgetAnimator(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset("assets/logo.png",height: 150,)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50,),
                WidgetAnimator(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.deny(
                      //       RegExp(r'\s')),
                      // ],
                      //controller here
                      style: const TextStyle(
                          color: Colors.pink,
                          fontFamily: 'Montserrat'
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(eye1 == true ?Icons.visibility:Icons.visibility_off,color: Colors.black54,),
                          onPressed: (){
                            setState(() {
                              eye1 = !eye1;
                            });
                          },
                        ),
                        hintStyle: const TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat'
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                        //enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        //disabledBorder: InputBorder.none,
                        alignLabelWithHint: true,
                        hintText: "Enter new password",
                      ),
                      cursorColor: Colors.pink,
                      obscureText: eye1,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                WidgetAnimator(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.deny(
                      //       RegExp(r'\s')),
                      // ],
                    //controller here
                      style: const TextStyle(
                          color: Colors.pink,
                          fontFamily: 'Montserrat'
                      ),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(eye2 == true ?Icons.visibility:Icons.visibility_off,color: Colors.black54,),
                            onPressed: (){
                              setState(() {
                                eye2 = !eye2;
                              });
                            },
                          ),
                          hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat'
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          //enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          //disabledBorder: InputBorder.none,
                          alignLabelWithHint: true,
                          hintText: "Confirm password"
                      ),
                      cursorColor: Colors.pink,
                      obscureText: eye2,
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loading == true ? SpinKitCircle(color: ascent,size: 70,) : Container(
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.topRight,
                                  stops: [0.0, 0.99],
                                  tileMode: TileMode.clamp,
                                  colors: <Color>[
                                    primary,
                                    secondary
                                  ])
                          ),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      )
                                  ),
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                                  padding: MaterialStateProperty.all(EdgeInsets.only(
                                      top: 8,bottom: 8,
                                      left:MediaQuery.of(context).size.width * 0.1,right: MediaQuery.of(context).size.width * 0.1)),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(fontSize: 12, color: Colors.white,fontFamily: 'Montserrat'))),
                              onPressed: () {
                              },
                              child: const Text('Save Password',style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat'
                              ),)),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
