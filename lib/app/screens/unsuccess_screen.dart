import 'package:cosmos_test/app/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class UnsuccessfulScreen extends StatefulWidget {
  final List<dynamic> games;
  final List<dynamic> consoles;

  const UnsuccessfulScreen({Key? key, required this.games, required this.consoles})
      : super(key: key);

  @override
  _UnsuccessfulScreenState createState() => _UnsuccessfulScreenState();
}

class _UnsuccessfulScreenState extends State<UnsuccessfulScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Unsuccessful')),
    );
  }
}
