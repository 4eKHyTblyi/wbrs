import 'package:flutter/material.dart';
import 'package:wbrs/app/helper/global.dart';
import 'package:wbrs/app/pages/auth/somebody_profile.dart';
import 'package:wbrs/app/widgets/circle_user_image.dart';
import 'package:wbrs/app/widgets/widgets.dart';

import '../../widgets/bottom_nav_bar.dart';

class Users extends StatelessWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context) {

    showConfirmMessage(Function callback, String action) {

      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('Вы уверены, что хотите $action пользователя?', style: const TextStyle(fontSize: 20),),
          actions: [
            TextButton(onPressed: (){
              callback();
              Navigator.pop(context);
            }, child: const Text('Да')),
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: const Text('Нет')),
          ],
        );
      });
    }

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
        Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
            ),
            bottomNavigationBar: const MyBottomNavigationBar(),
            body: Container(
              padding: const EdgeInsets.all(5),
              child: StreamBuilder(stream: firebaseFirestore.collection('users').orderBy('email', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => nextScreen(context, SomebodyProfile(uid: snapshot.data!.docs[index].id, photoUrl: snapshot.data!.docs[index]['profilePic'], name: snapshot.data!.docs[index]['fullName'], userInfo: snapshot.data!.docs[index].data(),)),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      snapshot.data!.docs[index]['status'] == 'blocked'
                                          ? const Icon(Icons.block, color: Colors.green,size: 40,)
                                          :IconButton(onPressed: (){
                                        showConfirmMessage((){
                                          firebaseFirestore.collection('users').doc(snapshot.data!.docs[index].id).update({'status': 'blocked'});
                                        }, 'заблокировать');
                                      }, icon: const Icon(Icons.block, color: Colors.redAccent,size: 40,),),
                                      UserImage(userPhotoUrl: snapshot.data!.docs[index]['profilePic'], group: snapshot.data!.docs[index]["группа"], width: 50, height: 50),
                                      IconButton(onPressed: (){
                                        showConfirmMessage((){
                                          firebaseFirestore.collection('TOKENS').doc(snapshot.data!.docs[index].id).delete();
                                          firebaseFirestore.collection('users').doc(snapshot.data!.docs[index].id).delete();
                                        }, 'удалить');
                                      }, icon: const Icon(Icons.delete_outline_rounded, color: Colors.red,size: 40,),),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [

                                      Text(snapshot.data!.docs[index]['fullName']),
                                      Text(snapshot.data!.docs[index]['email']),
                                      Text(snapshot.data!.docs[index]['city']),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),



          ),
        )
      ],
    );
  }
}
