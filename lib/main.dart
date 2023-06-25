import 'package:flutter/material.dart';
import "dart:math" as math; // 乱数を使うために必要
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart'; // Streamを使うために必要
import 'package:flutter_native_splash/flutter_native_splash.dart'; // スプラッシュ画面を表示するために必要

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ルートウィジェット
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 1.0), //端末設定の文字サイズを無視する
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false, // デバッグモードのバナーを非表示にする
    );
  }
}

// 状態を持つウィジェット
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Stream
  final intStream = StreamController<int>();
  final stringStream =
      StreamController<String>.broadcast(); // 複数のクラスでlistenするためにbroadcast()を使う

  // 初期化時にコンストラクタにStreamを渡す
  @override
  void initState() {
    super.initState();
    Consumer(stringStream);
    Coordinator(intStream, stringStream);
    Generator(intStream);
  }

  // 終了時にStreamを解放する
  @override
  void dispose() {
    super.dispose();
    intStream.close();
    stringStream.close();
  }

  @override
  Widget build(BuildContext context) {
    // 数秒後にスプラッシュ画面を非表示にする
    Timer.periodic(const Duration(seconds: 1), (Timer _timer) async {
      FlutterNativeSplash.remove();
    });

    // 画面の構成を定義する
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ScreenUtilInit(
          // デザイン原案におけるデバイス画面の大きさ(単位：dp)
          designSize: const Size(360, 690),
          builder: (context, child) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                StreamBuilder<String>(
                  stream: stringStream.stream,
                  initialData: "",
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data}',
                      style: Theme.of(context).textTheme.headline4,
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

// Generatorクラス
// データの生成を担当する
class Generator {
  //コンストラクタでint型のStreamを受け取る
  Generator(StreamController<int> intStream) {
    // 10秒に1度、整数の乱数を作ってStreamに流す
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        int data = math.Random().nextInt(100);
        print("Generatorが$dataを作ったよ");
        intStream.sink.add(data);
      },
    );
  }
}

// Coordinatorクラス
// データの加工を担当する
class Coordinator {
  //コンストラクタでint型のStreamとString型のStreamを受け取る
  Coordinator(
      StreamController<int> intStream, StreamController<String> stringStream) {
    // 流れてきたものをintからStringにする
    intStream.stream.listen((data) async {
      String newData = data.toString();
      print("Coordinatorが$data(数値)から$newData(文字列)に変換したよ");
      stringStream.sink.add(newData);
    });
  }
}

// Consumerクラス
// データの利用を担当する
class Consumer {
  //コンストラクタでString型のStreamを受け取る
  Consumer(StreamController<String> stringStream) {
    // Streamをlistenしてデータが来たらターミナルに表示する
    stringStream.stream.listen((data) async {
      print("Consumerが$dataを使ったよ");
    });
  }
}
