import 'dart:typed_data';
import 'package:book_your_own/colors.dart';
import 'package:book_your_own/components.dart';
import 'package:book_your_own/constants.dart';
import 'package:book_your_own/location_service.dart';
import 'package:book_your_own/services/notification_function.dart';
import 'package:book_your_own/services/pdf_invoice_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:page_route_transition/page_route_transition.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

class TrackTripUi extends StatefulWidget {
  final rideDetails;
  TrackTripUi({Key? key, this.rideDetails}) : super(key: key);
  @override
  _TrackTripUiState createState() =>
      _TrackTripUiState(rideDetails: rideDetails);
}

class _TrackTripUiState extends State<TrackTripUi> {
  final rideDetails;
  _TrackTripUiState({this.rideDetails});
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    imageToBytes();
    Constants.rideDetails = {};
    _getDirection();
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
  Set<Polyline> _polylines = <Polyline>{};
  int _polylineIdCounter = 1;

  _getDirection() async {
    var directions = await LocationService()
        .getDirections(rideDetails['pickAddress'], rideDetails['dropAddress']);
    _goToThePlace(
      directions['start_location']['lat'],
      directions['start_location']['lng'],
      directions['end_location']['lat'],
      directions['end_location']['lng'],
      directions['bounds_ne'],
      directions['bounds_sw'],
    );
    _polylines = {};
    _setPolyline(directions['polyline_decoded']);
  }

  Future<void> _goToThePlace(
      double originLat,
      double originLng,
      double destLat,
      double destLng,
      Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw) async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(originLat, originLng),
      zoom: 12,
    )));

    _controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          bytes == null
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
                      markers: {
                        Marker(
                          position: LatLng(snapshot.data['driverLat'],
                              snapshot.data['driverLng']),
                          markerId: const MarkerId('driverId'),
                          icon: BitmapDescriptor.fromBytes(bytes!),
                        ),
                        Marker(
                          position: LatLng(snapshot.data['pickLat'],
                              snapshot.data['pickLng']),
                          markerId: const MarkerId('originId'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                        ),
                        Marker(
                          position: LatLng(snapshot.data['dropLat'],
                              snapshot.data['dropLng']),
                          markerId: const MarkerId('destinationId'),
                          icon: BitmapDescriptor.defaultMarker,
                        ),
                      },
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(snapshot.data['driverLat'],
                            snapshot.data['driverLng']),
                        zoom: 18,
                        tilt: 50,
                        bearing: 30,
                      ),
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
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: GestureDetector(
                      onTap: () {
                        PageRouteTransition.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.arrow_back,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Spacer(),
                  MaterialButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        isScrollControlled: true,
                        enableDrag: false,
                        isDismissible: false,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        context: context,
                        builder: (BuildContext context) {
                          return tripDetails();
                        },
                      );
                    },
                    padding: EdgeInsets.zero,
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: const SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Trip Details',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          zoom: 18,
          tilt: 50,
          bearing: 30,
        ),
      ),
    );
  }

  Widget tripDetails() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 700),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trip Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "Trk. Id " + rideDetails['id'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'lib/assets/icons/homeMarker.svg',
                                    color: Colors.white,
                                    height: 15,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Source',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              rideDetails['pickAddress'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'lib/assets/icons/destination.svg',
                                    color: Colors.white,
                                    height: 15,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    'Destination',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              rideDetails['dropAddress'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            color: Color(0xFF90CAF9),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.map,
                                color: Color(0xFF0D47A1),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                rideDetails['distance'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: Color(0xFFFFE082),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.watch_later_outlined,
                                color: Color(0xFFFF6F00),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                rideDetails['transitTime'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFFFF6F00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            color: Color(0xFFA5D6A7),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.attach_money_rounded,
                                color: Color(0xFF1B5E20),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '₹ ' + Constants.cF.format(rideDetails['cost']),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Driver: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: rideDetails['driverName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Vehicle: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: rideDetails['vehicleType'] +
                              ', ' +
                              rideDetails['vehicleName'] +
                              ', ' +
                              rideDetails['vehicleNumber'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Start OTP: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: rideDetails['startOtp'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'End OTP: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: rideDetails['endOtp'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  rideDetails['status'] == "Completed"
                      ? Center(
                          child: OutlinedButton(
                            onPressed: () async {
                              final pdfFile =
                                  await PdfInvoiceApi.generate(rideDetails);
                              PdfInvoiceApi.openFile(pdfFile);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Color(0xFF3682F4), width: 1),
                            ),
                            child: Text(
                              "Download Invoice",
                              style: TextStyle(color: Color(0xFF3682F4)),
                            ),
                          ),
                        )
                      : rideDetails['status'] == "Cancelled"
                          ? Center(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Color(0xFFE6928C), width: 1),
                                ),
                                child: Text(
                                  "Cancelled",
                                  style: TextStyle(color: Color(0xFFE6928C)),
                                ),
                              ),
                            )
                          : rideDetails['status'] == "Active"
                              ? Center(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      Uri url = Uri.parse(
                                          'tel:' + rideDetails['driverMobile']);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        throw "cannot make call";
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Color.fromARGB(
                                                255, 54, 130, 244),
                                            width: 1)),
                                    child: Text(
                                      "Call - " +
                                          rideDetails['driverName']
                                              .split(' ')[0],
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 54, 130, 244)),
                                    ),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          showLoading(context);
                                          FirebaseFirestore.instance
                                              .collection('rideRequest')
                                              .doc(rideDetails['id'])
                                              .get()
                                              .then((value) {
                                            if (value.data()!['status'] ==
                                                "Pending") {
                                              FirebaseFirestore.instance
                                                  .collection('rideRequest')
                                                  .doc(rideDetails['id'])
                                                  .update(
                                                      {'status': 'Cancelled'});

                                              FirebaseFirestore.instance
                                                  .collection('drivers')
                                                  .doc(rideDetails['driverId'])
                                                  .update({
                                                'busyTime':
                                                    FieldValue.arrayRemove([
                                                  {
                                                    'from': rideDetails[
                                                        'tripStartTime'],
                                                    'to': rideDetails[
                                                        'tripEndTime']
                                                  }
                                                ])
                                              });
                                              sendNotification(
                                                tokenIdList: [
                                                  rideDetails['driverTokenId']
                                                ],
                                                heading: 'Oops! Trip Cancelled',
                                                contents:
                                                    'Customer cancelled the trip. ',
                                              );
                                              PageRouteTransition.pop(context);
                                            } else {
                                              showSnackBar(context,
                                                  "Cannot cancel the trip. It is Active.");
                                            }
                                          });
                                          PageRouteTransition.pop(context);
                                          PageRouteTransition.pop(context);
                                        },
                                        style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: Colors.red, width: 1)),
                                        child: Text(
                                          "Cancel Trip",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          Uri url = Uri.parse('tel:' +
                                              rideDetails['driverMobile']);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          } else {
                                            throw "cannot make call";
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 54, 130, 244),
                                                width: 1)),
                                        child: Text(
                                          "Call - " +
                                              rideDetails['driverName']
                                                  .split(' ')[0],
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 54, 130, 244)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
