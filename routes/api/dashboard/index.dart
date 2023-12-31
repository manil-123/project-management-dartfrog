import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../models/project/project_model.dart';
import '../../../models/user/user_model.dart';
import '../../../services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return DatabaseService.startConnection(
    context,
    getDashboardInfo(context),
  );
}

Future<Response> getDashboardInfo(RequestContext context) async {
  //check if the request is a GET request
  if (context.request.method == HttpMethod.get) {
    try {
      int totalSprints = 0;
      int totalTickets = 0;
      List<UserModel> totalMembers = [];
      final docs = await DatabaseService.projectsCollection.find().toList();
      final projectsList = docs.map(ProjectModel.fromJson).toList();

      Set<String> addedMemberIds = Set(); // To track added member IDs

      projectsList.forEach((element) {
        //Calculate total number of sprints
        totalSprints += element.sprints.length;
        // Add unique members to totalMembers list
        element.members.forEach((member) {
          if (!addedMemberIds.contains(member.id)) {
            totalMembers.add(member);
            addedMemberIds.add(member.id);
          }
        });
        // Calculate total tickets
        element.sprints.forEach((sprint) {
          totalTickets += sprint.tickets.length;
        });
      });
      final dashboardResponse = {
        "total_projects": projectsList.length,
        "total_sprints": totalSprints,
        "total_members": totalMembers.length,
        "total_tickets": totalTickets,
      };
      return Response.json(
        statusCode: 200,
        body: {
          'success': true,
          'data': dashboardResponse,
          'message': 'Projects fetched successfully',
        },
      );
    } catch (e) {
      print(' Dashboard error $e');
      return Response.json(
        statusCode: 500,
        body: {
          'success': false,
          'message': 'Internal Server Error',
        },
      );
    }
  }
  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {
      'message': 'Method not allowed',
    },
  );
}
