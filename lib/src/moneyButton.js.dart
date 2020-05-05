@JS()

library MoneyButtonJs;
import 'dart:js';

import 'package:js/js.dart';

@JS('moneyButton.IMB')
class IMBJS{
  external factory IMBJS(options);

  external Promise swipe(options);

  external Promise amountLeft();
  external Promise askForPermission(config);
}

@JS('console.log')
external log(object);

@JS('JSON.parse')
external jsonParse(String json);

@JS('JSON.stringify')
external jsonStringify(obj);

@JS()
class Promise<T>{
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}

