import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/repository/appointments_repository.dart';
import 'package:hopital_api/repository/branches_repository.dart';
import 'package:hopital_api/repository/chat_sessions_repository.dart';
import 'package:hopital_api/repository/clinics_repository.dart';
import 'package:hopital_api/repository/doctors_repository.dart';
import 'package:hopital_api/repository/feedbacks_repository.dart';
import 'package:hopital_api/repository/health_tips_repository.dart';
import 'package:hopital_api/repository/knowledge_chunks_repository.dart';
import 'package:hopital_api/repository/news_repository.dart';
import 'package:hopital_api/repository/packages_repository.dart';
import 'package:hopital_api/repository/refresh_token_repository.dart';
import 'package:hopital_api/repository/users_repository.dart';
import 'package:hopital_api/service/mongo_service.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Env.init();
  final mongoService = await MongoService.connect(Env.mongoUrl);

  //users
  final usersRepo = UsersRepository(mongoService.collection('users'));
  await usersRepo.createIndex();

  //RefreshTokens
  final refreshRepo = RefreshTokenRepository(
    mongoService.collection('refresh_token'),
  );
  await refreshRepo.createIndex();

  //packages
  final packagesRepo = PackagesRepository(
    mongoService.collection('packages'),
  );
  await packagesRepo.createIndex();

  //branches
  final branchesRepo = BranchesRepository(
    mongoService.collection('branches'),
  );
  await branchesRepo.createIndex();

  //clinics
  final clinicsRepo = ClinicsRepository(
    mongoService.collection('clinics'),
  );
  await clinicsRepo.createIndex();

  //doctors
  final doctorsRepo = DoctorsRepository(
    mongoService.collection('doctors'),
  );
  await doctorsRepo.createIndex();

  //appointments
  final appointmentsRepo = AppointmentsRepository(
    mongoService.collection('appointments'),
  );
  await appointmentsRepo.createIndex();

  //news
  final newsRepo = NewsRepository(
    mongoService.collection('news'),
  );
  await newsRepo.createIndex();

  //feedbacks
  final feedbacksRepo = FeedbacksRepository(
    mongoService.collection('feedbacks'),
  );
  await feedbacksRepo.createIndex();

  //health_tips
  final healthTipsRepo = HealthTipsRepository(
    mongoService.collection('health_tips'),
  );
  await healthTipsRepo.createIndex();

  //knowledge_chunks
  final knowledgeChunksRepo = KnowledgeChunksRepository(
    mongoService.collection('knowledge_chunks'),
  );
  await knowledgeChunksRepo.createIndex();

  //chat_sessions
  final chatSessionsRepo = ChatSessionsRepository(
    mongoService.collection('chat_sessions'),
  );
  await chatSessionsRepo.createIndex();

  return serve(
    handler
        .use(provider<UsersRepository>((_) => usersRepo))
        .use(provider<RefreshTokenRepository>((_) => refreshRepo))
        .use(provider<PackagesRepository>((_) => packagesRepo))
        .use(provider<BranchesRepository>((_) => branchesRepo))
        .use(provider<ClinicsRepository>((_) => clinicsRepo))
        .use(provider<DoctorsRepository>((_) => doctorsRepo))
        .use(provider<AppointmentsRepository>((_) => appointmentsRepo))
        .use(provider<NewsRepository>((_) => newsRepo))
        .use(provider<FeedbacksRepository>((_) => feedbacksRepo))
        .use(provider<HealthTipsRepository>((_) => healthTipsRepo))
        .use(provider<KnowledgeChunksRepository>((_) => knowledgeChunksRepo))
        .use(provider<ChatSessionsRepository>((_) => chatSessionsRepo)),
    ip,
    port,
  );
}
