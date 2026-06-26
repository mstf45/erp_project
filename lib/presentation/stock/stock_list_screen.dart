// lib/presentation/screens/stock/stock_list_screen.dart
import 'package:erp_frontend_project/presentation/providers/providers.dart';
import 'package:erp_frontend_project/presentation/widgets/common/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'stock_form_screen.dart'; // Form ekranını buraya bağlayacağız

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StokProvider>().stokKartlariDinle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stokProv = context.watch<StokProvider>();
    final kartlar = stokProv.filtrelenmisKartlar;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              baslik: 'Stok Kartları',
              alt: 'Depodaki tüm ürünlerin fiziksel ve finansal tanımları.',
              aksiyon: ElevatedButton.icon(
                onPressed: () {
                  // Yeni Stok Ekleme Ekranına Geçiş
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StockFormScreen()));
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Stok Kartı'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ─── ARAMA VE FİLTRELEME ───
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Stok Kodu veya Adı ile ara...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: stokProv.ara,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: stokProv.urunGruplari.isEmpty ? null : '',
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Ürün Grubu Filtresi'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Tümü')),
                      ...stokProv.urunGruplari.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                    ],
                    onChanged: (val) => stokProv.filtreGrubu(val ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ─── TABLO ───
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: kartlar.isEmpty
                    ? const EmptyState(
                  ikon: Icons.inventory_2_outlined,
                  baslik: 'Stok Kartı Bulunamadı',
                  aciklama: 'Arama kriterlerinize uygun sonuç yok veya henüz stok eklenmedi.',
                )
                    : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Stok Kodu')),
                      DataColumn(label: Text('Stok Adı')),
                      DataColumn(label: Text('Birim')),
                      DataColumn(label: Text('Mevcut Stok')),
                      DataColumn(label: Text('İşlemler')),
                    ],
                    rows: kartlar.map((k) {
                      final kritikMi = k.mevcutStok <= k.minimumStok;
                      return DataRow(
                        cells: [
                          DataCell(Text(k.stokKodu, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(k.stokAdi)),
                          DataCell(Text(k.stokTakipBirimi)),
                          DataCell(
                            Text(
                              k.mevcutStok.toStringAsFixed(2),
                              style: TextStyle(
                                color: kritikMi ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => StockFormScreen(duzenlenecekKart: k)));
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}