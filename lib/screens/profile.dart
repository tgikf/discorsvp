import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'session_wall.dart';

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String userName;
  final String userId;
  final String pictureUri;
  final SessionWall sessionWall;

  const Profile(
      {required this.logoutAction,
      required this.userName,
      required this.userId,
      required this.pictureUri,
      required this.sessionWall,
      required Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(
                  top: BorderSide(width: 0.8, color: Colors.grey),
                  bottom: BorderSide(width: 0.8, color: Colors.grey))),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Column(children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.8),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: NetworkImage(pictureUri),
                          ),
                        ),
                      ),
                    ])),
                Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: userName,
                                    style: const TextStyle(
                                        //fontWeight: FontWeight.bold,
                                        fontSize: 28))
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                              height: 25,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await logoutAction();
                                },
                                child: const Text('Logout'),
                              )),
                        ])),
              ])),
      Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
          child: const Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'History', style: TextStyle(fontSize: 28))
              ],
            ),
          )),
      sessionWall
    ]);
  }
}
