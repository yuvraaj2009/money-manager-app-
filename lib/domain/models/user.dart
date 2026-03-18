class User {
  final String id;
  final String email;
  final String name;
  final bool isSeeded;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isSeeded,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isSeeded: json['is_seeded'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'is_seeded': isSeeded,
        'created_at': createdAt.toIso8601String(),
      };
}
