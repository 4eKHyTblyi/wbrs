// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:wbrs/app/pages/policy/confidecialnost.dart';
import 'package:wbrs/app/widgets/drawer.dart';
import 'package:wbrs/app/widgets/widgets.dart';

class About_App extends StatelessWidget {
  const About_App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
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
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 22),
              title: const Text("О приложении"),
              backgroundColor: Colors.transparent,
            ),
            drawer: const MyDrawer(),
            body: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      nextScreenReplace(context, const Politica());
                    },
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.transparent)),
                    child: const Text(
                      'Политика конфиденциальности',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const Divider(
                    height: 5,
                    color: Colors.white,
                    thickness: 1,
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.transparent)),
                      child: const Text(
                        'Пользовательское соглашение',
                        style: TextStyle(fontSize: 18),
                      )),
                  const Divider(
                    height: 5,
                    color: Colors.white,
                    thickness: 1,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Версия приложения',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          '1.0',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    height: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        //nextScreenReplace(context, const ComplaintForm());
                      },
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child: const Text(
                            'Обратная связь',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
