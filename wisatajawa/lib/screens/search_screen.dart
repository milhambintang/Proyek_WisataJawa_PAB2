import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisatajawa/providers/wisata_provider.dart';
import 'package:wisatajawa/models/tempat_models.dart';
import 'package:wisatajawa/utils/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cari Wisata',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer<WisataProvider>(
        builder: (context, provider, _) {
          final results = provider.cari(_query);

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.1),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val),
                  decoration: InputDecoration(
                    hintText: 'Cari tempat wisata...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              // Hasil Pencarian
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _query.isEmpty ? Icons.search : Icons.search_off,
                              size: 64,
                              color: AppColors.hint,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _query.isEmpty
                                  ? 'Mulai cari tempat wisata'
                                  : 'Tidak ada hasil pencarian',
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.subtitle),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final tempat = results[index];
                          final provinsiId =
                              _findProvinsiId(provider, tempat.id);
                          return _buildSearchResultCard(
                              context, tempat, provinsiId, provider);
                        },
                      ),
              ),
            ],
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

  Widget _buildSearchResultCard(BuildContext context, TempatModels tempat,
      String provinsiId, WisataProvider provider) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context, tempat),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                tempat.gambarUtama,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.surface,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tempat.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tempat.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subtitle),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async {
                  await provider.toggleFavorit(provinsiId, tempat);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        !tempat.isFavorite
                            ? '${tempat.nama} ditambahkan ke favorit'
                            : '${tempat.nama} dihapus dari favorit',
                      ),
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
                icon: Icon(
                  tempat.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: tempat.isFavorite ? AppColors.error : AppColors.hint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, TempatModels tempat) {
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