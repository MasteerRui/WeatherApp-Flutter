import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cupertino_listview/cupertino_listview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:smooth_compass/utils/smooth_compass.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weather/extensions/capitaliza.dart';
import 'package:weather/models/weatherDailyModel.dart';
import 'package:weather/models/weatherHourlyModel.dart';
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
  double _shrinkOffset = 0;
  List<Weather> cityWeather = [];
  List<HourlyData> cityWeatherHr = [];
  List<DailyData> cityWeatherDy = [];
  PageController? _pageController;
  WeatherResponse? _response;
  bool? loca;
  bool _isCollapsed = false;
  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = 200;

  Future<Object> fetchWeather() async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=33.44&lon=-94.04&exclude=minutely&appid=ef5fcf1d7c5621b52cc80ce4f94be994&units=metric'));

    if (response.statusCode == 200) {
      List<HourlyData> weatherData = [];
      List<DailyData> weatherDataa = [];
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> dailyList = json["daily"];
      List<dynamic> hourlyList = json["hourly"];
      for (var hourly in hourlyList) {
        weatherData.add(HourlyData.fromJson(hourly));
      }
      for (var daily in dailyList) {
        weatherDataa.add(DailyData.fromJson(daily));
      }
      setState(() {
        cityWeatherHr = weatherData;
        cityWeatherDy = weatherDataa;
        print(cityWeatherDy);
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
    return _scrollController != null &&
        _scrollController!.hasClients &&
        _scrollController!.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
    cityWeather = widget.cityWeather;
    _pageController = PageController(initialPage: widget.indexx);
    loca = widget.loc;
    _response = widget.response;
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
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
                  onPageChanged: (int) {},
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
                          child: NestedScrollView(
                              controller: _scrollController,
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
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 22),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            width: double.infinity,
                                            height: 158,
                                            child: Stack(
                                              children: [
                                                BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 51),
                                                  child: Container(
                                                    height: 158,
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
                                                                          Text(
                                                                              getTime(cityWeatherHr[index].dt),
                                                                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                                          Image(
                                                                            image:
                                                                                AssetImage("assets/icons/${cityWeatherHr[index].weather[0].icon}.png"),
                                                                            height:
                                                                                20,
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
                                                                ' 10-DAY FORECAST',
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
                                                                        SizedBox(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              30,
                                                                          child:
                                                                              Image(image: AssetImage('assets/icons/${cityWeatherDy[index].weather[0].icon}.png')),
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
                                                  height: 185,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 185,
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
                                                  height: 185,
                                                  child: Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 10,
                                                                sigmaY: 51),
                                                        child: Container(
                                                          height: 185,
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
                                                                          .clock,
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
                                                                                modifier: (percentage) {
                                                                                  final roundedValue = percentage.ceil().toInt().toString();
                                                                                  return '$roundedValue %';
                                                                                },
                                                                                bottomLabelText: "Humidity",
                                                                                bottomLabelStyle: TextStyle(letterSpacing: 0.1, fontSize: 14, height: 1.5)),
                                                                            animationEnabled: true,
                                                                            size: 140,
                                                                            customColors: CustomSliderColors()),
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
                                    ],
                                  ),
                                ),
                              )));
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
            ),
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.lightBlueAccent,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SmoothPageIndicator(
                        onDotClicked: (index) {
                          _pageController!.jumpToPage(index);
                        },
                        controller: _pageController!,
                        count: widget.loc
                            ? cityWeather.length + 1
                            : cityWeather.length,
                        effect: SlideEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          dotColor: Colors.white38,
                          activeDotColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
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
      ..color = Colors.white54
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
