import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:FashionTime/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../animations/bottom_animation.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class LoginOtpScreen extends StatefulWidget {
  final String email;
  const LoginOtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  TextEditingController code = TextEditingController();
  bool loading = false;

  verifyOtp() async {
    setState(() {
      loading = true;
    });
    try {
      if(code.text.isEmpty == true) {
        code.text = "";
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: primary,
            title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: Text("Please fill all fields",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
          "code": code.text,
        };
        post(
          Uri.parse("${serverUrl}/api/verify-otp/"),
          body: body,
        ).then((value) {
          print("Response ==> ${value.body}");
          if(json.decode(value.body)["detail"] == "Invalid or expired code.") {
            setState(() {
              loading = false;
            });
            code.text = "";
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: primary,
                title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
                content: Text("Invalid Code.Please Resend new code.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
          }else{
            setState(() {
              loading = false;
            });
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Login()));
          }
        }).catchError((error){
          setState(() {
            loading = false;
          });
          code.text = "";
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
  reSendOtp() async {
    setState(() {
      loading = true;
    });
    try {
      Map<String, String> body = {
        "email": widget.email,
      };
      post(
        Uri.parse("${serverUrl}/api/regenerate-otp-code/"),
        body: body,
      ).then((value) {
        print("Response ==> ${value.body}");
        sendEmail(json.decode(value.body)["verification_code"]);
      }).catchError((error){
        setState(() {
          loading = false;
        });
        code.text = "";
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
    } catch(e){
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.email);
    reSendOtp();
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.17,),
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
                SizedBox(height: 25,),
                WidgetAnimator(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: OtpTextField(
                      textStyle: TextStyle(
                        color:Colors.pink.shade300,
                      ),
                      numberOfFields: 5,
                      borderColor: Colors.black54,
                      cursorColor: Colors.pink.shade300,
                      enabledBorderColor: Colors.black54,
                      disabledBorderColor: primary,
                      showFieldAsBox: true,
                      onCodeChanged: (String co) {
                        if(co != 0) {
                          code.text = code.text + co;
                          print(co);
                          print(code.text);
                        }
                      },
                      onSubmit: (String verificationCode){
                        verifyOtp();
                      }, // end onSubmit
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("We have send you a code for verification.",
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
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
                                      left:MediaQuery.of(context).size.width * 0.2,right: MediaQuery.of(context).size.width * 0.2)),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                              onPressed: () {
                                reSendOtp();
                                // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen()));
                              },
                              child: const Text('RESEND',style: TextStyle(
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
      ..recipients.add(widget.email)
      ..subject = 'Verification Code :: 😀 :: ${DateTime.now()}'
      ..text = "Your verification code is ${code}.";
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: primary,
          title: Text("Fashion Time",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
          content: Text("Code send successfully.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
