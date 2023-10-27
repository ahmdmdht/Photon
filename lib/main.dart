import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app.dart';
import 'package:flutterquiz/utils/send_telgram_message.dart';
import 'package:logger/logger.dart';

//Elite quiz - v-2.0.5
var logger = Logger();

void main() async {
  runApp(await initializeApp());
}
