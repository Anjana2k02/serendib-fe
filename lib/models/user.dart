class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? role;
  final bool? enabled;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role,
    this.enabled,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'enabled': enabled,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      enabled: json['enabled'] as bool?,
    );
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    bool? enabled,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      enabled: enabled ?? this.enabled,
    );
  }
}
