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
    if (key != null) {
      key = UniqueKey();
    }
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

class IMB {
  IMBJS _mb;

  IMB(Map config) {
    var jsObj = _jsObjFromMap(config);
    _mb = IMBJS(jsObj);
  }

  Future swipe(Map options) {
    var jsObj = _jsObjFromMap(options);
    return promiseToFutureAsMap(_mb.swipe(jsObj));
  }

  amountLeft() {
    return promiseToFutureAsMap(_mb.amountLeft());
  }

  Future askForPermission(Map options) {
    var jsObj = jsonParse(jsonEncode(options));
    return promiseToFutureAsMap(_mb.askForPermission(jsObj));
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
