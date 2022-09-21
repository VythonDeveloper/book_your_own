import 'dart:math';
import 'package:book_your_own/components.dart';
import 'package:book_your_own/constants.dart';
import 'package:book_your_own/services/notification_function.dart';
import 'package:book_your_own/track_trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class Page4 extends StatefulWidget {
  final setModalState;
  const Page4({Key? key, this.setModalState}) : super(key: key);

  @override
  State<Page4> createState() => _Page4State(setModalState: setModalState);
}

class _Page4State extends State<Page4> {
  final setModalState;
  _Page4State({this.setModalState});

  final dateFormat = new DateFormat('MMMM d, yyyy HH:mm');

  String generate5digit() {
    var rng = Random();
    var rand = rng.nextInt(90000) + 10000;
    if (kDebugMode) {
      print(rand);
    }
    return rand.toString();
  }

  rideRequest(var driver) {
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    Constants.rideDetails['id'] = uniqueId;
    Constants.rideDetails['customerId'] = Constants.customerDetails['id'];
    Constants.rideDetails['customerName'] =
        Constants.customerDetails['fullname'];
    Constants.rideDetails['customerMobile'] =
        Constants.customerDetails['mobile'];
    Constants.rideDetails['driverId'] = driver['id'];
    Constants.rideDetails['driverName'] = driver['fullname'];
    Constants.rideDetails['driverMobile'] = driver['mobile'];
    Constants.rideDetails['driverLat'] = 23.558613;
    Constants.rideDetails['driverLng'] = 87.269232;
    Constants.rideDetails['vehicleType'] = driver['vehicleType'];
    Constants.rideDetails['vehicleName'] = driver['vehicleName'];
    Constants.rideDetails['vehicleNumber'] = driver['vehicleNumber'];
    Constants.rideDetails['startOtp'] = generate5digit();
    Constants.rideDetails['endOtp'] = generate5digit();
    Constants.rideDetails['status'] = 'Pending';
    Constants.rideDetails['driverTokenId'] = driver['tokenId'];
    Constants.rideDetails['customerTokenId'] =
        Constants.customerDetails['tokenId'];
    Constants.rideDetails['bookedOn'] = int.parse(uniqueId);
    Constants.rideDetails['rating'] = 0.0;

    FirebaseFirestore.instance
        .collection('rideRequest')
        .doc(uniqueId)
        .set(Constants.rideDetails);

    var busyTimeElement = {
      'from': Constants.rideDetails['tripStartTime'],
      'to': Constants.rideDetails['tripEndTime']
    };
    FirebaseFirestore.instance.collection('drivers').doc(driver['id']).update({
      'busyTime': FieldValue.arrayUnion([busyTimeElement])
    });
    sendNotification(
      tokenIdList: [driver['tokenId']],
      heading: 'Hurray! A new trip scheduled',
      contents: 'on ' +
          dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
              Constants.rideDetails['tripStartTime'])) +
          ' | From: ' +
          Constants.rideDetails['pickAddress'] +
          ' | To: ' +
          Constants.rideDetails['dropAddress'],
    );
    PageRouteTransition.pop(context);
    PageRouteTransition.pop(context);
    PageRouteTransition.pushReplacement(
        context, TrackTripUi(rideDetails: Constants.rideDetails));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(30),
          topRight: const Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StreamBuilder<dynamic>(
                  stream: FirebaseFirestore.instance
                      .collection('drivers')
                      .where('vehicleType',
                          isEqualTo: Constants.selectedVehicle)
                      .where('bookingStatus', isEqualTo: "Available")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length > 0) {
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            DocumentSnapshot ds = snapshot.data.docs[index];
                            if (ds['busyTime'].length > 0) {
                              bool inValidFlag = false;
                              try {
                                ds['busyTime'].forEach((element) {
                                  if ((Constants.rideDetails['tripStartTime'] <
                                              element['from'] &&
                                          Constants.rideDetails['tripEndTime'] <
                                              element['from']) ||
                                      (Constants.rideDetails['tripStartTime'] >
                                              element['to'] &&
                                          Constants.rideDetails['tripEndTime'] >
                                              element['to'])) {
                                    // print(dateFormat.format(
                                    //         DateTime.fromMillisecondsSinceEpoch(
                                    //             element['from'])) +
                                    //     '-' +
                                    //     dateFormat.format(
                                    //         DateTime.fromMillisecondsSinceEpoch(
                                    //             element['to'])));
                                  } else {
                                    inValidFlag = true;
                                    throw 'Not available';
                                  }
                                });
                              } catch (e) {
                                print(e);
                              }

                              if (!inValidFlag) {
                                return driverDetailsCard(driver: ds);
                              } else {
                                return Center(
                                  child: Text(
                                    'No Driver Available for given time period.\nTry other schedule time.',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                );
                              }
                            }
                            return driverDetailsCard(driver: ds);
                          },
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          LinearProgressIndicator(
                            color: Colors.black,
                          ),
                          SizedBox(height: 10),
                          Text('Getting Driver Onboard'),
                        ],
                      );
                    }
                    return const LinearProgressIndicator(
                      color: Colors.black,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget driverDetailsCard({final driver}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['fullname'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      driver['vehicleName'] + ' ' + driver['vehicleNumber'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              // Text(
              //   driver['rating'],
              //   style: const TextStyle(
              //     color: Colors.black,
              //     fontWeight: FontWeight.w900,
              //   ),
              // ),

              FutureBuilder<dynamic>(
                future: FirebaseFirestore.instance
                    .collection('rideRequest')
                    .where('driverId', isEqualTo: driver['id'])
                    .where('ratings', isNotEqualTo: 0)
                    .get(),
                builder: (context, snapshot) {
                  var avgRate = 0.0;
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length > 0) {
                      for (int i = 0; i < snapshot.data.docs.length; i++) {
                        avgRate += snapshot.data.docs[i]['rating'];
                      }
                      avgRate = avgRate / snapshot.data.docs.length;
                      return Text(
                        avgRate.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    return Text(avgRate.toStringAsFixed(1));
                  }
                  return Center(
                    child: Transform.scale(
                      scale: 0.5,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 6,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  Uri url = Uri.parse('tel:' + driver['mobile']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw "cannot make call";
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.blue.shade700,
                  child: Icon(
                    Icons.phone,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.5),
                  onTap: () {
                    showLoading(context);
                    if (Constants.rideDetails['discountCouponId'] != '0') {
                      print('dhooka hai ');
                      FirebaseFirestore.instance
                          .collection('coupons')
                          .doc(Constants.rideDetails['discountCouponId'])
                          .update({
                        "redeemedBy": FieldValue.arrayUnion(
                            [Constants.customerDetails['id']])
                      });
                    }
                    rideRequest(driver);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Ride Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              ///////////////
              // GestureDetector(
              //   onTap: () {
              //     if (Constants.selectedPage != 0) {
              //       setModalState(() {
              //         Constants.selectedPage -= 1;
              //       });
              //     }
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       color: primaryAccentColor,
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //     child: Icon(
              //       Icons.phone,
              //       color: primaryColor,
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   width: 10,
              // ),
              // Expanded(
              //   flex: 5,
              //   child: MaterialButton(
              //     onPressed: () {
              //       showLoading(context);
              //       FirebaseFirestore.instance
              //           .collection('coupons')
              //           .doc(Constants.rideDetails['discountCouponId'])
              //           .update({
              //         "redeemedBy": FieldValue.arrayUnion(
              //             [Constants.customerDetails['id']])
              //       });
              //       rideRequest(driver);
              //     },
              //     padding: EdgeInsets.zero,
              //     color: primaryColor,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     elevation: 0,
              //     child: SizedBox(
              //       height: 60,
              //       width: double.infinity,
              //       child: Center(
              //         child: Text(
              //           'Ride Request',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 16,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}
