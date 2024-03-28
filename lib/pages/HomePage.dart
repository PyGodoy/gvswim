import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late TextEditingController _textController1;
  late TextEditingController _textController2;
  late FocusNode _textFieldFocusNode1;
  late FocusNode _textFieldFocusNode2;
  late StopWatchTimer _timerController;
  late int _timerMilliseconds;
  late String _timerValue;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _textController1 = TextEditingController();
    _textFieldFocusNode1 = FocusNode();

    _textController2 = TextEditingController();
    _textFieldFocusNode2 = FocusNode();

    _timerController = StopWatchTimer();
    _timerMilliseconds = 0;
    _timerValue = '';

    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textFieldFocusNode1.dispose();

    _textController2.dispose();
    _textFieldFocusNode2.dispose();

    _timerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_textFieldFocusNode1.canRequestFocus) {
          FocusScope.of(context).requestFocus(_textFieldFocusNode1);
        } else if (_textFieldFocusNode2.canRequestFocus) {
          FocusScope.of(context).requestFocus(_textFieldFocusNode2);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: Text(
            'GV SWIM',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional(-1, -1),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 50, 0, 0),
                  child: Text(
                    'Repetições',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-0.3, -1.2),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 228, 0),
                  child: Container(
                    width: 100,
                    child: TextFormField(
                      controller: _textController1,
                      focusNode: _textFieldFocusNode1,
                      autofocus: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: '0',
                        labelStyle: Theme.of(context).textTheme.subtitle1,
                        hintStyle: Theme.of(context).textTheme.subtitle1,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .bodyText1!
                                .color!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                      validator: (value) {
                        // Add your validation logic here
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-1, -1),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 600),
                  child: Text(
                    'Metragem',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, -1),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                  child: Container(
                    width: 100,
                    child: TextFormField(
                      controller: _textController2,
                      focusNode: _textFieldFocusNode2,
                      autofocus: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: 'Label here...',
                        labelStyle: Theme.of(context).textTheme.subtitle1,
                        hintStyle: Theme.of(context).textTheme.subtitle1,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .subtitle1!
                                .color!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).errorColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyText1,
                      validator: (value) {
                        // Add your validation logic here
                      },
                    ),
                  ),
                ),
              ),
              TimerWidget(
                timerController: _timerController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerWidget extends StatelessWidget {
  const TimerWidget({
    Key? key,
    required StopWatchTimer timerController,
  })  : _timerController = timerController,
        super(key: key);

  final StopWatchTimer _timerController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<int>(
        stream: _timerController.rawTime,
        initialData: _timerController.rawTime.value,
        builder: (context, snapshot) {
          final value = snapshot.data ?? 0;
          final displayTime = StopWatchTimer.getDisplayTime(
            value,
            hours: false,
            milliSecond: false,
          );
          return Text(
            displayTime,
            style: Theme.of(context).textTheme.headline5,
          );
        },
      ),
    );
  }
}
