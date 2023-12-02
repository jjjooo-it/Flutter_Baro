import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'navi.dart';
import 'news.dart';
import 'how.dart';

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
    const Navi(),
    const News(),
    const How()
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
              label:'길찾기',
              icon: Icon(Icons.assistant_navigation),
            ),
            BottomNavigationBarItem(
              label:'재난 뉴스',
              icon: Icon(Icons.newspaper),
            ),
            BottomNavigationBarItem(
              label:'대피 요령',
              icon: Icon(Icons.warning),
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
  late double curLat=37.32165076082689, curLong=127.12672145303995;

  @override
  void initState(){
    loadCsvData();
    getCurrentLocation();
  }

  //csv에서 데이터 가져오기
  Future<void> loadCsvData() async {
    var result = await DefaultAssetBundle.of(context).loadString("assets/shelter.csv");
    csvData = const CsvToListConverter().convert(result, eol: "\n");
  }

  // 현재 위치 얻기 및 마커 추가
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    curLat = position.latitude;
    curLong = position.longitude;
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
              }

              return Marker(
                markerId: MarkerId('${dataRow[0]}'),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: '${dataRow[4]}'),
              );
            }).toList(),
          );

          //현재 위치 마커 찍기
          Marker currentLocationMarker = Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(curLat, curLong),
              infoWindow: const InfoWindow(title: '현재 위치'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          );
          markers.add(currentLocationMarker);

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
                        ),
                        Positioned(
                          top: 48,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 45,
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
                            child: const Text(
                              '🚨  [속보] 경북 김천 서 규모 3.2 지진 발생',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                      padding: EdgeInsets.all(30),
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.3),
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '가장 가까운 대피소\n',
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(text: closeShelter, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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