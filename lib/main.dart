import 'package:flutter/material.dart';
import 'package:gv_swim/pages/CreatorInfoPage.dart';
import 'package:gv_swim/pages/gvswim.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => GvswimWidget(),
      '/creatorInfo': (context) => CreatorInfoPage(),
    },
  ));
}
