import 'package:flutter/material.dart';
import 'package:wisatajawa/models/provinsi_models.dart';
import 'package:wisatajawa/models/tempat_models.dart';
import 'package:wisatajawa/services/wisata_service.dart';

class WisataProvider extends ChangeNotifier {
  final WisataService _service = WisataService();

  List<ProvinsiModels> _provinsiList = [];
  Map<String, List<TempatModels>> _tempatMap = {}; // provinsiId → list tempat
  bool _isLoading = false;
  String? _error;

  List<ProvinsiModels> get provinsiList => _provinsiList;
  Map<String, List<TempatModels>> get tempatMap => _tempatMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Semua tempat dari semua provinsi (untuk search & favorit)
  List<TempatModels> get semuaTempat =>
      _tempatMap.values.expand((list) => list).toList();

  List<TempatModels> get favoritList =>
      semuaTempat.where((t) => t.isFavorite).toList();

  // Ambil tempat berdasarkan provinsiId
  List<TempatModels> tempatByProvinsi(String provinsiId) =>
      _tempatMap[provinsiId] ?? [];

  // ── Load semua provinsi ──
  void listenProvinsi() {
    _isLoading = true;
    notifyListeners();

    _service.getProvinsiStream().listen(
      (list) async {
        _provinsiList = list;
        // Load tempat untuk setiap provinsi
        for (final p in list) {
          _service.getTempatStream(p.id).listen((tempats) {
            _tempatMap[p.id] = tempats;
            notifyListeners();
          });
        }
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Toggle Favorit ──
  Future<void> toggleFavorit(String provinsiId, TempatModels tempat) async {
    await _service.toggleFavorit(provinsiId, tempat);
  }

  // ── Cari tempat ──
  List<TempatModels> cari(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return semuaTempat.where((t) {
      return t.nama.toLowerCase().contains(q) ||
          t.deskripsi.toLowerCase().contains(q) ||
          t.alamat.toLowerCase().contains(q);
    }).toList();
  }
}