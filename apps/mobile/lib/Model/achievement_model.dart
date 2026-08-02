class AchievementModel {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String iconKey;
  final bool isUnlocked;
  final bool celebrationShown;

  const AchievementModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.iconKey,
    this.isUnlocked = false,
    this.celebrationShown = true,
  });

  factory AchievementModel.fromCatalogRow(Map<String, dynamic> row) {
    return AchievementModel(
      id: row['id']?.toString() ?? '',
      slug: row['slug']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      iconKey: row['icon_key']?.toString() ?? '',
    );
  }

  AchievementModel copyWith({
    bool? isUnlocked,
    bool? celebrationShown,
  }) {
    return AchievementModel(
      id: id,
      slug: slug,
      name: name,
      description: description,
      iconKey: iconKey,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      celebrationShown: celebrationShown ?? this.celebrationShown,
    );
  }
}
