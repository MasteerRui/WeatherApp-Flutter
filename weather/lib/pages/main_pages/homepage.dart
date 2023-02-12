import 'package:flutter/material.dart';
import 'package:weather/pages/main_pages/listpage.dart';
import 'dart:convert';
import '../../models/weatherModel.dart';
import 'package:http/http.dart' as http;
import '../../models/weatherModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cityid});

  final double cityid;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
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
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/04d.jpeg"), fit: BoxFit.cover),
          ), // Foreground widget here
        ));
  }
}
