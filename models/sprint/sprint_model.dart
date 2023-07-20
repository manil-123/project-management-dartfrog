import '../ticket/ticket_model.dart';

class SprintModel {
  final String id;
  final String name;
  final List<TicketModel> tickets;

  SprintModel({
    required this.id,
    required this.name,
    required this.tickets,
  });

  factory SprintModel.fromJson(Map<String, dynamic> json) {
    var tickets = <TicketModel>[];
    if ((json['tickets'] as List).isNotEmpty) {
      json['tickets'].forEach((ticket) {
        tickets.add(TicketModel.fromJson(ticket));
      });
    }
    return SprintModel(
      id: json['sprint_id'],
      name: json['sprint_name'],
      tickets: tickets,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sprint_id'] = this.id;
    data['sprint_name'] = this.name;
    data['tickets'] = this.tickets.map((v) => v.toJson()).toList();
    return data;
  }

  SprintModel copyWith({String? name, List<TicketModel>? tickets}) {
    return SprintModel(
      id: id,
      name: name ?? this.name,
      tickets: tickets ?? this.tickets,
    );
  }
}
