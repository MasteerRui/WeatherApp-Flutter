import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' show asin, cos, pi, sqrt;
import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/extensions/capitaliza.dart';
import 'package:weather/pages/main_pages/homepage.dart';
import '../../models/models.dart';
import '../../models/weatherModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../service/dart_service.dart';

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
  bool edit = false;
  bool enabled = false;
  LocationData? _locationData;
  final _dataService = DataService();
  WeatherResponse? _response;
  LocationData? _previousLocationData;

  void _search(long, lat) async {
    final response = await _dataService.getWeather(long, lat);
    setState(() => _response = response);
  }

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
    _determinePosition();
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

  void _determinePosition() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      enabled = true;
    });
    LocationData _previousLocationData;

    LocationData _currentLocationData = await location.getLocation();

    location.onLocationChanged.listen((LocationData currentLocation) {
      double distanceInMeters = _calculateDistance(
          _currentLocationData.latitude,
          _currentLocationData.longitude,
          currentLocation.latitude,
          currentLocation.longitude);
      if (distanceInMeters > 500) {
        // change threshold as required
        _currentLocationData = currentLocation;
        _search(_currentLocationData.longitude, _currentLocationData.latitude);
      }
    });

    _previousLocationData = _currentLocationData;
    _search(_previousLocationData.longitude, _previousLocationData.latitude);
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    final p = pi / 180;
    final c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
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
        actions: [
          edit
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      edit = false;
                    });
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ))
              : IconButton(
                  onPressed: () {
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 23.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border:
                                  Border.all(color: Colors.white12, width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                            height: MediaQuery.of(context).size.height - 600,
                            child: Column(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 9, bottom: 4),
                                    child: DefaultTextStyle(
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      child: Text(
                                        'Settings',
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)),
                                    color: Color.fromARGB(60, 49, 49, 49),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                          child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: DefaultTextStyle(
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  child: Text('Edit List')),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  edit = true;
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              icon: Icon(
                                                CupertinoIcons.pencil,
                                                color: Colors.white,
                                              ))
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                              )
                            ]),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    CupertinoIcons.ellipsis_circle,
                    color: Colors.white,
                  ))
        ],
      ),
      body: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                          final country = filteredCities[index]['country_long'];
                          final state =
                              filteredCities[index]['admin_level_1_long'];
                          final teste = '$cityName, $state, $country';

                          final query = _searchController.text.toLowerCase();
                          final matchIndex = teste.toLowerCase().indexOf(query);

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
                              saveCityIds(filteredCities[index]['owm_city_id']);
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
                    itemCount:
                        enabled ? cityWeather.length + 1 : cityWeather.length,
                    itemBuilder: (ctx, index) {
                      if (index == 0 && enabled) {
                        return _response != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topLeft,
                                      children: [
                                        Ink.image(
                                          image: const AssetImage(
                                              'assets/images/04d.jpeg'),
                                          height: 115,
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
                                                          cityWeather:
                                                              cityWeather,
                                                          indexx: index,
                                                          loc: true,
                                                          response: _response,
                                                        )),
                                              );
                                            },
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      14.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'My Location',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          Lottie.asset(
                                                              'assets/animations/greenn.json',
                                                              repeat: true,
                                                              reverse: true,
                                                              height: 25)
                                                        ],
                                                      ),
                                                      Text(
                                                        _response!.cityName
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 20),
                                                        child: Text(
                                                          _response!.weatherInfo
                                                              .description
                                                              .toTitleCase(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 22),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Container(
                                                      width: 80,
                                                      height: 78,
                                                      color: Colors.transparent,
                                                      child: Stack(
                                                        children: [
                                                          BackdropFilter(
                                                            filter: ImageFilter
                                                                .blur(
                                                              sigmaX: 9.0,
                                                              sigmaY: 9.0,
                                                            ),
                                                            child: Container(),
                                                          ),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.13)),
                                                              gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                  colors: [
                                                                    //begin color
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.15),
                                                                    //end color
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.05),
                                                                  ]),
                                                            ),
                                                          ),
                                                          //child ==> the first/top layer of stack
                                                          Center(
                                                              child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Text(
                                                                _response!
                                                                        .tempInfo
                                                                        .temperature
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    '\u00B0',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        28,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'H:' +
                                                                        _response!
                                                                            .tempInfo
                                                                            .temperature
                                                                            .toStringAsFixed(0) +
                                                                        '\u00B0',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    'L:' +
                                                                        _response!
                                                                            .tempInfo
                                                                            .temperature
                                                                            .toStringAsFixed(0) +
                                                                        '\u00B0',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                      ]),
                                ),
                              )
                            : Container();
                      } else {
                        int cityIndex = enabled ? index - 1 : index;
                        return edit == false
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        maintainState: true,
                                        builder: (context) => HomePage(
                                              cityWeather: cityWeather,
                                              indexx: index,
                                              loc: true,
                                              response: _response,
                                            )),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.topLeft,
                                        children: [
                                          Ink.image(
                                            image: const AssetImage(
                                                'assets/images/04d.jpeg'),
                                            height: 115,
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
                                                            cityWeather:
                                                                cityWeather,
                                                            indexx: index,
                                                            loc: true,
                                                            response: _response,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          cityWeather[cityIndex]
                                                              .cityName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        UnixTimestampClock(
                                                          timezone: cityWeather[
                                                                  cityIndex]
                                                              .cityTimezone
                                                              .toInt(),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 20),
                                                          child: Text(
                                                            cityWeather[
                                                                    cityIndex]
                                                                .cityTempDesc
                                                                .toTitleCase(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 22),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Container(
                                                        width: 80,
                                                        height: 78,
                                                        color:
                                                            Colors.transparent,
                                                        child: Stack(
                                                          children: [
                                                            BackdropFilter(
                                                              filter:
                                                                  ImageFilter
                                                                      .blur(
                                                                sigmaX: 9.0,
                                                                sigmaY: 9.0,
                                                              ),
                                                              child:
                                                                  Container(),
                                                            ),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.13)),
                                                                gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    colors: [
                                                                      //begin color
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.15),
                                                                      //end color
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.05),
                                                                    ]),
                                                              ),
                                                            ),
                                                            //child ==> the first/top layer of stack
                                                            Center(
                                                                child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  cityWeather[cityIndex]
                                                                          .cityTemp
                                                                          .toStringAsFixed(
                                                                              0) +
                                                                      '\u00B0',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          28,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      'H:' +
                                                                          cityWeather[cityIndex]
                                                                              .cityHtemp
                                                                              .toStringAsFixed(0) +
                                                                          '\u00B0',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(
                                                                      'L:' +
                                                                          cityWeather[cityIndex]
                                                                              .cityLtemp
                                                                              .toStringAsFixed(0) +
                                                                          '\u00B0',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ]),
                                  ),
                                ))
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.topLeft,
                                        children: [
                                          Ink.image(
                                            image: const AssetImage(
                                                'assets/images/04d.jpeg'),
                                            height: 75,
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
                                                            cityWeather:
                                                                cityWeather,
                                                            indexx: index,
                                                            loc: true,
                                                            response: _response,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          cityWeather[cityIndex]
                                                              .cityName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        UnixTimestampClock(
                                                          timezone: cityWeather[
                                                                  cityIndex]
                                                              .cityTimezone
                                                              .toInt(),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 22),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Container(
                                                        width: 45,
                                                        height: 45,
                                                        color:
                                                            Colors.transparent,
                                                        child: Stack(
                                                          children: [
                                                            BackdropFilter(
                                                              filter:
                                                                  ImageFilter
                                                                      .blur(
                                                                sigmaX: 9.0,
                                                                sigmaY: 9.0,
                                                              ),
                                                              child:
                                                                  Container(),
                                                            ),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.13)),
                                                                gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    colors: [
                                                                      //begin color
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.15),
                                                                      //end color
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.05),
                                                                    ]),
                                                              ),
                                                            ),

                                                            //child ==> the first/top layer of stack
                                                            Center(
                                                                child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  cityWeather[cityIndex]
                                                                          .cityTemp
                                                                          .toStringAsFixed(
                                                                              0) +
                                                                      '\u00B0',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 75,
                                                    width: 59,
                                                    color: Colors.red,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          removeCityIds(
                                                              cityWeather[
                                                                      cityIndex]
                                                                  .cityId
                                                                  .toString());
                                                        },
                                                        icon: Icon(
                                                          CupertinoIcons.delete,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ]),
                                  ),
                                ));
                      }
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class UnixTimestampClock extends StatefulWidget {
  final int timezone;
  UnixTimestampClock({Key? key, required this.timezone}) : super(key: key);

  @override
  _UnixTimestampClockState createState() => _UnixTimestampClockState();
}

class _UnixTimestampClockState extends State<UnixTimestampClock> {
  late Timer _timer;
  late DateTime _dateTime;
  var _timezone = 0;

  @override
  void initState() {
    super.initState();
    _timezone = widget.timezone;
    _timer = Timer.periodic(Duration(seconds: 1), _updateDateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UnixTimestampClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timezone != oldWidget.timezone) {
      setState(() {
        _timezone = widget.timezone;
      });
    }
  }

  void _updateDateTime(Timer timer) {
    setState(() {
      _dateTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    _dateTime = DateTime.now();
    var date = _dateTime.add(Duration(
        seconds: _timezone.toInt() - DateTime.now().timeZoneOffset.inSeconds));
    var formattedTime = DateFormat.Hm().format(date);
    return Text(
      formattedTime,
      style: TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
    );
  }
}
