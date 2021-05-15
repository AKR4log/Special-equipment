import 'dart:io';
import 'dart:math';

import 'package:alaket_ios/my_texnika.dart';
import 'package:alaket_ios/pages/loging/loging.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTab extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  String _view_profile = 'Заказчик';
  bool is_worker = false;
  String _reg_nnumber_profile = '№0000000000000';
  String _name = '';
  String _lname = '';
  bool uploaded = false;
  String uri;
  String verificationID;
  String _radius = '0';
  String avatarsAuthUser;
  File _imageFile;
  final picker = ImagePicker();
  bool _sw_show_fio = true;
  bool _sw_show_date_reg = true;
  bool _sw_show_phone = true;
  bool _sw_show_notifications = false;
  bool _sw_show_chat_messages = false;
  TextEditingController _text_name_controller = TextEditingController();
  TextEditingController _text_lname_controller = TextEditingController();
  TextEditingController _text_radius_controller = TextEditingController();
  final double _height_switch_container = 30.0;
  bool status = false;
  TextEditingController controllerPhone = TextEditingController();
  TextEditingController controllerCode = TextEditingController();

  init() {
    var authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(authUser.uid)
          .get()
          .then((value) {
        if (value.data() != null) {
          setState(() {
            _name = value.data()['name'];
            _lname = value.data()['surname'];
            status = value.data()['status'];
            avatarsAuthUser = value.data()['avatars'];
          });
          print(value.data()['avatars']);
        }
      });
    }
  }

  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    init();
    _text_name_controller = TextEditingController();
    _text_lname_controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _text_name_controller.text = _name;
    _text_lname_controller.text = _lname;
    _text_radius_controller.text = _radius;
    _status = false;

    Widget buttonReplaceType = Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
          color: Color.fromRGBO(78, 41, 254, 1),
          borderRadius: BorderRadius.circular(15)),
      child: TextButton(
        child: Text(status ? 'СТАТЬ ЗАКАЗЧИКОМ' : 'СТАТЬ ПОДРЯДЧИКОМ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (FirebaseAuth.instance.currentUser != null) {
            var authUser = FirebaseAuth.instance.currentUser;
            FirebaseFirestore.instance
                .collection("users")
                .doc(authUser.uid)
                .update({
              "status": !status,
            });
            setState(() {
              status = !status;
            });
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => LoginPage()));
          }
        },
      ),
    );

    Future uploadImageToFirebase(BuildContext context) async {
      var ran = Random();
      var fileName = ran.nextInt(10000);
      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('avatars/$fileName');
      firebase_storage.UploadTask uploadTask =
          firebaseStorageRef.putFile(File(_imageFile.path));
      setState(() {
        uploaded = true;
      });
      uploadTask.snapshotEvents.listen((event) {}).onData((snapshot) {
        if (snapshot.state == firebase_storage.TaskState.success) {
          firebaseStorageRef.getDownloadURL().then((snapshot) {
            setState(() {
              uploaded = false;
              avatarsAuthUser = snapshot.toString();
            });
            var uid = FirebaseAuth.instance.currentUser.uid;
            CollectionReference refU =
                FirebaseFirestore.instance.collection("users");
            refU.doc(uid).update({
              "avatars": snapshot.toString(),
            });
          });
        }
      });
    }

    Widget divider = Container(
      height: 1.0,
      color: Colors.blueGrey.shade50,
      margin: EdgeInsets.only(left: 8.0, right: 8.0),
    );

    return Scaffold(
        body: Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            final pickedFile = await picker.getImage(
                                source: ImageSource.gallery);

                            setState(() {
                              _imageFile = File(pickedFile.path);
                            });
                            uploadImageToFirebase(context);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginPage()));
                          }
                        },
                        child: Container(
                          width: 125.0,
                          height: 125.0,
                          child: Stack(
                            children: [
                              avatarsAuthUser == null || avatarsAuthUser == ''
                                  ? Container(
                                      width: 125.0,
                                      height: 125.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: ExactAssetImage(
                                              'assets/icons/ic_icon_user_type_req.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ))
                                  : Container(
                                      width: 125.0,
                                      height: 125.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(96),
                                        child: CachedNetworkImage(
                                          imageUrl: avatarsAuthUser,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholderFadeInDuration:
                                              Duration(milliseconds: 500),
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[300]
                                                .withOpacity(0.3),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                              uploaded
                                  ? Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        width: 35,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                            color: Colors.white),
                                        margin: EdgeInsets.only(
                                            bottom: 2, right: 2),
                                        height: 35,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(status ? 'Подрядчик' : 'Заказчик',
                              style: TextStyle(fontSize: 24.0)),
                        ),
                        Container(
                          child: Text(
                              FirebaseAuth.instance.currentUser != null
                                  ? "№" + FirebaseAuth.instance.currentUser.uid
                                  : "№00000000000000000",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.0)),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: buttonReplaceType,
              ),
              divider,
              status
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => MyTex()));
                      },
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 15.0),
                            child: Container(
                              height: _height_switch_container,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Моя техника',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                    )
                  : SizedBox(),
              Container(
                color: Color(0xffFFFFFF),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Персональные данные',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Имя",
                                  ),
                                  style: TextStyle(fontSize: 12.0),
                                  enabled: !_status,
                                  autofocus: !_status,
                                  controller: _text_name_controller,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Фамилия",
                                  ),
                                  style: TextStyle(fontSize: 12.0),
                                  enabled: !_status,
                                  autofocus: !_status,
                                  controller: _text_lname_controller,
                                ),
                              ),
                            ],
                          )),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: TextButton(
                            onPressed: () {
                              if (FirebaseAuth.instance.currentUser != null) {
                                var authUser =
                                    FirebaseAuth.instance.currentUser;
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(authUser.uid)
                                    .update({
                                  "name": _text_name_controller.text.trim(),
                                  "surname": _text_lname_controller.text.trim(),
                                });
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                              }
                            },
                            child: Text('Сохранить')),
                      )
                    ],
                  ),
                ),
              ),
              divider,
              status
                  ? Container(
                      color: Color(0xffFFFFFF),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Радиус поиска заказов',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0, right: 16.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          hintText:
                                              "Радиус поиска (0, если нет ограничений), км.",
                                        ),
                                        style: TextStyle(fontSize: 12.0),
                                        enabled: !_status,
                                        autofocus: !_status,
                                        controller: _text_radius_controller,
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              divider,
              Padding(
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                child: Container(
                  height: _height_switch_container,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Поделиться ссылкой',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      Icon(Icons.share,
                          size: 20.0, color: Colors.blueGrey.shade700)
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }
}
