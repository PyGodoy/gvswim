import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

late AudioPlayer advancedPlayer;

class GvswimWidget extends StatefulWidget {
  const GvswimWidget({Key? key}) : super(key: key);

  @override
  State<GvswimWidget> createState() => _GvswimWidgetState();
}

class _GvswimWidgetState extends State<GvswimWidget> {
  late GvswimModel _model;
  late StopWatchTimer _timerController;
  List<String> trainingInfoList = [];
  String repetitionsLabel = 'Repetições';
  String metersLabel = 'Metros';
  String intervalLabel = 'Intervalo';
  bool soundPlayed = false;
  late AudioCache audioCache;

  @override
  void initState() {
    super.initState();
    _model = GvswimModel();
    _timerController = StopWatchTimer(
      mode: StopWatchMode.countUp,
      onChange: _updateWidget,
    );
    advancedPlayer = AudioPlayer();
  }

  Duration _calculateCurrentIntervalTime() {
    if (trainingInfoList.isNotEmpty) {
      final currentTraining = trainingInfoList.first;
      final currentInterval = currentTraining.split('x')[2].trim();
      final minutes = int.parse(currentInterval.split(':')[0]);
      final seconds = int.parse(currentInterval.split(':')[1]);

      return Duration(minutes: minutes, seconds: seconds);
    }

    return Duration.zero;
  }

  void _updateWidget(int value) {
    if (mounted && _timerController.isRunning) {
      setState(() {
        final currentIntervalTime = _calculateCurrentIntervalTime();
        final playSoundTime =
            currentIntervalTime - Duration(seconds: 1, milliseconds: 730);

        if (_timerController.rawTime.value >= playSoundTime.inMilliseconds) {
          if (!soundPlayed) {
            _playSound();
            soundPlayed = true;
          }

          if (_timerController.rawTime.value >=
              currentIntervalTime.inMilliseconds) {
            _timerController.onResetTimer();
            _updateTraining();
            soundPlayed = false;
          }
        }
      });
    }
  }

  void _playSound() async {
    if (advancedPlayer.state == PlayerState.playing) {
      await advancedPlayer.stop();
    }
    final player = AudioPlayer();
    player.play(AssetSource("saida.mp3"));
  }

  void _updateTraining() {
    if (trainingInfoList.isNotEmpty) {
      final currentTraining = trainingInfoList.first;
      final currentRepetition = int.parse(currentTraining.split('x')[0]);

      if (currentRepetition > 1) {
        final newTraining =
            '${currentRepetition - 1}${currentTraining.substring(currentTraining.indexOf('x'))}';
        trainingInfoList[0] = newTraining;
        _timerController.onResetTimer(); // Reiniciar o timer
        _timerController.onStartTimer(); // Iniciar o novo timer
      } else {
        trainingInfoList.removeAt(0);
        if (trainingInfoList.isEmpty) {
          // Limpar a lista de treinos e parar o timer quando todos os treinos forem concluídos
          _timerController.onStopTimer();
          _timerController.setPresetTime(mSec: 0);
        }
      }
    }
    setState(() {});
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

  void _addTrainingInfo() {
    final repetitions = _model.textController1.text;
    final meters = _model.textController2.text;
    final minutes = _model.textController3Minutes.text;
    final seconds = _model.textController3Seconds.text;

    trainingInfoList.add('$repetitions x $meters x $minutes:$seconds');

    _model.textController1.clear();
    _model.textController2.clear();
    _model.textController3Minutes.clear();
    _model.textController3Seconds.clear();

    setState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    _timerController.dispose();
    advancedPlayer.dispose();
    super.dispose();
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
          actions: [
            Align(
              alignment: AlignmentDirectional(0, 0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.home,
                    color: Color(0xFF2797FF),
                    size: 24,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0,0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.info,
                    color: Color(0xFF2797FF),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context,"/creatorInfo");
                  },
                ),
              ),
            )
          ],
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
                    hintStyle: GoogleFonts.getFont(
                      'Manrope',
                      color: Color(0xFF161C24),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF2797FF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: GoogleFonts.getFont(
                    'Manrope',
                    color: Color(0xFF161C24),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _model.textController2,
                  focusNode: _model.textFieldFocusNode2,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Meters',
                    hintText: 'Enter distance in meters...',
                    hintStyle: GoogleFonts.getFont(
                      'Manrope',
                      color: Color(0xFF161C24),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF2797FF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: GoogleFonts.getFont(
                    'Manrope',
                    color: Color(0xFF161C24),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    return null;
                  },
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
                          hintStyle: GoogleFonts.getFont(
                            'Manrope',
                            color: Color(0xFF161C24),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2797FF),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: GoogleFonts.getFont(
                          'Manrope',
                          color: Color(0xFF161C24),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          return null;
                        },
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
                          hintStyle: GoogleFonts.getFont(
                            'Manrope',
                            color: Color(0xFF161C24),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2797FF),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0x00000000),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: GoogleFonts.getFont(
                          'Manrope',
                          color: Color(0xFF161C24),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addTrainingInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2797FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: GoogleFonts.getFont(
                      'Manrope',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                        setState(
                            () {}); // Atualiza o estado do widget após iniciar/pausar o cronômetro
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2797FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          _timerController.isRunning ? 'Pause' : 'Start',
                          style: GoogleFonts.getFont(
                            'Manrope',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _timerController
                            .onResetTimer(); // Resetar o cronômetro imediatamente
                        _updateWidget(0); // Atualizar o widget
                        setState(
                            () {}); // Adicionar setState para forçar a atualização do widget
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2797FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.getFont(
                            'Manrope',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
                SizedBox(height: 20),
                // ... (código anterior)

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Repetições',
                            style: GoogleFonts.getFont(
                              'Manrope',
                              color: Color(0xFF161C24),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Metros',
                            style: GoogleFonts.getFont(
                              'Manrope',
                              color: Color(0xFF161C24),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Intervalo',
                            style: GoogleFonts.getFont(
                              'Manrope',
                              color: Color(0xFF161C24),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: trainingInfoList.length,
                    itemBuilder: (context, index) {
                      final training = trainingInfoList[index];
                      final repetitions = training.split('x')[0];
                      final meters = training.split('x')[1];
                      final interval = training.split('x')[2];

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  repetitions,
                                  style: GoogleFonts.getFont(
                                    'Manrope',
                                    color: Color(0xFF161C24),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  meters,
                                  style: GoogleFonts.getFont(
                                    'Manrope',
                                    color: Color(0xFF161C24),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                  interval,
                                  style: GoogleFonts.getFont(
                                    'Manrope',
                                    color: Color(0xFF161C24),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Text(
                    'Training will start once you hit \'Start\'. The timer will reset and move to the next interval after each interval time is reached, until the training is completed.',
                    style: GoogleFonts.getFont(
                      'Manrope',
                      color: Color(0xFF636F81),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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