import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:wbrs/app/helper/global.dart';

import '../../widgets/widgets.dart';

class Rules extends StatefulWidget {
  const Rules({super.key});

  @override
  State<Rules> createState() => _RulesState();
}

class _RulesState extends State<Rules> {

  String text = "";

  Uri emailLaunch = Uri(
    scheme: 'mailto',
    path: "myemail@email.com",
  );

  @override
  void initState() {
    getText();
    super.initState();
  }

  void getText() async {
    text = await loadAsset();
    setState(() {

    });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/rules.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.green,
            )
          ]),
          child: Image.asset(
            "assets/fon.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            scale: 0.6,
          ),
        ),
        Scaffold(
            appBar: AppBar(title: const Text("Правила использования", style: TextStyle(color: Colors.white),), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white),),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text("WBRS version 1.0",textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                  const SizedBox(height: 20,),
                  TextButton(
                    onPressed: (){
                      try {
                        launchUrl(Uri. parse("mailto:supp.wbrs@ya.ru"));
                      } on Exception catch (e) {
                        showSnackbar(context, Colors.red, e);
                      }
                    }, child: const Text("supp.wbrs@ya.ru",textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white),)),
                  const Text("Здесь благодаря алгоритму и психологии вы легко найдете близкого человека для создания долгих, крепких отношений, дружбы, семьи",textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white),),
                  const SizedBox(height: 20,),
                  const Text("Правила использования приложения",textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                  Text(text, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, color: Colors.white),),
                ],
              ),
            )),
      ],
    );
  }
}
