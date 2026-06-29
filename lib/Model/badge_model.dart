class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconPath; // Path to asset or URL
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final String requirementType; // e.g., 'spend_1000', 'create_trip'
  final dynamic requirementValue; // value to reach

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isUnlocked = false,
    this.progress = 0.0,
    required this.requirementType,
    this.requirementValue,
  });

  BadgeModel copyWith({
    bool? isUnlocked,
    double? progress,
  }) {
    return BadgeModel(
      id: id,
      name: name,
      description: description,
      iconPath: iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      requirementType: requirementType,
      requirementValue: requirementValue,
    );
  }
}
