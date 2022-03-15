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
                                        //fontWeight: FontWeight.bold,
                                        fontSize: 28))
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
      Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
          child: const Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'History', style: TextStyle(fontSize: 28))
              ],
            ),
          )),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const ListTile(
              trailing: Chip(
                label: Text('Pending'),
                backgroundColor: Colors.green,
              ),
              title: Text('Don Pedro'),
              subtitle: Text(
                '14 March 2020 (ll9ByWtuHVExOwIFZ0cx)',
                //style:
                //    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(17, 5, 0, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available slots: 3/4',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const Divider(),
                      Text(
                        'Squad',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Wrap(
                        children: const [
                          Chip(
                            label: Text('Ali',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                )),
                            backgroundColor: Colors.green,
                          ),
                          Chip(
                            label: Text('Don Pedro',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                )),
                            backgroundColor: Colors.green,
                          ),
                          Chip(
                            label: Text('Black Chicken',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                )),
                            backgroundColor: Colors.blueGrey,
                          ),
                          Chip(
                            label: Text('Pride',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                )),
                            backgroundColor: Colors.blueGrey,
                          ),
                        ],
                      )
                    ])),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    print('join pressed');
                  },
                  child: Text(
                    'Join',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.delete_outline_outlined,
                        color: Theme.of(context).colorScheme.error, size: 20),
                    onPressed: () {
                      print('delete pressed');
                    }),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
