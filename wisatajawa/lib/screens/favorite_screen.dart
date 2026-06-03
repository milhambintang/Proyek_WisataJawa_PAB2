import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisatajawa/providers/wisata_provider.dart';
import 'package:wisatajawa/models/tempat_models.dart';
import 'package:wisatajawa/utils/app_colors.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorit Saya',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer<WisataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = provider.favoritList;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.hint),
                  const SizedBox(height: 16),
                  const Text('Belum ada wisata favorit',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan wisata ke favorit untuk melihatnya di sini',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.subtitle),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final tempat = favorites[index];
              // Cari provinsiId untuk tempat ini
              final provinsiId = _findProvinsiId(provider, tempat.id);
              return _FavoriteCard(
                tempat: tempat,
                provinsiId: provinsiId,
              );
            },
          );
        },
      ),
    );
  }

  String _findProvinsiId(WisataProvider provider, String tempatId) {
    for (final entry in provider.tempatMap.entries) {
      if (entry.value.any((t) => t.id == tempatId)) {
        return entry.key;
      }
    }
    return '';
  }
}

class _FavoriteCard extends StatelessWidget {
  final TempatModels tempat;
  final String provinsiId;

  const _FavoriteCard({required this.tempat, required this.provinsiId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WisataProvider>();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () => _showDetailDialog(context, provider),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  Image.network(
                    tempat.gambarUtama,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 120,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surface,
                      child:
                          const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite,
                          color: AppColors.error, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tempat.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        tempat.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.subtitle),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await provider.toggleFavorit(provinsiId, tempat);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${tempat.nama} dihapus dari favorit'),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child:
                            const Text('Hapus', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, WisataProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: Center(
                            child: Text(tempat.nama,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.title)),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        tempat.gambarUtama,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surface,
                          height: 250,
                          child: const Center(
                              child: Icon(Icons.image_not_supported)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Deskripsi',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.title)),
                    const SizedBox(height: 8),
                    Text(tempat.deskripsi,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.subtitle)),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        Icons.location_on, 'Alamat', tempat.alamat),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.access_time, 'Jam Buka', tempat.jamBuka),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.local_offer, 'Harga Tiket',
                        tempat.hargaTiket),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.home, 'Fasilitas', tempat.fasilitas),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.subtitle)),
            ],
          ),
        ),
      ],
    );
  }
}