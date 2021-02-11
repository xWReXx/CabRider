import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/screens/registrationscreen.dart';
import 'package:cab_rider/widgets/progress.dart';
import 'package:cab_rider/widgets/taxibutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void showSnackbar(String title) {
    final snackbar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void login() async {
    try {
      showDialog(
          context: context,
          builder: (BuildContext context) => ProgressDialog(
                status: 'Logging In',
              ));
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      if (userCredential.user != null) {
        DatabaseReference userRef = FirebaseDatabase.instance
            .reference()
            .child('users/${userCredential.user.uid}');
        userRef.once().then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            Navigator.pushNamedAndRemoveUntil(
                context, MainPage.id, (route) => false);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        showSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackbar('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Sign in as a Rider',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                        controller: passwordController,
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
                        height: 40,
                      ),
                      TaxiButton(
                          title: 'Login',
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

                            if (!emailController.text.contains('@')) {
                              showSnackbar(
                                  'Please provide a valid email address');
                              return;
                            }
                            if (passwordController.text.length < 8) {
                              showSnackbar(
                                  'Pasword must be 8 charcters in length');
                              return;
                            }
                            login();
                          })
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RegistrationPage.id, (route) => false);
                    },
                    child: Text('Dont\'t have an account, sign up here'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
