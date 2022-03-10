import 'package:flutter/material.dart';
import './profile.dart';

class Home extends StatefulWidget {
  final Future<void> Function() logoutAction;
  final String name;
  final String picture;
  late final Profile userProfile;

  Home(this.logoutAction, this.name, this.picture, {required Key key})
      : super(key: key) {
    userProfile = Profile(logoutAction, name, picture, key: UniqueKey());
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _widgetOptions.add(widget.userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text('DiscoRsvp'), centerTitle: true),
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)), // ,
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
