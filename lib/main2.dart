import 'dart:convert';
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

void isloate1(SendPort sendPort) async {
  final dio = Dio();
  List data = [];
  for (int i = 0; i < 1000000; i++) {
    final response = await dio.get('https://randomuser.me/api/');
    data.add(response);
  }
  sendPort.send(data);
}

class _MainAppState extends State<MainApp> {
  final dio = Dio();
  ValueNotifier<String> normalState = ValueNotifier<String>("Normal");
  ValueNotifier<String> isolateState = ValueNotifier<String>("Isolate");
  ValueNotifier<List> apiData = ValueNotifier<List>([]);

  normal() async {
    final dio = Dio();
    List data = [];
    for (int i = 0; i < 1000000; i++) {
      final response = await dio.get('https://randomuser.me/api/');
      data.add(response);
    }
    return data;
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
                      apiData.value = await normal();
                      normalState.value = "Normal";
                      // debugPrint("$totoal");
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
                        apiData.value = list;
                      });
                    },
                    child: Text(value));
              },
              valueListenable: isolateState,
            ),
            ValueListenableBuilder(
              valueListenable: apiData,
              builder: (context, value, child) {
                return Expanded(
                  child: ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("12345"),
                        );
                      }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
