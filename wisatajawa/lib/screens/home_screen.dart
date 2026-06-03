import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisatajawa/providers/wisata_provider.dart';
import 'package:wisatajawa/models/tempat_models.dart';
import 'package:wisatajawa/screens/search_screen.dart';
import 'package:wisatajawa/screens/favorite_screen.dart';
import 'package:wisatajawa/screens/profile_screen.dart';
import 'package:wisatajawa/utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedProvinsiIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Mulai listen data Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WisataProvider>().listenProvinsi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text(
                'Wisata Pulau Jawa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primary,
              elevation: 0,
            )
          : null,
      body: _buildScreens()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.hint,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      _buildHomeContent(),
      const SearchScreen(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _buildHomeContent() {
    return Consumer<WisataProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.provinsiList.isEmpty) {
          return const Center(child: Text('Belum ada data provinsi.'));
        }

        // Pastikan index tidak out of range
        if (_selectedProvinsiIndex >= provider.provinsiList.length) {
          _selectedProvinsiIndex = 0;
        }

        final selectedProvinsi = provider.provinsiList[_selectedProvinsiIndex];
        final tempatList = provider.tempatByProvinsi(selectedProvinsi.id);

        return SafeArea(
          child: Column(
            children: [
              // Tab Provinsi
              Container(
                color: AppColors.primary.withOpacity(0.1),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      provider.provinsiList.length,
                      (index) {
                        final isSelected = _selectedProvinsiIndex == index;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedProvinsiIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              provider.provinsiList[index].name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.subtitle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Grid Wisata
              Expanded(
                child: tempatList.isEmpty
                    ? const Center(child: Text('Belum ada tempat wisata.'))
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                            16, 16, 16, 16 + kBottomNavigationBarHeight),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: tempatList.length,
                        itemBuilder: (context, index) {
                          return _buildWisataCard(
                              selectedProvinsi.id, tempatList[index], provider);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWisataCard(
      String provinsiId, TempatModels tempat, WisataProvider provider) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
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
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
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
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tempat.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            tempat.isFavorite ? AppColors.error : AppColors.hint,
                        size: 20,
                      ),
                    ),
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
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Text(
                      tempat.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showDetailDialog(provinsiId, tempat, provider),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Lihat Detail',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(
      String provinsiId, TempatModels tempat, WisataProvider provider) {
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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                                child: Text(
                                  tempat.nama,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.title,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
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
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () async {
                                  await provider.toggleFavorit(provinsiId, tempat);
                                  setModalState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    tempat.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: tempat.isFavorite
                                        ? AppColors.error
                                        : AppColors.hint,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                        _buildDetailRow(
                            Icons.home, 'Fasilitas', tempat.fasilitas),
                        const SizedBox(height: 20),
                        const Text('Galeri Gambar',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.title)),
                        const SizedBox(height: 8),
                        tempat.gambarGaleri.isEmpty
                            ? Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('Tidak ada galeri gambar',
                                      style: TextStyle(
                                          color: AppColors.subtitle)),
                                ),
                              )
                            : SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tempat.gambarGaleri.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 12),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.network(
                                          tempat.gambarGaleri[index],
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 180,
                                            height: 180,
                                            color: AppColors.surface,
                                            child: const Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  color: AppColors.hint),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
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