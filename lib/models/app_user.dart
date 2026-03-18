class AppUser {
  final String id;
  final String? email;
  final String displayName;
  final bool isGuest;

  const AppUser({
    required this.id,
    this.email,
    required this.displayName,
    required this.isGuest,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['display_name'] as String? ?? 'Gast',
      isGuest: map['is_guest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'is_guest': isGuest,
    };
  }
}
