import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class GvswimModel {
  late TextEditingController textController1;
  late FocusNode textFieldFocusNode1;

  late TextEditingController textController2;
  late FocusNode textFieldFocusNode2;

  late TextEditingController textController3Minutes;
  late TextEditingController textController3Seconds;
  late FocusNode textFieldFocusNode3Minutes;
  late FocusNode textFieldFocusNode3Seconds;

  GvswimModel() {
    textController1 = TextEditingController();
    textFieldFocusNode1 = FocusNode();

    textController2 = TextEditingController();
    textFieldFocusNode2 = FocusNode();

    textController3Minutes = TextEditingController();
    textController3Seconds = TextEditingController();
    textFieldFocusNode3Minutes = FocusNode();
    textFieldFocusNode3Seconds = FocusNode();
  }

  void dispose() {
    textController1.dispose();
    textFieldFocusNode1.dispose();

    textController2.dispose();
    textFieldFocusNode2.dispose();

    textController3Minutes.dispose();
    textController3Seconds.dispose();
    textFieldFocusNode3Minutes.dispose();
    textFieldFocusNode3Seconds.dispose();
  }
}

class GvswimWidget extends StatefulWidget {
  const GvswimWidget({Key? key}) : super(key: key);

  @override
  State<GvswimWidget> createState() => _GvswimWidgetState();
}

class _GvswimWidgetState extends State<GvswimWidget> {
  late GvswimModel _model;
  late StopWatchTimer _timerController;

  @override
  void initState() {
    super.initState();
    _model = GvswimModel();
    _timerController = StopWatchTimer(
      mode: StopWatchMode.countUp,
      onChange: _updateWidget,
    );
  }

  void _updateWidget(int value) {
    if (mounted && _timerController.isRunning) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _timerController.dispose();
    super.dispose();
  }

  String _formattedTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = ((duration.inMilliseconds % 1000) / 10)
        .floor()
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds:$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _model.textFieldFocusNode1.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.textFieldFocusNode1)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFF0F5F9),
        appBar: AppBar(
          backgroundColor: Color(0xFFF0F5F9),
          automaticallyImplyLeading: false,
          title: Text(
            'GV SWIM',
            style: GoogleFonts.getFont(
              'Outfit',
              color: Color(0xFF161C24),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextFormField(
                  controller: _model.textController1,
                  focusNode: _model.textFieldFocusNode1,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Repetitions',
                    hintText: 'Enter number of reps...',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _model.textController2,
                  focusNode: _model.textFieldFocusNode2,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Meters',
                    hintText: 'Enter distance in meters...',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _model.textController3Minutes,
                        focusNode: _model.textFieldFocusNode3Minutes,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Minutes',
                          hintText: '00',
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _model.textController3Seconds,
                        focusNode: _model.textFieldFocusNode3Seconds,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Seconds',
                          hintText: '00',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_timerController.isRunning) {
                          _timerController.onStopTimer();
                        } else {
                          _timerController.onStartTimer();
                        }
                        setState(() {});
                      },
                      child: Text(
                        _timerController.isRunning ? 'Pause' : 'Start',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _timerController.onResetTimer();
                        setState(() {});
                      },
                      child: Text('Reset'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  _formattedTime(
                      Duration(milliseconds: _timerController.rawTime.value)),
                  style: GoogleFonts.getFont(
                    'Outfit',
                    color: Color(0xFF161C24),
                    fontSize: 57,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
