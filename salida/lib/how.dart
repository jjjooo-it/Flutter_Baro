import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main(){
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: How(),
      )
  );
}

class How extends StatefulWidget{
  const How ({Key? key}) : super(key: key);

  @override
  State<How> createState() => _HowState();
}

class _HowState extends State<How> {
  int selectedIconNum =0;
  int _currentCarouselIndex = 0;  // 캐러셀의 현재 인덱스
  final CarouselController _carouselController = CarouselController();  // 캐러셀 컨트롤러
  final List<List<String>> categoryImages = [
    [
      'assets/지진/001.png',
      'assets/지진/002.png',
      'assets/지진/003.png',
      'assets/지진/004.png',
      'assets/지진/005.png',
    ],
    [
      'assets/지진해일/002.png',
      'assets/지진해일/003.png',
      'assets/지진해일/004.png',
    ],
    [
      'assets/공습경보/001.png',
      'assets/공습경보/002.png',
      'assets/공습경보/003.png',
    ],
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대피요령'),
        centerTitle: true,
      ),
      body:SingleChildScrollView(
        child: Column(
        children: [
            const Divider(
              indent: 30,
              endIndent: 30,),
            _productSelector(),
            _productPic(),
        ],
      ),
      ),
    );
  }
  Widget _productSelector() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProductIcon(0, selectedIconNum, "지진", changeIcon),
                ProductIcon(1, selectedIconNum, "해일", changeIcon),
                ProductIcon(2, selectedIconNum, "공습경보", changeIcon),
              ],
            ),
            SizedBox(height: 50), // 여기서 버튼과 이미지 사이의 마진을 추가합니다.
          ],
        ),
      );
  }

  Widget _productPic() {
    List<String> currentImages = categoryImages[selectedIconNum];

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,  // 캐러셀 컨트롤러 사용
          options: CarouselOptions(
            height: 400.0,
            autoPlay: false,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;  // 현재 인덱스 업데이트
              });
            },
            enableInfiniteScroll: false,  // 무한 스크롤 비활성화
          ),
          itemCount: currentImages.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: Image.asset(
                currentImages[itemIndex],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: currentImages.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                      .withOpacity(_currentCarouselIndex == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  void changeIcon(int num) {
      //components의 버튼에 함수를 넘겨 main에서 state를 변경
      setState(() {
        selectedIconNum = num;
      });
    }
  }
class ProductIcon extends StatelessWidget {
  final int productNum;
  final int selectedIconNum;
  final String mIcon;
  final Function changeIcon;

  const ProductIcon(//main에서 받아와야하는 값 정의
      this.productNum,
      this.selectedIconNum,
      this.mIcon,
      this.changeIcon, {
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: 80,
        height: 35,
        decoration: BoxDecoration(
          // 선택된 버튼, 선택안된 버튼 배경색 삼항 연산자로 정의
          color: productNum == selectedIconNum ? Colors.blueAccent : Colors
              .grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextButton(
          onPressed: () {
            changeIcon(productNum);
          },
          child: Text(
            mIcon,
            style: const TextStyle(color: Colors.black,),

          ),
        ),
      );
  }

}
