// lib/core/utils/hesaplama_motoru.dart
import 'dart:math';
import '../constants/app_constants.dart';
import '../../data/models/models.dart';

/// Tüm panjur hesaplamalarını yöneten motor.
/// PDF'deki tüm algoritmalar burada implemente edilmiştir.
class CalculationEngine {
  // ─── 1. NET DİKME BOYU ──────────────────────────────────────────────────
  /// Boy ölçüsü opsiyonuna göre net dikme boyunu hesaplar.
  static int netDikmeBoyuHesapla({
    required int girilenBoy,
    required BoyOlcuOpsiyonu opsiyonu,
    required int kutuPay, // Stok kartından gelir
  }) {
    switch (opsiyonu) {
      case BoyOlcuOpsiyonu.kutuDahil:
      // Toplam dıştan dışa = girilenBoy → DikmeBoyu = Boy - KutuPayı
        return girilenBoy - kutuPay;
      case BoyOlcuOpsiyonu.artiKutu:
      // Girilen = net dikme ölçüsü → doğrudan kullan
      return girilenBoy;
    }
  }

  // ─── 2. NET LAMEL ENİ ────────────────────────────────────────────────────
  /// En ölçüsü opsiyonuna ve dikme tipine göre net lamel enini hesaplar.
  static int netLamelEniHesapla({
    required int girilenEn,
    required EnOlcuOpsiyonu opsiyonu,
    required int sagDikmePay,
    required int solDikmePay,
    required int tekDikmePay,
    required int dikmeDusumu, // Lamel kesim için dikme düşümü (mm)
  }) {
    int toplamEn;
    switch (opsiyonu) {
      case EnOlcuOpsiyonu.dikmeDahil:
      // Girilen dıştan dışa → net lamel = toplamEn - dikmeDüşümü
        toplamEn = girilenEn;
        break;
      case EnOlcuOpsiyonu.ciftDikme:
      // Girilen net boşluk → toplamEn = NetEn + sağPay + solPay
        toplamEn = girilenEn + sagDikmePay + solDikmePay;
        break;
      case EnOlcuOpsiyonu.tekDikme:
        toplamEn = girilenEn + tekDikmePay;
        break;
      case EnOlcuOpsiyonu.dikmeYok:
      // Tapa payı düş: doğrudan lamel kesim ölçüsü
        return girilenEn - HesaplamaSabitleri.tapaPay;
    }
    return toplamEn - dikmeDusumu;
  }

  // ─── 3. LAMEL ADETİ VE YUVARLAMA ────────────────────────────────────────
  /// PDF kuralı:
  /// - Küsurat ≤ 0.50 → alt tamsayı
  /// - Küsurat > 0.50 → üst tamsayı + 1 eklenir
  static int lamelAdetiHesapla({
    required int netDikmeBoy,
    required LamelTipi lamelTipi,
  }) {
    // Kertme payı lamel hesabına KATILMAz
    final double sonuc = netDikmeBoy / lamelTipi.mm;
    final int tabanDeger = sonuc.floor();
    final double kusurat = sonuc - tabanDeger;

    if (kusurat <= HesaplamaSabitleri.yuvarlama) {
      return tabanDeger;
    } else {
      return tabanDeger + 1 + 1; // üst tamsayı + 1 eklenir
    }
  }

  // ─── 4. TAPA ADETİ ──────────────────────────────────────────────────────
  /// "Bir dolu bir boş" kuralı.
  /// Tapa adeti = Lamel adeti. Tek sayıysa +1 ile çift sayıya sabitle.
  static int tapaAdetiHesapla({
    required int lamelAdeti,
    required bool gozluLamel, // Gözlü lamelde her lamele takım tapa
  }) {
    if (gozluLamel) return lamelAdeti; // Gözlüde boşluk bırakılmaz
    return lamelAdeti.isOdd ? lamelAdeti + 1 : lamelAdeti;
  }

