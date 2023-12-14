import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'setting.dart';
import 'news.dart';
import 'how.dart';
import 'distance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

//bottom navigator
class _HomeScreenState extends State<HomeScreen> {
  var _index = 0;
  final _pages = [
    const Page1(),
    const News(),
    const How(),
    const Setting(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _index = index; // 선택된 탭의 인덱스로 _index를 변경
            });
          },
          currentIndex: _index, // 선택된 인덱스
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              label: '홈',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label:'실시간 뉴스',
              icon: Icon(Icons.newspaper),
            ),
            BottomNavigationBarItem(
              label:'행동 요령',
              icon: Icon(Icons.warning),
            ),
            BottomNavigationBarItem(
              label:'설정',
              icon: Icon(Icons.settings),
            ),
          ]
      ),
    );
  }
}

//홈 페이지 시작
class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  List<List<dynamic>>? csvData;
  Set<Marker> markers = {};
  double closeLat=0, closeLong=0;
  late double curLat=37.32165076082689, curLong=127.12672145303995;

  @override
  void initState(){
    loadCsvData();
    getCurrentLocation();
    _listenToServerEvents();
  }

  //csv에서 데이터 가져오기
  Future<void> loadCsvData() async {
    var result = await DefaultAssetBundle.of(context).loadString("assets/shelter.csv");
    csvData = const CsvToListConverter().convert(result, eol: "\n");
  }

  // 현재 위치 얻기
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    curLat = position.latitude;
    curLong = position.longitude;
  }

  //네비게이션에 현재 위치 파라미터로 넘기기
  Future<void> openMap(double latitude, double longitude) async {
    var googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  //거리를 알려주는 페이지로 이동
  void _navigateToDistancePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Distance()),
    );
  }
  double lat = 0;
  double long = 0;
  double mag = 0;
  String name ="";
  String myMessage = "재난 발생 시 여기에 표시 됩니다.";
  String place = "";

  void updateData(double newLat, double newLong, String newloc, double newMag) {
    lat = newLat;
    long = newLong;
    mag = newMag;
    place = newloc;

    setState(() {
      //위도 경도를 위치로 변경
      myMessage = "🚨진도 ${mag}지진이 ${place}에 발생했습니다";
    });
  }

  void _listenToServerEvents() {
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: 'http://ec2-3-35-100-8.ap-northeast-2.compute.amazonaws.com:8080/warn/connect',
      header: {
        "Cookie": '',
        "Accept": "text/event-stream",
        "Cache-Control": ""
      },
    ).listen((event) {
      var data = json.decode(event.data!);
      updateData(data['latitude'], data['longitude'],data['address'], data['magnitude']);
    });
  }

  //////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: checkPermission(),
      builder: (context, snapshot) {
        // 로딩 상태일 때
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 권한이 허가된 상태
        String closeShelter ='';
        double closestDistance = double.maxFinite;

        if (snapshot.data == '위치 권한이 허가되었습니다.') {
          //대피소 마커 찍기
          markers = Set.from(
            csvData!.map((dataRow) {
              double latitude = double.tryParse(dataRow[11].toString()) ?? 0.0;
              double longitude = double.tryParse(dataRow[10].toString()) ?? 0.0;

              double distance = Geolocator.distanceBetween(curLat, curLong, latitude, longitude);
              if(distance < closestDistance){
                closestDistance = distance;
                closeShelter = dataRow[4]; //현재 위치랑 가장 가까운 대피소 이름
                closeLat = latitude;
                closeLong = longitude;
              }

              return Marker(
                markerId: MarkerId('${dataRow[0]}'),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: '${dataRow[4]}',
                    snippet : '${dataRow[8]}'
                ),
              );
            }).toList(),
          );

          //현재 위치 마커 찍기
          Marker currentLocationMarker = Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(curLat, curLong),
              infoWindow: const InfoWindow(
                  title: '현재 위치',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          );
          markers.add(currentLocationMarker);

          //지진 발생 위치 마커 찍기
          Marker loc =  Marker(
            markerId: MarkerId("지진 발생 위치"),
            position: LatLng(lat,long),
            infoWindow: InfoWindow(title : "지진 발생 위치"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          );
          markers.add(loc);

          //지진 발생 위치에 원 표시
          Set<Circle> circles = {Circle(
            circleId: CircleId("id"),
            center: LatLng(lat,long),
            fillColor: Colors.black54, // 원의 색상
            radius: 10000, // 원의 반지름 (미터 단위)
            strokeColor: Colors.black54, // 원의 테두리 색
            strokeWidth: 1, // 원의 두께
          )};
          //////////////////////////////////////////////////////////////
          return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(curLat, curLong),
                            zoom: 13,
                          ),
                          markers: markers,
                          myLocationEnabled: true,
                          circles: circles,
                        ),
                        Positioned(
                          top: 48,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                  spreadRadius: 0,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(myMessage,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 115,
                          right: 28,
                          width: 153,
                          height: 35,
                          child: ElevatedButton(
                            onPressed: _navigateToDistancePage,
                            child: Text('우리 동네 대피소',  textAlign: TextAlign.center,),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.yellowAccent, // 배경색
                              onPrimary: Colors.black, // 글자색
                              elevation: 3, // 그림자 깊이
                              shadowColor: Colors.black, // 그림자 색
                              shape: RoundedRectangleBorder( // 네모난 모양
                                borderRadius: BorderRadius.circular(8), // 약간 둥근 모서리
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(30,5,30,5),
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.3),
                      ),
                      child: Row( // Row 위젯으로 변경
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 요소들을 양쪽 끝으로 정렬
                        children: [
                          Expanded( // 텍스트를 위한 Expanded 위젯
                            child: Text.rich(
                              TextSpan(
                                text: '가장 가까운 대피소\n',
                                style: TextStyle(fontSize: 18),
                                children: <TextSpan>[
                                  TextSpan(text: closeShelter, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27)),
                                ],
                              ),
                            ),
                          ),
                          Column( // 동그라미 버튼과 텍스트를 Column으로 감싸기
                            mainAxisSize: MainAxisSize.min, // Column 크기 최소화
                            children: [
                              InkWell(
                                onTap: () {
                                  openMap(closeLat, closeLong);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent,
                                  ),
                                  padding: EdgeInsets.all(14),
                                  child: Icon(Icons.navigation, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 5),//틈
                              const Text('안내 시작', // 버튼 아래 텍스트 추가
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
          )
        );
        }
              // 권한이 없는 상태
             return Center(
             child: Text(snapshot.data.toString()));
        }
     );
  }


  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화해주세요.';
    }
    LocationPermission checkedPermission = await Geolocator
        .checkPermission(); // 위치 권한 확인
    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();
      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }
    return '위치 권한이 허가되었습니다.';
  }
}

