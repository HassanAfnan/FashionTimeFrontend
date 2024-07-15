import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as https;
import '../animations/bottom_animation.dart';
import '../utils/constants.dart';

class ForgetPasswordViaProfileScreen extends StatefulWidget {
  const ForgetPasswordViaProfileScreen({required this.code, Key? key}) : super(key: key);

  final String code;

  @override
  State<ForgetPasswordViaProfileScreen> createState() => _ForgetPasswordViaProfileScreenState();
}
bool loading=false;
bool loading1=false;
bool eye1=false;
bool eye2=false;
TextEditingController newPassword=TextEditingController();
TextEditingController confirmPassword=TextEditingController();
class _ForgetPasswordViaProfileScreenState extends State<ForgetPasswordViaProfileScreen> {
  resetPassword(){
    print("password token and password2 is ======>${newPassword.text} ${confirmPassword.text} ${widget.code}");
    debugPrint("otp code is ===========>${widget.code.toString()}");
    const String url='$serverUrl/password/reset/confirm/';
    try{
      setState(() {
        loading1=true;
      });
      https.post(Uri.parse(url),body: {
        "password":newPassword.text.toString(),
        "token":widget.code.toString(),
        "password2":confirmPassword.text.toString(),

      }).then((value) {
        if(value.statusCode==200|| value.statusCode==201){
          Fluttertoast.showToast(msg: "Password Changed Successfully!",backgroundColor: primary);
          setState(() {
            loading1=false;
          });
          Navigator.pop(context);
          Navigator.pop(context);

        }
        else{
          debugPrint("error received with status code============>${value.statusCode}");
          setState(() {
            loading1=false;
          });
        }
      });
    }catch(e){
      setState(() {
        loading1=false;
        debugPrint("error received============>${e.toString()}");
      });
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: newPassword,
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: confirmPassword,
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
                        loading == true ? const SpinKitCircle(color: ascent,size: 70,) :
                        loading1?SpinKitCircle(color: primary,):
                        Container(
                          height: 35,
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
                          child:

                          ElevatedButton(
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
                                  resetPassword();
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
