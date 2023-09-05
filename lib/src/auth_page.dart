import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letovo_outside/widgets.dart';

import 'models.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int mode = 0;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _graduationYear = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 1:
        return signInPopup();
      case 2:
        return signUpPopup();
      default:
        return Scaffold(
            backgroundColor: Colors.black,
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/icon/icon.png')),
                  SizedBox(height: 10),
                  customButton(
                      'Войти',
                      true,
                      () => setState(() {
                            mode = 1;
                          })),
                  SizedBox(height: 10),
                  customButton(
                      'Регистрация',
                      false,
                      () => setState(() {
                            mode = 2;
                          }))
                ],
              ),
            ));
    }
  }

  Widget signInPopup() {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => setState(() {
                        mode = 0;
                      }),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: colors['text'],
                  )),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('прйвет!',
                        textAlign: TextAlign.center,
                        style: textStyles['title']),
                    SizedBox(height: 20),
                    customTextField('летовская почта', _email, false,
                        TextInputType.emailAddress),
                    SizedBox(height: 10),
                    customTextField(
                        'пароль', _password, true, TextInputType.text),
                  ],
                ),
              ),
              Visibility(
                  child: customButton('Забыли пароль?', false, () => {}),
                  visible: MediaQuery.of(context).viewInsets.bottom == 0),
              SizedBox(height: 10),
              customButton(
                  'Готово', true, () => signIn(_email.text, _password.text))
            ],
          ),
        ));
  }

  Widget signUpPopup() {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => setState(() {
                        mode = 0;
                      }),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: colors['text'],
                  )),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text('в первыи раз?',
                              textAlign: TextAlign.center,
                              style: textStyles['title']),
                          SizedBox(height: 20),
                          customTextField(
                              'имя', _name, false, TextInputType.name),
                          SizedBox(height: 10),
                          customTextField('год выпуска', _graduationYear, false,
                              TextInputType.number),
                          SizedBox(height: 10),
                          customTextField('летовская почта', _email, false,
                              TextInputType.emailAddress),
                          SizedBox(height: 10),
                          customTextField(
                              'пароль', _password, true, TextInputType.text),
                          SizedBox(height: 20),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              customButton(
                  'Готово',
                  true,
                  () => signUp(
                        _email.text,
                        _password.text,
                      ))
            ],
          ),
        ));
  }

  Future signIn(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future signUp(email, password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .then((value) => value.user != null
            ? addUserDetails(UserData(
                userId: value.user!.uid,
                name: _name.text.trim(),
                graduationYear: int.parse(_graduationYear.text.trim())))
            : print('auth failed'));
  }

  Future addUserDetails(UserData userData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userData.userId)
        .set({
      'name': userData.name,
      'graduationYear': userData.graduationYear,
    });
  }
}
