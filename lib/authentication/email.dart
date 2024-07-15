import 'package:FashionTime/authentication/otp_screen_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as https;
import '../animations/bottom_animation.dart';
import '../utils/constants.dart';
class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

bool loading =false;

TextEditingController email=TextEditingController();


class _EmailScreenState extends State<EmailScreen> {
  bool loading = false;
  resetPassword()async{
    setState(() {
      loading = true;
    });
    String url='$serverUrl/password/reset/';
    try{
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
            content: const Text("Email is not correct.Please add @",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
            content: const Text("Email is not correct.Please add .com",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
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
        final response= await https.post(Uri.parse(url),body: {
          'email':email.text.toLowerCase()
        });
        if(response.statusCode==200){
          setState(() {
            loading = false;
          });
          debugPrint('reset api response=========>${response.body.toString()}');
          //Fluttertoast.showToast(msg:"We have send you otp at your entered Email" ,backgroundColor: primary,textColor: ascent);
          // ignore: use_build_context_synchronously
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordOtpScreen(),));
        }
        else{
          setState(() {
            loading = false;
          });
          debugPrint("error received in api============> ${response.statusCode}");
        }
      }
    }
    catch(e){
      setState(() {
        loading = false;
      });
    debugPrint("exception occurred========>${e.toString()}");
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
                      Image.asset("assets/logo.png",height: 150,),
                    ],
                  ),
                ),
                const SizedBox(height: 50,),
                WidgetAnimator(
                  const Text('Enter your email address',style: TextStyle(color: ascent,fontFamily:"Montserrat",fontWeight: FontWeight.bold,fontSize: 16 ),)
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                WidgetAnimator(
                  SizedBox(
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
                        hintText: "Enter Email",
                      ),
                      cursorColor: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                WidgetAnimator(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loading == true ? const SpinKitCircle(color: ascent,size: 70,) : Container(
                          height: 40,
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
                              child: const Text('Send verification code',style: TextStyle(
                                  fontSize: 17,
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
