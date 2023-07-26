class UserModel {
  final String username;
  final String password;
  final String profilePic;
  final bool isAdmin;

  UserModel({
    required this.username,
    required this.password,
    this.profilePic = '',
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      profilePic: json['profilePic'],
      isAdmin: json['isAdmin'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['username'] = this.username;
    data['password'] = this.password;
    data['profilePic'] = this.profilePic;
    data['isAdmin'] = this.isAdmin;
    return data;
  }

  UserModel copyWith({
    String? userName,
    String? password,
    String? profilePic,
    bool? isAdmin,
  }) {
    return UserModel(
      username: userName ?? this.username,
      password: password ?? this.password,
      profilePic: profilePic ?? this.profilePic,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
