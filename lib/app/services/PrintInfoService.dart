

import 'dart:convert';
import 'package:foodorder/app/services/Storage.dart';
import 'package:get/get.dart';

/// Service to cache printer job payloads (JSON objects) in memory + persistent key-value storage.
/// Requirements:
/// 1. Append incoming print JSON to a stored JSON array (no database, simple key storage).
/// 2. Read back the stored list of print JSON objects.
///
/// Storage format (under [_storageKey]): a JSON encoded array of objects.
class PrintInfoService extends GetxService {
	static const String _storageKey = 'print_job_list';
	static const String _defaultCategory = 'default';

	/// Reactive in-memory cache of print jobs categorized by key.
	/// Key: category name; Value: RxList of print job payloads (Map).
	final RxMap<String, RxList<Map<String, dynamic>>> _jobsByCategory =
		<String, RxList<Map<String, dynamic>>>{}.obs;

	bool _initialized = false;
	/// Maximum number of jobs to retain per category. Set <= 0 for unlimited.
	int maxJobs = 30;

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

	/// Backward-compatible public getter (read-only) for observers.
	/// Returns a flattened, unmodifiable list across all categories.
	/// Prefer using [getJobsByCategory] for category-specific reads.
	List<Map<String, dynamic>> get printJobs {
		final result = <Map<String, dynamic>>[];
		for (final list in _jobsByCategory.values) {
			result.addAll(list);
		}
		return List.unmodifiable(result);
	}

	/// Get an unmodifiable view of jobs for a specific category.
	List<Map<String, dynamic>> getJobsByCategory(String category) {
		final list = _jobsByCategory[category]?.toList() ?? const <Map<String, dynamic>>[];
		return List.unmodifiable(list);
	}

	/// List all current categories.
	List<String> listCategories() => _jobsByCategory.keys.toList(growable: false);

	/// Add a print job payload to a category. Accepts either a Map or a JSON string.
	/// Returns the updated length of the category list.
	Future<int> addPrintJob(dynamic data, {String category = _defaultCategory}) async {
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
		if (obj == null) return getJobsByCategory(category).length; // ignore invalid input

		final list = _ensureCategory(category);
		list.add(obj);
		_enforceLimit(category);
		await _persist();
		return list.length;
	}

	/// Retrieve all print jobs (ensures initialization).
	/// - If [category] is provided, returns jobs for that category only.
	/// - Otherwise, returns a flattened list across all categories.
	Future<List<Map<String, dynamic>>> readAll({String? category}) async {
		await init();
		if (category != null) {
			// Ensure category exists even if it was not created before
			_ensureCategory(category);
			await _persist();
			return getJobsByCategory(category);
		}
		return printJobs;
	}

	/// Clear all stored print jobs.
	Future<void> clearAll() async {
		_jobsByCategory.clear();
		await _persist();
	}

	/// Clear jobs under a specific category.
	Future<void> clearCategory(String category) async {
		// Do not validate existence; create the category if missing, then clear
		final list = _ensureCategory(category);
		list.clear();
		await _persist();
	}

	/// Public helper to proactively ensure a category exists (even empty) and persist it.
	Future<void> ensureCategory(String category) async {
		await init();
		_ensureCategory(category);
		await _persist();
	}

	/// Internal: load from underlying key-value storage.
	Future<void> _loadFromStorage() async {
		try {
			// Read from underlying static storage.
			final raw = await _tryStaticStorageRead();

			dynamic decoded;
			if (raw is String && raw.isNotEmpty) {
				decoded = json.decode(raw);
			} else {
				decoded = raw; // allow pre-decoded values (if any)
			}

			if (decoded is Map) {
				// New format: { category: [ {...}, {...} ], ... }
				_jobsByCategory.clear();
				decoded.forEach((key, value) {
					if (key is String && value is List) {
						final jobs = value
							.whereType<Map>()
							.map((e) => e.cast<String, dynamic>())
							.toList();
						_jobsByCategory[key] = RxList<Map<String, dynamic>>.from(jobs);
					}
				});
			} else if (decoded is List) {
				// Backward-compatible old format: a single flat list -> move to default category
				final jobs = decoded
					.whereType<Map>()
					.map((e) => e.cast<String, dynamic>())
					.toList();
				_jobsByCategory.clear();
				_jobsByCategory[_defaultCategory] = RxList<Map<String, dynamic>>.from(jobs);
			}
		} catch (e) {
			// ignore corrupt stored data
			print("Error loading from storage: $e");
			_jobsByCategory.clear();
		}
		// Enforce limits per category
		for (final category in _jobsByCategory.keys) {
			_enforceLimit(category);
		}
	}

	Future<void> _persist() async {
		// Serialize as { category: [jobs] }
		final Map<String, List<Map<String, dynamic>>> toSave = {
			for (final entry in _jobsByCategory.entries) entry.key: entry.value.toList(),
		};
		final jsonStr = json.encode(toSave);
		await _tryStaticStorageWrite(jsonStr);
	}

	// ------- Fallback helpers (optional, no-op if Storage class absent) -------
	Future<dynamic> _tryStaticStorageRead() async {
		try {
			// Using mirrors is not available in Flutter; rely on a known global Storage class if imported elsewhere.
			// If your project has a Storage.getString method, you can integrate it directly here.
			// Example (uncomment if Storage is accessible):
			return await Storage.getString(_storageKey);
		} catch (_) {
			print("Error accessing Storage.getString");
		}
		return null;
	}

	Future<void> _tryStaticStorageWrite(String value) async {
		try {
			// Example (uncomment if Storage is accessible):
			await Storage.setString(_storageKey, value);
		} catch (_) {
			print("Error accessing Storage.setString");
		}
	}

	/// Ensure the category list does not exceed [maxJobs] by removing oldest (front) entries.
	void _enforceLimit(String category) {
		if (maxJobs <= 0) return; // treat 0 or negative as unlimited safeguard
		final list = _jobsByCategory[category];
		if (list == null) return;
		final overflow = list.length - maxJobs;
		if (overflow > 0) {
			list.removeRange(0, overflow); // remove oldest first
		}
	}

	/// Ensure a category list exists and return it.
	RxList<Map<String, dynamic>> _ensureCategory(String category) {
		return _jobsByCategory.putIfAbsent(category, () => <Map<String, dynamic>>[].obs);
	}
}