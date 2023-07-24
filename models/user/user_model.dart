class UserModel {
  final String id;
  final String userName;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.userName,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userName: json['userName'],
      isAdmin: json['isAdmin'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['userName'] = this.userName;
    data['isAdmin'] = this.isAdmin;
    return data;
  }
}
