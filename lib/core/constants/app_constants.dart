// lib/core/constants/app_constants.dart

// ─── PANJUR TİPLERİ ────────────────────────────────────────────────────────
enum PanjurTipi { motorlu, manuel, makasli, pano }

extension PanjurTipiExt on PanjurTipi {
  String get label {
    switch (this) {
      case PanjurTipi.motorlu: return 'Motorlu';
      case PanjurTipi.manuel:  return 'Manuel';
      case PanjurTipi.makasli: return 'makasli';
      case PanjurTipi.pano:    return 'Pano';
    }
  }

  bool get motorAktif => this == PanjurTipi.motorlu || this == PanjurTipi.makasli;
  bool get makaraAktif => this == PanjurTipi.manuel || this == PanjurTipi.makasli;
  bool get boruAktif => this != PanjurTipi.pano;
  bool get kutuAktif => this != PanjurTipi.pano;
}

// ─── KUTU TİPLERİ ───────────────────────────────────────────────────────────
enum KutuTipi { aluminyumDistan, monoblok, kopukKutu, gizli }

extension KutuTipiExt on KutuTipi {
  String get label {
    switch (this) {
      case KutuTipi.aluminyumDistan: return 'Alüminyum Dıştan Takma';
      case KutuTipi.monoblok:        return 'Monoblok';
      case KutuTipi.kopukKutu:       return 'Köpük Kutu';
      case KutuTipi.gizli:           return 'Gizli';
    }
  }

  bool get rulmanliParca =>
  this == KutuTipi.aluminyumDistan ||
  this == KutuTipi.gizli ||
  this == KutuTipi.kopukKutu;

  bool get pimliParca => this == KutuTipi.monoblok;

  bool get urunKitiDegistirAktif =>
      this == KutuTipi.gizli || this == KutuTipi.kopukKutu;

  bool get ilaveBoyAktif =>
      this == KutuTipi.gizli || this == KutuTipi.kopukKutu;

  bool get kertmePayiEklenir =>
      this == KutuTipi.aluminyumDistan ||
          this == KutuTipi.kopukKutu ||
          this == KutuTipi.gizli;
}

// ─── LAMEL TİPLERİ ──────────────────────────────────────────────────────────
enum LamelTipi { mm39, mm55, mm77 }

extension LamelTipiExt on LamelTipi {
  String get label {
    switch (this) {
      case LamelTipi.mm39: return '39 mm';
      case LamelTipi.mm55: return '55 mm';
      case LamelTipi.mm77: return '77 mm';
    }
  }
  int get mm {
    switch (this) {
      case LamelTipi.mm39: return 39;
      case LamelTipi.mm55: return 55;
      case LamelTipi.mm77: return 77;
    }
  }
  String get askiFormulu {
    switch (this) {
      case LamelTipi.mm39:
      case LamelTipi.mm55: return '300'; // Net Lamel Eni / 300
      case LamelTipi.mm77: return '250'; // Net Lamel Eni / 250
    }
  }
}

// ─── EN ÖLÇÜSÜ OPSİYONLARI ─────────────────────────────────────────────────
enum EnOlcuOpsiyonu {
  dikmeDahil,
  ciftDikme,
  tekDikme,
  dikmeYok,
}

extension EnOlcuOpsiyonuExt on EnOlcuOpsiyonu {
  String get label {
    switch (this) {
      case EnOlcuOpsiyonu.dikmeDahil: return 'Dikme Dahil (Dıştan Dışa)';
      case EnOlcuOpsiyonu.ciftDikme:  return '+ Çift Dikme (Net Boşluk)';
      case EnOlcuOpsiyonu.tekDikme:   return '+ Tek Dikme';
      case EnOlcuOpsiyonu.dikmeYok:   return 'Dikme Yok';
    }
  }
}

// ─── BOY ÖLÇÜSÜ OPSİYONLARI ────────────────────────────────────────────────
enum BoyOlcuOpsiyonu { kutuDahil, artiKutu }

