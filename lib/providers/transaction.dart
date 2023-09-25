import '../models/endpoint.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../models/parameters.dart';

class Transaction with ChangeNotifier {
  String crypto;
  double amount;
  String currency;
  double exchangeRate;
  String wallet;
  int id;
  int user;
  DateTime dateTime;
  int fiatAmount;
  int customerId;
  String branchOffice;
  String paymentMethod;
  int profit;
  String status;
  int amlLevel;
  int amlRating;
  List<dynamic> transactionData;
  int count;

  Transaction(
      this.crypto,
      this.amount,
      this.currency,
      this.exchangeRate,
      this.wallet,
      this.id,
      this.user,
      this.dateTime,
      this.fiatAmount,
      this.customerId,
      this.branchOffice,
      this.paymentMethod,
      this.profit,
      this.status,
      this.amlLevel,
      this.amlRating,
      this.transactionData,
      this.count);

  final List<Transaction> _transaction = [];

  Future<void> transactionUpload() async {
    final url2 = Uri.http(
      Endpoints().base,
      Endpoints().transactions + Endpoints().transactionUpload,
      {
        'apitoken': Parameters().apitoken,
      },
    );
    //print('Transaction URL: $url2');
    //a dátummal van még probléma
    dateTime = DateTime.now();
    //print(dateTime);
    Map<String, dynamic> body = {
      'crypto': crypto,
      'amount': amount,
      'currency': currency,
      'userid': user,
      'datetime': dateTime.toIso8601String(),
    };
    try {
      final response = await http.post(
        url2,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      final responseData = json.decode(response.body);
      print('Tranzakció: $responseData');

      if (responseData != null) {
        id = responseData;
      }
      // print(id);
      // if (responseData['error'] != null) {
      //   throw HttpException(responseData['error']['message']);
      // }
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateTransaction(int idSearch, String cryptoUpdate) async {
    final url2 = Uri.http(
      Endpoints().base,
      Endpoints().transactions + Endpoints().transactionUpdate,
      {
        'apitoken': Parameters().apitoken,
      },
    );
    print('Transaction update URL: $url2');
    Map<String, dynamic> body = {
      'crypto': crypto,
      'amount': amount,
      'currency': currency,
      'userid': user,
      'id': id,
      'datetime': dateTime.toIso8601String(),
    };
    try {
      final response = await http.put(
        url2,
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

  Future<void> allTransaction(
      {required int pageNumber, required int pageSize}) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().transactions + Endpoints().alltransaction,
      {
        //'apitoken': Parameters().apitoken,
        'pageNumber': pageNumber.toString(), //pageNumber.toString(),
        'pageSize': pageSize.toString(), //Parameters().pageSize.toString(),
      },
    );
    //print('Transaction URL: $url');
    List<dynamic> responseData;
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );
      //print(response.statusCode);
      if (response.statusCode == 200) {
        responseData = json.decode(response.body) as List<dynamic>;
        transactionData = responseData;
        print(response.body);
       
      } else {
        id = 0;
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> transactionsCount() async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().transactions + Endpoints().transactionscount,
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

  String get getCrypto {
    return crypto;
  }

  double get getAmount {
    return amount;
  }

  void addTransactionCrypto(String cryptoAdd) {
    crypto = cryptoAdd;
    notifyListeners();
  }

  void addTransactionAmount(double amountAdd) {
    amount = amountAdd;
    notifyListeners();
  }

  void addTransactionUser(int userAdd) {
    user = userAdd;
  }

  void addWallet(String? walletAdd) {
    if (walletAdd == null) {
      return;
    } else {
      wallet = walletAdd;
    }

    notifyListeners();
  }

  String get getCurrency {
    return currency;
  }

  Future<void> deleteTransaction(String id) async {
    final url = Uri.http(
      Endpoints().base,
      Endpoints().transactions + Endpoints().deletetransaction,
      {
        'apitoken': Parameters().apitoken,
      },
    );

    Map<String, String> body = {
      'id': id.toString(),
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
}
