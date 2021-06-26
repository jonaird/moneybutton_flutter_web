library moneybutton_flutter_web;

import 'dart:html';
import 'dart:js';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_web_view/easy_web_view.dart';
import 'package:js/js_util.dart';
import 'src/moneyButton.js.dart';

class MoneyButton extends StatelessWidget {
  Key key;
  String url;
  double width;

  String viewType;
  MoneyButton(Map options, {this.width = 200, this.key}) {
    if (key != null) key = UniqueKey();

    url =
        'https://x.bitfs.network/cddadb9f0d9e022b30ebf53eecd2eace05ae48b5291e3e36b2aa103f837c79a7.out.0.3' +
            '?data=' +
            base64.encode(utf8.encode(jsonEncode(options)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: 68,
        child: EasyWebView(
          src: url,
          width: width,
          height: 68,
          key: key,
        ));
  }
}

class Amount {
  final double amount;
  final String currency;
  int satoshis;

  Amount({@required this.amount, @required this.currency, this.satoshis});

  Map<String, String> toMap() =>
      {'amount': amount.toString(), 'currency': currency};
}

abstract class CryptoOperation {
  String value;
  String name;
  CryptoOperation(this.name);
  CryptoOperation._fromResponseMap(Map map)
      : name = map['name'],
        value = map['value'];
  Map toMap();
}

enum DataEncoding { hex, utf8 }

abstract class DataOperation extends CryptoOperation {
  final String data;
  final DataEncoding dataEncoding;
  DataOperation(String name, this.data, this.dataEncoding) : super(name);

  DataOperation._fromResponseMap(Map map)
      : data = map['data'],
        dataEncoding = map['dataEncoding'] == 'utf8'
            ? DataEncoding.utf8
            : DataEncoding.hex,
        super._fromResponseMap(map);

  Map toMap() {
    return {
      'name': name,
      'data': data,
      'dataEncoding': dataEncoding == DataEncoding.hex ? 'hex' : 'utf8',
      'key': 'identity',
    };
  }
}

class SignOperation extends DataOperation {
  DataEncoding valueEncoding;
  SignOperation(
      {String name, String data, DataEncoding encoding = DataEncoding.utf8})
      : super(name, data, encoding);

  SignOperation._fromResponseMap(Map map)
      : valueEncoding = DataEncoding.utf8,
        super._fromResponseMap(map);

  Map toMap() {
    return {
      ...super.toMap(),
      'method': 'sign',
      'algorithm': 'bitcoin-signed-message'
    };
  }
}

class VerifyOperation extends DataOperation {
  DataEncoding valueEncoding;
  bool verified;
  final String signature, paymail, publicKey;
  VerifyOperation(
      {@required String name,
      @required String data,
      DataEncoding encoding = DataEncoding.utf8,
      @required this.signature,
      this.paymail,
      this.publicKey})
      : assert(paymail != null || publicKey != null),
        super(name, data, encoding);

  VerifyOperation._fromResponseMap(Map map)
      : signature = map['signature'],
        paymail = map['paymail'],
        publicKey = map['publicKey'],
        valueEncoding = DataEncoding.hex,
        verified = map['verified'],
        super._fromResponseMap(map);

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'method': 'verify',
      'signature': signature,
      if (paymail != null) 'paymail': paymail,
      if (publicKey != null) 'publicKey': publicKey,
      'algorithm': 'bitcoin-signed-message'
    };
  }
}

class EncryptOperation extends DataOperation {
  final String paymail, publicKey;
  DataEncoding valueEncoding;
  EncryptOperation(
      {@required String name,
      @required String data,
      DataEncoding encoding = DataEncoding.utf8,
      this.paymail,
      this.publicKey})
      : super(name, data, encoding);

  EncryptOperation._fromResponseMap(Map map)
      : paymail = map['paymail'],
        publicKey = map['publicKey'],
        valueEncoding = DataEncoding.hex,
        super._fromResponseMap(map);

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'method': 'encrypt',
      if (paymail != null) 'paymail': paymail,
      if (publicKey != null) 'publicKey': publicKey,
      'algorithm': 'electrum-ecies'
    };
  }
}

class DecryptOperation extends DataOperation {
  final DataEncoding valueEncoding;
  DecryptOperation({
    @required String name,
    @required String data,
    DataEncoding dataEncoding = DataEncoding.utf8,
    @required this.valueEncoding,
  }) : super(name, data, dataEncoding);

  DecryptOperation._fromResponseMap(Map map)
      : valueEncoding = map['valueEncoding'],
        super._fromResponseMap(map);

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'method': 'decrypt',
      'valueEncoding': valueEncoding == DataEncoding.hex ? 'hex' : 'utf8',
      'algorithm': 'electrum-ecies'
    };
  }
}

class PublicKeyOperation extends CryptoOperation {
  PublicKeyOperation({@required String name}) : super(name);

  PublicKeyOperation._fromResponseMap(Map map) : super._fromResponseMap(map);

