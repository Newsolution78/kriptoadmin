import '../models/endpoint.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:async';
import 'package:dargon2_flutter/dargon2_flutter.dart';

import '../models/parameters.dart';

class User with ChangeNotifier {
  int id;
  String name;
  String email;
  String password;
  String type;
  List<dynamic> usersData;
  int count;
  String branch;

  User(this.id, this.name, this.email, this.usersData, this.count,
      this.password, this.type, this.branch);

  Future<void> allUsers(
      {required int pageNumber, required int pageSize}) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().users,
      {
        //'apitoken': Parameters().apitoken,
        'pageNumber': pageNumber.toString(), //pageNumber.toString(),
        'pageSize': pageSize.toString(), //Parameters().pageSize.toString(),
      },
    );
    //print('Customer URL: ' + url.toString());
    List<dynamic> responseData;
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        responseData = json.decode(response.body) as List<dynamic>;
        usersData = responseData;
      } else {
        id = 0;
        name = '';
        password = '';
        type = '';
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> newUser(String newName, String newType, String newEmail,
      String newPassword, String newBranchOffice) async {
    //titkosítás
    DArgon2Flutter.init();

    //print('NEWQUSER');
    //Uint8List passwordLocal = utf8.encode(password) as Uint8List;

    Uint8List salt = utf8.encode("helloworld") as Uint8List;
    //Argon2 argon2 =Argon2(iterations: 16, hashLength: 64, memory: 256, parallelism: 2);
    //Uint8List hash = await argon2.argon2i(passwordLocal, salt);
    DArgon2Result result =
        await argon2.hashPasswordString(password, salt: Salt(salt));
    int hashPosition = result.encodedString.indexOf('p=') + 2;
    String passwordHash = result.encodedString
        .substring(hashPosition, result.encodedString.length);

    //print(passwordHash);

    //print(newName + ':' + newType + ':' + newEmail + ':' + newPassword);
    final url = Uri.http(
      Endpoints().base,
      Endpoints().users,
      {
        'apitoken': Parameters().apitoken,
      },
    );
    Map<String, String> body = {
      'name': newName,
      'type': newType,
      'email': newEmail,
      'password': passwordHash,
      'branch': newBranchOffice,
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
        id = responseData[0]['id'];
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> usersCount() async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().users + Endpoints().userscount,
      {
        'apitoken': Parameters().apitoken,
      },
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        count = int.parse(response.body);
      } else {
        count = 0;
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateUser(int updateId, String updateName, String updateEmail,
      String updateType, String updateBranch) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().users + Endpoints().usersupdate,
      {
        'apitoken': Parameters().apitoken,
      },
    );

    //print('Transaction update URL: $url');

    Map<String, dynamic> body = {
      'name': updateName,
      'email': updateEmail,
      'type': updateType,
      'branch': updateBranch,
      'id': updateId,
    };
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      final responseData = json.decode(response.body);
      print('Message: $responseData');

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<dynamic> get getcustomersData {
    return usersData;
  }

  int get getId {
    return id;
  }
}
