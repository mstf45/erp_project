// lib/presentation/screens/orders/widgets/toplu_degisiklik_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../../widgets/common/app_shell.dart';

class TopluDegisiklikDialog extends StatefulWidget {
  const TopluDegisiklikDialog({super.key});

  @override
  State<TopluDegisiklikDialog> createState() => _TopluDegisiklikDialogState();
}

class _TopluDegisiklikDialogState extends State<TopluDegisiklikDialog> {
  String? _secilenRenk;
  PanjurTipi? _secilenPanjurTipi;
  KutuTipi? _secilenKutuTipi;
  LamelTipi? _secilenLamelTipi;

  @override
  Widget build(BuildContext context) {
    final stokProv = context.read<StokProvider>();
    final siparisProv = context.read<SiparisProvider>();

    return AlertDialog(
      title: const Text('Toplu Özellik Değiştir', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sadece değiştirmek istediğiniz özellikleri seçin. Boş bırakılan alanlar mevcut durumunu korur.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Renk Değişimi
              FormFieldWrap(
                etiket: 'Tüm Renkleri Değiştir',
                child: DropdownMenu<String>(
                  width: 350,
                  hintText: 'Değişiklik Yok',
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: '', label: 'Değişiklik Yok'),
                    ...stokProv.renkler.map((r) => DropdownMenuEntry(value: r.renkKodu, label: r.renkAdi)),
                  ],
                  onSelected: (v) => setState(() => _secilenRenk = v?.isEmpty ?? true ? null : v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Panjur Tipi Değişimi
              FormFieldWrap(
                etiket: 'Tüm Panjur Tiplerini Değiştir',
                child: DropdownMenu<PanjurTipi>(
                  width: 350,
                  hintText: 'Değişiklik Yok',
                  dropdownMenuEntries: PanjurTipi.values
                      .map((t) => DropdownMenuEntry(value: t, label: t.label))
                      .toList(),
                  onSelected: (v) => setState(() => _secilenPanjurTipi = v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Lamel Tipi Değişimi
              FormFieldWrap(
                etiket: 'Tüm Lamel Tiplerini Değiştir',
                child: DropdownMenu<LamelTipi>(
                  width: 350,
                  hintText: 'Değişiklik Yok',
                  dropdownMenuEntries: LamelTipi.values
                      .map((t) => DropdownMenuEntry(value: t, label: t.label))
                      .toList(),
                  onSelected: (v) => setState(() => _secilenLamelTipi = v),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            // Provider'daki fonksiyonu çağırıp işlemi uyguluyoruz
            siparisProv.topluOzellikDegistir(
              renk: _secilenRenk,
              panjurTipi: _secilenPanjurTipi,
              kutuTipi: _secilenKutuTipi,
              lamelTipi: _secilenLamelTipi,
            );
            Navigator.pop(context);

            // Kullanıcıya şık bir bildirim (Snackbar) gösterelim
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tüm pozlara seçilen özellikler başarıyla uygulandı!'),
                  backgroundColor: AppColors.success,
                )
            );
          },
          child: const Text('Tümüne Uygula'),
        ),
      ],
    );
  }
}