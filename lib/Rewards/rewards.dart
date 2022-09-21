import 'dart:ui';
import 'package:book_your_own/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

class RewardsUi extends StatefulWidget {
  const RewardsUi({Key? key}) : super(key: key);

  @override
  State<RewardsUi> createState() => _RewardsUiState();
}

class _RewardsUiState extends State<RewardsUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Rewards Section"),
      ),
      body: SafeArea(
        child: FutureBuilder<dynamic>(
          future: FirebaseFirestore.instance.collection('coupons').get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length == 0) {
                return Text("Come later");
              }
              return GridView.count(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: List.generate(
                  snapshot.data.docs.length,
                  (index) {
                    return Center(
                      child: scratchCard(snapshot.data.docs[index]),
                    );
                  },
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget scratchCard(var couponDetails) {
    var today = DateTime.now().millisecondsSinceEpoch;
    String couponStatus = "Expired";
    Color couponStatusColor = Colors.red;
    if (couponDetails['redeemedBy'].contains(Constants.customerDetails['id'])) {
      couponStatus = "Redeemed";
      couponStatusColor = Color.fromARGB(255, 144, 76, 175);
    } else if (couponDetails['validFrom'] <= today &&
        couponDetails['expiryOn'] >= today) {
      couponStatus = "Active";
      couponStatusColor = Colors.green;
    }
    bool scratched = false;
    if (couponDetails['scratchedBy']
        .contains(Constants.customerDetails['id'])) {
      scratched = true;
    }
    return GestureDetector(
      onTap: () async {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return ScratchCardPopup(couponDetails);
          },
        );
      },
      child: Container(
        // height: 200,
        // width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 230, 230, 230),
              blurRadius: 25.0,
              spreadRadius: 25,
              offset: Offset(
                20,
                20,
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          child: scratched
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            couponDetails['discount'] + "%",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "CODE: " + couponDetails['coupon_code'],
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            couponDetails['description'],
                            style: TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        color: couponStatusColor,
                        padding: EdgeInsets.all(5),
                        child: Text(couponStatus),
                      ),
                    )
                  ],
                )
              : Image.asset('./lib/assets/images/gift-paper.jpg'),
        ),
      ),
    );
  }

  Widget ScratchCardPopup(var couponDetails) {
    bool scratched = false;
    if (couponDetails['scratchedBy']
        .contains(Constants.customerDetails['id'])) {
      scratched = true;
    }
    return StatefulBuilder(
      builder: (context, setModalState) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titlePadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Scratcher(
                  onThreshold: () {
                    FirebaseFirestore.instance
                        .collection('coupons')
                        .doc(couponDetails['id'])
                        .update({
                      'scratchedBy': FieldValue.arrayUnion(
                          [Constants.customerDetails['id']])
                    });
                    setState(() {});
                  },
                  color: Colors.transparent,
                  accuracy: ScratchAccuracy.high,
                  threshold: 30,
                  brushSize: 40,
                  image: Image.asset(scratched
                      ? './lib/assets/images/transparent-gift-paper.png'
                      : './lib/assets/images/gift-paper.jpg'),
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 100),
                    opacity: 1,
                    child: Container(
                      height: 290,
                      width: 290,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset("./lib/assets/images/gift.png",
                                    height: 50),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Hurray! you won",
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                            Text(
                              couponDetails['discount'] + "%",
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              couponDetails['coupon_code'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              couponDetails['description'],
                              style: TextStyle(fontSize: 17),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
            elevation: 15,
            //backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}