  @override
  Map toMap() {
    return {'name': name, 'method': 'public-key', 'key': 'identity'};
  }
}

class AddressOperation extends CryptoOperation {
  AddressOperation({@required String name}) : super(name);

  AddressOperation._fromResponseMap(Map map) : super._fromResponseMap(map);

  @override
  Map toMap() {
    return {'name': name, 'method': 'address', 'key': 'identity'};
  }
}

class PaymailOperation extends CryptoOperation {
  PaymailOperation({@required String name}) : super(name);

  PaymailOperation._fromResponseMap(Map map) : super._fromResponseMap(map);

  @override
  Map toMap() {
    return {'name': name, 'method': 'paymail', 'key': 'identity'};
  }
}

class SwipeResponse {
  Map payment;
  List<CryptoOperation> cryptoOperations;
  SwipeResponse._fromResponseMap(Map map) {
    payment = map['payment'];
    cryptoOperations = (map['cryptoOperations'] as List)
        .map((e) => _mapToCryptoOperation(e))
        .toList();
  }
}

CryptoOperation _mapToCryptoOperation(Map map) {
  switch (map['method']) {
    case 'sign':
      return SignOperation._fromResponseMap(map);
    case 'verify':
      return VerifyOperation._fromResponseMap(map);
    case 'encrypt':
      return EncryptOperation._fromResponseMap(map);
    case 'decrypt':
      return DecryptOperation._fromResponseMap(map);
    case 'public-key':
      return PublicKeyOperation._fromResponseMap(map);
    case 'address':
      return AddressOperation._fromResponseMap(map);
    case 'paymail':
      return PaymailOperation._fromResponseMap(map);
    default:
      throw ('invaid crypto operation');
  }
}

class IMB {
  IMBJS _mb;

  IMB(
      {@required String clientIdentifier,
      Amount minimumAmount,
      Amount suggestedAmount,
      String permission,
      Function(String token) onNewPermissionGranted}) {
    var config = {
      'clientIdentifier': clientIdentifier,
      if (minimumAmount != null) 'minimumAmount': minimumAmount.toMap(),
      if (suggestedAmount != null) 'suggestedAmount': suggestedAmount.toMap(),
      if (permission != null) 'permission': permission,
      if (onNewPermissionGranted != null)
        'onNewPermissionGranted': onNewPermissionGranted
    };

    var jsObj = _jsObjFromMap(config);
    _mb = IMBJS(jsObj);
  }

  Future<String> getPaymail() {
    return swipe(cryptoOperations: [PaymailOperation(name: 'paymail')])
        .then((response) => response.cryptoOperations[0].value);
  }

  Future<String> getPublicKey() {
    return swipe(cryptoOperations: [PublicKeyOperation(name: 'paymail')])
        .then((response) => response.cryptoOperations[0].value);
  }

  Future<SwipeResponse> swipe(
      {Amount amount,
      String buttonData,
      String buttonId,
      String opReturn,
      String to,
      List<CryptoOperation> cryptoOperations,
      List outputs}) {
    var options = {
      if (amount != null) ...amount.toMap(),
      if (buttonData != null) 'buttonData': buttonData,
      if (buttonId != null) 'buttonId': buttonId,
      if (opReturn != null) 'opReturn': opReturn,
      if (to != null) 'to': to,
      if (outputs != null) 'outputs': outputs,
      if (cryptoOperations != null)
        'cryptoOperations': cryptoOperations.map((e) => e.toMap()).toList()
    };

    var jsObj = _jsObjFromMap(options);
    return promiseToFuture(_mb.swipe(jsObj))
        .then((value) => _convertToDart(value))
        .then((value) => SwipeResponse._fromResponseMap(value));
  }

  Future<Amount> amountLeft() {
    return promiseToFutureAsMap(_mb.amountLeft()).then((value) => Amount(
        amount: value['amount'],
        currency: value['currency'],
        satoshis: value['satoshis']));
  }

  Future askForPermission({Amount minimumAmount, Amount suggestedAmount}) {
    var options = {
      if (minimumAmount != null) 'minimumAmount': minimumAmount.toMap(),
      if (suggestedAmount != null) 'suggestedAmount': suggestedAmount.toMap(),
    };
    var jsObj = _jsObjFromMap(options);
    return promiseToFuture(_mb.askForPermission(jsObj));
  }
}

_jsObjFromMap(Map map) {
  var newMap = Map.from(map);
  var keysForFunctions = [];

  for (var key in map.keys) {
    if (map[key] is Function) {
      keysForFunctions.add(key);
      newMap[key] = null;
    }
  }

  var jsObj = jsonParse(jsonEncode(newMap));

  for (var key in keysForFunctions) {
    Function f = map[key];
    setProperty(jsObj, key, allowInterop(f));
  }

  return jsObj;
}

dynamic _convertToDart(value) {
  return jsonDecode(jsonStringify(value));
}
