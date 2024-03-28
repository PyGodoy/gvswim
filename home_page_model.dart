import 'package:flutter/material.dart';

class HomePageModel {
  TextEditingController? textController1;
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController2;
  FocusNode? textFieldFocusNode2;
  int timerMilliseconds = 0;
  String timerValue = '';
  final TextEditingController _validatorController = TextEditingController();

  Validator get textController1Validator =>
      (String? value) => _validatorController.text;

  Validator get textController2Validator =>
      (String? value) => _validatorController.text;

  final TextEditingController _unfocusController = TextEditingController();

  FocusNode get unfocusNode => FocusNode();

  void dispose() {
    textController1?.dispose();
    textFieldFocusNode1?.dispose();
    textController2?.dispose();
    textFieldFocusNode2?.dispose();
    _unfocusController.dispose();
  }
}

typedef Validator = String? Function(String? value);

HomePageModel createModel(BuildContext context) {
  return HomePageModel();
}
