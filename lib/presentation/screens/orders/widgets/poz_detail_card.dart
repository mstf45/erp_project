import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            // ARTIK SADECE "hesaplaniyor" DEĞİŞKENİNİ DİNLİYOR (Kaydet butonu ile karışmaz)
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