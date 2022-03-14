import 'package:flutter/material.dart';
import '../dto.dart';
import './profile.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'new_session_form.dart';

class Home extends StatefulWidget {
  final Future<void> Function() logoutAction;
  final String _discordUserName;
  final String _discordPictureUrl;
  final String _authToken;
  late final Profile _userProfile;
  late final IO.Socket socket;

  Home(this.logoutAction, this._authToken, this._discordUserName,
      this._discordPictureUrl,
      {required Key key})
      : super(key: key) {
    _userProfile = Profile(logoutAction, _discordUserName, _discordPictureUrl,
        key: UniqueKey());
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const Text(
      'Index 0: Home',
    ),
  ];

  @override
  void initState() {
    _widgetOptions.add(widget._userProfile);
    initSocket();
    super.initState();
  }

  Future<void> initSocket() async {
    widget.socket = IO.io(
        'http://10.0.2.2:3000',
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
            {'authorization': widget._authToken}).build());

    widget.socket.on('FullLoad', (data) => print('fullload ${data}'));
    widget.socket.on('error', (data) => print(data));

    widget.socket.onDisconnect((_) => print('disconnect'));
    widget.socket.on('fromServer', (_) => print(_));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => {
                  widget.socket.emitWithAck('pressed', null, ack: (data) {
                    final channels =
                        data.map<Channel>((e) => Channel.fromJson(e)).toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateForm(
                              channels, widget.socket,
                              key: UniqueKey())),
                    );
                  })
                },
            child: const Icon(Icons.add)),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                label: 'Home', icon: Icon(Icons.sports_esports)),
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
