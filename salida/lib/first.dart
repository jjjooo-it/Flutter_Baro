import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salida/home.dart';

void main(){
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FirstPage(),
      )
  );
}
class FirstPage extends StatefulWidget{
  const FirstPage ({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SALIDA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 70,
              ),
            ),
            const Text("재난 대피 통합 어플",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Image.asset('assets/logo.png',
              width: 250,
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text("Powered By LUMOS",
                style: TextStyle(
                  fontSize: 15,
                ),),
            )
          ],
        ),
      ),
    );
  }
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }
}