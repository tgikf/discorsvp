import 'package:flutter/material.dart';

import '../dto.dart';

class SessionCard extends StatelessWidget {
  final Session _session;

  const SessionCard(this._session, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            trailing: Chip(
              label: Text(_session.status.toString()),
              backgroundColor: Colors.green,
            ),
            title: Text(_session.owner.name),
            subtitle: const Text(
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
                      'Available slots: ${_session.target - _session.squad.length}/${_session.target}',
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
                    Row(
                      children: _session.squad
                          .map<Chip>(
                            (e) => Chip(
                              label: Text(e.member.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal)),
                              backgroundColor:
                                  e.hasJoined ? Colors.green : Colors.blueGrey,
                            ),
                          )
                          .toList(),
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
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
    );
  }
}
