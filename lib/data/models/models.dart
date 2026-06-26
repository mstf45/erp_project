// lib/data/models/models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

// Güvenli double çevirici (Firebase çökmelerini engeller)
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// ════════════════════════════════════════════════════════════
// STOK KARTI MODELİ
// ════════════════════════════════════════════════════════════
class StokKarti {
  final String id;
  final String stokKodu;
  final String stokAdi;
  final String urunGrubu;
  final String marka;
  final String renk;
  final String stokTakipBirimi;
  final double minimumStok;
  final double alisFiyati;
  final String paraBirimi;
  final double kdvOrani;
  final double standartProfilBoyu;
  final double urunGenisligi;
  final double urunYuksekligi;
  final double urunKalinligi;
  final double birimAgirlik;
  final String ambalajTipi;
  final double paketIciMiktar;
  final double toplamPaketAgirligi;
  final double maxKullanimEni;
  final double maxKullanimYuksekligi;
  final String uyumluTapaTipi;
  final double? motorTorku;
  final double? kaldirmaKapasitesi;
  final double? dikmeDusumPayi;
  final double? uzunluk;
  final double? genislik;
  final bool rengeGoreDegisir;
  final String kokKod;
  final bool aktif;
  final double mevcutStok;
  final double? satisKarMarji;
  final double? transitKarMarji;

  const StokKarti({
    required this.id,
    required this.stokKodu,
    required this.stokAdi,
    required this.urunGrubu,
    this.marka = '',
    this.renk = '',
    this.stokTakipBirimi = 'Adet',
    this.minimumStok = 0,
    this.alisFiyati = 0,
    this.paraBirimi = 'TRY',
    this.kdvOrani = 20,
    this.standartProfilBoyu = 0,
    this.urunGenisligi = 0,
    this.urunYuksekligi = 0,
    this.urunKalinligi = 0,
    this.birimAgirlik = 0,
    this.ambalajTipi = '',
    this.paketIciMiktar = 0,
    this.toplamPaketAgirligi = 0,
    this.maxKullanimEni = 0,
    this.maxKullanimYuksekligi = 0,
    this.uyumluTapaTipi = '',
    this.motorTorku,
    this.kaldirmaKapasitesi,
    this.dikmeDusumPayi,
    this.uzunluk,
    this.genislik,
    this.rengeGoreDegisir = false,
    this.kokKod = '',
    this.aktif = true,
    this.mevcutStok = 0,
    this.satisKarMarji,
    this.transitKarMarji,
  });

