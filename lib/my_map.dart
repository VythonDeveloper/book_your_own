// ignore_for_file: no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final rideDetails;
  const MyMap({Key? key, this.rideDetails}) : super(key: key);
  @override
  _MyMapState createState() => _MyMapState(rideDetails: rideDetails);
}

class _MyMapState extends State<MyMap> {
  final rideDetails;
  _MyMapState({this.rideDetails});

  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    imageToBytes();
  }

  imageToBytes() async {
    bytes = (await NetworkAssetBundle(
                Uri.parse("https://www.fluttercampus.com/img/car.png"))
            .load("https://www.fluttercampus.com/img/car.png"))
        .buffer
        .asUint8List();
    setState(() {});
  }

  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bytes == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection('rideRequest')
                  .doc(rideDetails['id'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (_added) {
                  mymap(snapshot.data);
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return GoogleMap(
                  mapType: MapType.normal,
                  buildingsEnabled: false,
                  compassEnabled: true,
                  liteModeEnabled: false,
                  mapToolbarEnabled: true,
                  markers: {
                    Marker(
                      position: LatLng(snapshot.data['driverLat'],
                          snapshot.data['driverLng']),
                      markerId: const MarkerId('driverId'),
                      icon: BitmapDescriptor.fromBytes(bytes!),
                    ),
                    Marker(
                      position: LatLng(
                          snapshot.data['pickLat'], snapshot.data['pickLng']),
                      markerId: const MarkerId('originId'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                    ),
                    Marker(
                      position: LatLng(
                          snapshot.data['dropLat'], snapshot.data['dropLng']),
                      markerId: const MarkerId('destinationId'),
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                      target: LatLng(snapshot.data['driverLat'],
                          snapshot.data['driverLng']),
                      zoom: 16),
                  onMapCreated: (GoogleMapController controller) async {
                    setState(
                      () {
                        _controller = controller;
                        _added = true;
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> mymap(ds) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            ds['driverLat'],
            ds['driverLng'],
          ),
          zoom: 16,
        ),
      ),
    );
  }
}
