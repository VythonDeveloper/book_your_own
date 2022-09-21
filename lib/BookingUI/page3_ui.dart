// ignore_for_file: no_logic_in_create_state, prefer_typing_uninitialized_variables

import 'package:book_your_own/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class Page3 extends StatefulWidget {
  final setModalState;
  const Page3({Key? key, this.setModalState}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State(setModalState: setModalState);
}

class _Page3State extends State<Page3> {
  final setModalState;
  _Page3State({this.setModalState});

  int fare = 0;
  double discount = 0.0;
  int netPayableAmount = 0;
  int discountedAmt = 0;
  final coupon_code = TextEditingController();
  String couponErrorMsg = "Coupon Code";
  @override
  void initState() {
    super.initState();
    fare = Constants.rideDetails['cost'];
    Constants.rideDetails['discountCouponId'] = '0';
    WidgetsBinding.instance.addPostFrameCallback((_) => _couponValidation());
  }

  @override
  void dispose() {
    super.dispose();
    coupon_code.dispose();
  }

  _couponValidation() async {
    int todayNow = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection('coupons')
        .where('coupon_code', isEqualTo: coupon_code.text)
        .where('scratchedBy', arrayContains: Constants.customerDetails['id'])
        .get()
        .then((value) {
      if (value.size == 1) {
        var couponData = value.docs[0].data();
        if (couponData['redeemedBy']
            .contains(Constants.customerDetails['id'])) {
          couponErrorMsg = "Coupon Code Redeemed";
          discount = 0.0;
        } else {
          if (couponData['validFrom'] <= todayNow &&
              couponData['expiryOn'] >= todayNow) {
            couponErrorMsg = "Coupon Code";
            Constants.rideDetails['discountCouponId'] = couponData['id'];
            discount = double.parse(couponData['discount']);
          } else {
            couponErrorMsg = "Coupon Code Expired";
            discount = 0.0;
          }
        }
      } else {
        setModalState(() {
          couponErrorMsg = "Invalid Coupon Code";
          discount = 0.0;
        });
      }
    });

    discountedAmt = ((fare * discount) / 100).round();
    netPayableAmount = fare - discountedAmt;
    Constants.rideDetails['cost'] = netPayableAmount;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Breakdown",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Fare",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹ ' + Constants.cF.format(fare),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Coupon Discount (" + discount.toString() + "%)",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 75),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: coupon_code,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  label: Text(
                                    couponErrorMsg,
                                    style: TextStyle(
                                        color: couponErrorMsg == "Coupon Code"
                                            ? Color.fromARGB(255, 66, 66, 66)
                                            : Color.fromARGB(255, 185, 51, 41)),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await _couponValidation();
                                setModalState(() {});
                              },
                              child: Icon(Icons.check_circle_outline_rounded),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '- ₹ ' + Constants.cF.format(discountedAmt),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "You will pay",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹ ' + Constants.cF.format(netPayableAmount),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Divider(),
            Divider(),
            Text(
              "Select Payment Mode",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "./lib/assets/images/rupee.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Payment',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Default method',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Color.fromARGB(255, 8, 56, 75),
                        child: Icon(
                          Icons.done,
                          color: Colors.white,
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
                        Constants.selectedPage = 4;
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
                          'Book Vehicle',
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
