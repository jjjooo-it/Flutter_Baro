import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  List<String> selectPic = [
    'assets/지진.png',
    'assets/지진해일.png',
    'assets/공습경보.png',
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //버튼에 자신의 번호, 선택된 번호, 아이콘, setState를 넘겨줌
            ProductIcon(0, selectedIconNum, Icons.directions_bike, changeIcon),
            ProductIcon(1, selectedIconNum, Icons.motorcycle, changeIcon),
            ProductIcon(2, selectedIconNum, CupertinoIcons.car_detailed, changeIcon),
          ],
        ),
      );
    }

  Widget _productPic() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Image.asset(
                selectPic[selectedIconNum],
                fit: BoxFit.cover,
              ),
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
  final IconData mIcon;
  final Function changeIcon;

  const ProductIcon(
      //main에서 받아와야하는 값 정의
      this.productNum,
      this.selectedIconNum,
      this.mIcon,
      this.changeIcon, {
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 35,
      decoration: BoxDecoration(
        // 선택된 버튼, 선택안된 버튼 배경색 삼항 연산자로 정의
        color: productNum == selectedIconNum ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: () {
          //받아온 change함수에 선택된 num 보내서 main에서 state 변경
          changeIcon(productNum);
        },
        icon: Icon(
          mIcon,
          color: Colors.black,
        ),
      ),
    );
  }
}

