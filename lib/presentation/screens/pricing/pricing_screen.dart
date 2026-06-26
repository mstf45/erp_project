// lib/presentation/screens/pricing/pricing_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_shell.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siparisProv = context.watch<SiparisProvider>();

    // Tüm pozlardaki hesaplanmış ürünleri tek bir listede toplayalım
    final tumUrunler = siparisProv.pozlar.expand((poz) => poz.hesaplananUrunler).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teklif ve Fiyatlandırma Paneli'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              baslik: 'Maliyet ve Satış Matrisi',
              alt: 'Tüm panjur pozlarının ve ilave malzemelerin finansal dökümü.',
              aksiyon: ElevatedButton.icon(
                onPressed: () {
                  // TODO: İlave Malzeme Ekleme Modülü Açılacak (Transit Satış)
                },
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('İlave Malzeme Ekle'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── FİYATLANDIRMA TABLOSU ───
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: tumUrunler.isEmpty
                    ? const EmptyState(
                  ikon: Icons.receipt_long,
                  baslik: 'Hesaplanmış Ürün Yok',
                  aciklama: 'Fiyatlandırma yapabilmek için önce panjur pozlarının reçetelerini hesaplatmalısınız.',
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
                      dataTextStyle: GoogleFonts.inter(fontSize: 12),
                      columns: const [
                        DataColumn(label: Text('Ürün Adı')),
                        DataColumn(label: Text('Tipi/Birim')),
                        DataColumn(label: Text('Kilosu')),
                        DataColumn(label: Text('Metrajı')),
                        DataColumn(label: Text('Birim Maliyet')),
                        DataColumn(label: Text('Kâr Marjı')),
                        DataColumn(label: Text('Satış Fiyatı')),
                        DataColumn(label: Text('KDV\'li Tutar')),
                      ],
                      rows: tumUrunler.map((u) {
                        return DataRow(
                          cells: [
                            DataCell(Text(u.stokAdi, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(u.birim)),
                            DataCell(Text('${(u.kilogram * u.miktar).toStringAsFixed(2)} kg')),
                            DataCell(Text('${(u.metraj * u.miktar).toStringAsFixed(2)} m')),
                            DataCell(Text('₺${u.maliyet.toStringAsFixed(2)}')),
                            DataCell(Text('%${u.karMarji.toStringAsFixed(0)}')),
                            DataCell(Text('₺${u.satisFiyati.toStringAsFixed(2)}')),
                            DataCell(Text('₺${u.kdvliFiyat.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ─── GENEL TOPLAMLAR VE İSKONTO ───
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fiziksel Toplamlar (Kantar ve Nakliye İçin)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fiziksel Toplamlar', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Toplam Ağırlık: ${siparisProv.pozlar.fold(0.0, (sum, p) => sum + p.hesaplananUrunler.fold(0.0, (s, u) => s + (u.kilogram * u.miktar))).toStringAsFixed(2)} kg'),
                    ],
                  ),

                  // İskonto Girişi
                  SizedBox(
                    width: 200,
                    child: FormFieldWrap(
                      etiket: 'Genel İskonto (%)',
                      child: TextFormField(
                        initialValue: siparisProv.genelIskonto.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(suffixText: '%'),
                        onChanged: (val) => siparisProv.genelIskontoGuncelle(double.tryParse(val) ?? 0),
                      ),
                    ),
                  ),

                  // Finansal Toplamlar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Alt Toplam: ₺${siparisProv.toplamMaliyet.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        'Genel Toplam: ₺${(siparisProv.toplamMaliyet * (1 - (siparisProv.genelIskonto / 100))).toStringAsFixed(2)}',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}