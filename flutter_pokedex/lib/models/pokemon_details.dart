class PokemonDetails {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<String> abilities;

  const PokemonDetails({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
  });

  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map((type) => type['type']['name'] as String)
        .toList();

    final abilities = (json['abilities'] as List)
        .map((ability) => ability['ability']['name'] as String)
        .toList();

    return PokemonDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default']
              as String,
      types: types,
      height: json['height'] as int,
      weight: json['weight'] as int,
      abilities: abilities,
    );
  }

  String get upperName {
    return name[0].toUpperCase() + name.substring(1);
  }
}