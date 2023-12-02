import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late GoogleMapController mapController;
  final double _mylocla = 37.2472234410208, _myloclon = 127.227329846699; //현재 위치
  final double _latitude = 37.2407973769594, _longitude = 127.167167214282; //대피소 위도&경도
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDXrGZwSs-D8_H2uizZGO1BCgAixRt5oPw";
  @override
  void initState() {
    super.initState();
    _addMarker(LatLng(_latitude, _longitude), "대피소", BitmapDescriptor.defaultMarker);
    _addMarker(LatLng(_mylocla, _myloclon), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title : const Text('목적지를 클릭하여 네비게이션 기능을 사용하세요!', style:  TextStyle(fontSize: 18,),)
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_latitude, _longitude), zoom: 15),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          )),
    );
  }
  void _onMapCreated(GoogleMapController controller) async {
     mapController = controller;
  }
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }
_addPolyLine() {
  PolylineId id = PolylineId("poly");
  Polyline polyline = Polyline(
      polylineId: id, color: Colors.red, points: polylineCoordinates);
  polylines[id] = polyline;
  setState(() {});
}

_getPolyline() async {
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(_latitude, _longitude),
      PointLatLng(_mylocla, _myloclon),
      travelMode: TravelMode.driving,
      wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  }
  _addPolyLine();
}
}
