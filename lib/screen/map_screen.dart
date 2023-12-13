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
  final _markers = <Marker>{};
  final _cats = [
    {
      //"postURL" : String,
      "postUserName": "예린",
      "latitude": 36.832225,
      "longitude": 127.177981,
    }
  ];
  @override
  void initState() {
    // TODO: implement initState
    _markers.addAll(_cats.map(
        (e) => Marker(
          markerId: MarkerId(e['postUserName'] as String),
          infoWindow: InfoWindow(title: e['postUserName'] as String),
          position: LatLng(
            e['latitude'] as double,
            e['longitude'] as double,
          )
        )
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: GoogleMap(
       initialCameraPosition: MapScreen._smu,
       myLocationEnabled: true,
       mapType: MapType.normal,
       zoomGesturesEnabled: true,
       zoomControlsEnabled: true,

       markers: _markers,
     ),
    );
  }
}
