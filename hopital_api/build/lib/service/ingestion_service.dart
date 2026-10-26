import 'package:hopital_api/client/embedding_client.dart';
import 'package:hopital_api/helper/chunk_builder.dart';
import 'package:hopital_api/models/branches.dart';
import 'package:hopital_api/models/clinics.dart';
import 'package:hopital_api/models/doctors.dart';
import 'package:hopital_api/models/health_tips.dart';
import 'package:hopital_api/models/knowledge_chunks.dart';
import 'package:hopital_api/models/news.dart';
import 'package:hopital_api/models/packages.dart';
import 'package:hopital_api/repository/branches_repository.dart';
import 'package:hopital_api/repository/clinics_repository.dart';
import 'package:hopital_api/repository/doctors_repository.dart';
import 'package:hopital_api/repository/health_tips_repository.dart';
import 'package:hopital_api/repository/knowledge_chunks_repository.dart';
import 'package:hopital_api/repository/news_repository.dart';
import 'package:hopital_api/repository/packages_repository.dart';
import 'package:logging/logging.dart';

class IngestionService {
  IngestionService(
    this._chunks,
    this._embedder,
    this._doctors,
    this._packages,
    this._clinics,
    this._branches,
    this._tips,
    this._news,
  );

  final KnowledgeChunksRepository _chunks;
  final EmbeddingClient _embedder;
  final DoctorsRepository _doctors;
  final PackagesRepository _packages;
  final ClinicsRepository _clinics;
  final BranchesRepository _branches;
  final HealthTipsRepository _tips;
  final NewsRepository _news;

  static final _log = Logger('IngestionService');

  Future<Map<String, int>> ingestAll() async {
    _log.info('Starting full ingestion...');
    final stats = <String, int>{
      'packages': 0,
      'doctors': 0,
      'clinics': 0,
      'branches': 0,
      'health_tips': 0,
      'news': 0,
      'total': 0,
    };

    final clinicsList = await _clinics.getAll(limit: 200);
    final branchesList = await _branches.getAll();

    final clinics = {
      for (final c in clinicsList)
        if (c.id != null) c.id!: c,
    };
    final branches = {
      for (final b in branchesList)
        if (b.id != null) b.id!: b,
    };

    String clinicName(String id) => clinics[id]?.name ?? '';
    List<String> branchNames(Iterable<String> ids) =>
        ids.map((id) => branches[id]?.name).whereType<String>().toList();

    for (final p in await _packages.getAll(limit: 200)) {
      if (!p.isActive || p.id == null) continue;
      final bNames = p.metadata.branchNames.isNotEmpty
          ? p.metadata.branchNames
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : branchNames(p.metadata.supportedBranchIds);

      final count = await _replace(
        sourceType: 'package',
        sourceId: p.id!,
        contents: [ChunkBuilder.package(p)],
        metadata: ChunkMetadata(
          title: p.title,
          clinic: '',
          branches: bNames,
          tags: const ['package', 'checkup'],
        ),
      );
      stats['packages'] = (stats['packages'] ?? 0) + count;
    }

    for (final d in await _doctors.getAll(limit: 500)) {
      if (!d.isAvailableForBooking || d.id == null) continue;
      final cName = clinicName(d.clinicId);
      final bNames = branchNames(d.branchesId);

      final count = await _replace(
        sourceType: 'doctor',
        sourceId: d.id!,
        contents: [
          ChunkBuilder.doctor(d, clinicName: cName, branchNames: bNames),
        ],
        metadata: ChunkMetadata(
          title: d.name,
          clinic: cName,
          branches: bNames,
          tags: ['doctor', 'specialist', ...d.languagesSpoken],
        ),
      );
      stats['doctors'] = (stats['doctors'] ?? 0) + count;
    }

    for (final c in clinics.values) {
      if (!c.isActive || c.id == null) continue;
      final bNames = branchNames(c.supportedBranchIds);

      final count = await _replace(
        sourceType: 'clinic',
        sourceId: c.id!,
        contents: [ChunkBuilder.clinic(c, branchNames: bNames)],
        metadata: ChunkMetadata(
          title: c.name,
          clinic: c.name,
          branches: bNames,
          tags: const ['clinic', 'department'],
        ),
      );
      stats['clinics'] = (stats['clinics'] ?? 0) + count;
    }

    for (final b in branches.values) {
      if (b.id == null) continue;

      final count = await _replace(
        sourceType: 'branch',
        sourceId: b.id!,
        contents: [ChunkBuilder.branch(b)],
        metadata: ChunkMetadata(
          title: b.name,
          clinic: '',
          branches: [b.name],
          tags: ['branch', 'facility', b.code],
        ),
      );
      stats['branches'] = (stats['branches'] ?? 0) + count;
    }

    for (final t in await _tips.getAll(limit: 200)) {
      if (t.id == null) continue;

      final count = await _replace(
        sourceType: 'health_tip',
        sourceId: t.id!,
        contents: [
          for (final block in t.contentBlocks)
            ChunkBuilder.contentBlock(
              kind: 'Health tip',
              title: t.title,
              text: block.text,
              clinic: t.clinic,
              caption: block.caption,
            ),
        ],
        metadata: ChunkMetadata(
          title: t.title,
          clinic: t.clinic,
          branches: const [],
          tags: ['health_tip', t.clinic],
        ),
      );
      stats['health_tips'] = (stats['health_tips'] ?? 0) + count;
    }

    for (final n in await _news.getAll(limit: 200)) {
      if (n.id == null) continue;

      final count = await _replace(
        sourceType: 'news',
        sourceId: n.id!,
        contents: [
          for (final block in n.contentBlocks)
            ChunkBuilder.contentBlock(
              kind: 'News',
              title: n.title,
              text: block.text,
              caption: block.caption,
            ),
        ],
        metadata: ChunkMetadata(
          title: n.title,
          clinic: '',
          branches: const [],
          tags: const ['news', 'announcement'],
        ),
      );
      stats['news'] = (stats['news'] ?? 0) + count;
    }

    var total = 0;
    stats.forEach((key, val) {
      if (key != 'total') total += val;
    });
    stats['total'] = total;

    _log.info('Ingestion finished: $stats');
    return stats;
  }

