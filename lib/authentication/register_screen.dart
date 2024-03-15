import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:FashionTime/authentication/login_screen.dart';
import 'package:FashionTime/authentication/otp_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import '../animations/bottom_animation.dart';
import '../utils/constants.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool terms = true;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  String gender = "Male";
  bool loading = false;
  bool eye = true;
  bool isUserNameRepeated=false;
  String? emailError;
  String? passwordError;
  String? nameError;
  String? userNameError;
  bool isEmailValid(String value) {
    // Use regex for simple email validation
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\.com)?$');
    return emailRegex.hasMatch(value);
    //
  }

  void validateEmail() {
    setState(() {
      if(email.text==''){
        emailError="Email is required.";
      }
      else{
      emailError = isEmailValid(email.text) ? null : "Invalid email format.";}
    });
  }
  void checkUsername(){
    setState(() {
      if(isUserNameRepeated==true){
        userNameError="Please select a unique user name.";
      }
    });
  }
  bool isPasswordValid(String value) {
    // Use regex for simple email validation
    final RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[\d_!@#$%^&*()-+=]).{7,}$');
    return passwordRegex.hasMatch(value);
  }
  void validatePassword() {
    setState(() {
      if(password.text==''){
        passwordError="Password is required.";
      }
      else{
      passwordError = isPasswordValid(password.text) ? null : "The password must contain at least 7 characters, one upper case character, and at least one symbol or number.";}
    });
  }
  void validateName() {
    setState(() {
      nameError = isNameValid(name.text) ? null : "Name is required.";
    });
  }
  bool isNameValid(String value) {
    // Use regex for simple email validation
    if(value.isNotEmpty){
      return true;
    }
    else{
      return false;
    }
  }








  signUp() async {
    setState(() {
      loading = true;
    });
    try {
      if(email.text == ""  || name.text == "" || password.text == "" || gender == ""|| username.text=="") {
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
        if(password.text.length <= 6){
          setState(() {
            loading = false;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: primary,
              title: const Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
              content: const Text("The password must be at least 7 characters long",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
              "email": email.text,
              "name": name.text,
              "username":username.text,
              "password": password.text,
              "gender": gender,
              "phone_number": phone.text,
              "fcmToken": value1!
            };
            post(
              Uri.parse("${serverUrl}/api/signup/"),
              body: body,
            ).then((value) {
              print(" user created with Response ==> ${json.decode(value.body)}");
              if (json.decode(value.body).containsKey("username") &&
                  json.decode(value.body)["username"] is List){
                isUserNameRepeated=true;
                print("username bool $isUserNameRepeated");
              }
              if (json.decode(value.body).containsKey("user") == true) {
                print("verification code");
                sendEmail(json.decode(value.body)["user"]["verification_code"],
                    json.decode(value.body));
              }
              else if (json.decode(value.body).containsKey("email") == true) {
                setState(() {
                  loading = false;
                });
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        backgroundColor: primary,
                        title: const Text("FashionTime", style: TextStyle(
                            color: ascent,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold),),
                        content: const Text("User with this email already exists.",
                          style: TextStyle(
                              color: ascent, fontFamily: 'Montserrat'),),
                        actions: [
                          TextButton(
                            child: const Text("Okay", style: TextStyle(
                                color: ascent, fontFamily: 'Montserrat')),
                            onPressed: () {
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
                  loading = false;
                });
                print("Code not sent");
              }
            }).catchError((error) {
              setState(() {
                loading = false;
              });
              print("${error}");
              showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      backgroundColor: primary,
                      title: const Text("FashionTime", style: TextStyle(
                          color: ascent,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),),
                      content: const Text("Invalid Credentials", style: TextStyle(
                          color: ascent, fontFamily: 'Montserrat'),),
                      actions: [
                        TextButton(
                          child: const Text("Okay", style: TextStyle(
                              color: ascent, fontFamily: 'Montserrat')),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
              );
            });
          });
        }
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
                  const SizedBox(height: 60,),
                  WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            child: Image.asset("assets/logo.png",height: MediaQuery.of(context).size.height * 0.20,)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  WidgetAnimator(
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: name,
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
                            //disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Enter Your Name",
                          errorText: nameError
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
                            //disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Enter Your Email",
                          errorText: emailError
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
                        controller: username,
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
                            //disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Enter Your Username",
                            errorText: userNameError
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
                        controller: password,
                        obscureText: eye,
                        style: const TextStyle(
                            color: Colors.pink,
                            fontFamily: 'Montserrat'
                        ),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(eye == true ?Icons.visibility:Icons.visibility_off,color: Colors.black54,),
                              onPressed: (){
                                setState(() {
                                  eye = !eye;
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
                            errorText: passwordError,
                            errorMaxLines: 3,
                            //disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: "Password"
                        ),
                        cursorColor: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleSwitch(
                          fontSize: 14,
                          centerText:true,
                          multiLineText: true,
                          dividerMargin: 0,
                          activeBgColor:[primary,secondary],
                          activeFgColor: ascent,
                          minWidth:100,
                          minHeight: 60,
                          initialLabelIndex: 0,
                          totalSwitches: 3,
                          labels: const ['Male','Female','Other'],
                          onToggle: (index) {
                            print('switched to: $index');
                            if(index == 0){
                              gender = "Male";
                            }else if(index == 1){
                              gender = "Female";
                            }else if(index == 2){
                              gender = "Other";
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12,),
                  GestureDetector(
                    onTap: (){
                      _launchURL();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Checkbox(
                        //     activeColor: Colors.pink.shade300,
                        //     value:terms, onChanged: (val){
                        //   setState(() {
                        //     terms = val!;
                        //   });
                        // }),
                        Container(
                          width: 250,
                          child: const AutoSizeText("By signing up, you agree to our ",
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Montserrat',
                            ),),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      _launchURL();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Terms",style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold
                    ),),
                        Text(" &",style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Montserrat',
                        ),),
                        Text(" Conditions",style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: (){
                      _launchPolicy();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(" Privacy Policy",style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  WidgetAnimator(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         loading == true ?  const SpinKitCircle(color: ascent,size: 70,) : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
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
                                    validateEmail();
                                    validatePassword();
                                    validateName();
                                    checkUsername();
                                    if(emailError==null&& passwordError==null&&nameError==null){
                                      signUp();
                                    }
                                    // else{
                                    //   AlertDialog(
                                    //     backgroundColor: primary,
                                    //     title: Text("FashionTime", style: TextStyle(
                                    //         color: ascent,
                                    //         fontFamily: 'Montserrat',
                                    //         fontWeight: FontWeight.bold),),
                                    //     content: Text("invalid email.",
                                    //       style: TextStyle(
                                    //           color: ascent, fontFamily: 'Montserrat'),),
                                    //     actions: [
                                    //       TextButton(
                                    //         child: Text("Okay", style: TextStyle(
                                    //             color: ascent, fontFamily: 'Montserrat')),
                                    //         onPressed: () {
                                    //           setState(() {
                                    //             Navigator.pop(context);
                                    //           });
                                    //         },
                                    //       ),
                                    //     ],
                                    //   );
                                    // }
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
                  const SizedBox(height: 5,),
                  WidgetAnimator(
                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const Login()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Already have an account?",style: TextStyle(color: Colors.black54),),
                            Text(" Log In",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),)
                          ],
                        ),
                      )
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  _launchURL() async {
    final Uri url = Uri.parse('https://fashion-time.vercel.app');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
  _launchPolicy() async {
    final Uri url = Uri.parse('https://fashion-time.vercel.app/policy.html');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
  sendEmail(code,data) async {
    String username = userID;
    String password = passID;

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Fashion Time')
      ..recipients.add(email.text)
      ..subject = 'Verification Code :: 😀 :: ${DateTime.now()}'
      ..text = "Your verification code is ${code}.";
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      setState(() {
        loading = false;
      });
        Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(
          id: data["user"]["id"].toString(),
          name: data["user"]["name"],
          email: data["user"]["email"],
          phone_number: data["user"]["phone_number"],
          username: data["user"]["username"],
          gender: data["user"]["gender"],
          access_token: data["access_token"],
          pic: data["user"]["pic"] == null ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w" :data["user"]["pic"],
          fcmToken: data["user"]["fcmToken"],
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



