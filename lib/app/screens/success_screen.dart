import 'package:cosmos_test/app/screens/details_screen.dart';
import 'package:cosmos_test/app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/success.png'),
              Text(
                'Заказ оформлен',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'В ближайшее время наш менеджер свяжется с вами',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 32,),
              InkWell(
                child: Container(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Go back'),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.white),
                          foregroundColor: WidgetStatePropertyAll(
                            Color(0xFF7281C6),
                          ),
                          fixedSize: WidgetStateProperty.all(Size(
                              MediaQuery.of(context).size.width * 0.9, MediaQuery.of(context).size.width * 0.15,)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      ElevatedButton(
                        onPressed: () {
                          Dio dio = Dio();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (c) => HomeScreen(dio: dio)),
                                  (route) => false);
                        },
                        child: Text('Go to main menu'),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Color(0xFF7281C6)),
                          foregroundColor: WidgetStatePropertyAll(
                            Colors.white,
                          ),
                          fixedSize: WidgetStateProperty.all(Size(
                              MediaQuery.of(context).size.width * 0.9,  MediaQuery.of(context).size.width * 0.15,)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
