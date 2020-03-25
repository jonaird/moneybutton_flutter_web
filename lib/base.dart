import 'package:flutter/material.dart';
import 'package:easy_web_view/easy_web_view.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:easy_web_view/easy_web_view.dart';


class MoneyButton extends StatelessWidget {
  String url;
  double width;

  String viewType;
  MoneyButton(Map options,{double this.width=200}) {
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
        child: EasyWebView(src: url, width: width, height: 68));
  }
}
