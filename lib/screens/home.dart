import 'dart:convert';

import 'package:discorsvp/screens/session_wall.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:overlay_support/overlay_support.dart';

import '../common/dto.dart';
import './profile.dart';
import 'new_session_form.dart';
import '../common/shared.dart';

class Home extends StatefulWidget {
  final Map<String, String> userProfile;
  final String authToken;
  final String deviceToken;
  late final IO.Socket socket;
  final Future<void> Function() logoutAction;

  Home(
      {required this.userProfile,
      required this.authToken,
      required this.deviceToken,
      required this.logoutAction,
      required Key key})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isBusy = false;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = [];
  List<Session> _pendingSessions = [];
  List<Session> _userHistory = [];

  @override
  void initState() {
    initSocket();
    updateWidgetOptions();
    super.initState();
  }

  void updateWidgetOptions() {
    _widgetOptions = <Widget>[
      SessionWall(
          sessions: _pendingSessions,
          sessionAction: performSessionAction,
          userId: widget.userProfile['userId'] ?? 'missingUserId',
          key: UniqueKey()),
      Profile(
        logoutAction: widget.logoutAction,
        userId: widget.userProfile['userId'] ?? 'missingUserId',
        userName: widget.userProfile['userName'] ?? 'missingUserName',
        pictureUri: widget.userProfile['pictureUri'] ?? 'missingPictureUri',
        sessionWall: SessionWall(
            sessions: _userHistory,
            sessionAction: performSessionAction,
            userId: widget.userProfile['userId'] ?? 'missingUserId',
            scroll: false,
            key: UniqueKey()),
        key: UniqueKey(),
      )
    ];
  }

  @override
  void dispose() {
    widget.socket.dispose();
    super.dispose();
  }

  Future<void> performSessionAction(
      String sessionId, SessionAction action) async {
    setState(() {
      isBusy = true;
    });
    widget.socket.emitWithAck(
        'SessionAction', {'sessionId': sessionId, 'action': action.name},
        ack: (data) {
      Map<String, dynamic> res = jsonDecode(data);
      final String msg = res['message'];

      final Icon icn = Icon(res['success'] ? Icons.done : Icons.error,
          color: Theme.of(context).colorScheme.onPrimary);

      showSimpleNotification(Text(msg),
          leading: icn,
          background: Theme.of(context).colorScheme.primary,
          foreground: Theme.of(context).colorScheme.onPrimary);

      setState(() {
        isBusy = false;
      });
    });
  }

  Future<void> initSocket() async {
    setState(() {
      isBusy = true;
    });
    widget.socket = IO.io(
        'http://192.168.1.244:3000',
        /*/ 'https://discorsvp-bfdda.nw.r.appspot.com:3000',*/
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({
              'authorization': widget.authToken,
              'device': widget.deviceToken
            })
            .enableForceNew()
            .build());
    widget.socket.onConnectError((data) {
      print('connect error' + data.toString());
      isBusy = false;
    });
    widget.socket.onConnect((_) {
      print('connected!!');
      setState(() {
        isBusy = true;
      });
      widget.socket.emitWithAck('GetPendingSessions', null, ack: (data) {
        setState(() {
          _pendingSessions = jsonDecode(data)
              .map<Session>((e) => Session.fromJson(e))
              .toList();
          updateWidgetOptions();
          isBusy = false;
        });
      });
      widget.socket.emitWithAck('GetUserHistory', null, ack: (data) {
        setState(() {
          _userHistory = jsonDecode(data)
              .map<Session>((e) => Session.fromJson(e))
              .toList();
          updateWidgetOptions();
          isBusy = false;
        });
      });
    });

    widget.socket.on('SessionUpdate', (data) {
      Session session = Session.fromJson(jsonDecode(data));
      setState(() {
        int pendingIndex =
            _pendingSessions.indexWhere((e) => e.id == session.id);
        if (pendingIndex >= 0) {
          _pendingSessions[pendingIndex] = session;
        } else if (session.status == SessionStatus.pending) {
          _pendingSessions.insert(0, session);
        }

        int historyIndex = _userHistory.indexWhere((e) => e.id == session.id);
        if (historyIndex >= 0) {
          _userHistory[historyIndex] = session;
        } else {
          final String userId = widget.userProfile['userId'] ?? 'missingUserId';
          if (session.isSquadMember(userId) || session.owner.id == userId) {
            _userHistory.insert(0, session);
          }
        }
        updateWidgetOptions();
        isBusy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: isBusy
                ? const CircularProgressIndicator()
                : _widgetOptions.elementAt(_selectedIndex)),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => {
                  setState(() {
                    isBusy = true;
                  }),
                  widget.socket.emitWithAck('GetChannels', null, ack: (data) {
                    final channels =
                        data.map<Channel>((e) => Channel.fromJson(e)).toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateForm(
                              channels, widget.socket,
                              key: UniqueKey())),
                    );
                    setState(() {
                      isBusy = false;
                    });
                  }),
                },
            child: const Icon(Icons.add)),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 30,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                label: 'Sessions', icon: Icon(Icons.headset_mic_outlined)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(Icons.account_circle)),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) => {
            setState(() {
              _selectedIndex = index;
            })
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ));
  }
}