  factory StokKarti.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StokKarti(
      id: doc.id,
      stokKodu: d['stokKodu'] ?? '',
      stokAdi: d['stokAdi'] ?? '',
      urunGrubu: d['urunGrubu'] ?? '',
      marka: d['marka'] ?? '',
      renk: d['renk'] ?? '',
      stokTakipBirimi: d['stokTakipBirimi'] ?? 'Adet',
      minimumStok: _parseDouble(d['minimumStok']),
      alisFiyati: _parseDouble(d['alisFiyati']),
      paraBirimi: d['paraBirimi'] ?? 'TRY',
      kdvOrani: _parseDouble(d['kdvOrani']),
      standartProfilBoyu: _parseDouble(d['standartProfilBoyu']),
      urunGenisligi: _parseDouble(d['urunGenisligi']),
      urunYuksekligi: _parseDouble(d['urunYuksekligi']),
      urunKalinligi: _parseDouble(d['urunKalinligi']),
      birimAgirlik: _parseDouble(d['birimAgirlik']),
      ambalajTipi: d['ambalajTipi'] ?? '',
      paketIciMiktar: _parseDouble(d['paketIciMiktar']),
      toplamPaketAgirligi: _parseDouble(d['toplamPaketAgirligi']),
      maxKullanimEni: _parseDouble(d['maxKullanimEni']),
      maxKullanimYuksekligi: _parseDouble(d['maxKullanimYuksekligi']),
      uyumluTapaTipi: d['uyumluTapaTipi'] ?? '',
      motorTorku: d['motorTorku'] != null ? _parseDouble(d['motorTorku']) : null,
      kaldirmaKapasitesi: d['kaldirmaKapasitesi'] != null ? _parseDouble(d['kaldirmaKapasitesi']) : null,
      dikmeDusumPayi: d['dikmeDusumPayi'] != null ? _parseDouble(d['dikmeDusumPayi']) : null,
      uzunluk: d['uzunluk'] != null ? _parseDouble(d['uzunluk']) : null,
      genislik: d['genislik'] != null ? _parseDouble(d['genislik']) : null,
      rengeGoreDegisir: d['rengeGoreDegisir'] ?? false,
      kokKod: d['kokKod'] ?? '',
      aktif: d['aktif'] ?? true,
      mevcutStok: _parseDouble(d['mevcutStok']),
      satisKarMarji: d['satisKarMarji'] != null ? _parseDouble(d['satisKarMarji']) : null,
      transitKarMarji: d['transitKarMarji'] != null ? _parseDouble(d['transitKarMarji']) : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'stokKodu': stokKodu,
    'stokAdi': stokAdi,
    'urunGrubu': urunGrubu,
    'marka': marka,
    'renk': renk,
    'stokTakipBirimi': stokTakipBirimi,
    'minimumStok': minimumStok,
    'alisFiyati': alisFiyati,
    'paraBirimi': paraBirimi,
    'kdvOrani': kdvOrani,
    'standartProfilBoyu': standartProfilBoyu,
    'urunGenisligi': urunGenisligi,
    'urunYuksekligi': urunYuksekligi,
    'urunKalinligi': urunKalinligi,
    'birimAgirlik': birimAgirlik,
    'ambalajTipi': ambalajTipi,
    'paketIciMiktar': paketIciMiktar,
    'toplamPaketAgirligi': toplamPaketAgirligi,
    'maxKullanimEni': maxKullanimEni,
    'maxKullanimYuksekligi': maxKullanimYuksekligi,
    'uyumluTapaTipi': uyumluTapaTipi,
    'motorTorku': motorTorku,
    'kaldirmaKapasitesi': kaldirmaKapasitesi,
    'dikmeDusumPayi': dikmeDusumPayi,
    'uzunluk': uzunluk,
    'genislik': genislik,
    'rengeGoreDegisir': rengeGoreDegisir,
    'kokKod': kokKod,
    'aktif': aktif,
    'mevcutStok': mevcutStok,
    'satisKarMarji': satisKarMarji,
    'transitKarMarji': transitKarMarji,
  };

  StokKarti copyWith({
    double? mevcutStok,
    double? alisFiyati,
    bool? aktif,
  }) => StokKarti(
    id: id, stokKodu: stokKodu, stokAdi: stokAdi, urunGrubu: urunGrubu,
    marka: marka, renk: renk, stokTakipBirimi: stokTakipBirimi,
    minimumStok: minimumStok, alisFiyati: alisFiyati ?? this.alisFiyati,
    paraBirimi: paraBirimi, kdvOrani: kdvOrani,
    standartProfilBoyu: standartProfilBoyu, urunGenisligi: urunGenisligi,
    urunYuksekligi: urunYuksekligi, urunKalinligi: urunKalinligi,
    birimAgirlik: birimAgirlik, ambalajTipi: ambalajTipi,
    paketIciMiktar: paketIciMiktar, toplamPaketAgirligi: toplamPaketAgirligi,
    maxKullanimEni: maxKullanimEni, maxKullanimYuksekligi: maxKullanimYuksekligi,
    uyumluTapaTipi: uyumluTapaTipi, motorTorku: motorTorku,
    kaldirmaKapasitesi: kaldirmaKapasitesi, dikmeDusumPayi: dikmeDusumPayi,
    uzunluk: uzunluk, genislik: genislik, rengeGoreDegisir: rengeGoreDegisir,
    kokKod: kokKod, aktif: aktif ?? this.aktif,
    mevcutStok: mevcutStok ?? this.mevcutStok,
    satisKarMarji: satisKarMarji, transitKarMarji: transitKarMarji,
  );
}

// ════════════════════════════════════════════════════════════
// REÇETE (BOM) MODELİ
// ════════════════════════════════════════════════════════════
class ReceteSatiri {
  final String id;
  final String anaUrunKodu;
  final String kokKod;
  final String stokAdi;
  final bool rengeGoreDegisir;
  final String miktarFormulu;
  final String receteDurumu;
  final List<ReceteSatiri> altRecete;

  const ReceteSatiri({
    required this.id,
    required this.anaUrunKodu,
    required this.kokKod,
    required this.stokAdi,
    this.rengeGoreDegisir = false,
    required this.miktarFormulu,
    this.receteDurumu = 'Varsayılan',
    this.altRecete = const [],
  });

