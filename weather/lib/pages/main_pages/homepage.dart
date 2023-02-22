import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cupertino_listview/cupertino_listview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:smooth_compass/utils/smooth_compass.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weather/extensions/capitaliza.dart';
import 'package:weather/models/weatherCurrentModel.dart';
import 'package:weather/models/weatherDailyModel.dart';
import 'package:weather/models/weatherHourlyModel.dart';
import 'package:weather/models/weatheralertsModel.dart';
import 'package:weather/pages/main_pages/listpage.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../models/models.dart';
import '../../models/weatherModel.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.cityWeather,
      required this.indexx,
      required this.loc,
      this.response});

  final cityWeather;
  final indexx;
  final loc;
  final response;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ScrollController> _scrollControllers = [];
  ScrollController? _scrollControllerr;
  double _shrinkOffset = 0;
  List<Weather> cityWeather = [];
  List<HourlyData> cityWeatherHr = [];
  List<DailyData> cityWeatherDy = [];
  List<WeatherCurrent> cityWeatherCu = [];
  List<AlertsData> cityWeatherAl = [];
  PageController? _pageController;
  WeatherResponse? _response;
  bool? loca;
  bool _isCollapsed = false;
  bool lastStatus = true;
  double height = 200;
  bool loading = true;
  bool loadingv2 = true;
  int cindex = 0;
  List<PaletteColor> colors = [];
  List<PaletteColor> colors2 = [];

  Future<Object> fetchWeather(lat, lon) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=ef5fcf1d7c5621b52cc80ce4f94be994&units=metric'));

    if (response.statusCode == 200) {
      List<HourlyData> weatherData = [];
      List<DailyData> weatherDataa = [];
      List<WeatherCurrent> weatherDataaa = [];
      List<AlertsData> weatherDataaaa = [];
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> dailyList = json["daily"];
      List<dynamic> hourlyList = json["hourly"];
      List<dynamic> alertsList = json["alerts"] ?? [];
      weatherDataaa.add(WeatherCurrent.fromJson(json));
      for (var alerts in alertsList) {
        print(alertsList);
        weatherDataaaa.add(AlertsData.fromJson(alerts));
      }
      for (var hourly in hourlyList) {
        weatherData.add(HourlyData.fromJson(hourly));
      }
      for (var daily in dailyList) {
        weatherDataa.add(DailyData.fromJson(daily));
      }
      setState(() {
        cityWeatherHr = weatherData;
        cityWeatherDy = weatherDataa;
        cityWeatherCu = weatherDataaa;
        cityWeatherAl = weatherDataaaa;
        loading = false;
      });

      return weatherData;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollControllers[cindex].hasClients &&
        _scrollControllers[cindex].offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    cityWeather = widget.cityWeather;
    _pageController = PageController(initialPage: widget.indexx);
    loca = widget.loc;
    cindex = widget.indexx;
    _response = widget.response;
    _scrollControllers = List.generate(
      widget.loc ? cityWeather.length + 1 : cityWeather.length,
      (index) => ScrollController(),
    );
    _scrollControllers[cindex] = ScrollController()
      ..addListener(_scrollListener);
    if (widget.indexx == 0 && widget.loc == true) {
      fetchWeather(_response!.locsInfo.lat.toDouble(),
          _response!.locsInfo.lon.toDouble());
    } else {
      fetchWeather(cityWeather[widget.indexx - 1].citylat.toDouble(),
          cityWeather[widget.indexx - 1].citylon.toDouble());
    }
  }

  @override
  void dispose() {
    _scrollControllers[widget.indexx].removeListener(_scrollListener);
    _scrollControllers[widget.indexx].dispose();
    super.dispose();
  }

  String getTime(final timeStamp) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    String x = DateFormat.H().format(time);
    return x;
  }

  String getDay(final day) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(day * 1000);
    String x = DateFormat.E().format(time);
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            Flexible(
              child: PageView.builder(
                  onPageChanged: (int) {
                    setState(() {
                      _isShrink;
                      _scrollControllers[widget.indexx]
                          .removeListener(_scrollListener);
                      _scrollControllers[int] = ScrollController()
                        ..addListener(_scrollListener);
                      loading = true;
                      cityWeatherHr = [];
                      cityWeatherDy = [];
                      cityWeatherCu = [];
                      cityWeatherAl = [];
                      cindex = int;
                    });
                    if (int == 0 && widget.loc == true) {
                      setState(() {
                        loading = true;
                      });
                      fetchWeather(_response!.locsInfo.lat.toDouble(),
                          _response!.locsInfo.lon.toDouble());
                    } else if (widget.loc == false) {
                      setState(() {
                        loading = true;
                      });
                      fetchWeather(cityWeather[int].citylat.toDouble(),
                          cityWeather[int].citylon.toDouble());
                    } else {
                      setState(() {
                        loading = true;
                      });
                      fetchWeather(cityWeather[int - 1].citylat.toDouble(),
                          cityWeather[int - 1].citylon.toDouble());
                    }
                  },
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
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/${_response!.weatherInfo.icon}.jpeg"),
                                fit: BoxFit.cover),
                          ),
                          child: NestedScrollView(
                              controller: _scrollControllers[i],
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) {
                                return [
                                  SliverAppBar(
                                    elevation: 0,
                                    surfaceTintColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    pinned: true,
                                    automaticallyImplyLeading: false,
                                    expandedHeight: 235,
                                    flexibleSpace: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.parallax,
                                      background: SafeArea(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 48),
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/icons/${_response!.weatherInfo.icon}.png'),
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                            Text(
                                              _response!.cityName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25),
                                            ),
                                            Text(
                                              _response!.tempInfo.temperature
                                                      .toStringAsFixed(0) +
                                                  '\u00B0' +
                                                  ' | ' +
                                                  _response!
                                                      .weatherInfo.description
                                                      .toTitleCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              'H:' +
                                                  _response!
                                                      .tempInfo.temperature
                                                      .toStringAsFixed(0) +
                                                  '\u00B0 ' +
                                                  ' L:' +
                                                  _response!
                                                      .tempInfo.temperature
                                                      .toStringAsFixed(0) +
                                                  '\u00B0',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    centerTitle: true,
                                    title: _isShrink
                                        ? Column(
                                            children: [
                                              Text(
                                                _response!.cityName,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                _response!.tempInfo.temperature
                                                        .toStringAsFixed(0) +
                                                    '\u00B0' +
                                                    ' | ' +
                                                    _response!
                                                        .weatherInfo.description
                                                        .toTitleCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          )
                                        : null,
                                  ),
                                  SliverOverlapAbsorber(
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                    sliver: SliverAppBar(
                                      surfaceTintColor: Colors.transparent,
                                      pinned: true,
                                      automaticallyImplyLeading: false,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ];
                              },
                              body: Padding(
                                padding: EdgeInsets.only(top: 77),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (!loading &&
                                          cityWeatherAl.length != 0) ...{
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: GestureDetector(
                                              onTap: () {
                                                showCupertinoModalPopup<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0,
                                                          vertical: 0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          16),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          16)),
                                                        ),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height -
                                                            500,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              9,
                                                                          bottom:
                                                                              4),
                                                                      child:
                                                                          DefaultTextStyle(
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        child:
                                                                            Text(
                                                                          'Alerts +',
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Container(
                                                                      width: double.infinity,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(9)),
                                                                        color: Color.fromARGB(
                                                                            60,
                                                                            49,
                                                                            49,
                                                                            49),
                                                                      ),
                                                                      child: SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: DefaultTextStyle(
                                                                                style: TextStyle(),
                                                                                child: Text('Event: ' + cityWeatherAl[0].sender_name),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: DefaultTextStyle(
                                                                                textAlign: TextAlign.start,
                                                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                                                                child: Text(
                                                                                  'Description: ' + cityWeatherAl[0].description,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )),
                                                                )
                                                              ]),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 110,
                                                child: Stack(
                                                  children: [
                                                    BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 10,
                                                          sigmaY: 51),
                                                      child: Container(
                                                        height: 110,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    CupertinoIcons
                                                                        .alarm,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .white54,
                                                                  ),
                                                                  Text(
                                                                    ' ALERTS',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white54,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 2,
                                                              color: Colors
                                                                  .white54,
                                                            ),
                                                            Flexible(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      cityWeatherAl[
                                                                              0]
                                                                          .sender_name,
                                                                      style: TextStyle(
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          color: Colors
                                                                              .white54,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      maxLines:
                                                                          1,
                                                                      cityWeatherAl[
                                                                              0]
                                                                          .description,
                                                                      style: TextStyle(
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          color: Colors
                                                                              .white70,
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      },
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, right: 22, left: 22),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            width: double.infinity,
                                            height: 173,
                                            child: Stack(
                                              children: [
                                                BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 51),
                                                  child: Container(
                                                    height: 173,
                                                    padding: EdgeInsets.all(5),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .clock,
                                                                size: 18,
                                                                color: Colors
                                                                    .white54,
                                                              ),
                                                              Text(
                                                                ' 24-HOURS FORECAST',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                          color: Colors.white54,
                                                        ),
                                                        Flexible(
                                                          child: loading
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      CupertinoActivityIndicator(),
                                                                )
                                                              : ListView
                                                                  .builder(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      shrinkWrap:
                                                                          true,
                                                                      scrollDirection:
                                                                          Axis
                                                                              .horizontal,
                                                                      itemCount: cityWeatherHr.length >
                                                                              24
                                                                          ? 24
                                                                          : cityWeatherHr
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return Container(
                                                                          padding:
                                                                              EdgeInsets.all(22),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  Text(getTime(cityWeatherHr[index].dt), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                                                ],
                                                                              ),
                                                                              Stack(
                                                                                alignment: AlignmentDirectional.bottomCenter,
                                                                                children: [
                                                                                  Image(
                                                                                    image: AssetImage("assets/icons/${cityWeatherHr[index].weather[0].icon}.png"),
                                                                                    height: 30,
                                                                                    width: 33,
                                                                                  ),
                                                                                  if (cityWeatherHr[index].rain! > 9) ...{
                                                                                    Container(
                                                                                      padding: EdgeInsets.all(0),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        color: Colors.black54,
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(1.0),
                                                                                        child: Text(
                                                                                          cityWeatherHr[index].rain!.toStringAsFixed(0) + '%',
                                                                                          style: TextStyle(color: Colors.lightBlue, fontSize: 12, fontWeight: FontWeight.w800),
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  },
                                                                                ],
                                                                              ),
                                                                              Text(
                                                                                cityWeatherHr[index].temp.toStringAsFixed(0) + '\u00B0',
                                                                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 22, vertical: 6),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            height: 415,
                                            child: Stack(
                                              children: [
                                                BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 51),
                                                  child: Container(
                                                    height: 415,
                                                    padding: EdgeInsets.all(5),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 8.0,
                                                                  left: 8.0,
                                                                  right: 8.0,
                                                                  bottom: 8.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .calendar,
                                                                size: 18,
                                                                color: Colors
                                                                    .white54,
                                                              ),
                                                              Text(
                                                                ' 8-DAY FORECAST',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                          color: Colors.white54,
                                                        ),
                                                        Flexible(
                                                          child: loading
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      CupertinoActivityIndicator(),
                                                                )
                                                              : ListView
                                                                  .separated(
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  scrollDirection:
                                                                      Axis.vertical,
                                                                  shrinkWrap:
                                                                      true,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  itemCount: cityWeatherDy
                                                                              .length >
                                                                          10
                                                                      ? 10
                                                                      : cityWeatherDy
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 8),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 80,
                                                                                child: Text(
                                                                                  getDay(cityWeatherDy[index].dt),
                                                                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                                                                                ),
                                                                              ),
                                                                              Stack(
                                                                                alignment: AlignmentDirectional.bottomCenter,
                                                                                children: [
                                                                                  Image(
                                                                                    image: AssetImage("assets/icons/${cityWeatherHr[index].weather[0].icon}.png"),
                                                                                    height: 30,
                                                                                    width: 33,
                                                                                  ),
                                                                                  if (cityWeatherHr[index].rain! > 9) ...{
                                                                                    Container(
                                                                                      padding: EdgeInsets.all(0),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        color: Colors.black54,
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(1.0),
                                                                                        child: Text(
                                                                                          cityWeatherDy[index].rain.toStringAsFixed(0) + '%',
                                                                                          style: TextStyle(color: Colors.lightBlue, fontSize: 12, fontWeight: FontWeight.w800),
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  },
                                                                                ],
                                                                              ),
                                                                              Text(
                                                                                cityWeatherDy[index].tempmax.toStringAsFixed(0) + '\u00B0 / ' + cityWeatherDy[index].tempmin.toStringAsFixed(0) + '\u00B0',
                                                                                style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    );
                                                                  },
                                                                  separatorBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8.0,
                                                                          right:
                                                                              8.0),
                                                                      child:
                                                                          Divider(
                                                                        height:
                                                                            0,
                                                                        color: Colors
                                                                            .white54,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22, right: 6),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .wind,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' WIND',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child:
                                                                      Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    Container(
                                                                  height: 120,
                                                                  width: 120,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image: AssetImage(
                                                                          'assets/images/compass.png'),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            CustomPaint(
                                                                          painter: WindDirectionPainter(_response!
                                                                              .windInfo
                                                                              .winddeg
                                                                              .toDouble()),
                                                                          size: Size(
                                                                              150,
                                                                              150),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                1,
                                                                            top:
                                                                                1.5),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              BackdropFilter(filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10)),
                                                                              Container(
                                                                                width: 45,
                                                                                height: 45,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  color: Colors.black54,
                                                                                ),
                                                                                child: Center(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        _response!.windInfo.windspeed.toStringAsFixed(0),
                                                                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                                                                                      ),
                                                                                      Text(
                                                                                        'km/h',
                                                                                        style: TextStyle(color: Colors.white.withOpacity(0.90), fontSize: 10, fontWeight: FontWeight.w900),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 2,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 22),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .eye_fill,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' VISIBILITY',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max: 50,
                                                                        initialValue: _response!
                                                                            .visibility
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            infoProperties: InfoProperties(
                                                                              mainLabelStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                                                              modifier: (percentage) {
                                                                                final roundedValue = percentage.ceil().toInt().toString();
                                                                                return '$roundedValue \km';
                                                                              },
                                                                            ),
                                                                            animationEnabled: true,
                                                                            angleRange: 360,
                                                                            startAngle: 90,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 5, handlerSize: 2),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [Colors.red, Colors.blueGrey])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22, right: 6, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .thermometer,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' FEELS LIKE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min:
                                                                            -100,
                                                                        max:
                                                                            100,
                                                                        initialValue: _response!
                                                                            .tempInfo
                                                                            .feelslike
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            angleRange: 360,
                                                                            spinnerMode: false,
                                                                            infoProperties: InfoProperties(
                                                                                mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                                modifier: (percentage) {
                                                                                  final roundedValue = percentage.ceil().toInt().toString();
                                                                                  return '$roundedValue' + '\u00B0';
                                                                                },
                                                                                bottomLabelText: "Feels Like",
                                                                                bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 8, handlerSize: 3),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [Colors.amber[600]!.withOpacity(0.54), Colors.blueGrey.withOpacity(0.54)])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 22, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .gauge,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' PRESSURE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max:
                                                                            2000,
                                                                        initialValue: _response!
                                                                            .tempInfo
                                                                            .pressure
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            infoProperties: InfoProperties(
                                                                                mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                                modifier: (percentage) {
                                                                                  var formatter = NumberFormat('#,##,000');
                                                                                  var fort = formatter.format(percentage);
                                                                                  final roundedValue = fort.toString();
                                                                                  return '$roundedValue';
                                                                                },
                                                                                bottomLabelText: "hPa",
                                                                                bottomLabelStyle: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 7, handlerSize: 6),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [
                                                                              Colors.white.withOpacity(1),
                                                                              Colors.white.withOpacity(0.54),
                                                                              Colors.transparent,
                                                                              Colors.transparent
                                                                            ])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22, right: 6, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .drop_fill,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' HUMIDITY',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max:
                                                                            100,
                                                                        initialValue: _response!
                                                                            .tempInfo
                                                                            .humidity
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            infoProperties: InfoProperties(
                                                                                mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                                modifier: (percentage) {
                                                                                  final roundedValue = percentage.ceil().toInt().toString();
                                                                                  return '$roundedValue%';
                                                                                },
                                                                                bottomLabelText: "Humidity",
                                                                                bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 8, handlerSize: 3),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [Colors.blueGrey, Colors.black54])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 22, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .sun_max_fill,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' UV INDEX',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max: 11,
                                                                        initialValue: loading
                                                                            ? 0
                                                                            : cityWeatherCu[0].cityUiv.toDouble(),
                                                                        appearance:
                                                                            CircularSliderAppearance(
                                                                          infoProperties: InfoProperties(
                                                                              mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                              modifier: (percentage) {
                                                                                final roundedValue = percentage.ceil().toInt().toString();
                                                                                return '$roundedValue';
                                                                              },
                                                                              bottomLabelText: "UV",
                                                                              bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                          animationEnabled:
                                                                              true,
                                                                          size:
                                                                              140,
                                                                          customWidths: CustomSliderWidths(
                                                                              progressBarWidth: 8,
                                                                              handlerSize: 3),
                                                                          customColors:
                                                                              CustomSliderColors(
                                                                            hideShadow:
                                                                                true,
                                                                            trackColor:
                                                                                Colors.white54,
                                                                            progressBarColors: [
                                                                              Colors.purple,
                                                                              Colors.redAccent,
                                                                              Colors.redAccent,
                                                                              Colors.redAccent,
                                                                              Colors.orange,
                                                                              Colors.orange,
                                                                              Colors.yellow,
                                                                              Colors.yellow,
                                                                              Colors.yellow,
                                                                              Colors.green,
                                                                              Colors.green,
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )));
                    } else {
                      int cityIndex = widget.loc ? i - 1 : i;
                      return Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/${cityWeather[cityIndex].cityIcon}.jpeg"),
                                fit: BoxFit.cover),
                          ),
                          child: NestedScrollView(
                              controller: _scrollControllers[i],
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) {
                                return [
                                  SliverAppBar(
                                    elevation: 0,
                                    surfaceTintColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    pinned: true,
                                    automaticallyImplyLeading: false,
                                    expandedHeight: 235,
                                    flexibleSpace: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.parallax,
                                      background: SafeArea(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 48),
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/icons/${cityWeather[cityIndex].cityIcon}.png'),
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                            Text(
                                              cityWeather[cityIndex].cityName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25),
                                            ),
                                            Text(
                                              cityWeather[cityIndex]
                                                      .cityTemp
                                                      .toStringAsFixed(0) +
                                                  '\u00B0' +
                                                  ' | ' +
                                                  cityWeather[cityIndex]
                                                      .cityTempDesc
                                                      .toTitleCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              'H:' +
                                                  cityWeather[cityIndex]
                                                      .cityHtemp
                                                      .toStringAsFixed(0) +
                                                  '\u00B0 ' +
                                                  ' L:' +
                                                  cityWeather[cityIndex]
                                                      .cityLtemp
                                                      .toStringAsFixed(0) +
                                                  '\u00B0',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    centerTitle: true,
                                    title: _isShrink
                                        ? Column(
                                            children: [
                                              Text(
                                                cityWeather[cityIndex].cityName,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                cityWeather[cityIndex]
                                                        .cityTemp
                                                        .toStringAsFixed(0) +
                                                    '\u00B0' +
                                                    ' | ' +
                                                    cityWeather[cityIndex]
                                                        .cityTempDesc
                                                        .toTitleCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          )
                                        : null,
                                  ),
                                  SliverOverlapAbsorber(
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                    sliver: SliverAppBar(
                                      surfaceTintColor: Colors.transparent,
                                      pinned: true,
                                      automaticallyImplyLeading: false,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ];
                              },
                              body: Padding(
                                padding: EdgeInsets.only(top: 77),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (!loading &&
                                          cityWeatherAl.length != 0) ...{
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: GestureDetector(
                                              onTap: () {
                                                showCupertinoModalPopup<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0,
                                                          vertical: 0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          16),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          16)),
                                                        ),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height -
                                                            500,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              9,
                                                                          bottom:
                                                                              4),
                                                                      child:
                                                                          DefaultTextStyle(
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        child:
                                                                            Text(
                                                                          'Alerts +',
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(9)),
                                                                            color: Color.fromARGB(
                                                                                60,
                                                                                49,
                                                                                49,
                                                                                49),
                                                                          ),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: DefaultTextStyle(
                                                                                    style: TextStyle(),
                                                                                    child: Text('Sender Name: ' + cityWeatherAl[0].sender_name),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: DefaultTextStyle(
                                                                                    textAlign: TextAlign.start,
                                                                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                                                                    child: Text(
                                                                                      'Description: ' + cityWeatherAl[0].description,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )),
                                                                )
                                                              ]),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 110,
                                                child: Stack(
                                                  children: [
                                                    BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 10,
                                                          sigmaY: 51),
                                                      child: Container(
                                                        height: 110,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    CupertinoIcons
                                                                        .alarm,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .white54,
                                                                  ),
                                                                  Text(
                                                                    ' ALERTS',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white54,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 2,
                                                              color: Colors
                                                                  .white54,
                                                            ),
                                                            Flexible(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      cityWeatherAl[
                                                                              0]
                                                                          .sender_name,
                                                                      style: TextStyle(
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          color: Colors
                                                                              .white54,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      maxLines:
                                                                          1,
                                                                      cityWeatherAl[
                                                                              0]
                                                                          .description,
                                                                      style: TextStyle(
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          color: Colors
                                                                              .white70,
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      },
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, right: 22, left: 22),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            width: double.infinity,
                                            height: 173,
                                            child: Stack(
                                              children: [
                                                BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 51),
                                                  child: Container(
                                                    height: 173,
                                                    padding: EdgeInsets.all(5),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .clock,
                                                                size: 18,
                                                                color: Colors
                                                                    .white54,
                                                              ),
                                                              Text(
                                                                ' 24-HOURS FORECAST',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                          color: Colors.white54,
                                                        ),
                                                        Flexible(
                                                          child:
                                                              ListView.builder(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  shrinkWrap:
                                                                      true,
                                                                  scrollDirection:
                                                                      Axis
                                                                          .horizontal,
                                                                  itemCount: cityWeatherHr
                                                                              .length >
                                                                          24
                                                                      ? 24
                                                                      : cityWeatherHr
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              22),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Text(getTime(cityWeatherHr[index].dt), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                                            ],
                                                                          ),
                                                                          Stack(
                                                                            alignment:
                                                                                AlignmentDirectional.bottomCenter,
                                                                            children: [
                                                                              Image(
                                                                                image: AssetImage("assets/icons/${cityWeatherHr[index].weather[0].icon}.png"),
                                                                                height: 30,
                                                                                width: 33,
                                                                              ),
                                                                              if (cityWeatherHr[index].rain! > 9) ...{
                                                                                Container(
                                                                                  padding: EdgeInsets.all(0),
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    color: Colors.black54,
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    child: Text(
                                                                                      cityWeatherHr[index].rain!.toStringAsFixed(0) + '%',
                                                                                      style: TextStyle(color: Colors.lightBlue, fontSize: 12, fontWeight: FontWeight.w800),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              },
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            cityWeatherHr[index].temp.toStringAsFixed(0) +
                                                                                '\u00B0',
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 22, vertical: 6),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            height: 415,
                                            child: Stack(
                                              children: [
                                                BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 51),
                                                  child: Container(
                                                    height: 415,
                                                    padding: EdgeInsets.all(5),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 8.0,
                                                                  left: 8.0,
                                                                  right: 8.0,
                                                                  bottom: 8.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .calendar,
                                                                size: 18,
                                                                color: Colors
                                                                    .white54,
                                                              ),
                                                              Text(
                                                                ' 8-DAY FORECAST',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                          color: Colors.white54,
                                                        ),
                                                        Flexible(
                                                          child: ListView
                                                              .separated(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            shrinkWrap: true,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemCount: cityWeatherDy
                                                                        .length >
                                                                    10
                                                                ? 10
                                                                : cityWeatherDy
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Column(
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            8),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              80,
                                                                          child:
                                                                              Text(
                                                                            getDay(cityWeatherDy[index].dt),
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.w700),
                                                                          ),
                                                                        ),
                                                                        Stack(
                                                                          alignment:
                                                                              AlignmentDirectional.bottomCenter,
                                                                          children: [
                                                                            Image(
                                                                              image: AssetImage("assets/icons/${cityWeatherHr[index].weather[0].icon}.png"),
                                                                              height: 30,
                                                                              width: 33,
                                                                            ),
                                                                            if (cityWeatherHr[index].rain! >
                                                                                9) ...{
                                                                              Container(
                                                                                padding: EdgeInsets.all(0),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                  color: Colors.black54,
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(1.0),
                                                                                  child: Text(
                                                                                    cityWeatherDy[index].rain.toStringAsFixed(0) + '%',
                                                                                    style: TextStyle(color: Colors.lightBlue, fontSize: 12, fontWeight: FontWeight.w800),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            },
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          cityWeatherDy[index].tempmax.toStringAsFixed(0) +
                                                                              '\u00B0 / ' +
                                                                              cityWeatherDy[index].tempmin.toStringAsFixed(0) +
                                                                              '\u00B0',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w700),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                            separatorBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0,
                                                                        right:
                                                                            8.0),
                                                                child: Divider(
                                                                  height: 0,
                                                                  color: Colors
                                                                      .white54,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22, right: 6),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .wind,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' WIND',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child:
                                                                      Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    Container(
                                                                  height: 120,
                                                                  width: 120,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image: AssetImage(
                                                                          'assets/images/compass.png'),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: [
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            CustomPaint(
                                                                          painter: WindDirectionPainter(cityWeather[cityIndex]
                                                                              .cityWdeg
                                                                              .toDouble()),
                                                                          size: Size(
                                                                              150,
                                                                              150),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                1,
                                                                            top:
                                                                                1.5),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              BackdropFilter(filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10)),
                                                                              Container(
                                                                                width: 45,
                                                                                height: 45,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  color: Colors.black54,
                                                                                ),
                                                                                child: Center(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        cityWeather[cityIndex].cityWspeed.toStringAsFixed(0),
                                                                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                                                                                      ),
                                                                                      Text(
                                                                                        'km/h',
                                                                                        style: TextStyle(color: Colors.white.withOpacity(0.90), fontSize: 10, fontWeight: FontWeight.w900),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 2,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 22),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .eye_fill,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' VISIBILITY',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max: 50,
                                                                        initialValue: cityWeather[cityIndex]
                                                                            .cityVisi
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            infoProperties: InfoProperties(
                                                                              mainLabelStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                                                              modifier: (percentage) {
                                                                                final roundedValue = percentage.ceil().toInt().toString();
                                                                                return '$roundedValue \km';
                                                                              },
                                                                            ),
                                                                            animationEnabled: true,
                                                                            angleRange: 360,
                                                                            startAngle: 90,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 5, handlerSize: 2),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [Colors.red, Colors.blueGrey])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22, right: 6, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .thermometer,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' FEELS LIKE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min:
                                                                            -100,
                                                                        max:
                                                                            100,
                                                                        initialValue: cityWeather[cityIndex]
                                                                            .cityVisi
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            angleRange: 360,
                                                                            spinnerMode: false,
                                                                            infoProperties: InfoProperties(
                                                                                mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                                modifier: (percentage) {
                                                                                  final roundedValue = percentage.ceil().toInt().toString();
                                                                                  return '$roundedValue' + '\u00B0';
                                                                                },
                                                                                bottomLabelText: "Feels Like",
                                                                                bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 8, handlerSize: 3),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [Colors.amber[600]!.withOpacity(0.54), Colors.blueGrey.withOpacity(0.54)])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 22, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .gauge,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' PRESSURE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max:
                                                                            2000,
                                                                        initialValue: cityWeather[cityIndex]
                                                                            .citypressure
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            infoProperties: InfoProperties(
                                                                                mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                                modifier: (percentage) {
                                                                                  var formatter = NumberFormat('#,##,000');
                                                                                  var fort = formatter.format(percentage);
                                                                                  final roundedValue = fort.toString();
                                                                                  return '$roundedValue';
                                                                                },
                                                                                bottomLabelText: "hPa",
                                                                                bottomLabelStyle: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 7, handlerSize: 6),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [
                                                                              Colors.white.withOpacity(1),
                                                                              Colors.white.withOpacity(0.54),
                                                                              Colors.transparent,
                                                                              Colors.transparent
                                                                            ])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22, right: 6, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .drop_fill,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' HUMIDITY',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max:
                                                                            100,
                                                                        initialValue: cityWeather[cityIndex]
                                                                            .cityhumidity
                                                                            .toDouble(),
                                                                        appearance: CircularSliderAppearance(
                                                                            infoProperties: InfoProperties(
                                                                                mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                                modifier: (percentage) {
                                                                                  final roundedValue = percentage.ceil().toInt().toString();
                                                                                  return '$roundedValue%';
                                                                                },
                                                                                bottomLabelText: "Humidity",
                                                                                bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customWidths: CustomSliderWidths(progressBarWidth: 8, handlerSize: 3),
                                                                            customColors: CustomSliderColors(hideShadow: true, trackColor: Colors.white54, progressBarColors: [Colors.blueGrey, Colors.black54])),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 22, top: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 180,
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .sun_max_fill,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                    Text(
                                                                      ' UV INDEX',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white54,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SleekCircularSlider(
                                                                        min: 0,
                                                                        max: 11,
                                                                        initialValue: loading
                                                                            ? 0
                                                                            : cityWeatherCu[0].cityUiv.toDouble(),
                                                                        appearance:
                                                                            CircularSliderAppearance(
                                                                          infoProperties: InfoProperties(
                                                                              mainLabelStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                                                                              modifier: (percentage) {
                                                                                final roundedValue = percentage.ceil().toInt().toString();
                                                                                return '$roundedValue';
                                                                              },
                                                                              bottomLabelText: "UV",
                                                                              bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5, color: Colors.white70, fontWeight: FontWeight.w700)),
                                                                          animationEnabled:
                                                                              true,
                                                                          size:
                                                                              140,
                                                                          customWidths: CustomSliderWidths(
                                                                              progressBarWidth: 8,
                                                                              handlerSize: 3),
                                                                          customColors:
                                                                              CustomSliderColors(
                                                                            hideShadow:
                                                                                true,
                                                                            trackColor:
                                                                                Colors.white54,
                                                                            progressBarColors: [
                                                                              Colors.purple,
                                                                              Colors.redAccent,
                                                                              Colors.redAccent,
                                                                              Colors.redAccent,
                                                                              Colors.orange,
                                                                              Colors.orange,
                                                                              Colors.yellow,
                                                                              Colors.yellow,
                                                                              Colors.yellow,
                                                                              Colors.green,
                                                                              Colors.green,
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )));
                    }
                  }),
            ),
          ],
        ));
  }
}

class WindDirectionPainter extends CustomPainter {
  final double windDirection;

  WindDirectionPainter(this.windDirection);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double arrowLength = size.height * 0.95;
    double arrowWidth = size.width * 0.07;
    double arrowHeadWidth = arrowWidth * 1;
    double arrowHeadLength = size.width * 0.15;

    Path path = Path();
    path.moveTo(-arrowLength / 2, 0);
    path.lineTo(arrowLength / 2 - arrowHeadLength, 0);
    path.lineTo(arrowLength / 2 - arrowHeadLength, -arrowHeadWidth / 2);
    path.lineTo(arrowLength / 2, 0);
    path.lineTo(arrowLength / 2 - arrowHeadLength, arrowHeadWidth / 2);
    path.lineTo(arrowLength / 2 - arrowHeadLength, 0);
    path.lineTo(-arrowLength / 2, 0);
    path.close();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 - 0.1);
    canvas.rotate(windDirection * (pi / 180));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
