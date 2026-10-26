// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../main.dart' as entrypoint;
import '../routes/index.dart' as index;
import '../routes/users/profile.dart' as users_profile;
import '../routes/users/packages.dart' as users_packages;
import '../routes/users/appointments/index.dart' as users_appointments_index;
import '../routes/users/appointments/[id].dart' as users_appointments_$id;
import '../routes/public/news/index.dart' as public_news_index;
import '../routes/public/news/[id].dart' as public_news_$id;
import '../routes/public/health_tips/index.dart' as public_health_tips_index;
import '../routes/public/health_tips/[id].dart' as public_health_tips_$id;
import '../routes/public/feedbacks/index.dart' as public_feedbacks_index;
import '../routes/public/doctors/index.dart' as public_doctors_index;
import '../routes/public/doctors/[id].dart' as public_doctors_$id;
import '../routes/public/clinics/index.dart' as public_clinics_index;
import '../routes/public/clinics/[id].dart' as public_clinics_$id;
import '../routes/public/branches/index.dart' as public_branches_index;
import '../routes/public/branches/[id].dart' as public_branches_$id;
import '../routes/auth/register.dart' as auth_register;
import '../routes/auth/refresh.dart' as auth_refresh;
import '../routes/auth/logout.dart' as auth_logout;
import '../routes/auth/login.dart' as auth_login;
import '../routes/auth/google.dart' as auth_google;
import '../routes/admin/news/index.dart' as admin_news_index;
import '../routes/admin/news/[id].dart' as admin_news_$id;
import '../routes/admin/health_tips/index.dart' as admin_health_tips_index;
import '../routes/admin/health_tips/[id].dart' as admin_health_tips_$id;
import '../routes/admin/feedbacks/index.dart' as admin_feedbacks_index;
import '../routes/admin/feedbacks/[id].dart' as admin_feedbacks_$id;
import '../routes/admin/doctors/index.dart' as admin_doctors_index;
import '../routes/admin/doctors/[id].dart' as admin_doctors_$id;
import '../routes/admin/clinics/index.dart' as admin_clinics_index;
import '../routes/admin/clinics/[id].dart' as admin_clinics_$id;
import '../routes/admin/branches/index.dart' as admin_branches_index;
import '../routes/admin/branches/[id].dart' as admin_branches_$id;

import '../routes/_middleware.dart' as middleware;
import '../routes/users/_middleware.dart' as users_middleware;
import '../routes/admin/_middleware.dart' as admin_middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return entrypoint.run(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/', (context) => buildHandler()(context))
    ..mount('/users', (context) => buildUsersHandler()(context))
    ..mount('/users/appointments', (context) => buildUsersAppointmentsHandler()(context))
    ..mount('/public/news', (context) => buildPublicNewsHandler()(context))
    ..mount('/public/health_tips', (context) => buildPublicHealthTipsHandler()(context))
    ..mount('/public/feedbacks', (context) => buildPublicFeedbacksHandler()(context))
    ..mount('/public/doctors', (context) => buildPublicDoctorsHandler()(context))
    ..mount('/public/clinics', (context) => buildPublicClinicsHandler()(context))
    ..mount('/public/branches', (context) => buildPublicBranchesHandler()(context))
    ..mount('/auth', (context) => buildAuthHandler()(context))
    ..mount('/admin/news', (context) => buildAdminNewsHandler()(context))
    ..mount('/admin/health_tips', (context) => buildAdminHealthTipsHandler()(context))
    ..mount('/admin/feedbacks', (context) => buildAdminFeedbacksHandler()(context))
    ..mount('/admin/doctors', (context) => buildAdminDoctorsHandler()(context))
    ..mount('/admin/clinics', (context) => buildAdminClinicsHandler()(context))
    ..mount('/admin/branches', (context) => buildAdminBranchesHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildUsersHandler() {
  final pipeline = const Pipeline().addMiddleware(users_middleware.middleware);
  final router = Router()
    ..all('/packages', (context) => users_packages.onRequest(context,))..all('/profile', (context) => users_profile.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildUsersAppointmentsHandler() {
  final pipeline = const Pipeline().addMiddleware(users_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => users_appointments_$id.onRequest(context,id,))..all('/', (context) => users_appointments_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPublicNewsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<id>', (context,id,) => public_news_$id.onRequest(context,id,))..all('/', (context) => public_news_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPublicHealthTipsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<id>', (context,id,) => public_health_tips_$id.onRequest(context,id,))..all('/', (context) => public_health_tips_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPublicFeedbacksHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => public_feedbacks_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPublicDoctorsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<id>', (context,id,) => public_doctors_$id.onRequest(context,id,))..all('/', (context) => public_doctors_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPublicClinicsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<id>', (context,id,) => public_clinics_$id.onRequest(context,id,))..all('/', (context) => public_clinics_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPublicBranchesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<id>', (context,id,) => public_branches_$id.onRequest(context,id,))..all('/', (context) => public_branches_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/google', (context) => auth_google.onRequest(context,))..all('/login', (context) => auth_login.onRequest(context,))..all('/logout', (context) => auth_logout.onRequest(context,))..all('/refresh', (context) => auth_refresh.onRequest(context,))..all('/register', (context) => auth_register.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAdminNewsHandler() {
  final pipeline = const Pipeline().addMiddleware(admin_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => admin_news_$id.onRequest(context,id,))..all('/', (context) => admin_news_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAdminHealthTipsHandler() {
  final pipeline = const Pipeline().addMiddleware(admin_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => admin_health_tips_$id.onRequest(context,id,))..all('/', (context) => admin_health_tips_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAdminFeedbacksHandler() {
  final pipeline = const Pipeline().addMiddleware(admin_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => admin_feedbacks_$id.onRequest(context,id,))..all('/', (context) => admin_feedbacks_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAdminDoctorsHandler() {
  final pipeline = const Pipeline().addMiddleware(admin_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => admin_doctors_$id.onRequest(context,id,))..all('/', (context) => admin_doctors_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAdminClinicsHandler() {
  final pipeline = const Pipeline().addMiddleware(admin_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => admin_clinics_$id.onRequest(context,id,))..all('/', (context) => admin_clinics_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAdminBranchesHandler() {
  final pipeline = const Pipeline().addMiddleware(admin_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => admin_branches_$id.onRequest(context,id,))..all('/', (context) => admin_branches_index.onRequest(context,));
  return pipeline.addHandler(router);
}

