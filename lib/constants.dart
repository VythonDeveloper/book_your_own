// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
  static String scheduleTime = '';
  static int selectedPage = 1;
  static String selectedVehicle = "Rickshaw";
  static double totalDistance = 0.0;

  static Map<String, dynamic> vehicleDetails = {
    "Rickshaw": {
      "label": "Rickshaw",
      "image": "./lib/assets/images/rickshaw.png",
      "costPerKm": 10.5,
      "speedPerHr": 15.0,
    },
    "Tractor": {
      "label": "Tractor",
      "image": "./lib/assets/images/tractor.png",
      "costPerKm": 12.5,
      "speedPerHr": 18.0,
    },
    "Mini Truck": {
      "label": "Mini Truck",
      "image": "./lib/assets/images/mini-truck.png",
      "costPerKm": 11.5,
      "speedPerHr": 22.0,
    },
    "Truck": {
      "label": "Truck",
      "image": "./lib/assets/images/truck.png",
      "costPerKm": 15.6,
      "speedPerHr": 25.0,
    },
    "Delivery Truck": {
      "label": "Delivery Truck",
      "image": "./lib/assets/images/delivery-truck.png",
      "costPerKm": 16.0,
      "speedPerHr": 30.0,
    },
  };

  static Map<String, dynamic> rideDetails = {
    "id": 0,
    "customerId": '',
    "customerName": "",
    "customerMobile": '',
    "driverId": 0,
    "driverName": "",
    "driverMobile": "",
    "driverLat": 23.558613,
    "driverLng": 87.269232,
    "vehicleType": '',
    "vehicleName": '',
    "vehicleNumber": '',
    "pickAddress": '',
    "pickLat": 0.0,
    "pickLng": 0.0,
    "dropAddress": '',
    "dropLat": 0.0,
    "dropLng": 0.0,
    "distance": '0 km',
    "transitTime": '00:00 hrs',
    "tripStartTime": 0,
    "tripEndTime": 0,
    "cost": 0,
    "startOtp": 00000,
    "endOtp": 00000,
    "status": '',
    "bookedOn": 0,
  };

  static Map<String, dynamic> driverDetails = {
    "id": 0,
    "fullname": '',
    "mobile": '',
    "email": '',
    "licenseNumber": '',
    "address": '',
    "password": '',
    "rating": 0.0,
    "vehicleType": '',
    "vehicleName": '',
    "vehicleNumber": '',
    "status": '',
    "registeredOn": 0,
    'tokenId': '',
  };

  static Map<String, dynamic> customerDetails = {
    "id": 0,
    "fullname": '',
    "mobile": '',
    "password": '',
    "registeredOn": 0,
    'tokenId': '',
  };

  static var cF = NumberFormat('#,##,###');

  static Map<String, dynamic> statusColor = {
    "Pending": Colors.amber,
    "Active": Colors.purple,
    "Completed": Colors.green,
    "Cancelled": Colors.red
  };
}
