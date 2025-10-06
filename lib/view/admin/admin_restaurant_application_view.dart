import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karpel_food_delivery/providers/AdminRestaurantApplicationProvider.dart';
import 'package:karpel_food_delivery/view/admin/admin_restaurant_application_detail_view.dart'; // Untuk navigasi ke halaman detail

class AdminRestaurantApplicationListView extends StatefulWidget {
  const AdminRestaurantApplicationListView({super.key});

  @override
  State<AdminRestaurantApplicationListView> createState() =>
      _AdminRestaurantApplicationListViewState();
}

class _AdminRestaurantApplicationListViewState
    extends State<AdminRestaurantApplicationListView> {
  // Map untuk menyimpan ScrollController per status (setiap tab butuh controllernya sendiri)
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    // Memastikan provider diinisialisasi dan data dimuat saat pertama kali widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminRestaurantApplicationProvider>(context, listen: false);
      
      // Inisialisasi provider, yang akan memuat token dan memicu fetchApplications() untuk setiap status
      provider.init(); 

      // Tambahkan listener untuk setiap scroll controller yang akan dibuat
      // Perhatikan: _availableStatuses ada di provider, jadi ini harus dipanggil setelah provider.init() selesai
      // atau setidaknya setelah _availableStatuses terisi
      for (String status in provider.availableStatuses) {
        _scrollControllers.putIfAbsent(status, () => ScrollController())
          .addListener(() => _onScroll(status));
      }
    });
  }

  @override
  void dispose() {
    // Dispose semua scroll controller saat widget dihapus
    _scrollControllers.forEach((status, controller) => controller.dispose());
    super.dispose();
  }

  // Listener scroll per status untuk fitur "Load More"
  void _onScroll(String status) {
    final provider = Provider.of<AdminRestaurantApplicationProvider>(context, listen: false);
    final controller = _scrollControllers[status];

    // Cek apakah controller sudah mencapai akhir scroll, tidak sedang loading, dan masih ada data
    if (controller != null && controller.position.pixels >=
            controller.position.maxScrollExtent - 200 && // 200 piksel dari bawah
        !provider.isLoadingMore(status) && // Pastikan tidak sedang memuat data lebih lanjut
        provider.hasMore(status)) { // Pastikan ada lebih banyak data yang tersedia di backend
      provider.loadMoreApplications(status: status);
    }
  }

  // --- Fungsi Pembantu untuk Tampilan Status (sesuai dengan halaman detail dan backend) ---
  Color _getStatusColor(String status) {
    switch (status) {
      case "pending": // Sesuaikan dengan nilai 'status' dari respons API backend
        return Colors.amber.shade700;
      case "approved":
        return Colors.green.shade700;
      case "rejected":
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case "all": // Label untuk tab "Semua"
        return "Semua";
      case "pending":
        return "Menunggu";
      case "approved":
        return "Diterima";
      case "rejected":
        return "Ditolak";
      default: 
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    // DefaultTabController harus membungkus Scaffold yang berisi TabBar dan TabBarView
    return DefaultTabController(
      // Mengambil jumlah tab dari daftar status yang tersedia di provider
      length: Provider.of<AdminRestaurantApplicationProvider>(context).availableStatuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pengajuan Restoran"),
          backgroundColor: Colors.deepOrange, // Warna AppBar yang konsisten
          foregroundColor: Colors.white, // Warna teks dan ikon AppBar
          elevation: 1, // Sedikit bayangan di AppBar
          bottom: TabBar( // TabBar diletakkan di bagian bawah AppBar
            isScrollable: true, // Agar bisa digulir jika jumlah tab banyak
            labelColor: Colors.white, // Warna teks tab yang aktif
            unselectedLabelColor: Colors.white70, // Warna teks tab yang tidak aktif
            indicatorColor: Colors.white, // Warna indikator garis bawah tab
            indicatorWeight: 3, // Tebal indikator
            // Membuat Tab widget untuk setiap status yang tersedia
            tabs: Provider.of<AdminRestaurantApplicationProvider>(context).availableStatuses.map((status) {
              return Tab(text: _formatStatus(status));
            }).toList(),
            // Aksi saat tab diubah
            onTap: (index) {
              final provider = Provider.of<AdminRestaurantApplicationProvider>(context, listen: false);
              final selectedStatus = provider.availableStatuses[index];
              // Panggil fetchApplications untuk status yang dipilih jika datanya belum ada dan tidak sedang loading
              if (provider.getApplicationsForStatus(selectedStatus).isEmpty && !provider.isLoading(selectedStatus)) {
                provider.fetchApplications(status: selectedStatus, reset: true);
              }
            },
          ),
        ),
        body: Consumer<AdminRestaurantApplicationProvider>(
          builder: (context, provider, _) {
            // TabBarView akan menampilkan konten yang berbeda untuk setiap tab
            return TabBarView(
              children: provider.availableStatuses.map((status) {
                final applications = provider.getApplicationsForStatus(status);
                final isLoadingInitial = provider.isLoading(status);
                final isLoadingMore = provider.isLoadingMore(status);
                final hasMore = provider.hasMore(status);
                final error = provider.getError(status);

                // --- Kondisi Loading Awal ---
                if (isLoadingInitial && applications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // --- Kondisi Error (jika ada error dan daftar aplikasi kosong) ---
                if (error != null && applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        Text(
                          "Error: $error\nMohon coba lagi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Coba muat ulang data untuk status ini
                            provider.fetchApplications(status: status, reset: true);
                          },
                          child: const Text("Muat Ulang"),
                        )
                      ],
                    ),
                  );
                }

                // --- Kondisi Daftar Kosong (Tidak ada pengajuan setelah loading selesai) ---
                if (applications.isEmpty && !isLoadingInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("Tidak ada pengajuan ${_formatStatus(status).toLowerCase()} saat ini.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Coba muat ulang data untuk status ini
                            provider.fetchApplications(status: status, reset: true);
                          },
                          child: const Text("Muat Ulang"),
                        )
                      ],
                    ),
                  );
                }

                // --- Tampilan Daftar Aplikasi ---
                return RefreshIndicator( // Pull-to-refresh untuk setiap tab
                  onRefresh: () => provider.fetchApplications(status: status, reset: true),
                  child: ListView.builder(
                    controller: _scrollControllers[status], // Gunakan controller khusus untuk tab ini
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding keseluruhan ListView
                    // itemCount: Jumlah item + 1 (jika ada lebih banyak data atau sedang memuat lebih banyak)
                    itemCount: applications.length + (hasMore || isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Menampilkan CircularProgressIndicator di bagian bawah daftar saat memuat lebih banyak item
                      if (index >= applications.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final app = applications[index];
                      return Card(
                        elevation: 3, // Tambahkan elevasi pada Card
                        margin: const EdgeInsets.only(bottom: 12), // Jarak antar Card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Sudut Card membulat
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16), // Padding konten ListTile
                          leading: CircleAvatar( // Menampilkan inisial nama restoran
                            backgroundColor: Colors.orange.shade100,
                            radius: 24,
                            child: Text(
                              app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          title: Text(
                            app.name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Alamat: ${app.location}",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                              Text("Email: ${app.email}",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                              Text("No. Telp: ${app.phone}",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                              const SizedBox(height: 8),
                              Chip( // Menampilkan status dengan Chip berwarna
                                label: Text(
                                  _formatStatus(app.status ?? ""),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                backgroundColor: _getStatusColor(app.status ?? ""),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey), // Ikon panah
                          onTap: () {
                            // Navigasi ke halaman detail saat item diklik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminRestaurantApplicationDetailView(
                                        application: app),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }).toList(), // Ubah hasil map menjadi List
            );
          },
        ),
      ),
    );
  }
}