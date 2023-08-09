import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../models/project/project_model.dart';
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
      final docs = await DatabaseService.projectsCollection.find().toList();
      final projectsList = docs.map(ProjectModel.fromJson).toList();
      projectsList.forEach((element) {
        totalSprints = totalSprints + element.sprints.length;
      });
      final dashboardResponse = {
        "total_projects": projectsList.length,
        "total_sprints": totalSprints,
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
