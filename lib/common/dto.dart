import 'package:discorsvp/common/shared.dart';

class Session {
  Session({
    required this.id,
    required this.status,
    required this.owner,
    required this.channel,
    required this.target,
    required this.audience,
    required this.squad,
    required this.others,
    required this.created,
  });

  String id;
  SessionStatus status;
  IdNamePair owner;
  Channel channel;
  int target;
  DateTime created;
  List<IdNamePair> audience;
  List<Squad> squad;
  List<dynamic> others;

  bool isSquadMember(String userId) =>
      squad.where((element) => element.member.id == userId).isNotEmpty;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json["id"],
        status: SessionStatus.values[json["status"]],
        owner: IdNamePair.fromJson(json["owner"]),
        channel: Channel.fromJson(json["channel"]),
        target: json["target"],
        created: DateTime.parse(json["created"]),
        audience: List<IdNamePair>.from(
            json["audience"].map((x) => IdNamePair.fromJson(x))),
        squad: List<Squad>.from(json["squad"].map((x) => Squad.fromJson(x))),
        others: List<dynamic>.from(json["others"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "owner": owner.toJson(),
        "channel": channel.toJson(),
        "target": target,
        "created": created,
        "audience": List<dynamic>.from(audience.map((x) => x.toJson())),
        "squad": List<dynamic>.from(squad.map((x) => x.toJson())),
        "others": List<dynamic>.from(others.map((x) => x)),
      };
}

class IdNamePair {
  IdNamePair({
    required this.id,
    required this.name,
  });

  String id;
  String name;

  factory IdNamePair.fromJson(Map<String, dynamic> json) => IdNamePair(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Channel {
  Channel({
    required this.serverChannelId,
    required this.channel,
    required this.server,
  });
  String serverChannelId;
  IdNamePair channel;
  IdNamePair server;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        serverChannelId: json["serverChannelId"],
        channel: IdNamePair.fromJson(json["channel"]),
        server: IdNamePair.fromJson(json["server"]),
      );

  Map<String, dynamic> toJson() => {
        "serverChannelId": serverChannelId,
        "channel": channel.toJson(),
        "server": server.toJson(),
      };
}

class Squad {
  Squad({
    required this.member,
    required this.hasConnected,
  });

  IdNamePair member;
  bool hasConnected;

  factory Squad.fromJson(Map<String, dynamic> json) => Squad(
        member: IdNamePair.fromJson(json["member"]),
        hasConnected: json["hasConnected"],
      );

  Map<String, dynamic> toJson() => {
        "member": member.toJson(),
        "hasConnected": hasConnected,
      };
}
