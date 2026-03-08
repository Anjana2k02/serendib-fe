import 'dart:ui';

class PointOfInterest {
  final String id;
  final String name;
  final String category;
  final Offset position;
  final String? description;
  final List<String> tags;
  final String? imagePath;
  final String? iconPath;
  final String? artifactId;
  final List<String> connectedPOIs;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.category,
    required this.position,
    this.description,
    this.tags = const [],
    this.imagePath,
    this.iconPath,
    this.artifactId,
    required this.connectedPOIs,
  });

  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      description: json['description'] as String?,
      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>).map((e) => e as String).toList()
          : [],
      imagePath: json['imagePath'] as String?,
      iconPath: json['iconPath'] as String?,
      artifactId: json['artifactId'] as String?,
      connectedPOIs: (json['connectedPOIs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'position': {
        'x': position.dx,
        'y': position.dy,
      },
      'description': description,
      'tags': tags,
      'imagePath': imagePath,
      'iconPath': iconPath,
      'artifactId': artifactId,
      'connectedPOIs': connectedPOIs,
    };
  }

  PointOfInterest copyWith({
    String? id,
    String? name,
    String? category,
    Offset? position,
    String? description,
    List<String>? tags,
    String? imagePath,
    String? iconPath,
    String? artifactId,
    List<String>? connectedPOIs,
  }) {
    return PointOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      position: position ?? this.position,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      iconPath: iconPath ?? this.iconPath,
      artifactId: artifactId ?? this.artifactId,
      connectedPOIs: connectedPOIs ?? this.connectedPOIs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointOfInterest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
