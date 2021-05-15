import 'dart:io';
import 'dart:math';

import 'package:alaket_ios/home_fragment.dart';
import 'package:alaket_ios/myCatTex.dart';
import 'package:alaket_ios/my_texnika.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateMyTex extends StatefulWidget {
  final String myCatTex;
  CreateMyTex({Key key, this.myCatTex}) : super(key: key);

  @override
  _CreateMyTexState createState() => _CreateMyTexState();
}

class _CreateMyTexState extends State<CreateMyTex> {
  TextEditingController controllerDescription = new TextEditingController();
  bool errorTex = false, errorTexUti = false;
  File _imageFile;
  bool workers = false;
  bool uploaded = false;
  String uri;
  final picker = ImagePicker();

  Future uploadImageToFirebase(BuildContext context) async {
    var ran = Random();
    var fileName = ran.nextInt(10000);
    firebase_storage.Reference firebaseStorageRef =
        firebase_storage.FirebaseStorage.instance.ref().child('tex/$fileName');
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
            uri = snapshot.toString();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
        elevation: 0,
        title: Text(
          'Создание техники',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile =
                      await picker.getImage(source: ImageSource.gallery);

                  setState(() {
                    _imageFile = File(pickedFile.path);
                  });
                  uploadImageToFirebase(context);
                },
                child: Container(
                  width: 75.0,
                  height: 75.0,
                  child: Stack(
                    children: [
                      uri == null || uri == ''
                          ? Container(
                              width: 75.0,
                              decoration: BoxDecoration(
                                  color: errorTexUti
                                      ? Colors.red[300]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15)),
                              height: 75.0,
                              child: Icon(
                                Icons.local_shipping_rounded,
                                color:
                                    errorTexUti ? Colors.white : Colors.black,
                              ))
                          : Container(
                              width: 75.0,
                              height: 75.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: uri,
                                  imageBuilder: (context, imageProvider) =>
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
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300].withOpacity(0.3),
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
                                width: 25,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35),
                                    color: Colors.white.withOpacity(0.4)),
                                margin: EdgeInsets.only(bottom: 2, right: 2),
                                height: 25,
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
              workers
                  ? SizedBox()
                  : GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyCatTexnik()));
                      },
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            widget.myCatTex ?? 'Выберете технику',
                            style: TextStyle(
                              color: errorTex ? Colors.red : Colors.black,
                            ),
                          )),
                    ),
              Row(
                children: [
                  Switch(
                    value: workers,
                    onChanged: (value) {
                      setState(() {
                        workers = value;
                      });
                    },
                    activeTrackColor: Colors.deepOrange.shade200,
                    activeColor: Colors.deepOrange.shade700,
                  ),
                  Text(
                    'Рабочие',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: controllerDescription,
                decoration: const InputDecoration(
                  hintText: "Описание",
                ),
                maxLines: 5,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              Container(
                height: 45,
                margin: EdgeInsets.only(top: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blueGrey.withOpacity(0.2)),
                child: TextButton(
                    onPressed: () {
                      if (uri != null && uri != '') {
                        if (workers) {
                          var uidTex = Uuid().v4();
                          var uid = FirebaseAuth.instance.currentUser.uid;
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('myTex')
                              .doc(uidTex)
                              .set({
                            "description":
                                controllerDescription.text.trim() ?? null,
                            "timeCreated": DateTime.now().toUtc().toString(),
                            "vehicle_type":
                                workers ? 'Рабочие' : widget.myCatTex,
                            "uriTex": uri,
                            "workers": workers,
                            "uidTex": uidTex,
                            "uidUser": uid
                          });

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => MyTex()));
                        } else if (widget.myCatTex != null) {
                          var uidTex = Uuid().v4();
                          var uid = FirebaseAuth.instance.currentUser.uid;
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('myTex')
                              .doc(uidTex)
                              .set({
                            "description":
                                controllerDescription.text.trim() ?? null,
                            "timeCreated": DateTime.now().toUtc().toString(),
                            "vehicle_type":
                                workers ? 'Рабочие' : widget.myCatTex,
                            "uriTex": uri,
                            "workers": workers,
                            "uidTex": uidTex,
                            "uidUser": uid
                          });

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => MyTex()));
                        } else {
                          setState(() {
                            errorTex = true;
                          });
                        }
                      } else {
                        setState(() {
                          errorTexUti = true;
                        });
                      }
                    },
                    child: Text(
                      'Создать',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
