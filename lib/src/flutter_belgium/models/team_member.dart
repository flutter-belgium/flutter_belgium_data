class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.linkedinUrl,
    this.githubUrl,
  });

  final String name;
  final String role;
  final String avatarUrl;
  final String? linkedinUrl;
  final String? githubUrl;

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        name: json['name'] as String,
        role: json['role'] as String,
        avatarUrl: json['avatarUrl'] as String,
        linkedinUrl: json['linkedinUrl'] as String?,
        githubUrl: json['githubUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'avatarUrl': avatarUrl,
        'linkedinUrl': linkedinUrl,
        'githubUrl': githubUrl,
      };
}
