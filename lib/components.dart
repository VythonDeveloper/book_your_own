import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

showLoading(BuildContext context) {
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(child: alert, onWillPop: () async => false);
    },
  );
}

showSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      msg,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    backgroundColor: Colors.blueGrey,
  ));
}

class CustomTextField extends StatelessWidget {
  String label;
  bool obsecureText;
  int maxLength;
  TextCapitalization textCapitalization;
  TextEditingController textEditingController;
  TextInputType keyboardType;
  String? Function(String?) validator;
  CustomTextField({
    required this.keyboardType,
    required this.label,
    required this.maxLength,
    required this.obsecureText,
    required this.textCapitalization,
    required this.textEditingController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade600.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            enableIMEPersonalizedLearning: true,
            enableSuggestions: true,
            controller: textEditingController,
            obscureText: obsecureText,
            textCapitalization: textCapitalization,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}

scratcher(context) {
  return Scratcher(
    color: Colors.cyan,
    accuracy: ScratchAccuracy.low,
    threshold: 30,
    brushSize: 40,
    onThreshold: () {
      // setState(() {
      //   _opacity = 1;
      // });
    },
    child: AnimatedOpacity(
      duration: Duration(milliseconds: 100),
      opacity: 0.5,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            Text(
              "Hurray! you won",
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
                child: Image.asset(
              "assets/gift.png",
            ))
          ],
        ),
      ),
    ),
  );
}
