import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wisatajawa/models/provinsi_models.dart';
import 'package:wisatajawa/models/tempat_models.dart';
 
class WisataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
 
  // ──────────────────────────────────────────
  //  PROVINSI
  // ──────────────────────────────────────────
 
  // Ambil semua provinsi
  Stream<List<ProvinsiModels>> getProvinsiStream() {
    return _db.collection('provinsi').snapshots().map(
          (snap) => snap.docs.map(ProvinsiModels.fromFirestore).toList(),
        );
  }
 
  // Tambah provinsi baru
  Future<String> addProvinsi(ProvinsiModels provinsi) async {
    final ref = await _db.collection('provinsi').add(provinsi.toFirestore());
    return ref.id;
  }
 
  // Update provinsi
  Future<void> updateProvinsi(ProvinsiModels provinsi) {
    return _db
        .collection('provinsi')
        .doc(provinsi.id)
        .update(provinsi.toFirestore());
  }
 
  // Hapus provinsi
  Future<void> deleteProvinsi(String provinsiId) {
    return _db.collection('provinsi').doc(provinsiId).delete();
  }
 
  // ──────────────────────────────────────────
  //  TEMPAT WISATA (sub-koleksi di bawah provinsi)
  //  Path: provinsi/{provinsiId}/tempat/{tempatId}
  // ──────────────────────────────────────────
 
  // Ambil semua tempat dalam 1 provinsi
  Stream<List<TempatModels>> getTempatStream(String provinsiId) {
    return _db
        .collection('provinsi')
        .doc(provinsiId)
        .collection('tempat')
        .snapshots()
        .map((snap) => snap.docs.map(TempatModels.fromFirestore).toList());
  }
 
  // Tambah tempat wisata baru
  Future<String> addTempat(String provinsiId, TempatModels tempat) async {
    final ref = await _db
        .collection('provinsi')
        .doc(provinsiId)
        .collection('tempat')
        .add(tempat.toFirestore());
    return ref.id;
  }
 
  // Update tempat wisata
  Future<void> updateTempat(String provinsiId, TempatModels tempat) {
    return _db
        .collection('provinsi')
        .doc(provinsiId)
        .collection('tempat')
        .doc(tempat.id)
        .update(tempat.toFirestore());
  }
 
  // Hapus tempat wisata
  Future<void> deleteTempat(String provinsiId, String tempatId) {
    return _db
        .collection('provinsi')
        .doc(provinsiId)
        .collection('tempat')
        .doc(tempatId)
        .delete();
  }
 
  // Toggle favorit
  Future<void> toggleFavorit(String provinsiId, TempatModels tempat) {
    return _db
        .collection('provinsi')
        .doc(provinsiId)
        .collection('tempat')
        .doc(tempat.id)
        .update({'isFavorite': !tempat.isFavorite});
  }
}
 