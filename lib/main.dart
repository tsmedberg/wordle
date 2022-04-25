import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wordle.dart';
import 'web.dart';

Wordle _wordle = Wordle();
String? _username;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
  if (prefs.containsKey('username')) {
    _username = await prefs.getString('username');
    _wordle.username = _username;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Wordle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final _usernameController = TextEditingController();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Future<bool> _setUsername(String username) async {
      if (await Web.validateUsername(username)) {
        print('valid username');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        setState(() {
          _username = username;
          _wordle.username = _username;
        });
        await Web.createUser(_username!);
        return true;
      } else {
        print('invalid username');
        showDialogEz(
            context: context,
            title: const Text('error'),
            content: const Text('invalid username'));
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          ListTile(
            title: Text('wordle'),
          ),
          if (_username != null)
            ListTile(
              leading: Text('username:'),
              title: Text(_username!),
            ),
          ListTile(
            title: Text('set username'),
            onTap: () async {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('enter username'),
                      content: TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.done,
                        decoration:
                            const InputDecoration(labelText: 'username'),
                        onFieldSubmitted: (value) async {
                          if (await _setUsername(value)) {
                            _usernameController.clear();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: (() async {
                              if (await _setUsername(
                                  _usernameController.text)) {
                                _usernameController.clear();
                                Navigator.of(context).pop();
                              }
                            }),
                            child: const Text('save'))
                      ],
                    );
                  });
            },
          ),
          ListTile(
            title: const Text('Show license page'),
            onTap: () {
              showLicensePage(context: context);
            },
          )
        ],
      )),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_wordle.widget()],
        ),
      ),
    );
  }
}

void showLicensePage({
  required BuildContext context,
  String? applicationName,
  String? applicationVersion,
  Widget? applicationIcon,
  String? applicationLegalese,
  bool useRootNavigator = false,
}) {
  assert(context != null);
  assert(useRootNavigator != null);
  Navigator.of(context, rootNavigator: useRootNavigator)
      .push(MaterialPageRoute<void>(
    builder: (BuildContext context) => LicensePage(
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: applicationIcon,
      applicationLegalese: applicationLegalese,
    ),
  ));
}

void showDialogEz({
  required BuildContext context,
  required Widget title,
  required Widget content,
}) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title,
          content: content,
          actions: [
            ElevatedButton(
                onPressed: (() {
                  Navigator.of(context).pop();
                }),
                child: const Text('ok'))
          ],
        );
      });
}
