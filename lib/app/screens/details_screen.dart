import 'package:draggable_home/draggable_home.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> game_or_console;

  const DetailsScreen({super.key, required this.game_or_console});

  @override
  State<DetailsScreen> createState() => DetailsScreenState();
}

class DetailsScreenState extends State<DetailsScreen> {
  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    print(widget.game_or_console);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: DraggableHome(
        alwaysShowLeadingAndAction: true,
        headerExpandedHeight: 0.5,
        title: Text(widget.game_or_console['name']),
        headerWidget: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.game_or_console['image'],
              fit: BoxFit.cover,
            ),
            Positioned(
                bottom: -20,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(
                          widget.game_or_console['price'].toString() + '₸',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: 0,
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                          width: MediaQuery.of(context).size.width - 40,
                          child: Text(
                            widget.game_or_console['name'],
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: Colors.white),
                          )
                      )
                    ],
                  ),
                )
            ),
          ],
        ),
        body: [
          Container(
            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SelectionArea(
                    child: SelectableText(
                      widget.game_or_console['description'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            print(widget.game_or_console['id']);
            final formData = FormData.fromMap({
              'game_id': widget.game_or_console['genre_id'] == null ? '' : widget.game_or_console['id'],
              'console_id': widget.game_or_console['genre_id'] == null ? widget.game_or_console['id'] : '',
              'quantity': 1,
              'cart_id': 1
            });
            var response = await dio.post(
              'http://192.168.0.103:8000/api/carts',
              data: formData,
              options: Options(
                  followRedirects: false,
                  validateStatus: (status) {
                    return status! < 500;
                  }),
            );
            if (response.statusCode == 201 || response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added successfully!'),
                ),
              );
            }
          } catch (e) {
            if (e is DioException) {
              print('Dio error!');
              print('STATUS: ${e.response?.statusCode}');
              print('DATA: ${e.response?.data}');
              print('HEADERS: ${e.response?.headers}');
            } else {
              print('Error: $e');
            }
          }
        },
        label: Text('Add to shopping cart'),
        icon: Icon(Icons.shopping_cart),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
