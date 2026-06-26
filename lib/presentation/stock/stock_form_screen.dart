// lib/presentation/screens/stock/stock_form_screen.dart
import 'package:erp_frontend_project/presentation/providers/providers.dart';
import 'package:erp_frontend_project/presentation/widgets/common/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class StockFormScreen extends StatefulWidget {
  final StokKarti? duzenlenecekKart;
  const StockFormScreen({super.key, this.duzenlenecekKart});

  @override
  State<StockFormScreen> createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Temel Bilgiler
  late TextEditingController _koduCtrl;
  late TextEditingController _adiCtrl;
  late TextEditingController _grubuCtrl;

  // Finansal
  late TextEditingController _fiyatCtrl;

  // Fiziksel (Kantar/Nakliye için Kritik)
  late TextEditingController _agirlikCtrl;
  late TextEditingController _boyCtrl;

  bool _rengeGoreDegisir = false;
  String _birim = 'Adet';

  @override
  void initState() {
    super.initState();
    final k = widget.duzenlenecekKart;
    _koduCtrl = TextEditingController(text: k?.stokKodu ?? '');
    _adiCtrl = TextEditingController(text: k?.stokAdi ?? '');
    _grubuCtrl = TextEditingController(text: k?.urunGrubu ?? '');
    _fiyatCtrl = TextEditingController(text: k?.alisFiyati.toString() ?? '0');
    _agirlikCtrl = TextEditingController(text: k?.birimAgirlik.toString() ?? '0');
    _boyCtrl = TextEditingController(text: k?.standartProfilBoyu.toString() ?? '0');
    _rengeGoreDegisir = k?.rengeGoreDegisir ?? false;
    _birim = k?.stokTakipBirimi ?? 'Adet';
  }

  @override
  void dispose() {
    _koduCtrl.dispose(); _adiCtrl.dispose(); _grubuCtrl.dispose();
    _fiyatCtrl.dispose(); _agirlikCtrl.dispose(); _boyCtrl.dispose();
    super.dispose();
  }

  void _kaydet() async {
    if (_formKey.currentState!.validate()) {
      final yeniKart = StokKarti(
        id: widget.duzenlenecekKart?.id ?? '',
        stokKodu: _koduCtrl.text,
        kokKod: _rengeGoreDegisir ? _koduCtrl.text : '', // Eğer renge göre değişirse, yazılan kod kök kod kabul edilir.
        stokAdi: _adiCtrl.text,
        urunGrubu: _grubuCtrl.text,
        alisFiyati: double.tryParse(_fiyatCtrl.text) ?? 0,
        birimAgirlik: double.tryParse(_agirlikCtrl.text) ?? 0,
        standartProfilBoyu: double.tryParse(_boyCtrl.text) ?? 0,
        rengeGoreDegisir: _rengeGoreDegisir,
        stokTakipBirimi: _birim,
        aktif: true,
      );

      await context.read<StokProvider>().stokKartiKaydet(yeniKart);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt Başarılı'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.duzenlenecekKart == null ? 'Yeni Stok Kartı' : 'Stok Düzenle'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOL KOLON: Temel Bilgiler
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(baslik: 'Temel Bilgiler'),
                        const SizedBox(height: AppSpacing.md),
                        FormFieldWrap(
                          etiket: 'Stok Kodu (Örn: LAM.055.ALU)',
                          zorunlu: true,
                          child: TextFormField(
                            controller: _koduCtrl,
                            validator: (v) => v!.isEmpty ? 'Boş bırakılamaz' : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FormFieldWrap(
                          etiket: 'Stok Adı',
                          zorunlu: true,
                          child: TextFormField(
                            controller: _adiCtrl,
                            validator: (v) => v!.isEmpty ? 'Boş bırakılamaz' : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FormFieldWrap(
                          etiket: 'Ürün Grubu (Kategori)',
                          zorunlu: true,
                          child: TextFormField(controller: _grubuCtrl),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Kök Kod / Dinamik Renk Mantığı
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: SwitchListTile(
                            title: const Text('Renge Göre Değişir (Dinamik Kök Kod)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Bu özellik açıksa, sipariş anında kodun sonuna seçilen renk kodu (Örn: .7016) otomatik eklenir.', style: TextStyle(fontSize: 11)),
                            value: _rengeGoreDegisir,
                            onChanged: (v) => setState(() => _rengeGoreDegisir = v),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // SAĞ KOLON: Finansal ve Fiziksel
              Expanded(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(baslik: 'Finansal ve Fiziksel (Kantar)'),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: FormFieldWrap(
                                    etiket: 'Alış Fiyatı (EUR)',
                                    child: TextFormField(controller: _fiyatCtrl, keyboardType: TextInputType.number),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: FormFieldWrap(
                                    etiket: 'Takip Birimi',
                                    child: DropdownButtonFormField<String>(
                                      value: _birim,
                                      isExpanded: true,
                                      items: ['Adet', 'Metre Tül', 'Takım', 'Kutu'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                                      onChanged: (v) => setState(() => _birim = v!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: FormFieldWrap(
                                    etiket: 'Birim Ağırlık (kg)',
                                    child: TextFormField(controller: _agirlikCtrl, keyboardType: TextInputType.number),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: FormFieldWrap(
                                    etiket: 'Standart Profil Boyu (mm)',
                                    child: TextFormField(controller: _boyCtrl, keyboardType: TextInputType.number),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _kaydet,
                        icon: const Icon(Icons.save),
                        label: const Text('STOK KARTINI KAYDET'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}