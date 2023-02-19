import 'package:flutter/material.dart';
import 'package:weather/pages/main_pages/listpage.dart';
import 'dart:convert';
import '../../models/weatherModel.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.cityWeather,
      required this.indexx,
      required this.loc});

  final cityWeather;
  final indexx;
  final loc;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Weather> cityWeather = [];
  PageController? _pageController;
  bool? loca;
  @override
  void initState() {
    super.initState();
    cityWeather = widget.cityWeather;
    _pageController = PageController(initialPage: widget.indexx);
    loca = widget.loc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(
                    maintainState: true,
                    builder: (context) => const CityList()),
              );
            },
            icon: Icon(
              Icons.list_rounded,
              size: 25,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.settings,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.blueGrey,
        body: Stack(
          children: [
            PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    widget.loc ? cityWeather.length + 1 : cityWeather.length,
                controller: _pageController,
                pageSnapping: true,
                itemBuilder: (ctx, i) {
                  if (i == 0 && widget.loc) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/04d.jpeg"),
                            fit: BoxFit.cover),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('TESTE'),
                      ),
                    );
                  } else {
                    int cityIndex = widget.loc ? i - 1 : i;
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/04d.jpeg"),
                            fit: BoxFit.cover),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(cityWeather[cityIndex].cityName),
                      ),
                    );
                  }
                }),
          ],
        ));
  }
}
