import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File pickedImage;
  bool isImageLoaded = false;
  String w = "";
  String kelimler = "";
  List<String> terorKelimeleri = [
    'terör',
    'pkk',
    'ypg',
    'dhkpc',
    'DHKPC',
    'TEROR',
    'PKK',
    'YDG',
    'YDG-',
    'YPG',
    'APO',
  ];
  TextEditingController tec = TextEditingController();

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          w = w + " " + word.text;
          print(word.text);
          for (int i = 0; i < terorKelimeleri.length; i++) {
            if (terorKelimeleri[i] == word.text) {
              print(word.text);
              kelimler += word.text;
            }
          }
        }
      }
    }
    if (kelimler.isNotEmpty) {
      veritabaninaEkle(tec.text, kelimler);
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            'Terör Kelimeli fotoğraf paylaşan kişi takip listesine alındı'),
      ),
    );
    kelimler = "";
  }

  void veritabaninaEkle(String kullaniciAdi, tespitKelimler) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var ref = _firestore.collection("TakibeAlinanKullanicilar");
    var documentRef = await ref.add({
      'kullaniciAdi': kullaniciAdi,
      'tespitEdilenKelimeler': tespitKelimler,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 300,
            child: TextField(
              controller: tec,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Kullanıcı Adınızı Giriniz'),
            ),
          ),
          SizedBox(height: 20),
          isImageLoaded
              ? Center(
                  child: Container(
                    //padding: EdgeInsets.all(30),
                    height: 200.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(pickedImage), fit: BoxFit.cover),
                    ),
                  ),
                )
              : Container(),
          SizedBox(height: 10.0),
          RaisedButton(
            color: Colors.tealAccent,
            child: Text("Galeriden Resim Seç"),
            onPressed: pickImage,
          ),
          SizedBox(height: 10.0),
          RaisedButton(
            color: Colors.tealAccent,
            child: Text("Resimdeki Terör Kelimlerini Bul"),
            onPressed: readText,
          ),
        ],
      ),
    );
  }
}
