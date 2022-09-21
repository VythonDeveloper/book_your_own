import 'package:book_your_own/constants.dart';
import 'package:book_your_own/components.dart';
import 'package:book_your_own/dashboard_ui.dart';
import 'package:book_your_own/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterUi extends StatefulWidget {
  const RegisterUi({Key? key}) : super(key: key);

  @override
  _RegisterUiState createState() => _RegisterUiState();
}

class _RegisterUiState extends State<RegisterUi> {
  final fullname = TextEditingController();
  final mobile = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    PageRouteTransition.effect = TransitionEffect.fade;
  }

  @override
  void dispose() {
    super.dispose();
    fullname.dispose();
    mobile.dispose();
    password.dispose();
  }

  createAccount() {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });

    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    Constants.customerDetails['id'] = uniqueId;
    Constants.customerDetails['fullname'] = fullname.text;
    Constants.customerDetails['mobile'] = "+91" + mobile.text;
    Constants.customerDetails['password'] = password.text;
    Constants.customerDetails['registeredOn'] = int.parse(uniqueId);

    _firestore
        .collection("users")
        .where('mobile', isEqualTo: "+91" + mobile.text)
        .get()
        .then((value) async {
      if (value.size == 0) {
        _firestore
            .collection("users")
            .doc(uniqueId)
            .set(Constants.customerDetails);

        final pref = await _prefs;
        pref.setString("mobile", "+91" + mobile.text);
        pref.setString("password", password.text);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DashboardUI()));
      } else {
        showSnackBar(context, "Already an account with mobile number");
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    "./lib/assets/images/icon.png",
                    height: 120,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  CustomTextField(
                    label: 'Fullname',
                    obsecureText: false,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                    textEditingController: fullname,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This Field is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Mobile',
                    obsecureText: false,
                    maxLength: 10,
                    textCapitalization: TextCapitalization.none,
                    textEditingController: mobile,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This Field is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Password',
                    obsecureText: true,
                    maxLength: 6,
                    textCapitalization: TextCapitalization.none,
                    textEditingController: password,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 6) {
                        return 'Password must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        createAccount();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Colors.black,
                    elevation: 0,
                    highlightElevation: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginUi()));
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