  factory ReceteSatiri.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReceteSatiri(
      id: doc.id,
      anaUrunKodu: d['anaUrunKodu'] ?? '',
      kokKod: d['kokKod'] ?? '',
      stokAdi: d['stokAdi'] ?? '',
      rengeGoreDegisir: d['rengeGoreDegisir'] ?? false,
      miktarFormulu: d['miktarFormulu'] ?? '1',
      receteDurumu: d['receteDurumu'] ?? 'Varsayılan',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'anaUrunKodu': anaUrunKodu,
    'kokKod': kokKod,
    'stokAdi': stokAdi,
    'rengeGoreDegisir': rengeGoreDegisir,
    'miktarFormulu': miktarFormulu,
    'receteDurumu': receteDurumu,
  };
}

// ════════════════════════════════════════════════════════════
// BÖLME MODELİ
// ════════════════════════════════════════════════════════════
class Bolme {
  final int bolmeNo;
  int enMm;
  int boyMm;
  PanjurTipi? panjurTipi;
  String? yanDikme;
  String? ortaDikme;
  OrtaDikmeTipi ortaDikmeTipi;
  bool ilaveLamel;
  int ilaveLamelAdet;
  int gozluLamelAdet;
  bool polikarbon;

  int netDikmeBoy;
  int netLamelEni;
  int lamelAdeti;
  int tapaAdeti;
  int askiAdeti;
  int zimbaAdeti;

  Bolme({
    required this.bolmeNo,
    this.enMm = 0,
    this.boyMm = 0,
    this.panjurTipi,
    this.yanDikme,
    this.ortaDikme,
    this.ortaDikmeTipi = OrtaDikmeTipi.pasif,
    this.ilaveLamel = false,
    this.ilaveLamelAdet = 0,
    this.gozluLamelAdet = 0,
    this.polikarbon = false,
    this.netDikmeBoy = 0,
    this.netLamelEni = 0,
    this.lamelAdeti = 0,
    this.tapaAdeti = 0,
    this.askiAdeti = 0,
    this.zimbaAdeti = 0,
  });

  Map<String, dynamic> toMap() => {
    'bolmeNo': bolmeNo,
    'enMm': enMm,
    'boyMm': boyMm,
    'panjurTipi': panjurTipi?.name,
    'yanDikme': yanDikme,
    'ortaDikme': ortaDikme,
    'ortaDikmeTipi': ortaDikmeTipi.name,
    'ilaveLamel': ilaveLamel,
    'ilaveLamelAdet': ilaveLamelAdet,
    'gozluLamelAdet': gozluLamelAdet,
    'polikarbon': polikarbon,
    'netDikmeBoy': netDikmeBoy,
    'netLamelEni': netLamelEni,
    'lamelAdeti': lamelAdeti,
    'tapaAdeti': tapaAdeti,
    'askiAdeti': askiAdeti,
    'zimbaAdeti': zimbaAdeti,
  };

  factory Bolme.fromMap(Map<String, dynamic> d, int no) => Bolme(
    bolmeNo: no,
    enMm: d['enMm'] ?? 0,
    boyMm: d['boyMm'] ?? 0,
    panjurTipi: d['panjurTipi'] != null
        ? PanjurTipi.values.firstWhere((e) => e.name == d['panjurTipi'])
        : null,
    yanDikme: d['yanDikme'],
    ortaDikme: d['ortaDikme'],
    ortaDikmeTipi: OrtaDikmeTipi.values.firstWhere((e) => e.name == (d['ortaDikmeTipi'] ?? 'pasif')),
    ilaveLamel: d['ilaveLamel'] ?? false,
    ilaveLamelAdet: d['ilaveLamelAdet'] ?? 0,
    gozluLamelAdet: d['gozluLamelAdet'] ?? 0,
    polikarbon: d['polikarbon'] ?? false,
    netDikmeBoy: d['netDikmeBoy'] ?? 0,
    netLamelEni: d['netLamelEni'] ?? 0,
    lamelAdeti: d['lamelAdeti'] ?? 0,
    tapaAdeti: d['tapaAdeti'] ?? 0,
    askiAdeti: d['askiAdeti'] ?? 0,
    zimbaAdeti: d['zimbaAdeti'] ?? 0,
  );
}

