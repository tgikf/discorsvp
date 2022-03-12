import 'package:flutter/material.dart';
import './profile.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

  var formData;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

    /* widget.socket.onConnect((_) {
      print('connect ${widget.socket.id}');
      widget.socket.emit('request', 'testRequest');
    }); */

    widget.socket.on('FullLoad', (data) => print('fullload ${data}'));
    widget.socket.on('error', (data) => print(data));

    widget.socket.onDisconnect((_) => print('disconnect'));
    widget.socket.on('fromServer', (_) => print(_));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text('DiscoRsvp'), centerTitle: true),
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)), // ,
        floatingActionButton: FloatingActionButton(
            onPressed: () => {
                  widget.socket.emitWithAck('pressed', null, ack: (data) {
                    print(data);
                    setState(() {
                      formData = data;
                    });
                  })
                },
            child: const Icon(Icons.add)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.list_alt)),
            BottomNavigationBarItem(
                label: 'Profile',
                icon: CircleAvatar(
                  radius: 12.0,
                  backgroundImage:
                      NetworkImage('https://picsum.photos/250?image=9'),
                  backgroundColor: Colors.transparent,
                ))
          ],
          currentIndex: 0,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ));
  }
}
