import 'dart:convert';

import 'package:FashionTime/authentication/fp_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import '../animations/bottom_animation.dart';
import '../utils/constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool loading = false;
  TextEditingController email = TextEditingController();

  forgetPassword() async {
    setState(() {
      loading = true;
    });
    try {
      if(email.text == "") {
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: const Text("Please fill all the fields.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
      else if(email.text.contains("@") == false){
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: const Text("Email is not correct.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
      else if(email.text.contains(".com") == false){
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: const Text("Email is not correct.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
        Map<String, String> body = {
          "email": email.text.toLowerCase(),
        };
        post(
          Uri.parse("$serverUrl/password/reset/"),
          body: body,
        ).then((value) {
          print("Response ==> ${value.body}");
          String code = json.decode(value.body)["code"];
          if(code.isEmpty == false){
            sendEmail(code);
          }else {
            setState(() {
              loading = false;
            });
            print("Code not sent");
          }
        }).catchError((error){
          setState(() {
            loading = false;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: primary,
              title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
              content: const Text("User with this email does not exist.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Enter your email for password reset.",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontFamily: 'Montserrat'
                          ),
                        )
                      ],
                    )
                ),
                const SizedBox(height: 30,),
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
                      decoration: const InputDecoration(
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
                          hintText: "Enter Your Email"
                      ),
                      cursorColor: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                WidgetAnimator(
                    loading == true ? const SpinKitCircle(color: ascent,size: 70,) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                                      left:MediaQuery.of(context).size.width * 0.2,right: MediaQuery.of(context).size.width * 0.2)),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(fontSize: 12, color: Colors.white,fontFamily: 'Montserrat'))),
                              onPressed: () {
                                forgetPassword();
                                // Navigator.pop(context);
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => OtpfpScreen()));
                              },
                              child: const Text('Send verification code',style: TextStyle(
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
  sendEmail(code) async {
    String username = userID;
    String password = passID;

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Fashion Time')
      ..recipients.add(email.text)
      ..subject = 'Verification Code :: 😀 :: ${DateTime.now()}'
      ..text = "$code.";
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => OtpfpScreen(
        email: email.text,
      )));
    } on MailerException catch (e) {
      setState(() {
        loading = false;
      });
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
