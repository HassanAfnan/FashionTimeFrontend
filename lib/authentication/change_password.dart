import 'package:FashionTime/authentication/fp_otp.dart';
import 'package:FashionTime/authentication/login_screen.dart';
import 'package:FashionTime/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import '../animations/bottom_animation.dart';
import '../utils/constants.dart';

class ChangePassword extends StatefulWidget {
  final String code;
  const ChangePassword({Key? key, required this.code}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool loading = false;
  TextEditingController password1 = TextEditingController();
  TextEditingController password2 = TextEditingController();
  bool eye1 = true;
  bool eye2 = true;
  forgetPassword() async {
    setState(() {
      loading = true;
    });
    try {
      if(password1.text == "" || password2.text == "") {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: Text("Please fill all the fields",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
            actions: [
              TextButton(
                child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                onPressed:  () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      }
      else if(password1.text !=  password2.text){
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: Text("Password mismatch.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
            actions: [
              TextButton(
                child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                onPressed:  () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      }
      else {
        setState(() {
          loading = true;
        });
        Map<String, String> body = {
          "password": password1.text,
          "token": widget.code,
          "password2": password2.text
        };
        post(
          Uri.parse("${serverUrl}/password/reset/confirm/"),
          body: body,
        ).then((value) {
          print("Response ==> ${value.body}");
            setState(() {
              loading = false;
            });
            // Navigator.pop(context);
            // Navigator.push(context,MaterialPageRoute(builder: (context) => Login()));
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: primary,
              title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
              content: Text("Password changed successfully.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
              actions: [
                TextButton(
                  child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                  onPressed:  () {
                    setState(() {
                      Navigator.pop(context);
                      Navigator.push(context,MaterialPageRoute(builder: (context) => Login()));
                    });
                  },
                ),
              ],
            ),
          );
        }).catchError((error){
          setState(() {
            loading = false;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: primary,
              title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
              content: Text(error.toString(),style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
              actions: [
                TextButton(
                  child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                  onPressed:  () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          );
        });
      }
    } catch(e){
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondary,
        image: DecorationImage(
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
                SizedBox(height: 30,),
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
                SizedBox(height: 50,),
                WidgetAnimator(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                            RegExp(r'\s')),
                      ],
                      controller: password1,
                      style: TextStyle(
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
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat'
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
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
                SizedBox(height: 10,),
                WidgetAnimator(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                            RegExp(r'\s')),
                      ],
                      controller: password2,
                      style: TextStyle(
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
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat'
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
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
                SizedBox(height: 50,),
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
                                forgetPassword();
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
