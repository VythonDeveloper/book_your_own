import 'package:book_your_own/constants.dart';
import 'package:book_your_own/dashboard_ui.dart';
import 'package:book_your_own/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashUi extends StatefulWidget {
  const SplashUi({Key? key}) : super(key: key);

  @override
  State<SplashUi> createState() => _SplashUiState();
}

class _SplashUiState extends State<SplashUi> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    PageRouteTransition.effect = TransitionEffect.fade;
    _getExistingUserVerified();
  }

  _getExistingUserVerified() async {
    final SharedPreferences prefs = await _prefs;
    String mobile = (prefs.getString('mobile') ?? '0');
    String password = (prefs.getString('password') ?? "0");
    // print(mobile + ", " + password);
    _firestore
        .collection("users")
        .where('mobile', isEqualTo: mobile)
        .where('password', isEqualTo: password)
        .get()
        .then((value) {
      if (value.size > 0) {
        Constants.customerDetails = value.docs[0].data();
        PageRouteTransition.pushReplacement(context, DashboardUI());
      } else {
        PageRouteTransition.pushReplacement(context, RegisterUi());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Book Your Own",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 170),
              child: LinearProgressIndicator(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
