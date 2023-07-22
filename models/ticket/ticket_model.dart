import '../user/user_model.dart';

class TicketModel {
  final String id;
  final String title;
  final String? logs;
  final int? weight;
  final String? createdAt;
  final String? closedAt;
  final UserModel? assignedTo;

  TicketModel({
    required this.id,
    required this.title,
    this.logs,
    this.weight,
    this.createdAt,
    this.closedAt,
    this.assignedTo,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'],
      logs: json['logs'],
      weight: json['weight'],
      createdAt: json['createdAt'],
      closedAt: json['closedAt'],
      assignedTo: json['assignedTo'] != null
          ? UserModel.fromJson(json['assignedTo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['title'] = this.title;
    data['logs'] = this.logs;
    data['weight'] = this.weight;
    data['createdAt'] = this.createdAt;
    data['closedAt'] = this.closedAt;
    if (this.assignedTo != null) {
      data['assignedTo'] = this.assignedTo!.toJson();
    }
    return data;
  }
}
