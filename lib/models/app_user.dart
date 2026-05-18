class AppUser {
  final String id;
  final String? email;
  final String displayName;
  final bool isGuest;
  final bool isPremium;

  const AppUser({required this.id, this.email, required this.displayName, required this.isGuest, this.isPremium = false});

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(id: id, email: map['email'] as String?, displayName: map['display_name'] as String? ?? 'Gast', isGuest: map['is_guest'] as bool? ?? false, isPremium: map['is_premium'] as bool? ?? false);
  }

  Map<String, dynamic> toMap() => {'email': email, 'display_name': displayName, 'is_guest': isGuest, 'is_premium': isPremium};
}
