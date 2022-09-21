import 'package:book_your_own/colors.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';

import '../constants.dart';

class Page1 extends StatefulWidget {
  final setModalState;
  const Page1({Key? key, this.setModalState}) : super(key: key);

  @override
  State<Page1> createState() => _Page1State(setModalState: setModalState);
}

class _Page1State extends State<Page1> {
  final setModalState;
  _Page1State({this.setModalState});

  final dateFormat = new DateFormat('MMMM d, yyyy HH:mm');

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Trip",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 15, bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pick Address"),
                        Text(
                          Constants.rideDetails['pickAddress'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Container(
                            color: Colors.grey.shade300,
                            width: double.infinity,
                            height: 1,
                          ),
                        ),
                        const Text("Drop Address"),
                        Text(
                          Constants.rideDetails['dropAddress'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              color: Colors.grey.shade300,
              width: double.infinity,
              height: 1,
            ),
            Text(
              "Schedule for",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              dateMask: 'MMM d, yyyy',
              initialValue: DateTime.now().toString(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Date',
              timeLabelText: "Hour",
              selectableDayPredicate: (date) {
                // Disable weekend days to select from the calendar
                if (date.weekday == 6 || date.weekday == 7) {
                  return false;
                }
                return true;
              },
              onChanged: (val) {
                setModalState(() {
                  Constants.rideDetails['tripStartTime'] =
                      DateTime.parse(val.toString()).millisecondsSinceEpoch;
                });
              },
              validator: (val) {
                setModalState(() {
                  Constants.rideDetails['tripStartTime'] =
                      DateTime.parse(val.toString()).millisecondsSinceEpoch;
                });
                return null;
              },
              onSaved: (val) {
                setModalState(() {
                  Constants.rideDetails['tripStartTime'] =
                      DateTime.parse(val.toString()).millisecondsSinceEpoch;
                });
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryAccentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                      Constants.rideDetails['tripStartTime'])),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    PageRouteTransition.effect = TransitionEffect.fade;
                    PageRouteTransition.pop(context);
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
                        Constants.selectedPage = 2;
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
          ],
        ),
      ),
    );
  }
}
