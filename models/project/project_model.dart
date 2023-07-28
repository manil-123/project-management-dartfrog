import '../sprint/sprint_model.dart';
import '../user/user_model.dart';

class ProjectModel {
  final String id;
  final String name;
  final List<SprintModel> sprints;
  final List<UserModel> members;

  ProjectModel({
    required this.id,
    required this.name,
    required this.sprints,
    required this.members,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    var sprints = <SprintModel>[];
    if ((json['sprints'] as List).isNotEmpty) {
      json['sprints'].forEach((ticket) {
        sprints.add(SprintModel.fromJson(ticket));
      });
    }
    var members = <UserModel>[];
    if ((json['members'] as List).isNotEmpty) {
      json['members'].forEach((ticket) {
        members.add(UserModel.fromJson(ticket));
      });
    }
    return ProjectModel(
      id: json['project_id'],
      name: json['project_name'],
      sprints: sprints,
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['project_id'] = this.id;
    data['project_name'] = this.name;
    data['sprints'] = this.sprints.map((v) => v.toJson()).toList();
    data['members'] = this.members.map((v) => v.toJson()).toList();
    return data;
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    List<SprintModel>? sprints,
    List<UserModel>? members,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sprints: sprints ?? this.sprints,
      members: members ?? this.members,
    );
  }
}
