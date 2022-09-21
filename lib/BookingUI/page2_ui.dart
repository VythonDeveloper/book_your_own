// ignore_for_file: prefer_typing_uninitialized_variables, no_logic_in_create_state

import 'package:book_your_own/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class Page2 extends StatefulWidget {
  final setModalState;
  const Page2({Key? key, this.setModalState}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State(setModalState: setModalState);
}

class _Page2State extends State<Page2> {
  final setModalState;
  _Page2State({this.setModalState});
  final dateFormat = new DateFormat('MMMM d, yyyy HH:mm');

  _calculateTransitTime() {
    Constants.totalDistance = double.parse(
      Constants.rideDetails['distance'].split(' ')[0].replaceAll(',', ''),
    );

    int transitTimeMillisecond = (Constants.totalDistance /
            Constants.vehicleDetails[Constants.selectedVehicle]['speedPerHr'] *
            3600000)
        .round();
    Duration duration = new Duration(milliseconds: transitTimeMillisecond);
    Constants.rideDetails['transitTime'] = duration.toString().split(":")[0] +
        ":" +
        duration.toString().split(":")[1] +
        " hrs";
    Constants.rideDetails['tripEndTime'] =
        Constants.rideDetails['tripStartTime'] + transitTimeMillisecond;
    Constants.rideDetails['cost'] = (Constants.totalDistance *
            Constants.vehicleDetails[Constants.selectedVehicle]['costPerKm'])
        .round();
    if (mounted) {
      setModalState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    Constants.rideDetails['transitTime'] = '00:00 hrs';
    Constants.rideDetails['cost'] = 0;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _calculateTransitTime());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 20),
            child: Text(
              "Select Vehicle",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                Constants.vehicleDetails.keys.length,
                (index) => vehicleSelectionBtn(
                  key: Constants.vehicleDetails.keys.elementAt(index),
                  setModalState: setModalState,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.map,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      Constants.rideDetails['distance'],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      Constants.rideDetails['transitTime'],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.money_outlined,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '₹ ' + Constants.cF.format(Constants.rideDetails['cost']),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (Constants.selectedPage != 0) {
                      setModalState(() {
                        Constants.selectedPage -= 1;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryAccentColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 5,
                  child: MaterialButton(
                    onPressed: () {
                      setModalState(() {
                        Constants.selectedPage = 3;
                      });
                    },
                    padding: EdgeInsets.zero,
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    child: const SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget vehicleSelectionBtn({final key, final setModalState}) {
    // print(key);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setModalState(() {
                Constants.selectedVehicle =
                    Constants.vehicleDetails[key]['label'];
                _calculateTransitTime();
              });
            },
            child: Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Constants.selectedVehicle ==
                          Constants.vehicleDetails[key]['label']
                      ? Colors.black
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Image.asset(
                Constants.vehicleDetails[key]['image'],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            Constants.vehicleDetails[key]['label'],
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
