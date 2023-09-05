import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({
    Key? key,
    required this.profileUid,
  }) : super(key: key);

  final profileUid;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors['backgroundLight'],
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: colors['text'],
                  )),
              Expanded(
                  child: Center(
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text('Имя Фамйлйя',
                              textAlign: TextAlign.center,
                              style: textStyles['title']),
                          SizedBox(height: 20),
                          Text('Всякие информации',
                              textAlign: TextAlign.center,
                              style: textStyles['text']),
                        ],
                      ),
                    )
                  ],
                ),
              )),
              Visibility(
                visible: profileUid == uid,
                child: customButton('Выйти', false, () => signOut()),
              )
            ],
          ),
        ));
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
