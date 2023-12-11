import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:csv/csv.dart';


void main() {
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Distance(),
      )
  );
}

class Distance extends StatefulWidget {
  const Distance({Key? key}) : super(key: key);

  @override
  State<Distance> createState() => _DistanceState();
}

class ShelterInfo {
  String name;
  String address;
  double distance;

  ShelterInfo({required this.name, required this.address, required this.distance});
}

class _DistanceState extends State<Distance> {
  List<List<dynamic>>? csvData;
  late double curLat = 37.32165076082689,
      curLong = 127.12672145303995;
  List<ShelterInfo> shelters = [];

  @override
  void initState() {
    super.initState();
    loadCsvData();
    getCurrentLocation();
  }

  Future<void> loadCsvData() async {
    var result = await DefaultAssetBundle.of(context).loadString(
        "assets/shelter.csv");
    List<List<dynamic>> rawData = const CsvToListConverter().convert(
        result, eol: "\n");

    // 첫 번째 행(헤더)을 제외하고 나머지 데이터 처리
    csvData = rawData.sublist(1);
  }


  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      curLat = position.latitude;
      curLong = position.longitude;
    });
    findDistance();
  }

  void findDistance() {
    shelters.clear();
    for (var dataRow in csvData!) {
      double latitude = double.tryParse(dataRow[11].toString()) ?? 0.0;
      double longitude = double.tryParse(dataRow[10].toString()) ?? 0.0;
      double distance = Geolocator.distanceBetween(
          curLat, curLong, latitude, longitude) / 1000;

      shelters.add(ShelterInfo(
        name: dataRow[4].toString(),
        address: dataRow[8].toString(),
        distance: distance,
      ));
    }

    // 거리에 따라 대피소 리스트를 정렬
    shelters.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {}); // 화면 갱신
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    double itemHeight = (screenHeight - appBarHeight - statusBarHeight) / 7;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('우리 동네 대피소'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          itemCount: shelters.length,
          itemBuilder: (context, index) {
            var shelter = shelters[index];
            return SizedBox(
              height: itemHeight, // 각 항목의 높이를 화면 크기에 맞춰 설정
              child: Card(
                child: ListTile(
                  title: Text(shelter.name),
                  subtitle: Text('${shelter.address}\n거리: ${shelter.distance
                      .toStringAsFixed(2)} km'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
