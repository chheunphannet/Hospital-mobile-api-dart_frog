import 'package:hopital_api/models/payments.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PaymentsRepository {
  PaymentsRepository(this._collection);

  final DbCollection _collection;
  static final _log = Logger('PaymentsRepository');

  Future<void> createIndex() async {
    final result = await _collection.db.runCommand({
      'createIndexes': _collection.collectionName,
      'indexes': [
        {
          'key': {'md5Hash': 1},
          'name': 'idx_payments_md5Hash',
          'unique': true,
        },
        {
          'key': {'billNumber': 1},
          'name': 'idx_payments_billNumber',
          'unique': true,
        },
        {
          'key': {'patientId': 1, 'createdAt': -1},
          'name': 'idx_payments_patient_history',
        },
      ],
    });

    if (result['ok'] != 1) {
      _log.warning('Create index response: $result');
    }
  }

  Future<Payments> createPayment(Payments payment) async {
    final doc = payment.toDocument();
    final result = await _collection.insertOne(doc);

    if (!result.isSuccess) {
      _log.severe('Failed to insert payment: ${result.errmsg}');
      throw StateError(
        'Failed to insert payment: ${result.writeError?.errmsg ?? "Unknown error"}',
      );
    }

    doc['_id'] = result.id;
    if (result.id is ObjectId) {
      doc['id'] = (result.id as ObjectId).oid;
    }
    return Payments.fromJson(doc);
  }

  Future<Payments?> findById(String id) async {
    final doc = await _collection.findOne(
      where.id(ObjectId.fromHexString(id)),
    );
    if (doc == null) return null;
    return Payments.fromJson(doc);
  }

  Future<Payments?> findByMd5(String md5Hash) async {
    final doc = await _collection.findOne(
      where.eq('md5Hash', md5Hash),
    );
    if (doc == null) return null;
    return Payments.fromJson(doc);
  }

  Future<Payments?> findByBillNumber(String billNumber) async {
    final doc = await _collection.findOne(
      where.eq('billNumber', billNumber),
    );
    if (doc == null) return null;
    return Payments.fromJson(doc);
  }

  Future<Payments?> updatePaymentStatus({
    required String id,
    required String status,
    String? transactionHash,
    String? fromAccountId,
    DateTime? paidAt,
  }) async {
    final modifier = modify
        .set('status', status)
        .set('updatedAt', DateTime.now().toUtc());

    if (transactionHash != null) {
      modifier.set('transactionHash', transactionHash);
    }
    if (fromAccountId != null) {
      modifier.set('fromAccountId', fromAccountId);
    }
    if (paidAt != null) {
      modifier.set('paidAt', paidAt);
    }

    final res = await _collection.findAndModify(
      query: where.id(ObjectId.fromHexString(id)),
      update: modifier,
      returnNew: true,
    );

    if (res == null) return null;
    return Payments.fromJson(res);
  }

  Future<List<Payments>> getPaymentsByPatient({
    required String patientId,
    int limit = 20,
    int skip = 0,
  }) async {
    final cursor = _collection.find(
      where
          .eq('patientId', ObjectId.fromHexString(patientId))
          .sortBy('createdAt', descending: true)
          .limit(limit)
          .skip(skip),
    );

    final list = await cursor.toList();
    return list.map(Payments.fromJson).toList();
  }
}