  // ─── 5. ASKI ADETİ ──────────────────────────────────────────────────────
  /// Net Lamel Eni (cm) / bölücü → daima bir üst tam sayıya yuvarla
  static int askiAdetiHesapla({
    required int netLamelEniMm,
    required LamelTipi lamelTipi,
  }) {
    final double eniCm = netLamelEniMm / 10;
    final double bolucu = lamelTipi == LamelTipi.mm77 ? 25.0 : 30.0;
    return (eniCm / bolucu).ceil();
  }

  // ─── 6. FİTİL METRAJ HESABI ─────────────────────────────────────────────
  /// Kertme payı dahil fitil metrajı.
  /// Dıştan Takma, Köpük, Gizli: +30 mm kertme payı eklenir.
  /// Monoblok, Pano, Makas: +30 mm EKLENMEz.
  static double fitilMetrajiHesapla({
    required int dikmeBoyu,
    required KutuTipi kutuTipi,
    required bool ortaDikmeVar, // Çift kanal mı?
  }) {
    final bool kertmePayi = kutuTipi.kertmePayiEklenir;
    final int efektifBoy = dikmeBoyu + (kertmePayi ? HesaplamaSabitleri.kertmePay : 0);
    // Tek kanal: boy x 2, Çift kanal (orta dikme): boy x 4
    return efektifBoy / 1000 * (ortaDikmeVar ? 4 : 2);
  }

  // ─── 7. BORU KESİM DÜŞÜMÜ ───────────────────────────────────────────────
  /// Stok kartından gelen sabit düşüm değerini kullanır.
  /// Bölme sayısının önemi yoktur.
  static int boruKesimHesapla({
    required int toplamEn,
    required int tekBolmeDusumuMm, // Stok kartından
    required bool ortaBolme,
    required int ortaBolmeDusumuMm, // Stok kartından
  }) {
    if (ortaBolme) {
      return toplamEn - ortaBolmeDusumuMm;
    }
    return toplamEn - tekBolmeDusumuMm;
  }

  // ─── 8. PANO DİKME METRAJ ───────────────────────────────────────────────
  static double panoDikmeMetrajHesapla({
    required int enMm,
    required int boyMm,
  }) {
    return 2 * (enMm + boyMm) / 1000; // metre
  }

  // ─── 9. OTOMATİK LAMEL YÜKSELTMESİ ────────────────────────────────────
  /// 39 mm lamel: En veya Boy > 2500 mm ise 55 mm'ye geçiş
  static LamelTipi lamelOtomatikYukselt({
    required LamelTipi mevcutLamel,
    required int enMm,
    required int boyMm,
    required bool sinirKaldir,
  }) {
    if (sinirKaldir) return mevcutLamel;
    if (mevcutLamel == LamelTipi.mm39) {
      if (enMm > HesaplamaSabitleri.mm39MaxEn ||
          boyMm > HesaplamaSabitleri.mm39MaxBoy) {
        return LamelTipi.mm55;
      }
    }
    return mevcutLamel;
  }

  // ─── 10. MOTOR TORKU ────────────────────────────────────────────────────
  /// Toplam Yük (kg) x 1.3 → stoktaki bir üst motora atanır.
  static double motorTorkuHesapla(double toplamYukKg) {
    return toplamYukKg * 1.3;
  }

  // ─── 11. DİNAMİK STOK KODU OLUŞTURMA ───────────────────────────────────
  /// Kök kodu + renk kodu birleştirme.
  /// rengeGoreDegisir=true ise: LAM.039. + 7016 → LAM.039.7016
  static String stokKoduOlustur({
    required String kokKod,
    required bool rengeGoreDegisir,
    required String renkKodu,
  }) {
    if (rengeGoreDegisir && renkKodu.isNotEmpty) {
      return '$kokKod$renkKodu';
    }
    return kokKod;
  }

