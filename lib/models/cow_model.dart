class Cow {
  final String id;
  final bool isAlive;
  final String name;
  final String breed;
  final bool isFemale;

  Cow({
    required this.id,
    required this.isAlive,
    required this.name,
    required this.breed,
    required this.isFemale,
  });

  String get gender => isFemale ? 'Female' : 'Male';

  // Convert Cow object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'cow_id': id,
      'alive': isAlive ? 1 : 0,
      'cow_name': name,
      'breed': breed,
      'isFemale': isFemale ? 1 : 0,
    };
  }

  // Create Cow object from Map (database retrieval)
  factory Cow.fromMap(Map<String, dynamic> map) {
    bool female = false;
    if (map.containsKey('isFemale')) {
      female = (map['isFemale'] ?? 0) == 1;
    } else if (map.containsKey('gender')) {
      final g = map['gender'];
      if (g is String) {
        female = g.toLowerCase() == 'female';
      } else if (g is int) {
        female = g == 1;
      }
    }
    return Cow(
      id: map['cow_id'] ?? '',
      isAlive: (map['alive'] ?? 0) == 1,
      name: map['cow_name'] ?? '',
      breed: map['breed'] ?? '',
      isFemale: female,
    );
  }

  // Create a copy of Cow with updated fields
  Cow copyWith({
    String? id,
    bool? isAlive,
    String? name,
    String? breed,
    bool? isFemale,
  }) {
    return Cow(
      id: id ?? this.id,
      isAlive: isAlive ?? this.isAlive,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      isFemale: isFemale ?? this.isFemale,
    );
  }

  @override
  String toString() {
    return 'Cow{id: $id, isAlive: $isAlive, name: $name, breed: $breed, Gender: $gender}';
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