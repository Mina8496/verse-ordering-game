class UserProfile {
  final String? churchId;
  final String? chapterId;
  final String? fullName;
  final String? season;
  final String? church;
  final String? role;
  final String? status;
  final String? email;
  final String? name;
  final String? gender;
  final String? phoneNumber;
  final String? profileImageUrl;
  final dynamic birthday; 

  const UserProfile({
    this.churchId,
    this.chapterId,
    this.fullName,
    this.season,
    this.church,
    this.role,
    this.status,
    this.email,
    this.name,
    this.gender,
    this.phoneNumber,
    this.profileImageUrl,
    this.birthday,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      churchId: data['ChurchID'] as String?,
      chapterId: data['ChapterID'] as String?,
      fullName: data['full_name'] as String?,
      season: data['Season'] as String?,
      church: data['Church'] as String?,
      role: data['role'] as String?,
      status: data['status'] as String?,
      email: data['email'] as String?,
      name: data['name'] as String?,
      gender: data['Gender'] as String?,
      phoneNumber: data['Phone_Namber'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      birthday: data['Birthday'],
    );
  }
}