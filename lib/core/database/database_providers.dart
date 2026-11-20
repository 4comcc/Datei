import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/attachment_store.dart';
import 'app_database.dart';

/// Opened once in `main()` (or in tests with an in-memory executor) and injected via override.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

/// The local profile that owns all data on this device (guest until bound to an account).
final currentProfileIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('currentProfileIdProvider must be overridden'),
);

/// Where photos and other attachments live (overridden at startup / in tests).
final attachmentStoreProvider = Provider<AttachmentStore>(
  (ref) => throw UnimplementedError('attachmentStoreProvider must be overridden'),
);

int nowUtcMs() => DateTime.now().toUtc().millisecondsSinceEpoch;
