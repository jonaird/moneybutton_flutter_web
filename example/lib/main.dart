import 'package:flutter/material.dart';
import 'package:moneybutton_flutter_web/moneybutton_flutter_web.dart';
import 'package:upstate/upstate.dart';

void main() {
  runApp(StateWidget(state: StateObject({'IMB': null}), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  StateObject state;
  void _incrementCounter() {

    if (_counter == 0) {
      state['IMB'].value = IMB({
        'clientIdentifier': 'a4764ce4c09db65ddb90a02701fd2d53',
        'suggestedAmount': {'amount': '1', 'currency': 'USD'},
        'onNewPermissionGranted': (String token) {
          print(token);
        }
      });
    } else if (_counter == 1) {
      state['IMB'].value.askForPermission({
        'suggestedAmount': {'amount': '1', 'currency': 'USD'}
      });
    } else if (_counter == 2) {
      state['IMB'].value.amountLeft().then((result) => print(result));
    } else {
      state['IMB'].value.swipe({
        'to': 'canyouhandleme@handcash.io',
        'amount': '0.01',
        'currency': 'USD'
      }).then((res) => print(res));
    }

    //  ..swipe({'to':'cheers@moneybutton.com','amount':'0.01','currency':'USD'});

    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    state = StateObject.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
