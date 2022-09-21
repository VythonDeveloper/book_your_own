import 'dart:ui';
import 'package:book_your_own/BookingUI/page1_ui.dart';
import 'package:book_your_own/BookingUI/page2_ui.dart';
import 'package:book_your_own/BookingUI/page3_ui.dart';
import 'package:book_your_own/BookingUI/page4_ui.dart';
import 'package:book_your_own/colors.dart';
import 'package:book_your_own/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:book_your_own/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_route_transition/page_route_transition.dart';

import '../constants.dart';

class VehicleBookingUi extends StatefulWidget {
  const VehicleBookingUi({Key? key}) : super(key: key);

  @override
  State<VehicleBookingUi> createState() => _VehicleBookingUiState();
}

class _VehicleBookingUiState extends State<VehicleBookingUi> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];
  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  bool _isTripAvailable = false;
  bool _isValidating = false;
  // bool? _isValidated;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.0805637963934, 78.96332190797392),
    zoom: 4.5,
  );

  @override
  void initState() {
    super.initState();
    _originController.text = '';
    _destController.text = '';
    Constants.rideDetails['distance'] = '0 km';
    Constants.rideDetails['tripStartTime'] =
        DateTime.now().millisecondsSinceEpoch;
  }

  void _setMarker(
      LatLng point, BitmapDescriptor icon, String id, String placeName) {
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId(id),
            position: point,
            icon: icon,
            infoWindow: InfoWindow(title: placeName)),
      );
    });
  }

  onBookingBtnClick() async {
    FocusScope.of(context).unfocus();

    if (_originController.text.isEmpty || _destController.text.isEmpty) {
      showSnackBar(context, "Please enter Pickup and Drop off locations");
      _isTripAvailable = false;
      _isValidating = false;
      setState(() {});
    } else {
      try {
        _isValidating = true;
        var directions = await LocationService()
            .getDirections(_originController.text, _destController.text);
        setState(() {
          Constants.rideDetails['distance'] = directions['distance'];
        });
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

        _isTripAvailable = true;
        _isValidating = false;
      } catch (e) {
        _isValidating = false;
        print(e);
        showSnackBar(context, "Invalid location");
      }
      setState(() {});
    }
    Constants.rideDetails['pickAddress'] = _originController.text;
    Constants.rideDetails['dropAddress'] = _destController.text;
  }

  void setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
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
  }

  Future<void> _goToThePlace(
      double originLat,
      double originLng,
      double destLat,
      double destLng,
      Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw) async {
    Constants.rideDetails['pickLat'] = originLat;
    Constants.rideDetails['pickLng'] = originLng;
    Constants.rideDetails['dropLat'] = destLat;
    Constants.rideDetails['dropLng'] = destLng;

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(originLat, originLng),
      zoom: 12,
    )));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));

    _markers = {};
    _setMarker(
        LatLng(originLat, originLng),
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        'origin',
        _originController.text);
    _setMarker(LatLng(destLat, destLng), BitmapDescriptor.defaultMarker,
        'destination', _destController.text);
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
          GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            polygons: _polygons,
            polylines: _polylines,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (point) {
              if (kDebugMode) {
                print(point);
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      PageRouteTransition.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        width: double.infinity,
                        // height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade600,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _originController,
                                              maxLines: 2,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 17,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                labelText: 'Pickup address',
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.grey,
                                              width: double.infinity,
                                              height: 1,
                                            ),
                                            TextFormField(
                                              controller: _destController,
                                              maxLines: 2,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 17,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                labelText: 'Drop address',
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              onChanged: (_) {
                                                _isTripAvailable = false;
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final temp = _originController.text;
                                          _originController.text =
                                              _destController.text;
                                          _destController.text = temp;
                                          setState(() {});
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: primaryColor,
                                          child: const Icon(
                                            Icons.swap_calls,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Constants.rideDetails['distance'] ==
                                              '0 km'
                                          ? Container()
                                          : Text(
                                              'Distance: ' +
                                                  Constants
                                                      .rideDetails['distance'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                      _isValidating
                                          ? Transform.scale(
                                              scale: 0.5,
                                              child: CircularProgressIndicator(
                                                color: Colors.black,
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () async {
                                                await onBookingBtnClick()
                                                    .then((value) {});
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 6),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Colors.black,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Visibility(
                                                      visible: _isTripAvailable
                                                          ? true
                                                          : false,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 6),
                                                        child: Icon(
                                                          Icons.done,
                                                          color: Colors.white,
                                                          size: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      _isTripAvailable
                                                          ? 'Validated'
                                                          : 'Validate',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: MaterialButton(
          onPressed: () {
            if (_isTripAvailable == true) {
              if (Constants.rideDetails['distance'] == "0 km" ||
                  _originController.text.isEmpty ||
                  _destController.text.isEmpty) {
                showSnackBar(context, "Please enter Pick and Drop address");
              } else {
                setState(() {
                  Constants.selectedPage = 1;
                });
                showModalBottomSheet<void>(
                  isScrollControlled: true,
                  enableDrag: false,
                  backgroundColor: primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return createTrip();
                  },
                );
              }
            } else {
              showSnackBar(context, "Please validate the trip first");
            }
          },
          padding: EdgeInsets.zero,
          color: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: Center(
              child: Text(
                !_isTripAvailable
                    ? 'Create a Trip'
                    : 'Trip Available'.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createTrip() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Constants.selectedPage == 4
                          ? IconButton(
                              onPressed: () {
                                setModalState(() {
                                  Constants.selectedPage = 3;
                                });
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            )
                          : Container(),
                      Text(
                        Constants.selectedPage == 4
                            ? 'Select Driver'
                            : "Create Trip",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: primaryAccentColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            Constants.selectedPage = 1;
                          });
                          PageRouteTransition.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: primaryAccentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      progressButtons(text: '1'),
                      progressButtons(text: '2'),
                      progressButtons(text: '3'),
                      progressButtons(text: '4'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (Constants.selectedPage == 1)
                  Page1(setModalState: setModalState),
                if (Constants.selectedPage == 2)
                  Page2(setModalState: setModalState),
                if (Constants.selectedPage == 3)
                  Page3(setModalState: setModalState),
                if (Constants.selectedPage == 4)
                  Page4(setModalState: setModalState),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget progressButtons({final text}) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Constants.selectedPage.toString() == text
            ? Colors.white
            : primaryLightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Constants.selectedPage.toString() == text
                ? primaryColor
                : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
