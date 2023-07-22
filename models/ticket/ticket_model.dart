class TicketModel {
  final String id;
  final String title;
  final String? logs;
  final int? weight;
  final String? createdAt;
  final String? closedAt;
  final String? assignedTo;

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
      assignedTo: json['assignedTo'],
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
    data['assignedTo'] = this.assignedTo;
    return data;
  }
}