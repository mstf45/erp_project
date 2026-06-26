import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _customerNameController = TextEditingController();
  final _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StokProvider>().renklerDinle();
      context.read<SiparisProvider>().resetOrderData();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<SiparisProvider>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context, orderProv),
              const SizedBox(height: AppSpacing.lg),

              if (orderProv.secilenRenk.isEmpty)
                const EmptyState(
                  ikon: Icons.palette_outlined,
                  baslik: 'Siparişe Başlamak İçin Renk Seçin',
                  aciklama: 'Tüm sisteme varsayılan olarak atanacak olan profil rengini yukarıdan belirlemelisiniz.',
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      baslik: 'Sipariş Kalemleri (Pozlar)',
                      aksiyon: Row(
                        children: [
                          if (orderProv.pozlar.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(context: context, builder: (_) => const TopluDegisiklikDialog());
                              },
                              icon: const Icon(Icons.auto_fix_high, size: 18),
                              label: const Text('Toplu Değiştir'),
                            ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton.icon(
                            onPressed: () => orderProv.addNewPosition(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Yeni Panjur Ekle'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (orderProv.pozlar.isEmpty)
                      const EmptyState(
                        ikon: Icons.view_list_rounded,
                        baslik: 'Henüz Panjur Eklenmedi',
                        aciklama: 'Yeni Panjur Ekle butonuna tıklayarak ilk pozisyonu oluşturun.',
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderProv.pozlar.length,
                        itemBuilder: (context, index) {
                          return PozDetailCard(poz: orderProv.pozlar[index], index: index);
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
        bottomNavigationBar: orderProv.pozlar.isEmpty ? null : _buildBottomBar(context, orderProv),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, SiparisProvider orderProv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Toplam Sistem Maliyeti', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text('₺${orderProv.toplamMaliyet.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          ElevatedButton.icon(
            // DİKKAT: ARTIK SADECE "KAYDEDILIYOR" DEĞİŞKENİNE BAKIYORUZ
            onPressed: orderProv.kaydediliyor ? null : () async {
              final id = await orderProv.saveOrder();
              if (context.mounted) {
                if (id != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş Başarıyla Kaydedildi! (ID: $id)'), backgroundColor: AppColors.success));
                  orderProv.resetOrderData();
                  context.read<NavigationProvider>().rotaDegistir(AppRoutes.dashboard);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(orderProv.hata ?? 'Kayıt sırasında hata oluştu.'), backgroundColor: AppColors.error));
                }
              }
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), backgroundColor: AppColors.success),
            icon: orderProv.kaydediliyor
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_rounded),
            label: Text(orderProv.kaydediliyor ? 'KAYDEDİLİYOR...' : 'SİPARİŞİ KAYDET'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, SiparisProvider orderProv) {
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
                      controller: _customerNameController,
                      onChanged: orderProv.updateCustomerName,
                      decoration: const InputDecoration(hintText: 'Müşteri veya Firma Adı'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Sipariş Referansı',
                    child: TextField(
                      controller: _referenceController,
                      onChanged: orderProv.updateOrderReference,
                      decoration: const InputDecoration(hintText: 'İsteğe bağlı referans'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Global Renk Seçimi',
                    zorunlu: true,
                    child: DropdownButtonFormField<String>(
                      value: orderProv.secilenRenk.isEmpty ? null : orderProv.secilenRenk,
                      isExpanded: true,
                      decoration: const InputDecoration(hintText: 'Renk Seçiniz'),
                      items: stokProv.renkler.map((r) => DropdownMenuItem(value: r.renkKodu, child: Text('${r.renkAdi} (${r.renkKodu})'))).toList(),
                      onChanged: (val) => val != null ? orderProv.selectGlobalColor(val) : null,
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
    final orderProv = context.read<SiparisProvider>();
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
                onPressed: () => orderProv.removePosition(poz.id),
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
                    child: DropdownButtonFormField<PanjurTipi>(
                      value: poz.panjurTipi,
                      isExpanded: true,
                      decoration: const InputDecoration(hintText: 'Tip Seçiniz'),
                      items: PanjurTipi.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                      onChanged: (val) => val != null ? orderProv.updatePositionType(poz.id, val) : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: poz.panjurTipi.kutuAktif
                      ? FormFieldWrap(
                    etiket: 'Kutu Tipi',
                    zorunlu: true,
                    child: DropdownButtonFormField<KutuTipi>(
                      value: poz.kutuTipi,
                      isExpanded: true,
                      decoration: const InputDecoration(hintText: 'Kutu Seçiniz'),
                      items: KutuTipi.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                      onChanged: (val) => orderProv.updateBoxType(poz.id, val),
                    ),
                  )
                      : _buildLockedField('Kutu Tipi', 'Pano tipinde seçilemez'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FormFieldWrap(
                    etiket: 'Lamel Tipi',
                    zorunlu: true,
                    child: DropdownButtonFormField<LamelTipi>(
                      value: poz.lamelTipi,
                      isExpanded: true,
                      decoration: const InputDecoration(hintText: 'Lamel Seçiniz'),
                      items: LamelTipi.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                      onChanged: (val) => val != null ? orderProv.updateLamelType(poz.id, val) : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildOlcuVeBolmeAlanlari(context, orderProv),
            _buildHesaplamaVeSonucAlani(context, orderProv),
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
        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(child: Text(aciklama, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          ],
        ),
      ),
    );
  }

  Widget _buildOlcuVeBolmeAlanlari(BuildContext context, SiparisProvider orderProv) {
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
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: poz.bolmeSayisi > 1 ? () => orderProv.updateSegmentCount(poz.id, poz.bolmeSayisi - 1) : null),
                      Text('${poz.bolmeSayisi}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () => orderProv.updateSegmentCount(poz.id, poz.bolmeSayisi + 1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
          child: Column(
            children: poz.bolmeler.map((bolme) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Text('${bolme.bolmeNo}', style: const TextStyle(color: Colors.white))),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FormFieldWrap(
                        etiket: 'Width (En - mm)',
                        child: TextFormField(
                          initialValue: bolme.enMm == 0 ? '' : '${bolme.enMm}',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(hintText: 'Örn: 1500'),
                          onChanged: (val) => orderProv.updateSegmentDimensions(poz.id, bolme.bolmeNo, int.tryParse(val) ?? 0, bolme.boyMm),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FormFieldWrap(
                        etiket: 'Height (Boy - mm)',
                        child: TextFormField(
                          initialValue: bolme.boyMm == 0 ? '' : '${bolme.boyMm}',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(hintText: 'Örn: 2000'),
                          onChanged: (val) => orderProv.updateSegmentDimensions(poz.id, bolme.bolmeNo, bolme.enMm, int.tryParse(val) ?? 0),
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

  Widget _buildHesaplamaVeSonucAlani(BuildContext context, SiparisProvider orderProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // DİKKAT: ARTIK SADECE "HESAPLANIYOR" DEĞİŞKENİNE BAKIYORUZ
            onPressed: orderProv.hesaplaniyor
                ? null
                : () async {
              await orderProv.calculateBillOfMaterials(poz.id);
              if (context.mounted && orderProv.hata == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reçete başarıyla hesaplandı!'), backgroundColor: AppColors.success));
              }
            },
            icon: orderProv.hesaplaniyor
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.precision_manufacturing_outlined),
            label: Text(orderProv.hesaplaniyor ? 'HESAPLANIYOR...' : 'REÇETEYİ PATLAT VE HESAPLA'),
          ),
        ),
        if (poz.hesaplananUrunler.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Kodu')),
                  DataColumn(label: Text('Adı')),
                  DataColumn(label: Text('Miktar')),
                ],
                rows: poz.hesaplananUrunler.map((u) {
                  return DataRow(cells: [
                    DataCell(Text(u.stokKodu, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(u.stokAdi)),
                    DataCell(Text('${u.miktar} ${u.birim}')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class TopluDegisiklikDialog extends StatefulWidget {
  const TopluDegisiklikDialog({super.key});

  @override
  State<TopluDegisiklikDialog> createState() => _TopluDegisiklikDialogState();
}

class _TopluDegisiklikDialogState extends State<TopluDegisiklikDialog> {
  String? _selectedColor;
  PanjurTipi? _selectedPanjurTipi;
  KutuTipi? _selectedKutuTipi;
  LamelTipi? _selectedLamelTipi;

  @override
  Widget build(BuildContext context) {
    final orderProv = context.read<SiparisProvider>();
    final stokProv = context.read<StokProvider>();

    return AlertDialog(
      title: const Text('Toplu Özellik Değiştir', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sadece değiştirmek istediğiniz özellikleri seçin.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.lg),
              FormFieldWrap(
                etiket: 'Tüm Renkleri Değiştir',
                child: DropdownButtonFormField<String>(
                  value: _selectedColor,
                  isExpanded: true,
                  decoration: const InputDecoration(hintText: 'Değişiklik Yok'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Değişiklik Yok')),
                    ...stokProv.renkler.map((r) => DropdownMenuItem(value: r.renkKodu, child: Text(r.renkAdi))),
                  ],
                  onChanged: (v) => setState(() => _selectedColor = v?.isEmpty ?? true ? null : v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FormFieldWrap(
                etiket: 'Tüm Panjur Tiplerini Değiştir',
                child: DropdownButtonFormField<PanjurTipi>(
                  value: _selectedPanjurTipi,
                  isExpanded: true,
                  decoration: const InputDecoration(hintText: 'Değişiklik Yok'),
                  items: PanjurTipi.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (v) => setState(() => _selectedPanjurTipi = v),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () {
            orderProv.batchUpdateProperties(color: _selectedColor, panjurType: _selectedPanjurTipi, boxType: _selectedKutuTipi, lamelType: _selectedLamelTipi);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm pozlara seçilen özellikler başarıyla uygulandı!'), backgroundColor: AppColors.success));
          },
          child: const Text('Tümüne Uygula'),
        ),
      ],
    );
  }
}