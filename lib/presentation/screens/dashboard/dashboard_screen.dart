// lib/presentation/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _istatistikler = {};
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _istatistikleriYukle();
  }

  Future<void> _istatistikleriYukle() async {
    // Demo data (Firebase bağlantısı sonrası gerçek data gelecek)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _istatistikler = {
          'toplamSiparis': 247,
          'buAySiparis': 18,
          'bekleyenSiparis': 5,
          'uretimde': 12,
        };
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoşgeldin
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoşgeldiniz 👋',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'İşte bugünkü özet bilgiler',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<NavigationProvider>().rotaDegistir(
                    AppRoutes.newOrder,
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Sipariş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stat kartları
          if (_yukleniyor)
            const Center(child: CircularProgressIndicator())
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _istatistikler.length,
              childAspectRatio: 1.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(
                  baslik: 'Toplam Sipariş',
                  deger: _istatistikler['toplamSiparis'].toString(),
                  ikon: Icons.receipt_long_rounded,
                  renk: AppColors.primary,
                  alt: 'Bu ay +18',
                ),
                StatCard(
                  baslik: 'Bu Ay',
                  deger: _istatistikler['buAySiparis'].toString(),
                  ikon: Icons.calendar_today_rounded,
                  renk: AppColors.accent,
                ),
                StatCard(
                  baslik: 'Bekleyen',
                  deger: _istatistikler['bekleyenSiparis'].toString(),
                  ikon: Icons.hourglass_empty_rounded,
                  renk: AppColors.warning,
                ),
                StatCard(
                  baslik: 'Üretimde',
                  deger: _istatistikler['uretimde'].toString(),
                  ikon: Icons.precision_manufacturing_rounded,
                  renk: AppColors.success,
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Alt grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Son siparişler
              Expanded(flex: 3, child: _SonSiparisler()),
              const SizedBox(width: 16),
              // Kritik stoklar + hızlı erişim
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _KritikStoklar(),
                    const SizedBox(height: 16),
                    _HizliErisim(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SonSiparisler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Demo data
    final siparisler = [
      {
        'no': 'PNJ-2024-0018',
        'musteri': 'Ali Yılmaz',
        'durum': 'uretimde',
        'tarih': '24.06.2024',
      },
      {
        'no': 'PNJ-2024-0017',
        'musteri': 'Mehmet Şahin',
        'durum': 'teklif',
        'tarih': '23.06.2024',
      },
      {
        'no': 'PNJ-2024-0016',
        'musteri': 'Fatma Kaya',
        'durum': 'onaylandi',
        'tarih': '22.06.2024',
      },
      {
        'no': 'PNJ-2024-0015',
        'musteri': 'Ahmet Demir',
        'durum': 'tamamlandi',
        'tarih': '21.06.2024',
      },
      {
        'no': 'PNJ-2024-0014',
        'musteri': 'Zeynep Arslan',
        'durum': 'taslak',
        'tarih': '20.06.2024',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            baslik: 'Son Siparişler',
            aksiyon: TextButton(
              onPressed: () => context.read<NavigationProvider>().rotaDegistir(
                AppRoutes.orders,
              ),
              child: const Text('Tümünü Gör'),
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                children: ['Sipariş No', 'Müşteri', 'Durum', 'Tarih']
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          h,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              ...siparisler.map(
                (s) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        s['no']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        s['musteri']!,
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: StatusBadge(durum: s['durum']!),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        s['tarih']!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KritikStoklar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StokProvider>(
      builder: (ctx, stok, _) {
        final kritik = stok.kritikStoklar;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kritik Stoklar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (kritik.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${kritik.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (kritik.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tüm stoklar yeterli düzeyde',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...kritik
                    .take(4)
                    .map(
                      (k) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                k.stokAdi,
                                style: GoogleFonts.inter(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${k.mevcutStok.toStringAsFixed(0)} / ${k.minimumStok.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _HizliErisim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı Erişim',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...[
            (
              Icons.add_circle_outline,
              'Yeni Sipariş',
              AppRoutes.newOrder,
              AppColors.accent,
            ),
            (
              Icons.inventory_2_outlined,
              'Stok Ekle',
              AppRoutes.stock,
              AppColors.primary,
            ),
            (
              Icons.palette_outlined,
              'Renk Yönet',
              AppRoutes.colorPool,
              AppColors.info,
            ),
            (
              Icons.bar_chart_outlined,
              'Raporlar',
              AppRoutes.reports,
              AppColors.success,
            ),
          ].map(
            (item) => InkWell(
              onTap: () =>
                  context.read<NavigationProvider>().rotaDegistir(item.$3),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(item.$1, size: 16, color: item.$4),
                    const SizedBox(width: 10),
                    Text(
                      item.$2,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
