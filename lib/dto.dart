import 'dart:ffi';

class IdNamePair {
  String id;
  String name;
  IdNamePair(this.id, this.name);

  factory IdNamePair.fromJson(Map<String, dynamic> json) {
    return IdNamePair(json['id'], json['name']);
  }
}

class Channel {
  IdNamePair server;
  IdNamePair channel;
  Channel(this.server, this.channel);

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(IdNamePair.fromJson(json['server']),
        IdNamePair.fromJson(json['channel']));
  }
}

class SquadMember {
  IdNamePair member;
  bool hasJoined;

  SquadMember(this.member, this.hasJoined);
  factory SquadMember.fromJson(Map<String, dynamic> json) {
    return SquadMember(IdNamePair.fromJson(json['member']), json['hasJoined']);
  }
}

enum SessionStatus { pending, complete, cancelled }

class Session {
  String id;
  SessionStatus status;
  IdNamePair owner;
  IdNamePair channel;
  int target;
  List<SquadMember> squad;

  Session(
      this.id, this.status, this.owner, this.channel, this.target, this.squad);

  factory Session.fromJson(Map<String, dynamic> json) {
    List<SquadMember> squad =
        (json['squad'] as List).map((e) => SquadMember.fromJson(e)).toList();
    return Session(
        json['id'],
        json['status'],
        IdNamePair.fromJson(json['owner']),
        IdNamePair.fromJson(json['channel']),
        json['target'],
        squad);
  }
}
