// ignore_for_file: must_be_immutable, empty_catches, non_constant_identifier_names, avoid_print, prefer_interpolation_to_compose_strings, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/helper/helper_function.dart';
import 'package:messenger/pages/auth/login_page.dart';
import 'package:messenger/pages/profile_edit_page.dart';
import 'package:messenger/pages/profiles_list.dart';
import 'package:messenger/pages/visiters.dart';
import 'package:messenger/service/auth_service.dart';
import 'package:messenger/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:messenger/widgets/widgets.dart';

import '../helper/global.dart' as global;
import '../widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  String about;
  String age;
  String rost;
  String city;
  String hobbi;
  bool deti;
  String pol;
  String group;
  ProfilePage({
    Key? key,
    required this.email,
    required this.userName,
    required this.about,
    required this.age,
    required this.pol,
    required this.group,
    required this.deti,
    required this.rost,
    required this.city,
    required this.hobbi,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  String imageUrl = " ";
  TextEditingController? name = TextEditingController();
  late User? user = FirebaseAuth.instance.currentUser;

  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
      for (int i = 0; i < selectedImages.length; i++) {
        loadImage(selectedImages[i].name, selectedImages[i]);
      }
    }
    selectedImages.clear();
  }

  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("profilepic${FirebaseAuth.instance.currentUser?.uid}.jpg");

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  AuthService authService = AuthService();
  String password = "";
  String passwordConfirm = "";

  var currentUser = FirebaseAuth.instance.currentUser;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(boxShadow: []),
          child: Image.asset(
            "assets/fon.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            scale: 0.6,
          ),
        ),
        Scaffold(
          bottomNavigationBar: const MyBottomNavigationBar(),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: Column(children: [
                                  TextFormField(
                                    style: const TextStyle(color: Colors.black),
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        labelText: "Введите пароль",
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    validator: (val) {
                                      if (val!.length < 6) {
                                        return "Пароль должен содержать 6 символов";
                                      } else {
                                        return null;
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        password = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    style: const TextStyle(color: Colors.black),
                                    obscureText: true,
                                    decoration: textInputDecoration.copyWith(
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        labelText: "Повторите пароль",
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    validator: (val) {
                                      if (val!.length < 6) {
                                        return "Пароль должен содержать 6 символов";
                                      } else {
                                        if (val != password) {
                                          return "Пароли не совпадают!";
                                        }
                                        return null;
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        passwordConfirm = val;
                                      });
                                    },
                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          try {
                                            await FirebaseAuth
                                                .instance.currentUser!
                                                .updatePassword(
                                                    passwordConfirm);

                                            FirebaseAuth.instance.signOut();
                                            nextScreen(
                                                context, const LoginPage());
                                            showSnackbar(context, Colors.green,
                                                "Пароль успешно изменен! Пожалуйста авторизуйтесь повторно.");
                                          } on Exception catch (e) {
                                            print(e);
                                          }
                                        }
                                      },
                                      child: const Text(
                                        "Сменить пароль",
                                        style: TextStyle(
                                            color: Colors.orangeAccent),
                                      )),
                                ]),
                              ),
                            ),
                          ),
                        );
                      });
                },
                icon: const Icon(Icons.more_horiz_rounded),
                splashRadius: 20,
              )
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Профиль",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold),
            ),
          ),
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 17),
            child: SizedBox(
              width: double.infinity,
              child: currentUser != null
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Stack(
                            children: [
                              (currentUser!.photoURL == "" ||
                                      currentUser!.photoURL == null)
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: Image.asset(
                                        "assets/profile.png",
                                        fit: BoxFit.cover,
                                        height: 100.0,
                                        width: 100.0,
                                      ))
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: Image.network(
                                        currentUser!.photoURL.toString(),
                                        fit: BoxFit.cover,
                                        height: 200.0,
                                        width: 200.0,
                                      )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ваша группа: ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Text(widget.group,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Вам подходят: ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Column(
                                children: getLikeGroup(widget.group),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 140,
                            child: Row(
                              //mainAxisSize: MainAxisSize.values.first,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                spreadRadius: 3,
                                                blurRadius:
                                                    7, // changes position of shadow
                                              ),
                                            ],
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50.0))),
                                        child: IconButton(
                                            onPressed: () {
                                              var visiters = FirebaseFirestore
                                                  .instance
                                                  .collection('users')
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .collection('visiters')
                                                  .snapshots();
                                              nextScreen(
                                                  context,
                                                  MyVisitersPage(
                                                    visiters: visiters,
                                                  ));
                                            },
                                            icon: const Icon(
                                              Icons.info,
                                              size: 30,
                                              color: Colors.white,
                                            ))),
                                    const Text(
                                      "Мои гости",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius:
                                                  7, // changes position of shadow
                                            ),
                                          ],
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50.0))),
                                      child: IconButton(
                                        onPressed: () {
                                          global.GlobalPol = widget.pol;
                                          nextScreenReplace(
                                              context,
                                              ProfilePageEdit(
                                                email: widget.email,
                                                userName: widget.userName,
                                                about: widget.about,
                                                age: widget.age,
                                                hobbi: widget.hobbi,
                                                deti: widget.deti,
                                                city: widget.city,
                                                rost: widget.rost,
                                              ));
                                        },
                                        icon: const Icon(
                                          Icons.mode_edit_sharp,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Изменить профиль",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                                //const SizedBox(width: 7,),
                                Column(
                                  children: [
                                    Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                spreadRadius: 3,
                                                blurRadius:
                                                    7, // changes position of shadow
                                              ),
                                            ],
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50.0))),
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                global.selectedIndex = 2;
                                              });
                                              nextScreenReplace(
                                                  context,
                                                  ProfilesList(
                                                    group: widget.group,
                                                  ));
                                            },
                                            icon: const Icon(
                                              Icons.person,
                                              size: 35,
                                              color: Colors.white,
                                            ))),
                                    const Text(
                                      "Люди",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            'Подарки',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.normal),
                          ),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('gifts')
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.data != null) {
                                  if (snapshot.data!.docs.length != 0) {
                                    return ifGiftsSnapshotNotEmtpry(snapshot);
                                  } else {
                                    return ifGiftsSnaphotEmpty(snapshot);
                                  }
                                } else {
                                  return ifGiftsSnaphotEmpty(snapshot);
                                }
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Фотографии',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.normal),
                          ),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('images')
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.data != null) {
                                  if (snapshot.data!.docs.length != 0) {
                                    return ifImageSnapshotNotEmtpry(snapshot);
                                  } else {
                                    return ifImageSnaphotEmpty(snapshot);
                                  }
                                } else {
                                  return ifImageSnaphotEmpty(snapshot);
                                }
                              }),
                        ])
                  : const SizedBox(),
            ),
          ),
        )
      ],
    );
  }

  ifImageSnapshotNotEmtpry(
    AsyncSnapshot snapshot,
  ) {
    List urls = [];
    List initList = [];
    for (int i = 0; i < snapshot.data.docs.length; i++) {
      urls.add(snapshot.data.docs[i]['url']);
      initList.add(snapshot.data.docs[i]['url']);
    }
    urls.sort(
      (a, b) {
        return a.toString().contains('avatar')
            ? -1
            : b.toString().contains('avatar')
                ? 1
                : 0;
      },
    );

    print(urls);
    print(initList);

    return Column(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15))),
                  height: 300,
                  child: InkWell(
                      onTap: () {
                        showDialog(
                          builder: (context) => AlertDialog(
                            iconPadding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.8),
                            icon: IconButton(
                              splashRadius: 20,
                              icon: const Icon(Icons.more_horiz_rounded),
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return TextButton(
                                        child: const Text('Удалить'),
                                        onPressed: () {
                                          print(initList.indexOf(urls[index]));
                                          deleteImage(snapshot,
                                              initList.indexOf(urls[index]));
                                        },
                                      );
                                    });
                              },
                            ),
                            iconColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(2),
                            title: Container(
                              decoration: const BoxDecoration(),
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                urls[index],
                              ),
                            ),
                          ),
                          context: context,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        width: 100,
                        child: Image.network(urls[index], fit: BoxFit.cover),
                      )),
                );
              },
              itemCount: urls.length),
        ),
        ElevatedButton(
            onPressed: () async {
              selectImages();

              imageFileList!.clear();
            },
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.orangeAccent)),
            child: const Text(
              "Добавить фотографии",
              style: TextStyle(color: Colors.white, fontSize: 16),
            )),
      ],
    );
  }

  ifImageSnaphotEmpty(AsyncSnapshot snapshot) {
    return Column(
      children: [
        const Text(
          "Нет фотографий",
          style: TextStyle(color: Colors.white),
        ),
        ElevatedButton(
          onPressed: () async {
            selectImages();
          },
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.orangeAccent)),
          child: const Text(
            "Добавить фотографии",
            style: TextStyle(color: Colors.black),
          ),
        )
      ],
    );
  }

  loadImage(String name, XFile image) async {
    var time = DateTime.now();
    FirebaseStorage storage = FirebaseStorage.instance;

    await storage
        .ref('$name+$time+${FirebaseAuth.instance.currentUser!.uid}')
        .putFile(File(image.path));
    var downloadUrl = await storage
        .ref('$name+$time+${FirebaseAuth.instance.currentUser!.uid}')
        .getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('images')
        .add({"url": downloadUrl});
  }

  ifGiftsSnapshotNotEmtpry(
    AsyncSnapshot snapshot,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15))),
                  height: 300,
                  child: InkWell(
                      onTap: () {
                        showDialog(
                          builder: (context) => AlertDialog(
                            iconPadding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.8),
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(2),
                            title: Container(
                              decoration: const BoxDecoration(),
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                snapshot.data.docs[index]['url'],
                              ),
                            ),
                          ),
                          context: context,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        width: 100,
                        child: Image.network(snapshot.data.docs[index]['url'],
                            fit: BoxFit.cover),
                      )),
                );
              },
              itemCount:
                  (snapshot.data != null ? (snapshot.data!).docs.length : 0)),
        ),
      ],
    );
  }

  ifGiftsSnaphotEmpty(AsyncSnapshot snapshot) {
    return const Column(
      children: [
        Text(
          "Нет подарков",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  deleteImage(snapshot, index) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.17,
            child: Column(
              children: [
                const DefaultTextStyle(
                  style: TextStyle(
                      decorationColor: Colors.white,
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                      fontSize: 16),
                  child: Text("Вы уверены, что хотите удалить это фото?"),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent),
                        onPressed: () async {
                          FirebaseStorage.instance
                              .refFromURL(snapshot.data.docs[index]['url'])
                              .delete();
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('images')
                              .doc(snapshot.data.docs[index].id)
                              .delete();

                          nextScreenReplace(
                              context,
                              ProfilePage(
                                  email: widget.email,
                                  userName: widget.userName,
                                  about: widget.about,
                                  age: widget.age,
                                  pol: widget.pol,
                                  group: widget.group,
                                  deti: widget.deti,
                                  rost: widget.rost,
                                  city: widget.city,
                                  hobbi: widget.hobbi));
                        },
                        child: const Icon(Icons.check)),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close)),
                  ],
                )
              ],
            ),
          );
        });
  }
}
