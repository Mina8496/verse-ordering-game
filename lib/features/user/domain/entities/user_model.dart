class UserModel {
  final String id;
  final String fullName;
  final String churchID;
  final String chapterID;
  final String season;
  final String church;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.churchID,
    required this.chapterID,
    required this.season,
    required this.church,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      fullName: data['full_name'] as String? ?? '',
      churchID: data['ChurchID'] as String? ?? '',
      chapterID: data['ChapterID'] as String? ?? '',
      season: data['Season'] as String? ?? '',
      church: data['Church'] as String? ?? '',
    );
  }
}
