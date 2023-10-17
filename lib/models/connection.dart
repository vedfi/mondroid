class Connection {
  String name;
  String uri;

  Connection(this.name, this.uri);

  Connection.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        uri = json["uri"];

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
      };

  String getConnectionString() => uri;
}