extension BoyOlcuOpsiyonuExt on BoyOlcuOpsiyonu {
  String get label {
    switch (this) {
      case BoyOlcuOpsiyonu.kutuDahil: return 'Kutu Dahil (Dıştan Dışa)';
      case BoyOlcuOpsiyonu.artiKutu:  return '+ Kutu (Net Dikme Ölçüsü)';
    }
  }
}

// ─── ORTA DİKME TİPİ ────────────────────────────────────────────────────────
enum OrtaDikmeTipi { pasif, tekMekanizmali, ciftMekanizmali }

extension OrtaDikmeTipiExt on OrtaDikmeTipi {
  String get label {
    switch (this) {
      case OrtaDikmeTipi.pasif:             return 'Pasif (Mekanizmasız)';
      case OrtaDikmeTipi.tekMekanizmali:    return 'Aktif Tek Mekanizmalı';
      case OrtaDikmeTipi.ciftMekanizmali:   return 'Aktif Çift Mekanizmalı';
    }
  }
}

// ─── HESAPLAMA SABİTLERİ ────────────────────────────────────────────────────
class HesaplamaSabitleri {
  // Kertme payı (fitil ve dikme için)
  static const int kertmePay = 30; // mm

  // Tapa payı (dikme yok seçeneğinde)
  static const int tapaPay = 10; // mm

  // Yuvarlama eşiği
  static const double yuvarlama = 0.50;

  // Lamel otomatik yükseltme limiti
  static const int mm39MaxEn = 2500; // mm
  static const int mm39MaxBoy = 2500; // mm

  // Askı bölücüler
  static const int askiBolucu39mm55 = 300;
  static const int askiBolucu77 = 250;

  // Pano dikme metraj formülü: 2 x (En + Boy)
  // 70'lik boru sabit parçaları
  static const String boruBasi70 = 'BRB.070.ALU.001'; // 70 Alüminyum Pimli Boru Başı
  static const String rulman42 = 'RLM.042.001';
  static const String rulmanYatagi42 = 'RLY.042.001';
}

// ─── NAVİGASYON ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const String login     = '/login';
  static const String dashboard = '/dashboard';
  static const String orders    = '/orders';
  static const String newOrder  = '/orders/new';
  static const String orderDetail = '/orders/:id';
  static const String stock     = '/stock';
  static const String stockCard = '/stock/:id';
  static const String pricing   = '/pricing';
  static const String reports   = '/reports';
  static const String settings  = '/settings';
  static const String colorPool = '/settings/colors';
}

// ─── RENKLERİN SABİT LİSTESİ (Admin'den yönetilir, bu sadece default) ───────
class DefaultRenkler {
  static const List<Map<String, dynamic>> renkler = [
    {'kod': '9016', 'ad': 'Beyaz',          'ortaDikmeVar': true},
    {'kod': '7016', 'ad': 'Antrasit',       'ortaDikmeVar': true},
    {'kod': '8014', 'ad': 'Kahverengi',     'ortaDikmeVar': true},
    {'kod': '8003', 'ad': 'Altın Meşe',     'ortaDikmeVar': true},
    {'kod': 'CEV',  'ad': 'Ceviz',          'ortaDikmeVar': true},
    {'kod': 'VZN',  'ad': 'Vizon',          'ortaDikmeVar': true},
    {'kod': 'MET',  'ad': 'Metalik',        'ortaDikmeVar': true},
    {'kod': '9001', 'ad': 'Krem',           'ortaDikmeVar': false},
    {'kod': 'BRZ-A','ad': 'Açık Bronz',     'ortaDikmeVar': false},
    {'kod': 'BRZ-K','ad': 'Koyu Bronz',     'ortaDikmeVar': false},
    {'kod': '9005', 'ad': 'Siyah',          'ortaDikmeVar': false},
  ];
}

// ─── BORU ÇAPLARI ────────────────────────────────────────────────────────────
class BoruCaplari {
  static const List<String> tumCaplar = ['40', '60', '70', '102'];
}

// ─── SIDEBAR MENU ITEMS ──────────────────────────────────────────────────────
class SidebarMenuItem {
  final String title;
  final String route;
  final String iconPath;

  const SidebarMenuItem({
    required this.title,
    required this.route,
    required this.iconPath,
  });
}