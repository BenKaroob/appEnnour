// Modèle Category qui représente une catégorie de cours
class Category {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String iconName;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.iconName = '',
  });

  // Crée une copie de Category avec des modifications spécifiques
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? iconName,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
    );
  }

  // Création d'une Category à partir d'un map (JSON)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      iconName: json['iconName'] ?? '',
    );
  }

  // Conversion de la Category en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconName': iconName,
    };
  }
}