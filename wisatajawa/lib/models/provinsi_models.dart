import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wisatajawa/models/tempat_models.dart';

class ProvinsiModels {
  final String id;
  final String name;
  final List<TempatModels> tempatList;

  ProvinsiModels({
    this.id = '',
    required this.name,
    this.tempatList = const [],
  });

  // Dari Firestore → ProvinsiModels (tanpa sub-koleksi tempat)
  factory ProvinsiModels.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProvinsiModels(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  // ProvinsiModels → Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}