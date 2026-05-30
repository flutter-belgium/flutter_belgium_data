class PersonCompany {
  const PersonCompany({
    required this.name,
    this.jobTitle,
    this.isActive = true,
  });

  final String name;
  final String? jobTitle;
  final bool isActive;
}
