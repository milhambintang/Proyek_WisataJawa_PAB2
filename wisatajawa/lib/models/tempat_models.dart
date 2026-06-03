import 'package:cloud_firestore/cloud_firestore.dart';

class TempatModels {
  final String id;
  final String nama;
  final String alamat;
  final String jamBuka;
  final String hargaTiket;
  final String deskripsi;
  final String gambarUtama;
  final String fasilitas;
  final List<String> gambarGaleri;
  bool isFavorite;

  TempatModels({
    this.id = '',
    required this.nama,
    this.alamat = '',
    this.jamBuka = '',
    this.hargaTiket = '',
    this.deskripsi = '',
    this.gambarUtama = '',
    this.fasilitas = '',
    this.gambarGaleri = const [],
    this.isFavorite = false,
  });

  // Dari Firestore → TempatModels
  factory TempatModels.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TempatModels(
      id: doc.id,
      nama: data['nama'] ?? '',
      alamat: data['alamat'] ?? '',
      jamBuka: data['jamBuka'] ?? '',
      hargaTiket: data['hargaTiket'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      gambarUtama: data['gambarUtama'] ?? '',
      fasilitas: data['fasilitas'] ?? '',
      gambarGaleri: List<String>.from(data['gambarGaleri'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // TempatModels → Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'alamat': alamat,
      'jamBuka': jamBuka,
      'hargaTiket': hargaTiket,
      'deskripsi': deskripsi,
      'gambarUtama': gambarUtama,
      'fasilitas': fasilitas,
      'gambarGaleri': gambarGaleri,
      'isFavorite': isFavorite,
    };
  }
}