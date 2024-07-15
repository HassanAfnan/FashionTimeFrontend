import 'package:FashionTime/authentication/login_screen.dart';
import 'package:FashionTime/authentication/otp_screen_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import '../animations/bottom_animation.dart';
import '../utils/constants.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({super.key});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

bool loading = false;
String token = '';

TextEditingController email = TextEditingController();

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  changeUsername() {
    const String url = "$serverUrl/user/api/profile/";
    try {
      https.patch(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },body: {
        "username":email.text.toString()
      }).then((value) {
        if(value.statusCode==200){
          Fluttertoast.showToast(msg: "Username changed successfully",backgroundColor: primary);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login(),));
        }
        else{
          Fluttertoast.showToast(msg: "Error received",backgroundColor: primary);
        }
      });
    } catch (e) {
      debugPrint("error encountered========>${e.toString()}");
      Fluttertoast.showToast(msg: "Error received",backgroundColor: primary);
    }
  }

  getCachedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString("token")!;
  }

  @override
  void initState() {
    getCachedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondary,
        image: const DecorationImage(
            image: AssetImage("assets/background.jpg"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WidgetAnimator(
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const SizedBox(
                  height: 30,
                ),
                WidgetAnimator(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: 150,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                // WidgetAnimator(
                //     const Text('Enter a unique username',style: TextStyle(color: ascent,fontFamily:"Montserrat",fontWeight: FontWeight.bold,fontSize: 16 ),)
                // ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                WidgetAnimator(
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                            RegExp(r'\s')),
                        FilteringTextInputFormatter(RegExp(r'[A-Z]'), allow: false),
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
                      ],
                      controller: email,
                      style: const TextStyle(
                          color: Colors.pink, fontFamily: 'Montserrat'),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat'),
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
                        hintText: "Username",
                      ),
                      cursorColor: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                WidgetAnimator(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loading == true
                        ? const SpinKitCircle(
                            color: ascent,
                            size: 70,
                          )
                        : Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.topRight,
                                    stops: const [0.0, 0.99],
                                    tileMode: TileMode.clamp,
                                    colors: <Color>[primary, secondary])),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    )),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: MediaQuery.of(context).size.width *
                                                0.1,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1)),
                                    textStyle: MaterialStateProperty.all(
                                        const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontFamily: 'Montserrat'))),
                                onPressed: () {
                                  changeUsername();
                                },
                                child: const Text(
                                  'Change username',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat'),
                                )),
                          ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
