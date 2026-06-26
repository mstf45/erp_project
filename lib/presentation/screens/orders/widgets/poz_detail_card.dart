// lib/presentation/screens/orders/widgets/poz_detail_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../../widgets/common/app_shell.dart';
import '../../../../data/models/models.dart';

class PozDetailCard extends StatelessWidget {
  final SiparisPoz poz;
  final int index;

  const PozDetailCard({super.key, required this.poz, required this.index});

  @override
  Widget build(BuildContext context) {
    // Read kullanarak metotları tetikleyeceğiz, rebuild işlemini ana sayfa(watch) hallediyor
    final siparisProv = context.read<SiparisProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── POZ BAŞLIĞI VE SİLME BUTONU ───
            SectionHeader(
              baslik: 'Poz ${index + 1}',
              alt: 'ID: ${poz.id.substring(0, 8)}...',
              aksiyon: IconButton(
                onPressed: () => siparisProv.pozSil(poz.id),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'Pozu Sil',
              ),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // ─── TEMEL SEÇİMLER VE KOŞULLU KİLİTLER ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Panjur Tipi (Ana Kilit Belirleyici)
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Panjur Tipi',
                    zorunlu: true,
                    child: DropdownMenu<PanjurTipi>(
                      initialSelection: poz.panjurTipi,
                      width: double.infinity,
                      onSelected: (val) {
                        if (val != null) {
                          siparisProv.pozPanjurTipiGuncelle(poz.id, val);
                        }
                      },
                      dropdownMenuEntries: PanjurTipi.values
                          .map(
                            (t) => DropdownMenuEntry(value: t, label: t.label),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 2. Kutu Tipi (Sadece Kutu Aktifse Açılır)
                Expanded(
                  child: poz.panjurTipi.kutuAktif
                      ? FormFieldWrap(
                          etiket: 'Kutu Tipi',
                          zorunlu: true,
                          child: DropdownMenu<KutuTipi>(
                            initialSelection: poz.kutuTipi,
                            width: double.infinity,
                            hintText: 'Kutu Seçiniz',
                            onSelected: (val) =>
                                siparisProv.pozKutuTipiGuncelle(poz.id, val),
                            dropdownMenuEntries: KutuTipi.values
                                .map(
                                  (t) => DropdownMenuEntry(
                                    value: t,
                                    label: t.label,
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      : _buildLockedField(
                          'Kutu Tipi',
                          'Pano tipinde kutu seçilemez',
                        ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 3. Lamel Tipi
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Lamel Tipi',
                    zorunlu: true,
                    child: DropdownMenu<LamelTipi>(
                      initialSelection: poz.lamelTipi,
                      width: double.infinity,
                      onSelected: (val) {
                        if (val != null) {
                          siparisProv.pozLamelTipiGuncelle(poz.id, val);
                        }
                      },
                      dropdownMenuEntries: LamelTipi.values
                          .map(
                            (t) => DropdownMenuEntry(value: t, label: t.label),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 4. Motor Seçimi (Sadece Motor Aktifse Açılır)
                Expanded(
                  child: poz.panjurTipi.motorAktif
                      ? FormFieldWrap(
                          etiket: 'Motor Türü',
                          zorunlu: true,
                          child: DropdownMenu<String>(
                            initialSelection: poz.motorMarkasi.isNotEmpty
                                ? poz.motorMarkasi
                                : null,
                            width: double.infinity,
                            hintText: 'Motor Seçiniz',
                            onSelected: (val) {
                              // TODO: SiparisProvider içine pozMotorGuncelle eklenebilir
                            },
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(
                                value: 'Standart',
                                label: 'Standart Motor',
                              ),
                              DropdownMenuEntry(
                                value: 'Alıcılı',
                                label: 'Kendinden Alıcılı',
                              ),
                              DropdownMenuEntry(
                                value: 'Redüktörlü',
                                label: 'Redüktörlü (Zincirli)',
                              ),
                            ],
                          ),
                        )
                      : _buildLockedField(
                          'Motor Türü',
                          'Manuel/Pano tipinde motor kullanılamaz',
                        ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // TODO: Bölme Sayısı ve Asimetrik Ölçü Girişi Buraya Gelecek
          ],
        ),
      ),
    );
  }

  // Pasif/Kilitli alanların UI'ı
  Widget _buildLockedField(String etiket, String aciklama) {
    return FormFieldWrap(
      etiket: etiket,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                aciklama,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PozDetailCard sınıfının içine eklenecek metot
  Widget _buildOlcuVeBolmeAlanlari(BuildContext context, SiparisProvider siparisProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(baslik: 'Ölçü Opsiyonları ve Bölmeler'),
        const SizedBox(height: AppSpacing.md),

        // ─── 1. GENEL ÖLÇÜ OPSİYONLARI ───
        Row(
          children: [
            Expanded(
              child: FormFieldWrap(
                etiket: 'En Ölçüsü Opsiyonu',
                child: DropdownMenu<EnOlcuOpsiyonu>(
                  initialSelection: poz.enOlcuOpsiyonu,
                  width: double.infinity,
                  onSelected: (val) {
                    if (val != null) {
                      poz.enOlcuOpsiyonu = val;
                      // TODO: notifyListeners tetiklenecek metod eklenebilir
                    }
                  },
                  dropdownMenuEntries: EnOlcuOpsiyonu.values
                      .map((e) => DropdownMenuEntry(value: e, label: e.label))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FormFieldWrap(
                etiket: 'Boy Ölçüsü Opsiyonu',
                child: DropdownMenu<BoyOlcuOpsiyonu>(
                  initialSelection: poz.boyOlcuOpsiyonu,
                  width: double.infinity,
                  onSelected: (val) {
                    if (val != null) {
                      poz.boyOlcuOpsiyonu = val;
                    }
                  },
                  dropdownMenuEntries: BoyOlcuOpsiyonu.values
                      .map((e) => DropdownMenuEntry(value: e, label: e.label))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Bölme Sayısı Arttırıcı/Azaltıcı
            Expanded(
              child: FormFieldWrap(
                etiket: 'Bölme Sayısı',
                child: Container(
                  height: 48, // DropdownMenu ile aynı hizada olması için
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: poz.bolmeSayisi > 1
                            ? () => siparisProv.pozBolmeSayisiGuncelle(poz.id, poz.bolmeSayisi - 1)
                            : null,
                      ),
                      Text(
                        poz.bolmeSayisi.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => siparisProv.pozBolmeSayisiGuncelle(poz.id, poz.bolmeSayisi + 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ─── 2. DİNAMİK BÖLME KARTLARI (ASİMETRİK) ───
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: poz.bolmeler.map((bolme) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Bölme Etiketi
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${bolme.bolmeNo}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // En Girişi
                    Expanded(
                      child: FormFieldWrap(
                        etiket: 'En (mm)',
                        child: TextFormField(
                          initialValue: bolme.enMm == 0 ? '' : bolme.enMm.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Örn: 1500'),
                          onChanged: (val) => siparisProv.bolmeOlcuGuncelle(
                            poz.id,
                            bolme.bolmeNo,
                            int.tryParse(val) ?? 0,
                            bolme.boyMm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Boy Girişi
                    Expanded(
                      child: FormFieldWrap(
                        etiket: 'Boy (mm)',
                        child: TextFormField(
                          initialValue: bolme.boyMm == 0 ? '' : bolme.boyMm.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Örn: 2000'),
                          onChanged: (val) => siparisProv.bolmeOlcuGuncelle(
                            poz.id,
                            bolme.bolmeNo,
                            bolme.enMm,
                            int.tryParse(val) ?? 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Hibrit Sistem: Bölge Bazlı Kilit Açma (PDF Kuralı)
                    Expanded(
                      flex: 2,
                      child: FormFieldWrap(
                        etiket: 'Bölmeye Özel Tip (Opsiyonel)',
                        child: DropdownMenu<PanjurTipi?>(
                          initialSelection: bolme.panjurTipi,
                          width: double.infinity,
                          hintText: 'Globali Kullan (${poz.panjurTipi.label})',
                          onSelected: (val) {
                            siparisProv.bolmePanjurTipiGuncelle(poz.id, bolme.bolmeNo, val);
                          },
                          dropdownMenuEntries: [
                            const DropdownMenuEntry(value: null, label: 'Global Tipi Kullan'),
                            ...PanjurTipi.values.map((t) => DropdownMenuEntry(value: t, label: t.label)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // PozDetailCard sınıfının içine eklenecek metot
  Widget _buildHesaplamaVeSonucAlani(BuildContext context, SiparisProvider siparisProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: AppSpacing.md),

        // ─── HESAPLA BUTONU ───
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: siparisProv.yukleniyor
                ? null
                : () => siparisProv.hesaplaBomlariniPatlaAt(poz.id),
            icon: siparisProv.yukleniyor
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
                : const Icon(Icons.precision_manufacturing_outlined),
            label: const Text('REÇETEYİ PATLAT VE HESAPLA (BOM)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ─── HESAPLANAN ÜRÜNLER (BOM TABLOSU) ───
        if (poz.hesaplananUrunler.isNotEmpty) ...[
          const SectionHeader(
            baslik: 'Üretim Reçetesi ve Fiyatlandırma',
            alt: 'Bu panjur için sistemin otomatik hesapladığı malzeme listesi.',
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            // Ekrana sığması için yatay scroll ekliyoruz
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 12
                ),
                dataTextStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary
                ),
                columns: const [
                  DataColumn(label: Text('Stok Kodu')),
                  DataColumn(label: Text('Ürün Adı')),
                  DataColumn(label: Text('Miktar')),
                  DataColumn(label: Text('Birim')),
                  DataColumn(label: Text('Bölme')),
                ],
                rows: poz.hesaplananUrunler.map((urun) {
                  return DataRow(
                    cells: [
                      DataCell(
                          Text(
                              urun.stokKodu,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent
                              )
                          )
                      ),
                      DataCell(Text(urun.stokAdi)),
                      DataCell(
                          Text(
                              urun.miktar.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold)
                          )
                      ),
                      DataCell(Text(urun.birim)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: urun.bolmeNo != null ? AppColors.info.withOpacity(0.1) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            urun.bolmeNo != null ? 'Bölme ${urun.bolmeNo}' : 'Genel',
                            style: TextStyle(
                                color: urun.bolmeNo != null ? AppColors.info : AppColors.textMuted,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