  // ─── 12. KUTU KİTİ HESAPLAMA ────────────────────────────────────────────
  static List<Map<String, dynamic>> kutuKitiHesapla({
    required KutuTipi kutuTipi,
    required int bolmeSayisi,
    required String kutuOlcusu,
  }) {
    final List<Map<String, dynamic>> urunler = [];
    switch (kutuTipi) {
      case KutuTipi.aluminyumDistan:
      // Ön Kapak + Arka Kapak + Yan Kapak + Vida (10 adet 3x1.9)
        urunler.addAll([
          {'kod': 'KAP.ON.$kutuOlcusu', 'adet': 1, 'ad': 'Ön Kapak'},
          {'kod': 'KAP.ARK.$kutuOlcusu', 'adet': 1, 'ad': 'Arka Kapak'},
          {'kod': 'KAP.YAN.$kutuOlcusu', 'adet': 1, 'ad': 'Yan Kapak Takımı'},
          {'kod': 'VID.3X19.001', 'adet': 10, 'ad': 'Vida (3x1.9)'},
        ]);
        if (kutuOlcusu == '400') {
          urunler.add({'kod': 'KAP.UST.400', 'adet': 1, 'ad': 'Üst Kapak'});
        }
        // İlave her bölme: +1 Orta Kapak + 4 Vida
        if (bolmeSayisi > 1) {
          urunler.add({
            'kod': 'KAP.ORT.$kutuOlcusu',
            'adet': bolmeSayisi - 1,
            'ad': 'Orta Kapak (Alüminyum)',
          });
          urunler.add({
            'kod': 'VID.3X19.001',
            'adet': (bolmeSayisi - 1) * 4,
            'ad': 'Vida (İlave Bölme)',
          });
        }
        break;

      case KutuTipi.monoblok:
      // 2x Kutu Kapak + Alt + Üst + Bitiş Çıtası + Yan + Dış + 51x600 Kıl Fitil + 12 Vida
        urunler.addAll([
          {'kod': 'KAP.KUT.$kutuOlcusu', 'adet': 2, 'ad': 'Kutu Kapak'},
          {'kod': 'KAP.ALT.$kutuOlcusu', 'adet': 1, 'ad': 'Alt Kapak'},
          {'kod': 'KAP.UST.$kutuOlcusu', 'adet': 1, 'ad': 'Üst Kapak'},
          {'kod': 'CIT.BIT.$kutuOlcusu', 'adet': 1, 'ad': 'Bitiş Çıtası'},
          {'kod': 'KAP.YAN.$kutuOlcusu', 'adet': 1, 'ad': 'Yan Kapak'},
          {'kod': 'KAP.DIS.$kutuOlcusu', 'adet': 1, 'ad': 'Dış Kapama'},
          {'kod': 'FTL.051.600.001', 'adet': 1, 'ad': '51x600 Kıl Fitil'},
          {'kod': 'VID.4X30.001', 'adet': 12, 'ad': 'Vida (4x30)'},
        ]);
        break;

      case KutuTipi.kopukKutu:
      // Gövde + Yan Kapak + Vida (plastik:4, saç:8) - tek parça üretim
        urunler.addAll([
          {'kod': 'KPK.GOV.$kutuOlcusu', 'adet': 1, 'ad': 'Köpük Kutu Gövde'},
          {'kod': 'KAP.YAN.PLT.$kutuOlcusu', 'adet': 1, 'ad': 'Yan Kapak (Plastik)'},
          {'kod': 'VID.PLT.001', 'adet': 4, 'ad': 'Vida (Plastik Kapak)'},
        ]);
        break;

      case KutuTipi.gizli:
        urunler.add({'kod': 'GZL.KIT.$kutuOlcusu', 'adet': 1, 'ad': 'Gizli Kutu Kiti'});
        break;
    }
    return urunler;
  }

