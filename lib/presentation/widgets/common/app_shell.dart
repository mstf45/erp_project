// lib/presentation/widgets/common/app_shell.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../../core/constants/app_constants.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarWidget(),
          Expanded(
            child: Column(
              children: [
                const TopBarWidget(),
                Expanded(
                  child: Container(color: AppColors.bgLight, child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SIDEBAR ────────────────────────────────────────────────────────────────
class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Container(
      width: 240,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.blinds,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DÜZGÜN',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'PANJUR ERP',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sidebarItem,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Color(0xFF1E2D40), thickness: 1),
          ),

          const SizedBox(height: 8),

          // Nav items
          _SidebarGroup(
            baslik: 'ANA MENÜ',
            items: [
              _SidebarItem(
                ikon: Icons.dashboard_rounded,
                baslik: 'Dashboard',
                rota: AppRoutes.dashboard,
                aktif: nav.aktifRota == AppRoutes.dashboard,
              ),
              _SidebarItem(
                ikon: Icons.receipt_long_rounded,
                baslik: 'Siparişler / Teklifler',
                rota: AppRoutes.orders,
                aktif:
                    nav.aktifRota == AppRoutes.orders ||
                    nav.aktifRota.startsWith('/orders'),
              ),
            ],
          ),

          _SidebarGroup(
            baslik: 'YÖNETİM',
            items: [
              _SidebarItem(
                ikon: Icons.inventory_2_rounded,
                baslik: 'Stok Kartları',
                rota: AppRoutes.stock,
                aktif: nav.aktifRota == AppRoutes.stock,
              ),
              _SidebarItem(
                ikon: Icons.palette_rounded,
                baslik: 'Renk Havuzu',
                rota: AppRoutes.colorPool,
                aktif: nav.aktifRota == AppRoutes.colorPool,
              ),
              _SidebarItem(
                ikon: Icons.bar_chart_rounded,
                baslik: 'Raporlar',
                rota: AppRoutes.reports,
                aktif: nav.aktifRota == AppRoutes.reports,
              ),
            ],
          ),

          const Spacer(),

          // Alt kısım
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(color: Color(0xFF1E2D40)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF1A2B4A),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<AuthProvider>().kullaniciEmail,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Yönetici',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.sidebarItem,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<AuthProvider>().cikisYap(),
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.sidebarItem,
                      ),
                      tooltip: 'Çıkış',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  final String baslik;
  final List<Widget> items;

  const _SidebarGroup({required this.baslik, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
          child: Text(
            baslik,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A6080),
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String rota;
  final bool aktif;

  const _SidebarItem({
    required this.ikon,
    required this.baslik,
    required this.rota,
    required this.aktif,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<NavigationProvider>().rotaDegistir(rota);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: aktif ? const Color(0xFF1A2B4A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: aktif
              ? Border(left: BorderSide(color: AppColors.accent, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              ikon,
              size: 16,
              color: aktif ? AppColors.accent : AppColors.sidebarItem,
            ),
            const SizedBox(width: 12),
            Text(
              baslik,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                color: aktif ? Colors.white : AppColors.sidebarItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TOP BAR ────────────────────────────────────────────────────────────────
class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  String _rotaBasligi(String rota) {
    if (rota.startsWith('/orders/new')) return 'Yeni Sipariş / Teklif';
    if (rota.startsWith('/orders/')) return 'Sipariş Detayı';
    switch (rota) {
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.orders:
        return 'Siparişler & Teklifler';
      case AppRoutes.stock:
        return 'Stok Kartları';
      case AppRoutes.colorPool:
        return 'Renk Havuzu';
      case AppRoutes.reports:
        return 'Raporlar';
      default:
        return 'Düzgün Panjur ERP';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rota = context.watch<NavigationProvider>().aktifRota;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            _rotaBasligi(rota),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Hızlı stok uyarısı
          Consumer<StokProvider>(
            builder: (ctx, stok, _) {
              final kritik = stok.kritikStoklar.length;
              if (kritik == 0) return const SizedBox();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$kritik kritik stok',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Text(
            _simdi(),
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _simdi() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
  }
}

// ─── STAT CARD ──────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;
  final String? alt;

  const StatCard({
    super.key,
    required this.baslik,
    required this.deger,
    required this.ikon,
    required this.renk,
    this.alt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: renk.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(ikon, color: renk, size: 20),
              ),
              if (alt != null)
                Expanded(
                  child: Text(
                    alt!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              deger,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              baslik,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION HEADER ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String baslik;
  final String? alt;
  final Widget? aksiyon;

  const SectionHeader({
    super.key,
    required this.baslik,
    this.alt,
    this.aksiyon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (alt != null) ...[
              const SizedBox(height: 2),
              Text(
                alt!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        if (aksiyon != null) aksiyon!,
      ],
    );
  }
}

// ─── STATUS BADGE ────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String durum;

  const StatusBadge({super.key, required this.durum});

  @override
  Widget build(BuildContext context) {
    final (renk, bg, etiket) = switch (durum) {
      'taslak' => (AppColors.textMuted, const Color(0xFFF1F5F9), 'Taslak'),
      'teklif' => (AppColors.info, const Color(0xFFEFF8FF), 'Teklif'),
      'onaylandi' => (AppColors.success, const Color(0xFFF0FDF4), 'Onaylandı'),
      'uretimde' => (AppColors.warning, const Color(0xFFFFFBEB), 'Üretimde'),
      'tamamlandi' => (
        AppColors.primary,
        const Color(0xFFF8F9FC),
        'Tamamlandı',
      ),
      _ => (AppColors.textMuted, const Color(0xFFF1F5F9), durum),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: renk.withOpacity(0.2)),
      ),
      child: Text(
        etiket,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: renk,
        ),
      ),
    );
  }
}

// ─── FORM FIELD WRAPPER ──────────────────────────────────────────────────────
class FormFieldWrap extends StatelessWidget {
  final String etiket;
  final Widget child;
  final bool zorunlu;

  const FormFieldWrap({
    super.key,
    required this.etiket,
    required this.child,
    this.zorunlu = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              etiket,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (zorunlu)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String? aciklama;
  final Widget? buton;

  const EmptyState({
    super.key,
    required this.ikon,
    required this.baslik,
    this.aciklama,
    this.buton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, size: 36, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            baslik,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (aciklama != null) ...[
            const SizedBox(height: 6),
            Text(
              aciklama!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (buton != null) ...[const SizedBox(height: 24), buton!],
        ],
      ),
    );
  }
}
