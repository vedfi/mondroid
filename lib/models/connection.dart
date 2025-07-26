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

  String getMaskedConnectionString() {
    final pattern = RegExp(r"(mongodb(?:\+srv)?://[^:]+:)([^@]+)(@)");
    return uri.replaceAllMapped(pattern, (match) {
      return "${match.group(1)}*****${match.group(3)}";
    });
  }
}
