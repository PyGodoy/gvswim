import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
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
  final bool isDarkMode;
  final bool isLocked; // Adicionando o parâmetro isLocked
  final Function() toggleTheme;
  final Function() toggleLock;

  const GvswimWidget({
    Key? key,
    required this.isDarkMode,
    required this.isLocked, // Adicionando o parâmetro isLocked
    required this.toggleTheme,
    required this.toggleLock,
  }) : super(key: key);

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
    if (widget.isLocked) {
      return; // Impede a adição de informações se estiver bloqueado
    }

    final repetitions = _model.textController1.text;
    final meters = _model.textController2.text;
    var minutes = _model.textController3Minutes.text;
    var seconds = _model.textController3Seconds.text;

    // Verifica se os segundos têm apenas um dígito e adiciona um zero à frente, se necessário
    if (seconds.length == 1) {
      seconds = '0$seconds';
    }

    // Verifica se os minutos estão vazios e os preenche com "00"
    if (minutes.isEmpty) {
      minutes = '00';
    }

    // Verifica se os segundos estão vazios e os preenche com "00"
    if (seconds.isEmpty) {
      seconds = '00';
    }

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
    _enableSystemUI(); // Garante que a UI do sistema seja habilitada ao sair
    super.dispose();
  }

  void _disableSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  void _enableSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // Habilita a UI do sistema
    FlutterWindowManager.clearFlags; // Limpa todas as flags
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      _disableSystemUI(); // Desabilita a UI do sistema se estiver bloqueado
    } else {
      _enableSystemUI(); // Garante que a UI do sistema seja habilitada se não estiver bloqueado
    }

    return WillPopScope(
        onWillPop: () async {
          // Impede a ação de voltar (minimizar) se o aplicativo estiver bloqueado
          return !widget.isLocked;
        },
        child: Scaffold(
          backgroundColor: widget.isDarkMode ? Colors.black : Color(0xFFF0F5F9),
          appBar: AppBar(
            backgroundColor:
                widget.isDarkMode ? Colors.black : Color(0xFFF0F5F9),
            automaticallyImplyLeading: false,
            title: Text(
              'GV SWIM',
              style: GoogleFonts.getFont(
                'Outfit',
                color: widget.isDarkMode ? Colors.white : Color(0xFF161C24),
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IgnorePointer(
                ignoring: widget.isLocked, // Ignora toques se estiver bloqueado
                child: AnimatedCrossFade(
                  duration: Duration(milliseconds: 500),
                  crossFadeState: widget.isDarkMode
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: IconButton(
                    key: ValueKey<bool>(widget.isDarkMode),
                    icon: Icon(
                      Icons.wb_sunny,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: widget.isLocked
                        ? null
                        : () {
                            widget.toggleTheme();
                          },
                  ),
                  secondChild: IconButton(
                    key: ValueKey<bool>(widget.isDarkMode),
                    icon: Icon(
                      Icons.nightlight_round,
                      color: Color(0xFF2797FF),
                    ),
                    onPressed: widget.isLocked
                        ? null
                        : () {
                            widget.toggleTheme();
                          },
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: widget.isLocked, // Ignora toques se estiver bloqueado
                child: IconButton(
                  icon: Icon(
                    Icons.info,
                    color: widget.isDarkMode ? Colors.white : Color(0xFF2797FF),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/creatorInfo");
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.isLocked ? Icons.lock : Icons.lock_open,
                  color: widget.isDarkMode ? Colors.white : Color(0xFF2797FF),
                ),
                onPressed: () {
                  widget.toggleLock(); // Alternar o estado de bloqueio
                },
              ),
            ],
            centerTitle: false,
            elevation: 0,
          ),
          body: AbsorbPointer(
            absorbing: widget.isLocked, // Absorve toques se estiver bloqueado
            child: SafeArea(
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
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Repetitions',
                        hintText: 'Enter number of reps...',
                        hintStyle: GoogleFonts.getFont(
                          'Manrope',
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
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
                        color: widget.isDarkMode ? Colors.white : Colors.black,
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
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Meters',
                        hintText: 'Enter distance in meters...',
                        hintStyle: GoogleFonts.getFont(
                          'Manrope',
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
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
                        color: widget.isDarkMode ? Colors.white : Colors.black,
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
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
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
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
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
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
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
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                      _formattedTime(Duration(
                          milliseconds: _timerController.rawTime.value)),
                      style: GoogleFonts.getFont(
                        'Outfit',
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 57,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 250, // Altura máxima da tabela
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent!),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: 100, // Largura da célula DataColumn
                                child: Center(child: Text('Repetições')),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100, // Largura da célula DataColumn
                                child: Center(child: Text('Metros')),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100, // Largura da célula DataColumn
                                child: Center(child: Text('Intervalo')),
                              ),
                            ),
                          ],
                          rows: trainingInfoList.map((training) {
                            final repetitions = training.split('x')[0];
                            final meters = training.split('x')[1];
                            final interval = training.split('x')[2];
                            return DataRow(cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    repetitions,
                                    textAlign: TextAlign
                                        .center, // Centralizar horizontalmente
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    meters,
                                    textAlign: TextAlign
                                        .center, // Centralizar horizontalmente
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    interval,
                                    textAlign: TextAlign
                                        .center, // Centralizar horizontalmente
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
