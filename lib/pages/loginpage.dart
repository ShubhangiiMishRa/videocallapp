import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:firebase_core/firebase_core.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>{
  final _formKey = GlobalKey<FormState>();
  late String email, password;

  final _auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.reference().child('users');

  void _signIn() async {
    try{
      final newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if(newUser != null){
        //print("Successful");
        //final FirebaseUser user = await _auth.currentUser();
        //final userId = user;
      }
      else{
        print('Failed');
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}