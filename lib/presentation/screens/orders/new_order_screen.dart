import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_shell.dart';
import '../../../data/models/models.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _musteriAdiController = TextEditingController();
  final _referansController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StokProvider>().renklerDinle();
      context.read<SiparisProvider>().sifirla();
    });
  }

  @override
  void dispose() {
    _musteriAdiController.dispose();
    _referansController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final siparisProv = context.watch<SiparisProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, siparisProv),
            const SizedBox(height: AppSpacing.lg),

            if (siparisProv.secilenRenk.isEmpty)
              const EmptyState(
                ikon: Icons.palette_outlined,
                baslik: 'Siparişe Başlamak İçin Renk Seçin',
                aciklama:
                    'Tüm sisteme varsayılan olarak atanacak olan profil rengini yukarıdan belirlemelisiniz.',
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    baslik: 'Sipariş Kalemleri (Pozlar)',
                    aksiyon: Row(
                      children: [
                        if (siparisProv.pozlar.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const TopluDegisiklikDialog(),
                              );
                            },
                            icon: const Icon(Icons.auto_fix_high, size: 18),
                            label: const Text('Toplu Değiştir'),
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton.icon(
                          onPressed: () => siparisProv.yeniPozEkle(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Yeni Panjur Ekle'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (siparisProv.pozlar.isEmpty)
                    const EmptyState(
                      ikon: Icons.view_list_rounded,
                      baslik: 'Henüz Panjur Eklenmedi',
                      aciklama:
                          'Yeni Panjur Ekle butonuna tıklayarak ilk pozisyonu oluşturun.',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: siparisProv.pozlar.length,
                      itemBuilder: (context, index) {
                        return PozDetailCard(
                          poz: siparisProv.pozlar[index],
                          index: index,
                        );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: siparisProv.pozlar.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toplam Sistem Maliyeti',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '₺${siparisProv.toplamMaliyet.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // bottomNavigationBar içindeki ElevatedButton:
                  ElevatedButton.icon(
                    onPressed: siparisProv.yukleniyor
                        ? null
                        : () async {
                            // 1. Firebase'e kaydetme işlemini tetikle
                            final id = await siparisProv.siparisKaydet();

                            if (context.mounted) {
                              if (id != null) {
                                // 2. Başarılıysa yeşil bildirim göster ve formu sıfırla
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sipariş Başarıyla Kaydedildi! (ID: $id)',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                siparisProv.sifirla(); // Ekranı temizle
                                context.read<NavigationProvider>().rotaDegistir(
                                  AppRoutes.dashboard,
                                );
                              } else {
                                // 3. Hata varsa kırmızı bildirim göster
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      siparisProv.hata ??
                                          'Kayıt sırasında hata oluştu.',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.success,
                    ),
                    icon: siparisProv.yukleniyor
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      siparisProv.yukleniyor
                          ? 'KAYDEDİLİYOR...'
                          : 'SİPARİŞİ KAYDET',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, SiparisProvider siparisProv) {
    final stokProv = context.watch<StokProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(baslik: '1. Başlık Bilgileri ve Renk'),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Müşteri Adı',
                    zorunlu: true,
                    child: TextField(
                      controller: _musteriAdiController,
                      onChanged: siparisProv.musteriAdiGuncelle,
                      decoration: const InputDecoration(
                        hintText: 'Müşteri veya Firma Adı',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Sipariş Referansı',
                    child: TextField(
                      controller: _referansController,
                      onChanged: siparisProv.referansGuncelle,
                      decoration: const InputDecoration(
                        hintText: 'İsteğe bağlı referans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // _buildHeaderCard içindeki Renk Seçimi kısmı:
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Global Renk Seçimi',
                    zorunlu: true,
                    child: DropdownButtonFormField<String>(
                      value: siparisProv.secilenRenk.isEmpty
                          ? null
                          : siparisProv.secilenRenk,
                      isExpanded: true, // Ekrandan taşmasını engeller!
                      decoration: const InputDecoration(
                        hintText: 'Renk Seçiniz',
                      ),
                      items: [
                        ...stokProv.renkler.map(
                          (r) => DropdownMenuItem(
                            value: r.renkKodu,
                            child: Text('${r.renkAdi} (${r.renkKodu})'),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          val != null ? siparisProv.renkSec(val) : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── POZ DETAIL CARD ───
class PozDetailCard extends StatelessWidget {
  final SiparisPoz poz;
  final int index;

  const PozDetailCard({super.key, required this.poz, required this.index});

  @override
  Widget build(BuildContext context) {
    final siparisProv = context.read<SiparisProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              baslik: 'Poz ${index + 1}',
              alt: 'ID: ${poz.id.substring(0, 8)}...',
              aksiyon: IconButton(
                onPressed: () => siparisProv.pozSil(poz.id),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Panjur Tipi',
                    zorunlu: true,
                    child: DropdownMenu<PanjurTipi>(
                      initialSelection: poz.panjurTipi,
                      width: double.infinity,
                      onSelected: (val) => val != null
                          ? siparisProv.pozPanjurTipiGuncelle(poz.id, val)
                          : null,
                      dropdownMenuEntries: PanjurTipi.values
                          .map(
                            (t) => DropdownMenuEntry(value: t, label: t.label),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: poz.panjurTipi.kutuAktif
                      ? FormFieldWrap(
                          etiket: 'Kutu Tipi',
                          zorunlu: true,
                          child: DropdownMenu<KutuTipi>(
                            initialSelection: poz.kutuTipi,
                            width: double.infinity,
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
                          'Pano tipinde seçilemez',
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
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
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(
                                value: 'Standart',
                                label: 'Standart Motor',
                              ),
                            ],
                          ),
                        )
                      : _buildLockedField(
                          'Motor Türü',
                          'Bu tipte kullanılamaz',
                        ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildOlcuVeBolmeAlanlari(context, siparisProv),
            _buildHesaplamaVeSonucAlani(context, siparisProv),
          ],
        ),
      ),
    );
  }

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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOlcuVeBolmeAlanlari(
    BuildContext context,
    SiparisProvider siparisProv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(baslik: 'Ölçü ve Bölmeler'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FormFieldWrap(
                etiket: 'Bölme Sayısı',
                child: Container(
                  height: 48,
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
                            ? () => siparisProv.pozBolmeSayisiGuncelle(
                                poz.id,
                                poz.bolmeSayisi - 1,
                              )
                            : null,
                      ),
                      Text(
                        '${poz.bolmeSayisi}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => siparisProv.pozBolmeSayisiGuncelle(
                          poz.id,
                          poz.bolmeSayisi + 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${bolme.bolmeNo}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FormFieldWrap(
                        etiket: 'En (mm)',
                        child: TextFormField(
                          initialValue: bolme.enMm == 0 ? '' : '${bolme.enMm}',
                          keyboardType: TextInputType.number,
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
                    Expanded(
                      child: FormFieldWrap(
                        etiket: 'Boy (mm)',
                        child: TextFormField(
                          initialValue: bolme.boyMm == 0
                              ? ''
                              : '${bolme.boyMm}',
                          keyboardType: TextInputType.number,
                          onChanged: (val) => siparisProv.bolmeOlcuGuncelle(
                            poz.id,
                            bolme.bolmeNo,
                            bolme.enMm,
                            int.tryParse(val) ?? 0,
                          ),
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

  Widget _buildHesaplamaVeSonucAlani(
    BuildContext context,
    SiparisProvider siparisProv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // Provider yükleniyorsa butonu pasif (null) yap
            onPressed: siparisProv.yukleniyor
                ? null
                : () async {
                    await siparisProv.hesaplaBomlariniPatlaAt(poz.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reçete başarıyla hesaplandı!'),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            // Yükleniyorsa dönen ikon (spinner), yoksa normal ikon göster
            icon: siparisProv.yukleniyor
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.precision_manufacturing_outlined),
            label: Text(
              siparisProv.yukleniyor
                  ? 'HESAPLANIYOR...'
                  : 'REÇETEYİ PATLAT VE HESAPLA',
            ),
          ),
        ),
        if (poz.hesaplananUrunler.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Kodu')),
                  DataColumn(label: Text('Adı')),
                  DataColumn(label: Text('Miktar')),
                ],
                rows: poz.hesaplananUrunler.map((u) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          u.stokKodu,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(u.stokAdi)),
                      DataCell(Text('${u.miktar} ${u.birim}')),
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

// ─── TOPLU DEĞİŞİKLİK DIALOG ───
class TopluDegisiklikDialog extends StatelessWidget {
  const TopluDegisiklikDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final siparisProv = context.read<SiparisProvider>();
    return AlertDialog(
      title: const Text('Toplu Özellik Değiştir'),
      content: const Text(
        'Burada toplu seçim işlemleri yapılacak (UI hazır, bağlanacak).',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Uygula'),
        ),
      ],
    );
  }
}
