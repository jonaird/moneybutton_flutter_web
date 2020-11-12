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
  double height;
  Function onLoaded;

  String viewType;
  MoneyButton(Map options, {this.width = 200, this.height = 68, this.onLoaded, this.key}) {
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
        height: height,
        child: EasyWebView(
          onLoaded: onLoaded ?? () {},
          src: url,
          width: width,
          height: height,
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

  Future swipe(
      {Amount amount,
      String buttonData,
      String buttonId,
      String opReturn,
      String to,
      List cryptoOperations,
      List outputs}) {
    var options = {
      if (amount != null) ...amount.toMap(),
      if (buttonData != null) 'buttonData': buttonData,
      if (buttonId != null) 'buttonId': buttonId,
      if (opReturn != null) 'opReturn': opReturn,
      if (to != null) 'to': to,
      if (outputs != null) 'outputs': outputs,
      if (cryptoOperations != null) 'cryptoOperations': cryptoOperations
    };

    var jsObj = _jsObjFromMap(options);
    return promiseToFuture(_mb.swipe(jsObj))
        .then((value) => _convertToDart(value));
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
