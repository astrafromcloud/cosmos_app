import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cosmos_test/app/screens/game_screen.dart';
import 'package:cosmos_test/app/screens/cart_screen.dart';
import 'package:cosmos_test/app/screens/details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Dio dio;

  const HomeScreen({Key? key, required this.dio}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final GlobalKey<CartScreenState> cartScreenKey = GlobalKey<CartScreenState>();


class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> genres = [];
  List<dynamic> banners = [];
  List<dynamic> consoles = [];
  List<dynamic> games = [];
  List<String> cities = [];
  List<dynamic> cartItems = [];
  bool isLoading = true;
  String? selectedCity;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        widget.dio.get('http://192.168.0.103:8000/api/genres'),
        widget.dio.get('http://192.168.0.103:8000/api/banners/'),
        widget.dio.get('http://192.168.0.103:8000/api/consoles'),
        widget.dio.get('http://192.168.0.103:8000/api/cities'),
        widget.dio.get('http://192.168.0.103:8000/api/games'),
        widget.dio.get('http://192.168.0.103:8000/api/carts'),
      ]);

      setState(() {
        genres = results[0].data;
        banners = results[1].data;
        consoles = results[2].data;
        games = results[4].data;
        cartItems = results[5].data;
        cities = List<String>.from(results[3].data.map((city) => city['name']));
        selectedCity = cities.isNotEmpty ? cities.first : null;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _selectedIndex == 0 ? "Home" : "Cart",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: _selectedIndex == 0
          ? [
        TextButton(
          onPressed: !isLoading && cities.isNotEmpty
              ? _showCitySelectionModal
              : null,
          child: Text(
            selectedCity ?? "Select city",
            style: const TextStyle(color: Color(0xFF7281C6)),
          ),
        ),
      ]
          : [
        if (cartItems.isNotEmpty) TextButton(
          onPressed: () {
            cartScreenKey.currentState?.deleteAllCarts();
          },
          child: Text(
            'Clear the cart',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      backgroundColor: Color(0xFF7281C6),
      elevation: 5,
    );
  }


  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return CartScreen(
          key: cartScreenKey,
          games: games,
          consoles: consoles,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCarousel(),
          _buildSectionTitle("Games"),
          _buildGenreslist(),
          SizedBox(
            height: 8,
          ),
          _buildSectionTitle("Consoles"),
          _buildConsolesGrid(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF7281C6),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      items: banners.map((banner) => Image.network(banner['image'])).toList(),
      options: CarouselOptions(
        height: 150.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGenreslist() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) => _categoryButton(genres[index]),
      ),
    );
  }

  Widget _buildConsolesGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 4 / 5,
        ),
        itemCount: consoles.length,
        itemBuilder: (context, index) => InkWell(
          child: index % 2 == 0
              ? _consoleCard(consoles[index])
              : _consoleCardSecond(consoles[index]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                game_or_console: consoles[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(dynamic genre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesScreen(
              genreId: genre['id'],
              genreName: genre['name'],
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(genre['image'],
                  width: 150, height: 150, fit: BoxFit.cover),
              Container(
                width: 150,
                height: 150,
                color: Colors.black.withOpacity(0.5),
              ),
              Text(
                genre['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consoleCard(dynamic console) {
    return Card(
      child: Stack(
        children: [
          Positioned(
            right: 60,
            bottom: 80,
            child: Image.asset(
              'assets/kok.png',
              width: 200,
            ),
          ),
          Positioned(
            bottom: 60,
            child: Container(
              height: 150,
              width: 150,
              child: Image.network(
                console['image'],
                fit: BoxFit.contain,
                width: 150,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 140, 0, 0),
              child: Text(
                "Аренда " + console['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7281C6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _consoleCardSecond(dynamic console) {
    return Card(
      child: Stack(
        children: [
          Positioned(
            left: 100,
            bottom: 50,
            child: Image.asset(
              'assets/kok.png',
              width: 100,
            ),
          ),
          Positioned(
            bottom: 60,
            child: Container(
              height: 150,
              width: 150,
              child: Image.network(
                console['image'],
                fit: BoxFit.contain,
                width: 150,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 140, 0, 0),
              child: Text(
                "Аренда " + console['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7281C6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCitySelectionModal() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(cities[index]),
              onTap: () => Navigator.pop(context, cities[index]),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() => selectedCity = result);
    }
  }
}
