import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ElapsedTime {
  final int centenas;
  final int segundos;
  final int minutos;

  ElapsedTime({
    this.centenas,
    this.segundos,
    this.minutos,
  });
}

class Dependencies {

  final List<ValueChanged<ElapsedTime>> timerListeners = <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle = const TextStyle(fontSize: 90.0, fontFamily: "Arial");
  final Stopwatch stopwatch = new Stopwatch();
  final int taxaRefreshMilissegundos= 30;
}

class TimerPage extends StatefulWidget {
  TimerPage({Key key}) : super(key: key);

  TimerPageState createState() => new TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  final Dependencies dependencies = new Dependencies();
  final cliente = <int>[];

  int i = 1;

  void btnEsquerdoPressionado() {

    final int segundo = (dependencies.stopwatch.elapsed.inSeconds) % 60;
    final int minuto = (dependencies.stopwatch.elapsed.inMinutes);

    final tempo = ('${minuto}:${segundo}');
//    final int media = (segundo % cliente.reduce(max));



    setState(() {
      if (dependencies.stopwatch.isRunning) {
        cliente.add(i++);
        print("Cliente: ${cliente.reduce(max)}\n");
        print("Tempo de espera na fila: ${tempo}\n");
//        print("media:  ${media}");

      } else {


        dependencies.stopwatch.reset();
        cliente.clear();
        i = 1;


      }
    });
  }

  void btnDireitoPressionado() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();

      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  void btnDados(){

    final int segundo = (dependencies.stopwatch.elapsed.inSeconds) % 60;
    final int minuto = (dependencies.stopwatch.elapsed.inMinutes);
    final tempo = ('${minuto}:${segundo}');
    final int tempoMedio = (segundo % cliente.reduce(max));

    print("Total de Clientes: ${cliente.reduce(max)}\n");
    print("Tempo total elapsado: ${tempo}\n");
    print("Tempo médio de espera: ${tempoMedio}\n");
  }

  Widget buildFloatingButton(String text, VoidCallback callback) {
    TextStyle roundTextStyle = const TextStyle(fontSize: 16.0, color: Colors.white);
    return new FloatingActionButton(
        child: new Text(text, style: roundTextStyle),
        onPressed: callback);
  }



  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
          child: new TimerText(dependencies: dependencies),
        ),
        new Expanded(
          flex: 0,
          child: new Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFloatingButton(dependencies.stopwatch.isRunning ? "Registrar" : "Resetar", btnEsquerdoPressionado),
                buildFloatingButton(dependencies.stopwatch.isRunning ? "Parar" : "Iniciar", btnDireitoPressionado),
                buildFloatingButton("Registros", btnDados)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() => new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: dependencies.taxaRefreshMilissegundos), callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int centenas = (milliseconds / 10).truncate();
      final int segundos = (centenas / 100).truncate();
      final int minutos = (segundos / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        centenas: centenas,
        segundos: segundos,
        minutos: minutos,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new SizedBox(
            height: 72.0,
            child: new MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
        new RepaintBoundary(
          child: new SizedBox(
            height: 72.0,
            child: new Hundreds(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() => new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutos = 0;
  int segundos = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutos != minutos || elapsed.segundos != segundos) {
      setState(() {
        minutos = elapsed.minutos;
        segundos = elapsed.segundos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutos % 60).toString().padLeft(2, '0');
    String secondsStr = (segundos % 60).toString().padLeft(2, '0');
    return new Text('$minutesStr:$secondsStr.', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});
  final Dependencies dependencies;

  int centenas = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.centenas != centenas) {
      setState(() {
        centenas = elapsed.centenas;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (centenas % 100).toString().padLeft(2, '00');
    return new Text(hundredsStr, style: dependencies.textStyle);
  }
}
