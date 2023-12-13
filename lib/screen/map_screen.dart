import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapScreen extends StatefulWidget {
  static const CameraPosition _smu =
      CameraPosition(target: LatLng(36.832225, 127.177981),
      zoom: 15);

  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CollectionReference _reference =
  FirebaseFirestore.instance.collection('uploadImgTest');
  final _markers = <Marker>{};
  bool startSetMark=false;
  List<Map<String, dynamic>> _cats = [
    {
      'postId': '143776c0-99df-11ee-a819-4314bc619ba7',
      'postURL': 'https://firebasestorage.googleapis.com/v0/b/smu-catsns-92e01.appspot.com/o/testImg%2F134a7eb0-99df-11ee-a819-4314bc619ba7?alt=media&token=a4e095fa-f31c-42c6-b294-e5e03b27b1ae',
      'postUserEmail': 'test2@email.com',
      'like': 0,
      'latitude': 36.8330,
      'longitude': 127.1779,
    },
    {
      'postId': '883aa3a0-99ec-11ee-9daf-0b239255e16d',
      'postURL': 'https://firebasestorage.googleapis.com/v0/b/smu-catsns-92e01.appspot.com/o/testImg%2F873c4670-99ec-11ee-9daf-0b239255e16d?alt=media&token=1398e484-8836-4ed3-b95e-0018fcca333f',
      'postUserEmail': 'test2@email.com',
      'like': 1,
      'latitude': 36.8330017,
      'longitude': 127.1768083,
    },
    {
      'postId': 'fb78fc10-9a08-11ee-b187-f5560241b81c',
      'postURL': 'https://firebasestorage.googleapis.com/v0/b/smu-catsns-92e01.appspot.com/o/testImg%2Ffaa2c050-9a08-11ee-b187-f5560241b81c?alt=media&token=05e19348-f622-4eda-94a7-f6cfd5c68aa5',
      'postUserEmail': 'test2@email.com',
      'like': 0,
      'latitude':  36.8313,
      'longitude':127.1792,
    }
  ];

  Future<void> makeMarker() async {
    FirebaseFirestore.instance
        .collection('uploadImgTest')
        .get()
        .then((value) {
      for (var thisItem in value.docs) {
       // print('길이');
       // print(value.docs.length);
        Map<String, dynamic> map = {
          "postId": thisItem['postId'],
          "postURL": thisItem['postUrl'],
          "postUserEmail": thisItem['user'],
          "like": thisItem['like'],
          "latitude": thisItem["latitude"],
          "longitude": thisItem["longitude"],
        };
        _cats.add(map);
      }
      //print(_cats);
    //  print(_markers);
      print(_cats.length);
      print(_cats);
    });
    Future.delayed(Duration(seconds: 10),(){mark();});

  }

  Future<void> mark() async{
        _markers.addAll(
            _cats.map(
                    (e) =>Marker(
                      onTap: (){
                        showPost(e['postUserEmail'], e['postURL'], e['like'], e['postId']);},
                      markerId: MarkerId(e['postId'] as String),
                      infoWindow: InfoWindow(
                          title: e['postUserEmail'] as String),
                      position: LatLng(
                        e['longitude'] as double,
                        e['latitude'] as double,
                      )
                  )
            ));

          setState(() {
            startSetMark = true;
          });
           print('//////mark////');
      print(_markers);
    }


  void showPost(String userName
      , String ImageUrl, int likes, String postId,) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext conext, StateSetter setState) {
                return SingleChildScrollView(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    shadowColor: Colors.black,
                    title:
                    new Column(
                      children: <Widget>[
                        new Text(
                          '유저 이름 : ${userName}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Image.network(
                          ImageUrl,
                          scale: 1.0,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      new Column(
                        children: [
                          Text(
                            '$likes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          new Container(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black45,
                                  onPrimary: Colors.white,
                                  shadowColor: Colors.black12,
                                ),
                                onPressed: () {
                                  //사진 저장
                                },
                                child: Text('사진 저장하기'),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              new ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red[700],
                                    onPrimary: Colors.white,
                                    shadowColor: Colors.black12,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('고양이 더 구경하기')),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // makeMarker();
    _markers.addAll(
        _cats.map(
                (e) =>Marker(
                markerId: MarkerId(e['postId'] as String),
                infoWindow: InfoWindow(
                    title: e['postUserEmail'] as String),
                position: LatLng(
                  e['latitude'] as double,
                  e['longitude'] as double,
                )
            )
        ));
  if(this.mounted){
    setState(() {
      startSetMark = true;
    });
  }
    //mark();
    //print(_cats);
    //mark();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:startSetMark ?
      GoogleMap(
        initialCameraPosition: MapScreen._smu,
        myLocationEnabled: true,
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        markers: Set.from(_markers),
      ): Container(
         child: Text('loading'),
      ),
    );
  }

}