  // ─── 13. BORU AKSESUARİ HESAPLAMA ───────────────────────────────────────
  static List<Map<String, dynamic>> boruAksesuariHesapla({
    required KutuTipi kutuTipi,
    required PanjurTipi panjurTipi,
    required String boruCapi,
  }) {
    final List<Map<String, dynamic>> urunler = [];

    if (boruCapi == '70') {
      // 70'lik sabit parçalar - kutu tipi fark etmez
      urunler.addAll([
        {'kod': 'BRB.070.ALU.001', 'adet': 1, 'ad': '70 Alüminyum Pimli Boru Başı'},
        {'kod': 'RLM.042.001', 'adet': 1, 'ad': '42 mm Rulman'},
        {'kod': 'RLY.042.001', 'adet': 1, 'ad': '42 mm Rulman Yatağı'},
      ]);
      // Kasnak YOKTUR 70'likte
      return urunler;
    }

    // Diğer çaplar
    if (kutuTipi.rulmanliParca) {
      // Dıştan, Gizli, Köpük → Rulmanlı
      if (panjurTipi == PanjurTipi.motorlu) {
        urunler.add({'kod': 'BRB.$boruCapi.RLM.001', 'adet': 1, 'ad': '$boruCapi\'lık Rulmanlı Boru Başı'});
      } else {
        urunler.addAll([
          {'kod': 'KSN.$boruCapi.RLM.001', 'adet': 1, 'ad': '$boruCapi\'lık Rulmanlı Kasnak'},
          {'kod': 'BRB.$boruCapi.RLM.001', 'adet': 1, 'ad': '$boruCapi\'lık Rulmanlı Boru Başı'},
        ]);
      }
      urunler.add({'kod': 'RLM.028.001', 'adet': 1, 'ad': '28 mm Rulman'});
    } else {
      // Monoblok → Pimli
      if (panjurTipi == PanjurTipi.motorlu) {
        urunler.add({'kod': 'BRB.$boruCapi.PIM.001', 'adet': 1, 'ad': '$boruCapi\'lık Pimli Boru Başı'});
      } else {
        urunler.addAll([
          {'kod': 'KSN.$boruCapi.PIM.001', 'adet': 1, 'ad': '$boruCapi\'lık Pimli Kasnak'},
          {'kod': 'BRB.$boruCapi.PIM.001', 'adet': 1, 'ad': '$boruCapi\'lık Pimli Boru Başı'},
        ]);
      }
    }
    return urunler;
  }

  // ─── 14. MAKASLIII SİSTEM EK DONANIM ────────────────────────────────────
  static List<Map<String, dynamic>> makasEkDonanim({required int toplamEnMm}) {
    return [
      {'kod': 'MAK.TAK.001', 'adet': 1, 'ad': 'Makas Takımı'},
      {'kod': 'MEN.001', 'adet': 2, 'ad': 'Menteşe'},
      {
        'kod': 'KSB.20X50.001',
        'adet': (toplamEnMm / 1000 * 10).ceil(), // en ölçüsü kadar
        'ad': '20x50 Köşebent',
      },
      {'kod': 'PRF.PAU.001', 'adet': 1, 'ad': 'Pano U Profili'},
    ];
  }

  // ─── 15. PANO HESAPLAMA ──────────────────────────────────────────────────
  static Map<String, dynamic> panoPozHesapla({
    required int toplamEnMm,
    required int toplamBoyMm,
    required LamelTipi lamelTipi,
    required int netLamelEniMm,
    required String dikmeTipi,
    required int dikmeDusumu,
  }) {
    // Motor/boru/makara/tapa/zımba İPTAL
    // Askı HESAPLANIR
    final int askiAdeti = askiAdetiHesapla(
      netLamelEniMm: netLamelEniMm,
      lamelTipi: lamelTipi,
    );

    // Kesim formülü
    int lamelKesimEni;
    bool fitilHesapla;
    if (dikmeTipi.contains('Pano U') || dikmeTipi.contains('Geniş Pano U')) {
      lamelKesimEni = toplamEnMm - 1; // -0.6 mm (yaklaşık)
      fitilHesapla = false; // Pano U'da fitil kanalı yok
    } else {
      lamelKesimEni = toplamEnMm - dikmeDusumu - 10; // 10mm tapa boşluk payı
      fitilHesapla = true;
    }

    final double panoDikmeMetraj = panoDikmeMetrajHesapla(
      enMm: toplamEnMm, boyMm: toplamBoyMm,
    );

    return {
      'lamelKesimEni': lamelKesimEni,
      'askiAdeti': askiAdeti,
      'fitilHesapla': fitilHesapla,
      'panoDikmeMetraj': panoDikmeMetraj,
    };
  }
}