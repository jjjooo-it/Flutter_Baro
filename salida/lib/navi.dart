import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:csv/csv.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Navi(),
      )
  );
}

class Navi extends StatefulWidget {
  const Navi({Key? key}) : super(key: key);

  @override
  State<Navi> createState() => _NaviState();
}

class _NaviState extends State<Navi> {
  List<List<dynamic>>? csvData;
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  late double curLat=37.32165076082689, curLong=127.12672145303995;
  late double closeShelterLat = 37.331471, closeShelterLong = 127.124713;
  Map<PolylineId, Polyline> polylines = {};
  double myDistance =0;
  String closeShelter ='';

  @override
  void initState(){
    loadCsvData();
    getCurrentLocation();
    _addMarker();
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
  void findClosestShelter() {
    double closestDistance = double.maxFinite;
    for (var dataRow in csvData!) {
      double latitude = double.tryParse(dataRow[11].toString()) ?? 0.0;
      double longitude = double.tryParse(dataRow[10].toString()) ?? 0.0;
      double distance = Geolocator.distanceBetween(curLat, curLong, latitude, longitude);
      if (distance < closestDistance) {
        closestDistance = distance;
        closeShelterLat = latitude;
        closeShelterLong = longitude;
        closeShelter = dataRow[4]; //현재 위치랑 가장 가까운 대피소 이름
      }
    }
    //거리 km로 구하기
    myDistance = closestDistance/1000;
    myDistance = double.parse(myDistance.toStringAsFixed(2));
  }


  Future<void> _addMarker() async {
    Uint8List currentLocationIcon = await _createCustomMarkerIcon("현재 위치", Colors.grey);
    Uint8List shelterIcon = await _createCustomMarkerIcon("가장 가까운 대피소", Colors.red);

    Marker currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(curLat, curLong),
      icon: BitmapDescriptor.fromBytes(currentLocationIcon),
    );

    findClosestShelter();
    setState(() {
      markers.add(currentLocationMarker);
      if (closeShelterLat != null && closeShelterLong != null) {
        markers.add(Marker(
          markerId: const MarkerId('shelter_location'),
          position: LatLng(closeShelterLat, closeShelterLong),
          infoWindow: InfoWindow(title: closeShelter),
          icon:  BitmapDescriptor.fromBytes(shelterIcon),
        ));
      }
    });
  }

  //////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: checkPermission(),
      builder: (context,snapshot) {
        // 로딩 상태일 때
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // 권한이 허가된 상태
       double closestDistance = double.maxFinite;
        if (snapshot.data == '위치 권한이 허가되었습니다.') {

          return Scaffold(
              appBar: AppBar(
                title: const Text('핀을 눌러 길 안내 기능을 사용하세요!'),
                centerTitle: true,
              ),
              body: Column(
                children :[
                  Expanded(
                  flex: 4,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                    target: LatLng(curLat, curLong), zoom: 14),
                    markers: markers,
                    polylines: Set<Polyline>.of(polylines.values),
                    myLocationEnabled: true,
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
                          text: '가장 가까운 대피소까지의 거리는\n',
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(text: "${myDistance}km입니다", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27)),
                          ],
                        ),
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
  /////////////////////////////////////////////////
    Future<void> makePolyline() async{
      PolylinePoints polylinePoints = PolylinePoints();
      String googleAPiKey = "AIzaSyDXrGZwSs-D8_H2uizZGO1BCgAixRt5oPw";
      LatLng startLocation = LatLng(curLat, curLong); //현위치
      LatLng endLocation = LatLng(closeShelterLat, closeShelterLong); //대피소

      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPiKey,
          PointLatLng(startLocation.latitude, startLocation.longitude),
          PointLatLng(endLocation.latitude, endLocation.longitude),
          travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
      } else {
          print(result.errorMessage);
      }
      PolylineId id = PolylineId("poly");
      Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.deepPurpleAccent,
          points: polylineCoordinates,
          width: 8,
      );
        polylines[id] = polyline;
        setState(() {});
  }
  /////////////////////////////////////////////////
  //말풍선 모양으로 마커 커스텀하기
  Future<Uint8List> _createCustomMarkerIcon(String _text, Color _color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = _color;
    final textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // 말풍선
    final rectWidth = textWidth + 40;
    final rectHeight = textHeight + 40;
    const tailWidth = 30.0;
    const tailHeight = 30.0;
    final rect = Rect.fromLTWH(0, 0, rectWidth, rectHeight);
    final path = Path()
      ..addRect(rect)
      ..moveTo(rectWidth / 2 - tailWidth / 2, rectHeight)
      ..lineTo(rectWidth / 2, rectHeight + tailHeight)
      ..lineTo(rectWidth / 2 + tailWidth / 2, rectHeight)
      ..close();
    canvas.drawPath(path, paint);

    textPainter.paint(canvas, Offset(20, 20));

    final picture = recorder.endRecording();
    final image = await picture.toImage(rectWidth.toInt(), (rectHeight + tailHeight).toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /////////////////////////////////////////////////
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
