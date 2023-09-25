import 'dart:typed_data';

import '../models/endpoint.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../models/parameters.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dargon2_flutter/dargon2_flutter.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime _expiryDate = DateTime.now();
  int _userId = 0;
  Timer? _authTimer;
  String name = '';

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_expiryDate != DateTime.now() &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != '') {
      return _token;
    }
    return '';
  }

  int get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password) async {
    //titkosítás
    DArgon2Flutter.init();
    //Uint8List passwordLocal = utf8.encode(password) as Uint8List;

    Uint8List salt = utf8.encode("helloworld") as Uint8List;
    //Argon2 argon2 =Argon2(iterations: 16, hashLength: 64, memory: 256, parallelism: 2);
    //Uint8List hash = await argon2.argon2i(passwordLocal, salt);
    DArgon2Result result =
        await argon2.hashPasswordString(password, salt: Salt(salt));
    int hashPosition = result.encodedString.indexOf('p=') + 2;
    String passwordHash = result.encodedString
        .substring(hashPosition, result.encodedString.length);
    print(passwordHash);

    final url = Uri.http(
      Endpoints().base,
      Endpoints().users + Endpoints().bodytest,
      {
        'apitoken': Parameters().apitoken,
      },
    );
    Map<String, String> body = {
      'email': email,
      'password': passwordHash,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      final status = response.statusCode;
      print('STATUS: $status');
      final responseData = json.decode(response.body);

      if (status != 200) {
        print('STATUS: $status');
        throw HttpException(response.body);
      }

      print('BODY: ${response.body}');
      if (responseData[0]['name'] != null) {
        name = responseData[0]['name'];
        _userId = responseData[0]['id'];
      }

      //   _token = responseData['idToken'];
      //   _userId = responseData['localId'];
      //   _expiryDate = DateTime.now().add(
      //     Duration(
      //       seconds: int.parse(responseData['expiresIn']),
      //     ),
      //   );
      //   _autpLogout();
      //   notifyListeners();
      //   final prefs = await SharedPreferences.getInstance();
      //   final userData = json.encode({
      //     'token': _token,
      //     'userId': _userId,
      //     'expiryDate': _expiryDate.toIso8601String()
      //   });
      //   prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }

    //print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());
    if (expiryDate.isAfter(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'].toString();
    //_userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autpLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _userId = 0;
    _expiryDate = DateTime.now();
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autpLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  String get getName {
    return '$name/$_userId';
  }

  int get getUserID {
    return _userId;
  }
}
