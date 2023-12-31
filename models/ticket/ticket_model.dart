import '../user/user_model.dart';

class TicketModel {
  final String id;
  final String title;
  final String? logs;
  final int? weight;
  final String? createdAt;
  final String? closedAt;
  final UserModel? assignedTo;
  final String? ticketStatus;

  TicketModel({
    required this.id,
    required this.title,
    this.logs,
    this.weight,
    this.createdAt,
    this.closedAt,
    this.assignedTo,
    this.ticketStatus,
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
      ticketStatus: json['ticketStatus'],
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
    data['assignedTo'] = this.assignedTo?.toJson();
    data['ticketStatus'] = this.ticketStatus;
    return data;
  }

  TicketModel copyWith({
    String? title,
    String? logs,
    int? weight,
    String? createdAt,
    String? closedAt,
    UserModel? assignedTo,
    String? ticketStatus,
  }) {
    return TicketModel(
      id: id,
      title: title ?? this.title,
      logs: logs ?? this.logs,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      ticketStatus: ticketStatus ?? this.ticketStatus,
    );
  }
}
