class Pokemon {
  final int id;
  final String name;
  final String url;

  const Pokemon({
    required this.id,
    required this.name,
    required this.url,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;

    final uri = Uri.parse(url);
    final segments = uri.pathSegments;

    final id = int.parse(
      segments.where((segment) => segment.isNotEmpty).last,
    );
    return Pokemon(
      id: id,
      name: json['name'],
      url: url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }

  factory Pokemon.fromStorageJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  String get imageUrl {
    return 'https://raw.githubusercontent.com/'
        'PokeAPI/sprites/master/sprites/pokemon/other/'
        'official-artwork/$id.png';
  }

  String get upperName {
    return name[0].toUpperCase() + name.substring(1);
  }
}