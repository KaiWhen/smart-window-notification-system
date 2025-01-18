import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:smart_windows_app/util/helper.dart';

class SmartWindowApi {
  final String apiUrl = 'http://13.60.58.148:8080/';

  Future<int> registerUserId(String puid, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}user/reg'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'user_id': puid, 'username': email}),
      );

      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        if (responseData['registered']) {
          return 1;
        } else {
          return 2;
        }
      } else {
        log("Failed to post data");
        return -1;
      }
    } on SocketException {
      log("Cannot connect to server");
      return -1;
    } catch (e) {
      log("Error: $e");
      return -1;
    }
  }

  Future<bool> postFcmToken(String? fcmToken, String? userId) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}fcm'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{'user_id': userId, 'fcm_token': fcmToken}),
      );

      if (response.statusCode == 200) {
        // final responseData = jsonDecode(response.body);
        return true;
      } else {
        log("Failed to post data");
        return false;
      }
    } on SocketException catch (e) {
      log("Error: $e");
      return false;
    } catch (e) {
      log("Error: $e");
      return false;
    }
  }

  Future<int> regDevices(
      String indoorDeviceId, String outdoorDeviceId, String? userId) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}device/reg'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'indoor_device_id': indoorDeviceId,
          'outdoor_device_id': outdoorDeviceId
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        int reg = responseData['reg'];
        return reg;
      } else {
        log("Failed to post data");
        return -1;
      }
    } on SocketException {
      log("Cannot connect to server");
      return -1;
    } catch (e) {
      log("Error: $e");
      return -1;
    }
  }

  Future<bool> postThresholds(String? userId, final thresholds) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}threshold/set'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{'user_id': userId, 'thresholds': thresholds}),
      );

      if (response.statusCode == 200) {
        // final responseData = jsonDecode(response.body);
        return true;
      } else {
        log("Failed to post data");
        return false;
      }
    } on SocketException {
      log("Cannot connect to server");
      return false;
    } catch (e) {
      log("Error: $e");
      return false;
    }
  }

  Future<Map?> getDevicesFromUser() async {
    String? userId = await Helper.getUserId();
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}device'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        log('Failed to post data');
        return null;
      }
    } on SocketException {
      log("Cannot connect to server");
      return null;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<Map?> getCurrentReadings() async {
    Map? deviceIds = await getDevicesFromUser();
    if (deviceIds == null) {
      return null;
    }
    int indoorDeviceId = deviceIds['indoor_device_id'];
    int outdoorDeviceId = deviceIds['outdoor_device_id'];
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}readings'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'indoor_device_id': indoorDeviceId,
          'outdoor_device_id': outdoorDeviceId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        log('Failed to post data');
        return null;
      }
    } on SocketException {
      log("Cannot connect to server");
      return null;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<Map?> getDeviceThresholds() async {
    String? userId = await Helper.getUserId();
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}threshold/device'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        log('Failed to post data');
        return null;
      }
    } on SocketException {
      log("Cannot connect to server");
      return null;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<Map?> getReadingsHistorical() async {
    Map? deviceIds = await getDevicesFromUser();
    if (deviceIds == null) {
      return null;
    }
    int indoorDeviceId = deviceIds['indoor_device_id'];
    int outdoorDeviceId = deviceIds['outdoor_device_id'];
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}readings/historical'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'indoor_device_id': indoorDeviceId,
          'outdoor_device_id': outdoorDeviceId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        log('Failed to post data');
        return null;
      }
    } on SocketException {
      log("Cannot connect to server");
      return null;
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }

  Future<bool?> isOwner() async {
    String? userId = await Helper.getUserId();
    Map? deviceIds = await getDevicesFromUser();
    if (deviceIds == null) {
      return false;
    }
    int indoorDeviceId = deviceIds['indoor_device_id'];
    int outdoorDeviceId = deviceIds['outdoor_device_id'];
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}user/isowner'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'indoor_device_id': indoorDeviceId,
          'outdoor_device_id': outdoorDeviceId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['is_owner'];
      } else {
        log('Failed to post data');
        return false;
      }
    } on SocketException {
      log("Cannot connect to server");
      return false;
    } catch (e) {
      log("Error: $e");
      return false;
    }
  }

  Future<bool?> transferOwnership(String email) async {
    String? userId = await Helper.getUserId();
    Map? deviceIds = await getDevicesFromUser();
    if (deviceIds == null) {
      return false;
    }
    int indoorDeviceId = deviceIds['indoor_device_id'];
    int outdoorDeviceId = deviceIds['outdoor_device_id'];
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}device/owner'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'target_email': email,
          'indoor_device_id': indoorDeviceId,
          'outdoor_device_id': outdoorDeviceId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'];
      } else {
        log('Failed to post data');
        return false;
      }
    } on SocketException {
      log("Cannot connect to server");
      return false;
    } catch (e) {
      log("Error: $e");
      return false;
    }
  }

  Future<bool?> setDays(List<bool> days) async {
    String? userId = await Helper.getUserId();
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}user/preferences/days'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'days_list': days,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'];
      } else {
        log('Failed to post data');
        return false;
      }
    } on SocketException {
      log("Cannot connect to server");
      return false;
    } catch (e) {
      log("Error: $e");
      return false;
    }
  }

  Future<bool?> setInterval(int interval) async {
    String? userId = await Helper.getUserId();
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}user/preferences/interval'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'interval': interval,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'];
      } else {
        log('Failed to post data');
        return false;
      }
    } on SocketException {
      log("Cannot connect to server");
      return false;
    } catch (e) {
      log("Error: $e");
      return false;
    }
  }
}
