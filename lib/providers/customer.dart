import '../models/endpoint.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../models/parameters.dart';

class Customer with ChangeNotifier {
  int id;
  String name;
  String email;
  List<dynamic> customersData;
  int count;

  Customer(this.id, this.name, this.email, this.customersData, this.count);

  Future<void> allCustomers(
      {required int pageNumber, required int pageSize}) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().customers + Endpoints().allcustomers,
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
        customersData = responseData;
      } else {
        id = 0;
        name = '';
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> customersFind(
      {required int pageNumber,
      required int pageSize,
      required String searchString}) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().customers + Endpoints().findCustomer,
      {
        //'apitoken': Parameters().apitoken,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'customerEmail': searchString,
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
        customersData = responseData;
      } else {
        id = 0;
        name = '';
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> customersCount() async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().customers + Endpoints().customerscount,
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

  Future<void> deleteCustomers(int id, String name, String email) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().customers + Endpoints().deletecustomers,
      {
        'apitoken': Parameters().apitoken,
      },
    );

    Map<String, String> body = {
      'id': id.toString(),
      'name': name,
      'email': email,
    };

    //print('Customer URL: ' + url.toString());
    //List<dynamic> responseData;
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      print('DELETE: ${response.body}');

      // if (response.statusCode == 200) {
      //   responseData = json.decode(response.body) as List<dynamic>;
      //   customersData = responseData;
      // } else {}

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<dynamic> get getcustomersData {
    return customersData;
  }

  int get getId {
    return id;
  }
}
