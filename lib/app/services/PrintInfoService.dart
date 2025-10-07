

import 'dart:convert';
import 'package:get/get.dart';

/// Service to cache printer job payloads (JSON objects) in memory + persistent key-value storage.
/// Requirements:
/// 1. Append incoming print JSON to a stored JSON array (no database, simple key storage).
/// 2. Read back the stored list of print JSON objects.
///
/// Storage format (under [_storageKey]): a JSON encoded array of objects.
class PrintInfoService extends GetxService {
	static const String _storageKey = 'print_job_list';

	/// Reactive in-memory cache of print jobs.
	final RxList<Map<String, dynamic>> _printJobs = <Map<String, dynamic>>[].obs;

	bool _initialized = false;
  int maxJobs = 30; // Maximum number of jobs to retain

  @override
  void onInit() async {
    init();
    super.onInit();
  }

	/// Initialize by loading existing data from persistent storage.
	Future<PrintInfoService> init() async {
		if (!_initialized) {
			await _loadFromStorage();
			_initialized = true;
		}
		return this;
	}

	/// Public getter (read-only) for observers.
	List<Map<String, dynamic>> get printJobs => List.unmodifiable(_printJobs);

	/// Add a print job payload. Accepts either a Map or a JSON string.
	/// Returns the updated length of the list.
	Future<int> addPrintJob(dynamic data) async {
		await init();
		Map<String, dynamic>? obj;
		if (data is Map<String, dynamic>) {
			obj = data;
		} else if (data is String) {
			try {
				final decoded = json.decode(data);
				if (decoded is Map<String, dynamic>) obj = decoded;
			} catch (e) {
        print("Error decoding JSON: $e");
      }
		}
		if (obj == null) return _printJobs.length; // ignore invalid input
		_printJobs.add(obj);
		_enforceLimit();
		await _persist();
		return _printJobs.length;
	}

	/// Retrieve all print jobs (ensures initialization).
	Future<List<Map<String, dynamic>>> readAll() async {
		await init();
		return printJobs;
	}

	/// Clear all stored print jobs.
	Future<void> clearAll() async {
		_printJobs.clear();
		await _persist();
	}

	/// Internal: load from underlying key-value storage.
	Future<void> _loadFromStorage() async {
		try {
			// Try GetStorage first if available via Get.find, else fallback to custom Storage class if present.
			dynamic raw;
			try {
				// If GetStorage registered via Get.put, we can access it. Using dynamic to avoid hard dep.
				final box = Get.isRegistered<dynamic>(tag: 'GetStorage')
						? Get.find<dynamic>(tag: 'GetStorage')
						: null;
				if (box != null) {
					raw = box.read(_storageKey);
				}
			} catch (e) {
        print("Error reading from GetStorage: $e");
      }

			// Fallback: attempt reflection to a global Storage static API if exists.
			raw ??= await _tryStaticStorageRead();

			if (raw is String && raw.isNotEmpty) {
				final decoded = json.decode(raw);
				if (decoded is List) {
					_printJobs.assignAll(decoded.whereType<Map>().map((e) => e.cast<String, dynamic>()));
				}
			} else if (raw is List) {
				_printJobs.assignAll(raw.whereType<Map>().map((e) => e.cast<String, dynamic>()));
			}
		} catch (e) {
			// ignore corrupt stored data
      print("Error loading from storage: $e");
			_printJobs.clear();
		}
		_enforceLimit();
	}

	Future<void> _persist() async {
		final jsonStr = json.encode(_printJobs);
		// Write to GetStorage if exists else fallback.
		bool written = false;
		try {
			final box = Get.isRegistered<dynamic>(tag: 'GetStorage')
					? Get.find<dynamic>(tag: 'GetStorage')
					: null;
			if (box != null) {
				await box.write(_storageKey, jsonStr);
				written = true;
			}
		} catch (e) {
			print("Error writing to GetStorage: $e");
		}
		if (!written) {
			await _tryStaticStorageWrite(jsonStr);
		}
	}

	// ------- Fallback helpers (optional, no-op if Storage class absent) -------
	Future<dynamic> _tryStaticStorageRead() async {
		try {
			// Using mirrors is not available in Flutter; rely on a known global Storage class if imported elsewhere.
			// If your project has a Storage.getString method, you can integrate it directly here.
			// Example (uncomment if Storage is accessible):
			// return Storage.getString(_storageKey);
		} catch (_) {}
		return null;
	}

	Future<void> _tryStaticStorageWrite(String value) async {
		try {
			// Example (uncomment if Storage is accessible):
			// Storage.setString(_storageKey, value);
		} catch (_) {}
	}

	/// Ensure list does not exceed [maxJobs] by removing oldest (front) entries.
	void _enforceLimit() {
		if (maxJobs <= 0) return; // treat 0 or negative as unlimited safeguard
		final overflow = _printJobs.length - maxJobs;
		if (overflow > 0) {
			_printJobs.removeRange(0, overflow); // remove oldest first
		}
	}
}