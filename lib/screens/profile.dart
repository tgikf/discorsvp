import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String name;
  final String picture;

  const Profile(this.logoutAction, this.name, this.picture, {required Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            margin: const EdgeInsets.fromLTRB(0, 80, 0, 40),
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 65, 65, 65),
                border: Border(
                    top: BorderSide(
                        width: 0.8, color: Color.fromARGB(255, 148, 148, 148)),
                    bottom: BorderSide(
                        width: 0.8,
                        color: Color.fromARGB(255, 148, 148, 148)))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Divider(thickness: 1),
                  Expanded(
                      flex: 1,
                      child: Column(children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 148, 148, 148),
                                width: 0.8),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(picture),
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
                                      text: name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24))
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                height: 25,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.logout),
                                  onPressed: () async {
                                    await logoutAction();
                                  },
                                  label: const Text('Logout'),
                                )),
                          ])),
                ])),
        const Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'History', style: TextStyle(fontSize: 24))
            ],
          ),
        ),
        ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
          children: const <Widget>[
            Text("I'm dedicating every day to you"),
            Text('Domestic life was never quite my style'),
            Text('When you smile, you knock me out, I fall apart'),
            Text('And I thought I was so smart'),
          ],
        )
      ],
    );
  }
}
