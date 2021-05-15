import 'dart:async';

import 'package:alaket_ios/all_task.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TasksUI extends StatefulWidget {
  final Tasks tasks;
  TasksUI({Key key, this.tasks}) : super(key: key);

  @override
  _TasksUIState createState() => _TasksUIState();
}

class _TasksUIState extends State<TasksUI> with TickerProviderStateMixin {
  String _address;
  Geolocator _geolocator = Geolocator();
  Widget twoColumns(Widget one, Widget two) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [one, two],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setAddressToSearch(widget.tasks.lat, widget.tasks.lng);
  }

  Future<Null> setAddressToSearch(double latitude, double longitude) async {
    List<Placemark> newPlace =
        await _geolocator.placemarkFromCoordinates(latitude, longitude);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    String sth = placeMark.thoroughfare;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;

    String addressFull =
        "${sth} ${name}, ${administrativeArea} ${postalCode}, ${country}";

    setState(() {
      _address = addressFull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25), color: Colors.grey.shade100),
      padding: EdgeInsets.all(5),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 125,
                width: 125,
                child: CachedNetworkImage(
                  imageUrl: widget.tasks.image,
                  imageBuilder: (context, imageProvider) => Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2)),
                          child: Center(
                            child: Text(
                              "₸" + widget.tasks.cash,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  placeholderFadeInDuration: Duration(milliseconds: 500),
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300].withOpacity(0.3),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          Flexible(
              flex: 5,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.tasks.vehicle_type,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "№" + widget.tasks.uidTask,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      _address ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.tasks.type_cash,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      widget.tasks.description,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      widget.tasks.time,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
