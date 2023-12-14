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
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
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
    shelters = shelters.take(30).toList();

    setState(() {}); // 화면 갱신
  }
  int itemsPerPage = 6;
  PageController _pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double itemHeight = (screenHeight - appBarHeight - statusBarHeight) / itemsPerPage;

    int numberOfPages = (shelters.length / itemsPerPage).ceil();

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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '가까운 순으로 보는 우리동네 대피소',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: numberOfPages,
                    itemBuilder: (context, pageIndex) {
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                        itemCount: pageIndex == 0 ? itemsPerPage : itemsPerPage,
                        itemBuilder: (context, index) {
                          int actualIndex = pageIndex * itemsPerPage + index;
                          if (actualIndex >= shelters.length) return Container(); // 빈 컨테이너 반환
                          var shelter = shelters[actualIndex];
                          return SizedBox(
                            height: 100,
                            child: Card(
                              child: ListTile(
                                title: Text(shelter.name),
                                subtitle: Text('${shelter.address}\n거리: ${shelter.distance.toStringAsFixed(2)} km'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(numberOfPages, (index) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index ? Colors.blue : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