  Future<int> ingestPackage(Packages p) async {
    if (p.id == null) return 0;
    final bNames = p.metadata.branchNames.isNotEmpty
        ? p.metadata.branchNames
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : const <String>[];

    return _replace(
      sourceType: 'package',
      sourceId: p.id!,
      contents: [ChunkBuilder.package(p)],
      metadata: ChunkMetadata(
        title: p.title,
        clinic: '',
        branches: bNames,
        tags: const ['package', 'checkup'],
      ),
    );
  }

  Future<int> ingestDoctor(Doctors d) async {
    if (d.id == null) return 0;
    final clinic = await _clinics.findById(d.clinicId);
    final cName = clinic?.name ?? '';

    final bNames = <String>[];
    for (final bId in d.branchesId) {
      final b = await _branches.findById(bId);
      if (b != null) bNames.add(b.name);
    }

    return _replace(
      sourceType: 'doctor',
      sourceId: d.id!,
      contents: [
        ChunkBuilder.doctor(d, clinicName: cName, branchNames: bNames),
      ],
      metadata: ChunkMetadata(
        title: d.name,
        clinic: cName,
        branches: bNames,
        tags: ['doctor', 'specialist', ...d.languagesSpoken],
      ),
    );
  }

  Future<int> ingestClinic(Clinics c) async {
    if (c.id == null) return 0;
    final bNames = <String>[];
    for (final bId in c.supportedBranchIds) {
      final b = await _branches.findById(bId);
      if (b != null) bNames.add(b.name);
    }

    return _replace(
      sourceType: 'clinic',
      sourceId: c.id!,
      contents: [ChunkBuilder.clinic(c, branchNames: bNames)],
      metadata: ChunkMetadata(
        title: c.name,
        clinic: c.name,
        branches: bNames,
        tags: const ['clinic', 'department'],
      ),
    );
  }

  Future<int> ingestBranch(Branches b) async {
    if (b.id == null) return 0;
    return _replace(
      sourceType: 'branch',
      sourceId: b.id!,
      contents: [ChunkBuilder.branch(b)],
      metadata: ChunkMetadata(
        title: b.name,
        clinic: '',
        branches: [b.name],
        tags: ['branch', 'facility', b.code],
      ),
    );
  }

  Future<int> ingestHealthTip(HealthTips tip) async {
    if (tip.id == null) return 0;
    return _replace(
      sourceType: 'health_tip',
      sourceId: tip.id!,
      contents: [
        for (final block in tip.contentBlocks)
          ChunkBuilder.contentBlock(
            kind: 'Health tip',
            title: tip.title,
            text: block.text,
            clinic: tip.clinic,
            caption: block.caption,
          ),
      ],
      metadata: ChunkMetadata(
        title: tip.title,
        clinic: tip.clinic,
        branches: const [],
        tags: ['health_tip', tip.clinic],
      ),
    );
  }

  Future<int> ingestNews(News news) async {
    if (news.id == null) return 0;
    return _replace(
      sourceType: 'news',
      sourceId: news.id!,
      contents: [
        for (final block in news.contentBlocks)
          ChunkBuilder.contentBlock(
            kind: 'News',
            title: news.title,
            text: block.text,
            caption: block.caption,
          ),
      ],
      metadata: ChunkMetadata(
        title: news.title,
        clinic: '',
        branches: const [],
        tags: const ['news', 'announcement'],
      ),
    );
  }

  Future<void> deleteSource(String sourceType, String sourceId) async {
    await _chunks.deleteBySource(sourceType, sourceId);
  }

  Future<int> _replace({
    required String sourceType,
    required String sourceId,
    required List<String> contents,
    required ChunkMetadata metadata,
  }) async {
    if (contents.isEmpty) return 0;

    final embeddings = <List<double>>[];
    for (final text in contents) {
      embeddings.add(await _embedder.embed(text, task: EmbeddingTask.document));
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    await _chunks.deleteBySource(sourceType, sourceId);
    for (var i = 0; i < contents.length; i++) {
      await _chunks.insert(
        KnowledgeChunks(
          sourceType: sourceType,
          sourceId: sourceId,
          metadata: metadata,
          content: contents[i],
          embedding: embeddings[i],
        ),
      );
    }
    return contents.length;
  }
}
