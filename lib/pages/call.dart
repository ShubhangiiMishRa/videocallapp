import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'dart:async';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:videocallapp/utils/settings.dart';

class CallPage extends StatefulWidget {
  final String? meetingName;
  final ClientRole? role; // if the user is the host or a participant

  CallPage({
    Key? key,
    this.meetingName,
    this.role,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  void initState() {
    super.initState();
    initialize();
  }

  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings
            .add('App ID missing, please provide your App ID settings.dart');
        _infoStrings.add('Agaro Engine is not starting');
      });
      return;
    }
    //!_initAgoraRtcEngine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);

    //!_addAgoraEventHandlers
    _addAgoraEventHandlers();
    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(config);
    await _engine.joinChannel(token, widget.meetingName!, null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'Error: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (meeting, uid, elapsed) {
      setState(() {
        _infoStrings.add('Leave meeting');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'User Offline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'First Remote Video: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(rtc_local_view.SurfaceView());
    }
    for (var uid in _users) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: widget.meetingName!,
      ));
    }
    final views = list;
    return Column(
      children:
          List.generate(views.length, (index) => Expanded(child: views[index])),
    );
  }

  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteAllRemoteAudioStreams(muted);
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _panel() {
    return Visibility(
        visible: viewPanel,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 48),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (BuildContext context, int index){
                if(_infoStrings.isEmpty){
                  return Text('null');
                }
                return Padding(padding: EdgeInsets.symmetric(
                  vertical:  3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _infoStrings[index],
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ))
                  ],
                ),
                );
              }
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Video Call'),
        //   centerTitle: true,
        // ),
        );
  }
}