// ════════════════════════════════════════════════════════════
// SİPARİŞ POZ MODELİ
// ════════════════════════════════════════════════════════════
class SiparisPoz {
  final String id;
  String renk;
  String ozelRenk;
  PanjurTipi panjurTipi;
  KutuTipi? kutuTipi;
  String kutuOlcusu;
  LamelTipi lamelTipi;
  bool lamelSinirKaldir;
  String motorMarkasi;
  String motorTipi;
  EnOlcuOpsiyonu enOlcuOpsiyonu;
  BoyOlcuOpsiyonu boyOlcuOpsiyonu;
  int bolmeSayisi;
  List<Bolme> bolmeler;
  int ilaveBoyMm;
  String siparisNotu;
  String teknikNot;
  String uretimNotu;
  String urunKitiSecimi;
  List<HesaplananUrun> hesaplananUrunler;
  double? karMarji;
  double? iskonto;
  bool transitSatis;
  int siraNo;

  SiparisPoz({
    required this.id,
    this.renk = '',
    this.ozelRenk = '',
    this.panjurTipi = PanjurTipi.motorlu,
    this.kutuTipi,
    this.kutuOlcusu = '',
    this.lamelTipi = LamelTipi.mm55,
    this.lamelSinirKaldir = false,
    this.motorMarkasi = '',
    this.motorTipi = '',
    this.enOlcuOpsiyonu = EnOlcuOpsiyonu.dikmeDahil,
    this.boyOlcuOpsiyonu = BoyOlcuOpsiyonu.kutuDahil,
    this.bolmeSayisi = 1,
    List<Bolme>? bolmeler,
    this.ilaveBoyMm = 0,
    this.siparisNotu = '',
    this.teknikNot = '',
    this.uretimNotu = '',
    this.urunKitiSecimi = 'standart',
    List<HesaplananUrun>? hesaplananUrunler,
    this.karMarji,
    this.iskonto,
    this.transitSatis = false,
    this.siraNo = 0,
  })  : bolmeler = bolmeler ?? [Bolme(bolmeNo: 1)],
        hesaplananUrunler = hesaplananUrunler ?? [];

  factory SiparisPoz.fromMap(Map<String, dynamic> d) => SiparisPoz(
    id: d['id'] ?? '',
    renk: d['renk'] ?? '',
    ozelRenk: d['ozelRenk'] ?? '',
    panjurTipi: PanjurTipi.values.firstWhere((e) => e.name == (d['panjurTipi'] ?? 'motorlu')),
    kutuTipi: d['kutuTipi'] != null ? KutuTipi.values.firstWhere((e) => e.name == d['kutuTipi']) : null,
    kutuOlcusu: d['kutuOlcusu'] ?? '',
    lamelTipi: LamelTipi.values.firstWhere((e) => e.name == (d['lamelTipi'] ?? 'mm55')),
    lamelSinirKaldir: d['lamelSinirKaldir'] ?? false,
    motorMarkasi: d['motorMarkasi'] ?? '',
    motorTipi: d['motorTipi'] ?? '',
    enOlcuOpsiyonu: EnOlcuOpsiyonu.values.firstWhere((e) => e.name == (d['enOlcuOpsiyonu'] ?? 'dikmeDahil')),
    boyOlcuOpsiyonu: BoyOlcuOpsiyonu.values.firstWhere((e) => e.name == (d['boyOlcuOpsiyonu'] ?? 'kutuDahil')),
    bolmeSayisi: d['bolmeSayisi'] ?? 1,
    bolmeler: (d['bolmeler'] as List? ?? []).asMap().entries.map((e) => Bolme.fromMap(e.value as Map<String, dynamic>, e.key + 1)).toList(),
    ilaveBoyMm: d['ilaveBoyMm'] ?? 0,
    siparisNotu: d['siparisNotu'] ?? '',
    teknikNot: d['teknikNot'] ?? '',
    uretimNotu: d['uretimNotu'] ?? '',
    urunKitiSecimi: d['urunKitiSecimi'] ?? 'standart',
    karMarji: d['karMarji'] != null ? _parseDouble(d['karMarji']) : null,
    iskonto: d['iskonto'] != null ? _parseDouble(d['iskonto']) : null,
    transitSatis: d['transitSatis'] ?? false,
    siraNo: d['siraNo'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'renk': renk,
    'ozelRenk': ozelRenk,
    'panjurTipi': panjurTipi.name,
    'kutuTipi': kutuTipi?.name,
    'kutuOlcusu': kutuOlcusu,
    'lamelTipi': lamelTipi.name,
    'lamelSinirKaldir': lamelSinirKaldir,
    'motorMarkasi': motorMarkasi,
    'motorTipi': motorTipi,
    'enOlcuOpsiyonu': enOlcuOpsiyonu.name,
    'boyOlcuOpsiyonu': boyOlcuOpsiyonu.name,
    'bolmeSayisi': bolmeSayisi,
    'bolmeler': bolmeler.map((b) => b.toMap()).toList(),
    'ilaveBoyMm': ilaveBoyMm,
    'siparisNotu': siparisNotu,
    'teknikNot': teknikNot,
    'uretimNotu': uretimNotu,
    'urunKitiSecimi': urunKitiSecimi,
    'hesaplananUrunler': hesaplananUrunler.map((h) => h.toMap()).toList(),
    'karMarji': karMarji,
    'iskonto': iskonto,
    'transitSatis': transitSatis,
    'siraNo': siraNo,
  };
}

// ════════════════════════════════════════════════════════════
// HESAPLANAN ÜRÜN (BOM Sonucu)
// ════════════════════════════════════════════════════════════
class HesaplananUrun {
  final String stokKodu;
  final String stokAdi;
  final double miktar;
  final String birim;
  final double alisFiyati;
  final double maliyet;
  final double alisIskontosu;
  final double satisFiyati;
  final double karMarji;
  final double kdvOrani;
  final double kdvliFiyat;
  final double kilogram;
  final double metraj;
  final int? bolmeNo;
  final bool ilaveMalzeme;

