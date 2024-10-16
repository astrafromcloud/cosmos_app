import 'package:cosmos_test/app/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class GamesScreen extends StatefulWidget {
  final int genreId;
  final String genreName;

  const GamesScreen({Key? key, required this.genreId, required this.genreName})
      : super(key: key);

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List games = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGamesByGenre();
  }

  Future<void> fetchGamesByGenre() async {
    try {
      final response = await Dio().get(
          'http://192.168.0.103:8000/api/games?genre_id=${widget.genreId}');
      setState(() {
        games = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching games: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.genreName,
              style: TextStyle(
                  fontWeight: FontWeight.bold
              )
          ),
          backgroundColor: Colors.white,
            foregroundColor: Color(0xFF7281C6),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                shrinkWrap: true,
                primary: false,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 4 / 5),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              game_or_console: games[index],
                            ),
                          ),
                        ),
                        child: Card(
                            child: GridTile(
                                child: Column(children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              height: 150,
                              child: Image.network(
                                games[index]['image'],
                                fit: BoxFit.fill,
                              )),
                          Text(games[index]['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ]))),
                      ),
                  );
                },
                // Disable grid scroll
                physics: NeverScrollableScrollPhysics(),
              ));
  }
}
