import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letovo_outside/src/auth_page.dart';
import 'package:letovo_outside/src/map_page.dart';
import 'package:letovo_outside/widgets.dart';

import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letovo Outside',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MapPage();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _email,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _pw,
              textInputAction: TextInputAction.done,
            ),
            ElevatedButton(onPressed: signIn, child: Text('Submit'))
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: _email.text, password: _pw.text);
  }
}
