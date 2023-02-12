import 'dart:convert';
import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:weather/pages/main_pages/homepage.dart';
import '../../models/weatherModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CityList extends StatefulWidget {
  const CityList({super.key});

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> filteredCities = [];
  Map<String, List<Map<String, dynamic>>> _searchIndex = {};
  TextEditingController _searchController = TextEditingController();
  bool searching = false;
  List<Weather> cityWeather = [];
  bool isLoading = true;

  Future<Object> fetchWeather() async {
    final prefs = await SharedPreferences.getInstance();
    cityWeather = [];
    List<dynamic> ctid = prefs.getStringList('cityIds') ?? [];
    String cittiesIds = ctid.join(',');
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/group?id=$cittiesIds&APPID=d89566b7541ecad9d211291d677951ba&units=metric'));

    if (response.statusCode == 200) {
      List<Weather> weatherData = [];
      Map<String, dynamic> values = json.decode(response.body);
      List<dynamic> list = values['list'];
      for (Map<String, dynamic> weather in list) {
        weatherData.add(Weather.fromJson(weather));
      }
      setState(() {
        cityWeather = weatherData;
      });
    }
    return cityWeather;
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _loadCities();
  }

  void _loadCities() async {
    String data = await rootBundle.loadString('assets/json/citys.json');
    List<dynamic> _cities = json.decode(data);
    setState(() {
      cities = _cities.map((city) => Map<String, dynamic>.from(city)).toList();
      filteredCities = cities;
      isLoading = false;

      // Populate the search index
      _searchIndex = {};
      for (var city in cities) {
        String name =
            '${city['owm_city_name']}, ${city['admin_level_1_long']}, ${city['country_long']}';
        if (name.isNotEmpty) {
          // check if name is not empty
          String initial = name.substring(0, 1).toLowerCase();
          if (_searchIndex[initial] == null) {
            _searchIndex[initial] = [];
          }
          _searchIndex[initial]?.add(city);
        }
      }
    });
  }

  void _filterCities(String query) {
    List<String> searchTerms = query.split(",");
    if (searchTerms.isNotEmpty && searchTerms[0].isNotEmpty) {
      String initial = searchTerms[0].toLowerCase().substring(0, 1);
      if (_searchIndex[initial] != null) {
        setState(() {
          filteredCities = _searchIndex[initial]!.where((city) {
            String cityName = city['owm_city_name'].toLowerCase();
            String stateName = city['admin_level_1_long'].toLowerCase();
            String countryName = city['country_long'].toLowerCase();
            for (var term in searchTerms) {
              if (term.trim().isNotEmpty &&
                  !cityName.contains(term.trim().toLowerCase()) &&
                  !stateName.contains(term.trim().toLowerCase()) &&
                  !countryName.contains(term.trim().toLowerCase())) {
                return false;
              }
            }
            return true;
          }).toList();
        });
      } else {
        setState(() {
          filteredCities = [];
        });
      }
    } else {
      setState(() {
        filteredCities = [];
      });
    }
  }

  Future<void> saveCityIds(String cityId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> cityIds = prefs.getStringList('cityIds') ?? <String>[];
    if (!cityIds.contains(cityId)) {
      cityIds.add(cityId);
      await prefs.setStringList('cityIds', cityIds);
      fetchWeather();
    }
  }

  Future<void> removeCityIds(String cityId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> cityIds = prefs.getStringList('cityIds') ?? <String>[];
    if (cityIds.contains(cityId)) {
      cityIds.remove(cityId);
      await prefs.setStringList('cityIds', cityIds);
      fetchWeather();
      print(cityIds);
    }
  }

  Future<List<String>> getCityIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cityIds') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Weather App',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 13, right: 13),
              child: Container(
                child: CupertinoSearchTextField(
                  itemSize: 18,
                  placeholder: 'Search for a city',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                      inherit: false),
                  controller: _searchController,
                  onSuffixTap: () {
                    setState(() {
                      _searchController.text = '';
                      filteredCities = [];
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    isLoading ? _loadCities() : _filterCities(value);
                  },
                ),
              ),
            ),
            Flexible(
              child: _searchController.text.isNotEmpty
                  ? filteredCities.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: 30,
                          itemBuilder: (context, index) {
                            if (index >= filteredCities.length) {
                              return SizedBox.shrink();
                            }
                            final cityName =
                                filteredCities[index]['owm_city_name'];
                            final country =
                                filteredCities[index]['country_long'];
                            final state =
                                filteredCities[index]['admin_level_1_long'];
                            final teste = '$cityName, $state, $country';

                            final query = _searchController.text.toLowerCase();
                            final matchIndex =
                                teste.toLowerCase().indexOf(query);

                            if (matchIndex == -1) {
                              return SizedBox.shrink();
                            }

                            final before = teste.substring(0, matchIndex);
                            final match = teste.substring(
                                matchIndex, matchIndex + query.length);
                            final after =
                                teste.substring(matchIndex + query.length);

                            return GestureDetector(
                              onTap: () {
                                saveCityIds(
                                    filteredCities[index]['owm_city_id']);
                                setState(() {
                                  _searchController.text = '';
                                  filteredCities = [];
                                });
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: before,
                                        style: TextStyle(color: Colors.white12),
                                      ),
                                      TextSpan(
                                        text: match,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: after,
                                        style: TextStyle(color: Colors.white12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                      : Text(_searchController.text)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: cityWeather.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onDoubleTap: () {
                              removeCityIds(
                                  cityWeather[index].cityId.toString());
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    maintainState: true,
                                    builder: (context) => HomePage(
                                          cityid: cityWeather[index]
                                              .cityId
                                              .toDouble(),
                                        )),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Ink.image(
                                        image: const AssetImage(
                                            'assets/images/04d.jpeg'),
                                        height: 113,
                                        fit: BoxFit.cover,
                                        child: InkWell(
                                          hoverColor: Colors.transparent,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  maintainState: true,
                                                  builder: (context) =>
                                                      HomePage(
                                                        cityid:
                                                            cityWeather[index]
                                                                .cityId
                                                                .toDouble(),
                                                      )),
                                            );
                                          },
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(13.0),
                                            child: Text(
                                              cityWeather[index].cityName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 21),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                color: Colors.black,
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ]),
                              ),
                            ));
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
