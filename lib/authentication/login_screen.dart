

import 'dart:convert';

import 'package:FashionTime/authentication/forget_password.dart';
import 'package:FashionTime/authentication/login_verify.dart';
import 'package:FashionTime/authentication/register_screen.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';

import '../animations/bottom_animation.dart';
import '../screens/home_screen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool loading = false;
  bool eye = true;
  bool isEmailIncorrect=false;
  bool isPasswordIncorrect=false;

  Login() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      loading = true;
    });
    try {
      if(email.text == ""  || password.text == "") {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: const Text("Please fill all the fields",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
            actions: [
              TextButton(
                child: const Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
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
        FirebaseMessaging.instance.getToken().then((value1) {
          Map<String, String> body = {
            "username_or_email": email.text,
            "password": password.text,
          };
          https.post(
            Uri.parse("${serverUrl}/api/login/"),
            body: body,
          ).then((value) {
            print("Response ==> ${value.body}");
            if (json.decode(value.body)["detail"] ==
                "Username/email or password is incorrect.") {
              setState(() {
                loading = false;
              });
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) =>
                  LoginOtpScreen(
                    email: email.text,
                  )));
            }
            else if(json.decode(value.body)["detail"] == "Invalid credentials"){
              isEmailIncorrect=true;
              setState(() {
                loading = false;

                print("email of user $isEmailIncorrect");
              });
              // showDialog(
              //     context: context,
              //     builder: (context) =>
              //         AlertDialog(
              //           backgroundColor: primary,
              //           title: Text("FashionTime", style: TextStyle(color: ascent,
              //               fontFamily: 'Montserrat',
              //               fontWeight: FontWeight.bold),),
              //           content: Text("Invalid Credentials", style: TextStyle(
              //               color: ascent, fontFamily: 'Montserrat'),),
              //           actions: [
              //             TextButton(
              //               child: Text("Okay", style: TextStyle(
              //                   color: ascent, fontFamily: 'Montserrat')),
              //               onPressed: () {
              //                 setState(() {
              //                   Navigator.pop(context);
              //                 });
              //               },
              //             ),
              //           ],
              //         )
              // );
            }
            else {

              //print("Fcm Token "+value1.toString());
              var postUri = Uri.parse("${serverUrl}/user/api/profile/");
              var request = https.MultipartRequest("PATCH", postUri);
              request.fields['fcmToken'] = value1.toString();
              Map<String, String> headers = {
                "Accept": "application/json",
                "Authorization": "Bearer ${json.decode(value.body)["access"]}",
                "Content-Type": "multipart/form-data"
              };
              request.headers.addAll(headers);
              request.send().then((value5){
                print(value5.toString());
                preferences.setString("id", json.decode(value.body)["user"]["id"].toString());
                preferences.setString("name", json.decode(value.body)["user"]["name"].toString());
                preferences.setString("username", json.decode(value.body)["user"]["username"].toString());
                preferences.setString("email", json.decode(value.body)["user"]["email"].toString());
                preferences.setString("pic", json.decode(value.body)["user"]["pic"] == null ? "https://www.w3schools.com/w3images/avatar2.png" : json.decode(value.body)["user"]["pic"].toString());
                preferences.setString("phone", json.decode(value.body)["user"]["phone_number"].toString());
                preferences.setString("gender",json.decode(value.body)["user"]["gender"].toString());
                preferences.setString("token", json.decode(value.body)["access"].toString());
                preferences.setString("fcm_token", value1.toString());
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                });
                setState(() {
                  loading = false;
                });
              }).catchError((error){
                isEmailIncorrect=true;
                // showDialog(
                //   context: context,
                //   builder: (context) =>
                //       AlertDialog(
                //         backgroundColor: primary,
                //         title: Text("Fashion Time", style: TextStyle(color: ascent,
                //             fontFamily: 'Montserrat',
                //             fontWeight: FontWeight.bold),),
                //         content: Text("Invalid Credentials", style: TextStyle(
                //             color: ascent, fontFamily: 'Montserrat'),),
                //         actions: [
                //           TextButton(
                //             child: Text("Okay", style: TextStyle(
                //                 color: ascent, fontFamily: 'Montserrat')),
                //             onPressed: () {
                //               setState(() {
                //                 Navigator.pop(context);
                //               });
                //             },
                //           ),
                //         ],
                //       )
                // );
                print(error);
              });
            }
            setState(() {
              loading = false;
            });
            // String code = json.decode(value.body);
          }).catchError((error) {
            isEmailIncorrect=true;
            setState(() {
              loading = false;
            });
            // showDialog(
            //   context: context,
            //   builder: (context) =>
            //       AlertDialog(
            //         backgroundColor: primary,
            //         title: Text("FashionTime", style: TextStyle(color: ascent,
            //             fontFamily: 'Montserrat',
            //             fontWeight: FontWeight.bold),),
            //         content: Text("Invalid Credentials", style: TextStyle(
            //             color: ascent, fontFamily: 'Montserrat'),),
            //         actions: [
            //           TextButton(
            //             child: Text("Okay", style: TextStyle(
            //                 color: ascent, fontFamily: 'Montserrat')),
            //             onPressed: () {
            //               setState(() {
            //                 Navigator.pop(context);
            //               });
            //             },
            //           ),
            //         ],
            //       ),
            // );
          });
        });
      }
    } catch(e){
      isEmailIncorrect=true;
      setState(() {
        loading = false;
      });
      // AlertDialog(
      //   backgroundColor: primary,
      //   title: Text("FashionTime", style: TextStyle(color: ascent,
      //       fontFamily: 'Montserrat',
      //       fontWeight: FontWeight.bold),),
      //   content: Text("Invalid Credential", style: TextStyle(
      //       color: ascent, fontFamily: 'Montserrat'),),
      //   actions: [
      //     TextButton(
      //       child: Text("Okay", style: TextStyle(
      //           color: ascent, fontFamily: 'Montserrat')),
      //       onPressed: () {
      //         setState(() {
      //           Navigator.pop(context);
      //         });
      //       },
      //     ),
      //   ],
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('The user tries to pop()');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: const Text("Do you want to close this application?",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
            actions: [
              TextButton(
                child: const Text("Yes",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                onPressed:  () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: const Text("No",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                onPressed:  () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
        return false;
      },
      child: Container(
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
                            child: Image.asset("assets/logo.png",
                              height: MediaQuery.of(context).size.height * 0.22,

                            )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25,),
                  WidgetAnimator(
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                              RegExp(r'\s')),
                        ],
                        controller: email,
                        style: const TextStyle(
                            color: Colors.pink,
                            fontFamily: 'Montserrat'
                        ),
                        decoration: InputDecoration(
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
                            errorText: isEmailIncorrect?"Invalid Email.":null,
                            //disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Email or Username"
                        ),
                        cursorColor: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  WidgetAnimator(
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                              RegExp(r'\s')),
                        ],
                        controller: password,
                        obscureText: eye,
                        style: const TextStyle(
                            color: Colors.pink,
                            fontFamily: 'Montserrat'
                        ),
                        decoration: InputDecoration(
                            hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat'
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(eye == true ?Icons.visibility:Icons.visibility_off,color: Colors.black54,),
                              onPressed: (){
                                 setState(() {
                                   eye = !eye;
                                 });
                              },
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink),
                            ),
                            //enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            errorText: isEmailIncorrect?"Invalid Password.":null,
                            //disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Password"
                        ),
                        cursorColor: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40,),
                  WidgetAnimator(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         loading == true ? const SpinKitCircle(color: ascent,size: 70,) : Container(
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
                                        left:MediaQuery.of(context).size.width * 0.24,right: MediaQuery.of(context).size.width * 0.24)),
                                    textStyle: MaterialStateProperty.all(
                                        const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                                onPressed: () {
                                  Login();
                                  },
                                child: const Text('LOG IN',style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat'
                                ),)),
                         ),
                        ],
                      )
                  ),
                  const SizedBox(height: 10,),
                  WidgetAnimator(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
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
                                          left:MediaQuery.of(context).size.width * 0.22,right: MediaQuery.of(context).size.width * 0.22)),
                                      textStyle: MaterialStateProperty.all(
                                          const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                                  onPressed: () {
                                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const Register()));
                                  },
                                  child: const Text('SIGN UP',style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat'
                                  ),)),
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 13,),
                  WidgetAnimator(
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPassword()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Forgotten your password?",style: TextStyle(
                                color: Colors.black54,
                                fontFamily: 'Montserrat'
                            ),)
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
