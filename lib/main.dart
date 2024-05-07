import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // final dio = Dio();
  // final response = await dio.get('https://randomuser.me/api/');
  // print(response);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

void isloate1(SendPort sendPort) {
  int j = 0;
  for (int i = 0; i < 1000000000; i++) {
    j++;
  }
  sendPort.send(j);
}

class _MainAppState extends State<MainApp> {
  final dio = Dio();
  ValueNotifier<String> normalState = ValueNotifier<String>("Normal");
  ValueNotifier<String> isolateState = ValueNotifier<String>("Isolate");

  normal() {
    normalState.value = "loading";
    int j = 0;
    for (int i = 0; i < 1999999999; i++) {
      j++;
    }
    return j;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset("assets/giff.gif")),
            ValueListenableBuilder(
              builder: (context, value, _) {
                return ElevatedButton(
                    onPressed: () async {
                      normalState.value = "Loading";
                      int totoal = await normal();
                      normalState.value = "Normal";
                      debugPrint("$totoal");
                    },
                    child: Text(value));
              },
              valueListenable: normalState,
            ),
            ValueListenableBuilder(
              builder: (context, value, _) {
                return ElevatedButton(
                    onPressed: () async {
                      isolateState.value = "Loading";
                      final receivePort = ReceivePort();
                      await Isolate.spawn(isloate1, receivePort.sendPort);
                      receivePort.listen((list) {
                        debugPrint("========= $list");
                        isolateState.value = "Isolate";
                      });
                    },
                    child: Text(value));
              },
              valueListenable: isolateState,
            ),
            ElevatedButton(onPressed: () async {}, child: Text("kill")),
          ],
        ),
      ),
    );
  }
}
