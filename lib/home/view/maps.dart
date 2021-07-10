import 'dart:async';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login/app/bloc/app_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart';

class FireMap extends StatefulWidget {
  @override
  _FireMapState createState() => _FireMapState();
}

class _FireMapState extends State<FireMap> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  Location location = new Location();
  late GoogleMapController mapController;
  // Set<Marker> _markers = {};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late Stream<dynamic> query;
  BehaviorSubject<double> radius = BehaviorSubject.seeded(100.0);
  late StreamSubscription subscription;

  static final CameraPosition _kInitialPosition =
      const CameraPosition(zoom: 16, bearing: 30, target: LatLng(23.5, 55.2));

  CameraPosition _position = _kInitialPosition;

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _addMarker();
    super.initState();
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    int _markerIdCounter = 1;
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    documentList.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      GeoPoint pos = data['position']['geopoint'];
      double distance = data['distance'];
      var marker = Marker(
          markerId: markerId,
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow:
              InfoWindow(title: 'magic marker $distance', snippet: '*'));
      setState(() {
        markers[markerId] = marker;
      });
    });
  }

  _startQuery() async {
    LocationData pos = await location.getLocation();
    double lat = pos.latitude!;
    double lng = pos.longitude!;
    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
    final zoomMap = {
      100.0: 12.0,
      200.0: 10.0,
      300.0: 7.0,
      400.0: 6.0,
      500.0: 5.0
    };

    final zoom = zoomMap[value];
    mapController.moveCamera(CameraUpdate.zoomTo(zoom!));
    setState(() {
      radius.add(value);
    });
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  _addMarker() async {
    int _markerIdCounter = 1;
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    var pos = await location.getLocation();

    var marker = Marker(
        position: LatLng(pos.latitude as double, pos.longitude as double),
        markerId: markerId,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: '$markerIdVal'));
    // _markers.add(marker);

    print('something fucking markers are added $markers');
    // var marker=Marker(markerId: markerId,position: mapController.)
  }

  _onMapCreated(GoogleMapController controller) {
    _startQuery();
    setState(() {
      mapController = controller;
    });
  }

  Future<DocumentReference> _addGeoPoint() async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(
        latitude: pos.latitude as double, longitude: pos.longitude as double);
    return firestore
        .collection('locations')
        .add({'positon': point.data, 'name': 'yay '});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
            initialCameraPosition: _kInitialPosition,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            mapType: MapType.hybrid,
            onCameraMove: _updateCameraPosition,
            markers: Set<Marker>.of(markers.values)),
        Positioned(
          bottom: 90,
          right: 10,
          child: ElevatedButton(
            onPressed: _addGeoPoint,
            child: Icon(
              Icons.pin_drop,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 10,
          child: Slider(
            min: 100.0,
            max: 500.0,
            divisions: 4,
            value: radius.value,
            label: 'Radius ${radius.value}km',
            activeColor: Colors.green,
            inactiveColor: Colors.green.withOpacity(0.2),
            onChanged: _updateQuery,
          ),
        )
      ],
    );
  }
}
