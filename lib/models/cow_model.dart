class Cow {
  final String id;
  final bool isAlive;
  final String name;
  final String farm;
  final String breed;

  Cow({
    required this.id,
    required this.isAlive,
    required this.name,
    required this.farm,
    required this.breed,
  });

  // Convert Cow object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'cow_id': id,
      'alive': isAlive ? 1 : 0,
      'cow_name': name,
      'farm': farm,
      'breed': breed,
    };
  }

  // Create Cow object from Map (database retrieval)
  factory Cow.fromMap(Map<String, dynamic> map) {
    return Cow(
      id: map['cow_id'] ?? '',
      isAlive: (map['alive'] ?? 0) == 1,
      name: map['cow_name'] ?? '',
      farm: map['farm'] ?? '',
      breed: map['breed'] ?? '',
    );
  }

  // Create a copy of Cow with updated fields
  Cow copyWith({
    String? id,
    bool? isAlive,
    String? name,
    String? farm,
    String? breed,
  }) {
    return Cow(
      id: id ?? this.id,
      isAlive: isAlive ?? this.isAlive,
      name: name ?? this.name,
      farm: farm ?? this.farm,
      breed: breed ?? this.breed,
    );
  }

  @override
  String toString() {
    return 'Cow{id: $id, isAlive: $isAlive, name: $name, farm: $farm, breed: $breed}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cow && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}