  const HesaplananUrun({
    required this.stokKodu,
    required this.stokAdi,
    required this.miktar,
    this.birim = 'Adet',
    this.alisFiyati = 0,
    this.maliyet = 0,
    this.alisIskontosu = 0,
    this.satisFiyati = 0,
    this.karMarji = 0,
    this.kdvOrani = 20,
    this.kdvliFiyat = 0,
    this.kilogram = 0,
    this.metraj = 0,
    this.bolmeNo,
    this.ilaveMalzeme = false,
  });

  Map<String, dynamic> toMap() => {
    'stokKodu': stokKodu,
    'stokAdi': stokAdi,
    'miktar': miktar,
    'birim': birim,
    'alisFiyati': alisFiyati,
    'maliyet': maliyet,
    'alisIskontosu': alisIskontosu,
    'satisFiyati': satisFiyati,
    'karMarji': karMarji,
    'kdvOrani': kdvOrani,
    'kdvliFiyat': kdvliFiyat,
    'kilogram': kilogram,
    'metraj': metraj,
    'bolmeNo': bolmeNo,
    'ilaveMalzeme': ilaveMalzeme,
  };

  factory HesaplananUrun.fromMap(Map<String, dynamic> d) => HesaplananUrun(
    stokKodu: d['stokKodu'] ?? '',
    stokAdi: d['stokAdi'] ?? '',
    miktar: _parseDouble(d['miktar']),
    birim: d['birim'] ?? 'Adet',
    alisFiyati: _parseDouble(d['alisFiyati']),
    maliyet: _parseDouble(d['maliyet']),
    alisIskontosu: _parseDouble(d['alisIskontosu']),
    satisFiyati: _parseDouble(d['satisFiyati']),
    karMarji: _parseDouble(d['karMarji']),
    kdvOrani: _parseDouble(d['kdvOrani'] ?? 20),
    kdvliFiyat: _parseDouble(d['kdvliFiyat']),
    kilogram: _parseDouble(d['kilogram']),
    metraj: _parseDouble(d['metraj']),
    bolmeNo: d['bolmeNo'],
    ilaveMalzeme: d['ilaveMalzeme'] ?? false,
  );
}

// ════════════════════════════════════════════════════════════
// SİPARİŞ / TEKLİF MODELİ
// ════════════════════════════════════════════════════════════
class Siparis {
  final String id;
  final String siparisNo;
  final String musteriAdi;
  final String siparisReferansi;
  final DateTime olusturmaTarihi;
  final String durum;
  final List<SiparisPoz> pozlar;
  final double genelIskonto;
  final String siparisNotu;
  final String createdBy;

  const Siparis({
    required this.id,
    required this.siparisNo,
    required this.musteriAdi,
    this.siparisReferansi = '',
    required this.olusturmaTarihi,
    this.durum = 'taslak',
    this.pozlar = const [],
    this.genelIskonto = 0,
    this.siparisNotu = '',
    this.createdBy = '',
  });

  double get toplamMaliyet => pozlar.fold(0, (s, p) => s + p.hesaplananUrunler.fold(0, (s2, u) => s2 + u.maliyet * u.miktar));
  double get toplamSatisFiyati => pozlar.fold(0, (s, p) => s + p.hesaplananUrunler.fold(0, (s2, u) => s2 + u.satisFiyati * u.miktar));
  double get toplamKdvliFiyat => toplamSatisFiyati * (1 - genelIskonto / 100);
  double get toplamKilo => pozlar.fold(0, (s, p) => s + p.hesaplananUrunler.fold(0, (s2, u) => s2 + u.kilogram * u.miktar));

