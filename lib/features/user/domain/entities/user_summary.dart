class UserSummary {
  const UserSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.season,
    this.profileImageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String season;
  final String? profileImageUrl;
}
