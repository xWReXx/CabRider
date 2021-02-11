import 'package:cab_rider/screens/loginscreen.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/widgets/progress.dart';
import 'package:cab_rider/widgets/taxibutton.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../brand_colors.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'registration';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passController = TextEditingController();

  void showSnackbar(String title) {
    final snackbar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void registerUser() async {
    try {
      showDialog(
          context: context,
          builder: (BuildContext context) => ProgressDialog(
                status: 'Registering Your Account',
              ));
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: emailController.text, password: passController.text);
      if (userCredential.user != null) {
        DatabaseReference newUserRef = FirebaseDatabase.instance
            .reference()
            .child('users/${_auth.currentUser.uid}');

        Map userMap = {
          'Full Name': fullNameController.text,
          'Email': emailController.text,
          'Phone': phoneController.text,
        };
        newUserRef.set(userMap);
        Navigator.pushNamedAndRemoveUntil(
            context, MainPage.id, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackbar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackbar('The account already exists for that email.');
      }
    } catch (e) {
      showSnackbar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70,
                ),
                Image(
                  image: AssetImage('images/logo.png'),
                  height: 100,
                  width: 100,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Create a Rider Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                      ),
                      TextField(
                        controller: passController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TaxiButton(
                          title: 'Register',
                          color: BrandColors.colorGreen,
                          onPressed: () async {
                            var connectivityReult =
                                await Connectivity().checkConnectivity();

                            if (connectivityReult !=
                                    ConnectivityResult.mobile &&
                                connectivityReult != ConnectivityResult.wifi) {
                              showSnackbar('No internet connectivity');
                              return;
                            }

                            if (fullNameController.text.length < 3) {
                              showSnackbar('Please provide a valid name');
                              return;
                            }
                            if (phoneController.text.length < 10) {
                              showSnackbar(
                                  'Please provide a valid phone number');
                              return;
                            }
                            if (!emailController.text.contains('@')) {
                              showSnackbar(
                                  'Please provide a valid email address');
                              return;
                            }
                            if (passController.text.length < 8) {
                              showSnackbar(
                                  'Pasword must be 8 charcters in length');
                              return;
                            }
                            registerUser();
                          })
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.id, (route) => false);
                    },
                    child: Text('Already have an account, Log in'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