  factory Siparis.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Siparis(
      id: doc.id,
      siparisNo: d['siparisNo'] ?? '',
      musteriAdi: d['musteriAdi'] ?? '',
      siparisReferansi: d['siparisReferansi'] ?? '',
      olusturmaTarihi: (d['olusturmaTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durum: d['durum'] ?? 'taslak',
      pozlar: (d['pozlar'] as List? ?? []).map((p) => SiparisPoz.fromMap(p as Map<String, dynamic>)).toList(),
      genelIskonto: _parseDouble(d['genelIskonto']),
      siparisNotu: d['siparisNotu'] ?? '',
      createdBy: d['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'siparisNo': siparisNo,
    'musteriAdi': musteriAdi,
    'siparisReferansi': siparisReferansi,
    // DİKKAT: Timestamp.fromDate YERİNE FieldValue.serverTimestamp() KULLANIYORUZ!
    'olusturmaTarihi': FieldValue.serverTimestamp(),
    'durum': durum,
    'pozlar': pozlar.map((p) => p.toMap()).toList(),
    'genelIskonto': genelIskonto,
    'siparisNotu': siparisNotu,
    'createdBy': createdBy,
  };

  Siparis copyWith({
    String? durum,
    List<SiparisPoz>? pozlar,
    double? genelIskonto,
  }) => Siparis(
    id: id, siparisNo: siparisNo, musteriAdi: musteriAdi,
    siparisReferansi: siparisReferansi, olusturmaTarihi: olusturmaTarihi,
    durum: durum ?? this.durum,
    pozlar: pozlar ?? this.pozlar,
    genelIskonto: genelIskonto ?? this.genelIskonto,
    siparisNotu: siparisNotu, createdBy: createdBy,
  );
}

// ════════════════════════════════════════════════════════════
// RENK TANIM MODELİ
// ════════════════════════════════════════════════════════════
class RenkTanim {
  final String id;
  final String renkKodu;
  final String renkAdi;
  final bool ortaDikmeVar;

  const RenkTanim({
    required this.id,
    required this.renkKodu,
    required this.renkAdi,
    this.ortaDikmeVar = true,
  });

  factory RenkTanim.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RenkTanim(
      id: doc.id,
      renkKodu: d['renkKodu'] ?? '',
      renkAdi: d['renkAdi'] ?? '',
      ortaDikmeVar: d['ortaDikmeVar'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'renkKodu': renkKodu,
    'renkAdi': renkAdi,
    'ortaDikmeVar': ortaDikmeVar,
  };
}

class IkameKurali {
  final String id;
  final String urunGrubu;
  final String orijinalKokKod;
  final String birincilIkame;
  final String? ikincilIkame;
  final String? ucunculIkame;

  const IkameKurali({
    required this.id,
    required this.urunGrubu,
    required this.orijinalKokKod,
    required this.birincilIkame,
    this.ikincilIkame,
    this.ucunculIkame,
  });

  factory IkameKurali.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return IkameKurali(
      id: doc.id,
      urunGrubu: d['urunGrubu'] ?? '',
      orijinalKokKod: d['orijinalKokKod'] ?? '',
      birincilIkame: d['birincilIkame'] ?? '',
      ikincilIkame: d['ikincilIkame'],
      ucunculIkame: d['ucunculIkame'],
    );
  }
}

class KapasteMatris {
  final String id;
  final String kutuTipi;
  final String kutuOlcusu;
  final String lamelTipi;
  final String kullanilanBoruCapi;
  final int maxLamelAdeti;

  const KapasteMatris({
    required this.id,
    required this.kutuTipi,
    required this.kutuOlcusu,
    required this.lamelTipi,
    required this.kullanilanBoruCapi,
    required this.maxLamelAdeti,
  });

  factory KapasteMatris.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KapasteMatris(
      id: doc.id,
      kutuTipi: d['kutuTipi'] ?? '',
      kutuOlcusu: d['kutuOlcusu'] ?? '',
      lamelTipi: d['lamelTipi'] ?? '',
      kullanilanBoruCapi: d['kullanilanBoruCapi'] ?? '',
      maxLamelAdeti: d['maxLamelAdeti'] ?? 0,
    );
  }
}