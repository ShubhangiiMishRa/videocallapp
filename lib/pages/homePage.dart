
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:developer';

import 'call.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();

}
class _HomePageState extends State<HomePage>{
  final _meetingController = TextEditingController();
  bool _validateError = false;
  ClientRole? _role = ClientRole.Broadcaster;

  void dispose(){
    _meetingController.dispose();
    super.dispose();
  }
  Future<void> onJoin() async{
    setState(() {
      _meetingController.text.isEmpty?
          _validateError= true
          : _validateError = false;
    });
    if(_meetingController.text.isNotEmpty){
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage(
      meetingName: _meetingController.text,
      role: _role,
      )));
    }
  }
  Future<void> _handleCameraAndMic(Permission permission)
  async {
    final status = await permission.request();
    log(status.toString());

  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Video Call Application', style: TextStyle(
            fontSize: 25,
            fontStyle: FontStyle.italic
          ),),
          centerTitle: true,
          backgroundColor: Colors.black,
          toolbarHeight: 60,
        ),
        body: SingleChildScrollView(
        child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 40),
            TextField(
              controller: _meetingController,
              decoration: InputDecoration(
                errorText: _validateError? 'Meeting name is mandatory':null,
              border: UnderlineInputBorder(
                borderSide: BorderSide(width: 1),
              ),
              hintText: 'Meeting name',  
              ),
            ),
            RadioListTile(
              title: Text('Host'),
              value: ClientRole.Broadcaster,
                groupValue: _role,
                onChanged: (ClientRole? value){
                  setState(() {
                    _role = value;
                  });
                },
            ),
            RadioListTile(
              title: Text('Participant'),
              value: ClientRole.Audience,
              groupValue: _role,
              onChanged: (ClientRole? value){
                setState(() {
                  _role = value;
                });
              },
            ),
            ElevatedButton(onPressed: onJoin,
              child: Text('Join'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
            ),
            )
          ],
        ),
    ),
    ),
    );
  }
}
