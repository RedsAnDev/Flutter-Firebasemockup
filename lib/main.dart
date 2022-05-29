import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
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
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Work with Flutter'),
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
  FirebaseApp? _firebaseApp;
  FirebaseAuth? _firebaseAuth;
  Logger _logger = Logger();

  Future awakeState() async {
    _firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseAuth = FirebaseAuth.instance;
    _snackbar(context,message:"FirebaseApp Inizializzata");
  }

  @override
  initState() {
    awakeState();
  }

  void _snackbar(BuildContext context, {String message: "Errore"}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _send() async{
    if (_firebaseApp == null) {
      _snackbar(context, message: "FireBaseApp non ancora inizializzata");
      return;
    }
    await prepareInstance("+39 339 111 1111","123456");
    setState(() {
      _logger.i(_firebaseAuth.toString());
      _snackbar(context, message: "Ok!");
    });
  }

  Future<bool> prepareInstance(String phoneNumber,String smsCode) async {
    if(_firebaseAuth==null){
      _snackbar(context,message: "FirefaseAuth non é ancora inizializzato");
      return false;
    }
    await _firebaseAuth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth!.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _logger.e(e.toString());
        _snackbar(context, message: e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);
        UserCredential userCredential=await _firebaseAuth!.signInWithCredential(phoneAuthCredential);
        if(userCredential.user!=null){
          String token=await userCredential.user!.getIdToken();
         _logger.i("ID TOKEN  ${token}");
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    child: Column(
                  children: [
                    TextFormField(
                      initialValue: "Num telefono",
                    ),
                    TextFormField(
                      initialValue: "Pin",
                    ),
                  ],
                )))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _send,
        tooltip: 'Invia',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
