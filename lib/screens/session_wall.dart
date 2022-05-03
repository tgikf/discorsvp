import 'package:discorsvp/common/shared.dart';
import 'package:flutter/material.dart';

import '../common/session_card.dart';
import '../common/dto.dart';

class SessionWall extends StatelessWidget {
  final Future<void> Function(String, SessionAction) sessionAction;
  final List<Session> sessions;
  final String userId;
  const SessionWall(
      {required this.sessions,
      required this.sessionAction,
      required this.userId,
      Key? key})
      : super(key: key);

  Widget? _buildActionButton(BuildContext context, Session s) {
    if (s.status != SessionStatus.pending) return null;
    if (s.owner.id == userId) return null;
    final bool isInNoSquad = sessions
        .where(
            (s) => s.isSquadMember(userId) && s.status == SessionStatus.pending)
        .isEmpty;
    final bool isInThisSquad = s.isSquadMember(userId);
    if (isInNoSquad || isInThisSquad) {
      String label = s.isSquadMember(userId) ? 'Leave' : 'Join';
      SessionAction action =
          s.isSquadMember(userId) ? SessionAction.leave : SessionAction.join;

      return OutlinedButton(
        onPressed: () {
          sessionAction(s.id, action);
        },
        child: Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
    return null;
  }

  Widget? _buildDeleteButton(BuildContext context, Session s) {
    if (s.status != SessionStatus.pending) return null;
    if (s.owner.id != userId) return null;

    return OutlinedButton(
      onPressed: () {
        sessionAction(s.id, SessionAction.cancel);
      },
      child: Text(
        'Cancel',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SessionCard> _cardList = sessions
        .map<SessionCard>((e) => SessionCard(
            e, _buildActionButton(context, e), _buildDeleteButton(context, e),
            key: Key(e.id)))
        .toList();

    return _cardList.isEmpty
        ? const Text('No sessions found.')
        :Column(
                children: _cardList,
              );
  }
}
