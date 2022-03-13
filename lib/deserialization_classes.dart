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
