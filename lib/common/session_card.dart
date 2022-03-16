import 'package:discorsvp/common/shared.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../dto.dart';

class SessionCard extends StatelessWidget {
  final Session _session;
  final Widget? _actionButton;
  final Widget? _deleteButton;

  const SessionCard(this._session, this._actionButton, this._deleteButton,
      {Key? key})
      : super(key: key);

  Chip getStatusChip(SessionStatus status) {
    Color clr;
    String text;
    switch (status) {
      case SessionStatus.pending:
        clr = Colors.green;
        text = 'Pending';
        break;
      case SessionStatus.complete:
        clr = Colors.blueGrey;
        text = 'Completed';
        break;
      case SessionStatus.cancelled:
        clr = Colors.red;
        text = 'Cancelled';
        break;
      default:
        clr = Colors.red;
        text = 'Invalid';
        break;
    }
    return Chip(label: Text(text), backgroundColor: clr);
  }

  @override
  Widget build(BuildContext context) {
    int openSlots = _session.status == SessionStatus.pending &&
            _session.target - _session.squad.length > 0
        ? _session.target - _session.squad.length
        : 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            trailing: getStatusChip(_session.status),
            title: RichText(
                text: TextSpan(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface),
                    children: [
                  TextSpan(text: _session.owner.name),
                  TextSpan(
                    text: ' ${timeago.format(_session.created)}',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface),
                  )
                ])),
            subtitle: Text('${_session.id}'),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface),
                            children: [
                          TextSpan(text: _session.channel.channel.name),
                          TextSpan(
                            text: ' on ${_session.channel.server.name}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface),
                          )
                        ])),
                    const Divider(),
                    Text(
                      'Squad (${_session.squad.length}/${_session.target})',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Wrap(spacing: 4, children: [
                      ..._session.squad
                          .map<Chip>(
                            (e) => Chip(
                              label: Text(e.member.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal)),
                              backgroundColor: e.hasConnected &&
                                      _session.status != SessionStatus.cancelled
                                  ? Colors.green
                                  : Colors.blueGrey,
                            ),
                          )
                          .toList(),
                      ...List.generate(openSlots, (int index) => index).map(
                        (e) => ChoiceChip(
                          label: Text('Player ${e + 1}',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          backgroundColor: Colors.blueGrey,
                          selected: false,
                        ),
                      )
                    ]),
                  ])),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButton ?? Container(),
              _deleteButton ?? Container(),
            ],
          ),
        ],
      ),
    );
  }
}
