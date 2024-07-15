import 'dart:convert';

import 'package:FashionTime/authentication/forget_password_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;

import '../animations/bottom_animation.dart';
import '../utils/constants.dart';
import 'change_password.dart';
class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}
bool loading=false;
TextEditingController code = TextEditingController();
class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
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
            title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
            content: const Text("Please fill all fields",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
          "token": code.text,
        };
        https.post(
          Uri.parse("$serverUrl/password/reset/verify-token/"),
          body: body,
        ).then((value) {
          debugPrint("Response ==> ${value.body}");
          debugPrint("Response ==> ${value.statusCode.toString()}");
          if(json.decode(value.body)[0] == "Not found.") {
            setState(() {
              loading = false;
            });
            code.text = "";
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: primary,
                title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
                content: const Text("Invalid code. If this problem persists, please resend a code.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
          }else{
            setState(() {
              loading = false;
            });
            String otpCode = code.text;
            code.clear();
            Navigator.pop(context);
            debugPrint("Navigating to next screen with code: $otpCode");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>  ForgetPasswordViaProfileScreen(
              code: otpCode,
            )));
            code.clear();
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
              title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
              content: Text(error.toString(),style: const TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.17,),
                WidgetAnimator(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/logo.png",height: 150,),
                    ],
                  ),
                ),
                const SizedBox(height: 25,),
                WidgetAnimator(
                  SizedBox(
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
                        }
                        //handle validation or checks here
                      },
                      onSubmit: (String verificationCode){
                        debugPrint("all otp fields filled");
                        verifyOtp();
                        //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => ChangePassword()));
                      }, // end onSubmit
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                    loading ? const SpinKitCircle(color: ascent,size: 70,) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.topRight,
                                  stops: const [0.0, 0.99],
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
                                        borderRadius: BorderRadius.circular(15.0),
                                      )
                                  ),
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                                  padding: MaterialStateProperty.all(EdgeInsets.only(
                                      top: 13,bottom: 13,
                                      left:MediaQuery.of(context).size.width * 0.2,right: MediaQuery.of(context).size.width * 0.2)),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                              onPressed: () {
                                //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomeScreen()));
                              },
                              child: const Text('RESEND',style: TextStyle(
                                  fontSize: 20,
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
