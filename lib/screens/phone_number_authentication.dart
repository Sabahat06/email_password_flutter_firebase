import 'package:email_password_login/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'login_screen.dart';

class VerifyPhoneNumber extends StatefulWidget {
  const VerifyPhoneNumber({Key key}) : super(key: key);

  @override
  _VerifyPhoneNumberState createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends State<VerifyPhoneNumber> {
  // form key
  final _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool showOTPField = false.obs;
  String verficationIDReceived = '';

  // editing controller
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController otpController = new TextEditingController();

  // firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String errorMessage;


  @override
  Widget build(BuildContext context) {
    //email field
    final phoneField = TextFormField(
      autofocus: false,
      controller: phoneController,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please Enter Your Phone Number");
        }
        // reg expression for email validation
        if (!RegExp("r'\+994\s+\([0-9]{2}\)\s+[0-9]{3}\s+[0-9]{2}\s+[0-9]{2}'")
            .hasMatch(value)) {
          return ("Please Enter a valid Phone Number");
        }
        return null;
      },
      onSaved: (value) {
        phoneController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.phone),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Phone Number",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      )
    );

    final otpField = TextFormField(
      autofocus: false,
      controller: otpController,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please Enter verification code");
        }
        // reg expression for email validation
        if (!RegExp("").hasMatch(value)) {
          return ("Please Enter a valid verification code");
        }
        return null;
      },
      onSaved: (value) {
        otpController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.code_outlined),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "OTP code",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      )
    );

    final verifyButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if(showOTPField.value) {
            verifyOTP(otpController.text);
          } else {
            verifyPhoneNumber(phoneController.text);
          }
        },
        child: Text(
          "VERIFY",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        )
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 15),
                    SizedBox(height: 180, child: Image.asset("assets/logo.png", fit: BoxFit.contain,)),
                    Obx(() => showOTPField.value ? otpField : phoneField,),
                    SizedBox(height: 15),
                    Obx(() => isLoading.value ? Center(child: CircularProgressIndicator(),) : verifyButton),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // login function
  void verifyPhoneNumber(String number) async {
    isLoading.value = true;
    _auth.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) {
          print('Verification Completed');
          }
        );
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception.message);
      },
      codeSent: (String verificationID, int resendToken) {
        verficationIDReceived = verificationID;
        showOTPField.value = true;
      },
      codeAutoRetrievalTimeout: (String verificationID) {}
    );
    isLoading.value = false;
  }

  verifyOTP(String otp) async {
    isLoading.value = true;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verficationIDReceived, smsCode: otp);
    try {
      await _auth.signInWithCredential(credential).then((value) => {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()))
      });
    } on FirebaseAuthException catch (error) {
      // switch (error.code) {
      //   case "invalid-email":
      //     errorMessage = "Your email address appears to be malformed.";
      //     break;
      //   case "wrong-password":
      //     errorMessage = "Your password is wrong.";
      //     break;
      //   case "user-not-found":
      //     errorMessage = "User with this email doesn't exist.";
      //     break;
      //   case "user-disabled":
      //     errorMessage = "User with this email has been disabled.";
      //     break;
      //   case "too-many-requests":
      //     errorMessage = "Too many requests";
      //     break;
      //   case "operation-not-allowed":
      //     errorMessage = "Signing in with Email and Password is not enabled.";
      //     break;
      //   default:
      //     errorMessage = "An undefined Error happened.";
      // }
      Fluttertoast.showToast(msg: error.code);
      print(error.code);
    }

    isLoading.value = false;
  }
}
