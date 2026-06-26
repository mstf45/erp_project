// lib/presentation/providers/providers.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/calculation_engine.dart';
import '../../data/models/models.dart';
import '../../data/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';

final _uuid = Uuid();

// ════════════════════════════════════════════════════════════
// AUTH PROVIDER
// ════════════════════════════════════════════════════════════
class AuthProvider extends ChangeNotifier {
  final FirebaseService _service;
  bool _yukleniyor = false;
  String? _hata;

  AuthProvider(this._service);

  bool get yukleniyor => _yukleniyor;
  String? get hata => _hata;
  bool get girisYapti => _service.mevcutKullanici != null;
  String get kullaniciEmail => _service.mevcutKullanici?.email ?? '';

  Future<bool> girisYap(String email, String sifre) async {
    _yukleniyor = true;
    _hata = null;
    notifyListeners();
    try {
      await _service.girisYap(email, sifre);
      _yukleniyor = false;
      notifyListeners();
      return true;
    } catch (e) {
      _hata = _hataMetni(e.toString());
      _yukleniyor = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cikisYap() => _service.cikisYap();

  String _hataMetni(String e) {
    if (e.contains('wrong-password')) return 'Şifre hatalı.';
    if (e.contains('user-not-found')) return 'Kullanıcı bulunamadı.';
    if (e.contains('too-many-requests'))
      return 'Çok fazla deneme. Lütfen bekleyin.';
    return 'Giriş başarısız. Bilgilerinizi kontrol edin.';
  }
}

// ════════════════════════════════════════════════════════════
// SİPARİŞ PROVIDER - Ana iş mantığı
// ════════════════════════════════════════════════════════════
class SiparisProvider extends ChangeNotifier {
  final FirebaseService _service;

  List<Siparis> _siparisler = [];
  Siparis? _aktifSiparis;
  bool _yukleniyor = false;
  String? _hata;

  // Yeni sipariş oluşturma state'i
  String _musteriAdi = '';
  String _siparisReferansi = '';
  String _secilenRenk = '';
  String _ozelRenk = '';
  List<SiparisPoz> _pozlar = [];
  double _genelIskonto = 0;

  SiparisProvider(this._service);

  List<Siparis> get siparisler => _siparisler;
  Siparis? get aktifSiparis => _aktifSiparis;
  bool get yukleniyor => _yukleniyor;
  String? get hata => _hata;
  String get musteriAdi => _musteriAdi;
  String get secilenRenk => _secilenRenk;
  List<SiparisPoz> get pozlar => _pozlar;
  double get genelIskonto => _genelIskonto;

  void siparislerDinle() {
    _service.siparislerStream().listen((liste) {
      _siparisler = liste;
      notifyListeners();
    });
  }

  // ─── Başlık bilgileri
  void musteriAdiGuncelle(String v) {
    _musteriAdi = v;
    notifyListeners();
  }

  void referansGuncelle(String v) {
    _siparisReferansi = v;
    notifyListeners();
  }

  void genelIskontoGuncelle(double v) {
    _genelIskonto = v;
    notifyListeners();
  }

  void renkSec(String renkKodu) {
    _secilenRenk = renkKodu;
    // Tüm pozlara varsayılan rengi ata
    for (var poz in _pozlar) {
      poz.renk = renkKodu;
    }
    notifyListeners();
  }

  // ─── Poz yönetimi
  void yeniPozEkle() {
    final poz = SiparisPoz(
      id: _uuid.v4(),
      renk: _secilenRenk,
      siraNo: _pozlar.length,
    );
    _pozlar.add(poz);
    notifyListeners();
  }

  void pozSil(String pozId) {
    _pozlar.removeWhere((p) => p.id == pozId);
    // Sıra numaralarını yeniden ata
    for (int i = 0; i < _pozlar.length; i++) {
      _pozlar[i].siraNo = i;
    }
    notifyListeners();
  }

  void pozSiraDegistir(int eskiIndex, int yeniIndex) {
    if (yeniIndex > eskiIndex) yeniIndex--;
    final poz = _pozlar.removeAt(eskiIndex);
    _pozlar.insert(yeniIndex, poz);
    for (int i = 0; i < _pozlar.length; i++) {
      _pozlar[i].siraNo = i;
    }
    notifyListeners();
  }

  SiparisPoz? pozBul(String pozId) {
    try {
      return _pozlar.firstWhere((p) => p.id == pozId);
    } catch (_) {
      return null;
    }
  }

  // ─── Poz güncelleme
  void pozPanjurTipiGuncelle(String pozId, PanjurTipi tip) {
    final poz = pozBul(pozId);
    if (poz == null) return;
    poz.panjurTipi = tip;
    // Global kilitler
    if (tip == PanjurTipi.manuel) {
      poz.motorMarkasi = '';
      poz.motorTipi = '';
    }
    if (tip == PanjurTipi.pano) {
      poz.kutuTipi = null;
    }
    notifyListeners();
  }

  void pozKutuTipiGuncelle(String pozId, KutuTipi? tip) {
    final poz = pozBul(pozId);
    if (poz == null) return;
    poz.kutuTipi = tip;
    notifyListeners();
  }

  void pozLamelTipiGuncelle(String pozId, LamelTipi tip) {
    final poz = pozBul(pozId);
    if (poz == null) return;
    poz.lamelTipi = tip;
    notifyListeners();
  }

  void pozBolmeSayisiGuncelle(String pozId, int sayi) {
    final poz = pozBul(pozId);
    if (poz == null) return;
    final eskiSayi = poz.bolmeSayisi;
    poz.bolmeSayisi = sayi;

    if (sayi > eskiSayi) {
      for (int i = eskiSayi; i < sayi; i++) {
        poz.bolmeler.add(Bolme(bolmeNo: i + 1));
      }
    } else if (sayi < eskiSayi) {
      poz.bolmeler = poz.bolmeler.sublist(0, sayi);
    }
    notifyListeners();
  }

  void bolmeOlcuGuncelle(String pozId, int bolmeNo, int en, int boy) {
    final poz = pozBul(pozId);
    if (poz == null) return;
    final bolme = poz.bolmeler.firstWhere((b) => b.bolmeNo == bolmeNo);
    bolme.enMm = en;
    bolme.boyMm = boy;

    // Otomatik lamel yükseltmesi
    if (!poz.lamelSinirKaldir) {
      poz.lamelTipi = CalculationEngine.lamelOtomatikYukselt(
        mevcutLamel: poz.lamelTipi,
        enMm: en,
        boyMm: boy,
        sinirKaldir: poz.lamelSinirKaldir,
      );
    }
    notifyListeners();
  }

  void bolmePanjurTipiGuncelle(String pozId, int bolmeNo, PanjurTipi? tip) {
    final poz = pozBul(pozId);
    if (poz == null) return;
    final bolme = poz.bolmeler.firstWhere((b) => b.bolmeNo == bolmeNo);
    bolme.panjurTipi = tip;
    notifyListeners();
  }

  // ─── Toplu özellik değiştir
  void topluOzellikDegistir({
    String? renk,
    PanjurTipi? panjurTipi,
    KutuTipi? kutuTipi,
    LamelTipi? lamelTipi,
    String? motorMarkasi,
  }) {
    for (final poz in _pozlar) {
      if (renk != null) poz.renk = renk;
      if (panjurTipi != null) poz.panjurTipi = panjurTipi;
      if (kutuTipi != null) poz.kutuTipi = kutuTipi;
      if (lamelTipi != null) poz.lamelTipi = lamelTipi;
      if (motorMarkasi != null) poz.motorMarkasi = motorMarkasi;
    }
    notifyListeners();
  }

  // ─── Hesaplama
  Future<void> hesaplaBomlariniPatlaAt(String pozId) async {
    final poz = pozBul(pozId);
    if (poz == null) return;
    _yukleniyor = true;
    notifyListeners();

    try {
      final urunler = <HesaplananUrun>[];

      for (final bolme in poz.bolmeler) {
        final bolmeTipi = bolme.panjurTipi ?? poz.panjurTipi;

        // Net dikme boyu (kutu payı stoktan gelir, şimdilik 165 default)
        final netBoy = CalculationEngine.netDikmeBoyuHesapla(
          girilenBoy: bolme.boyMm,
          opsiyonu: poz.boyOlcuOpsiyonu,
          kutuPay: 165,
        );
        bolme.netDikmeBoy = netBoy;

        // Net lamel eni (dikme düşümü stoktan gelir, şimdilik 44 default)
        final netEn = CalculationEngine.netLamelEniHesapla(
          girilenEn: bolme.enMm,
          opsiyonu: poz.enOlcuOpsiyonu,
          sagDikmePay: 44,
          solDikmePay: 44,
          tekDikmePay: 44,
          dikmeDusumu: 44,
        );
        bolme.netLamelEni = netEn;

        if (bolmeTipi == PanjurTipi.pano) {
          // Pano hesaplama
          final panoSonuc = CalculationEngine.panoPozHesapla(
            toplamEnMm: bolme.enMm,
            toplamBoyMm: bolme.boyMm,
            lamelTipi: poz.lamelTipi,
            netLamelEniMm: netEn,
            dikmeTipi: bolme.yanDikme ?? 'Pano U',
            dikmeDusumu: 44,
          );
          bolme.askiAdeti = panoSonuc['askiAdeti'];
        } else {
          // Normal lamel hesaplama
          final lamelAdeti = CalculationEngine.lamelAdetiHesapla(
            netDikmeBoy: netBoy,
            lamelTipi: poz.lamelTipi,
          );
          bolme.lamelAdeti = lamelAdeti;

          final tapaAdeti = CalculationEngine.tapaAdetiHesapla(
            lamelAdeti: lamelAdeti,
            gozluLamel: bolme.gozluLamelAdet > 0,
          );
          bolme.tapaAdeti = tapaAdeti;
          bolme.zimbaAdeti = tapaAdeti;

          final askiAdeti = CalculationEngine.askiAdetiHesapla(
            netLamelEniMm: netEn,
            lamelTipi: poz.lamelTipi,
          );
          bolme.askiAdeti = askiAdeti;

          // Lamel ürünü
          final renkKodu = poz.ozelRenk.isNotEmpty ? poz.ozelRenk : poz.renk;
          final lamelKodu = CalculationEngine.stokKoduOlustur(
            // CalculationEngine
            kokKod: 'LAM.0${poz.lamelTipi.mm}.',
            rengeGoreDegisir: true,
            renkKodu: renkKodu,
          );

          final lamelStok = await _service.stokKoduIleGetir(lamelKodu);

          urunler.add(
            HesaplananUrun(
              stokKodu: lamelKodu,
              stokAdi: '${poz.lamelTipi.label} Alüminyum Lamel ($renkKodu)',
              miktar: lamelAdeti.toDouble(),
              birim: 'Adet',
              alisFiyati: lamelStok?.alisFiyati ?? 0,
              bolmeNo: bolme.bolmeNo,
            ),
          );

          // Tapa
          urunler.add(
            HesaplananUrun(
              stokKodu: 'TAP.0${poz.lamelTipi.mm}.PLT.001',
              stokAdi: '${poz.lamelTipi.label} Standart Tapa',
              miktar: tapaAdeti.toDouble(),
              birim: 'Adet',
              bolmeNo: bolme.bolmeNo,
            ),
          );

          // Askı
          urunler.add(
            HesaplananUrun(
              stokKodu: poz.lamelTipi == LamelTipi.mm77
                  ? 'ASK.077.CEL.001'
                  : 'ASK.039.CEL.001',
              stokAdi: '${poz.lamelTipi.label} Çelik Askı',
              miktar: askiAdeti.toDouble(),
              birim: 'Adet',
              bolmeNo: bolme.bolmeNo,
            ),
          );
        }

        // Fitil
        if (poz.kutuTipi != null && bolmeTipi != PanjurTipi.pano) {
          final fitilMetraj = CalculationEngine.fitilMetrajiHesapla(
            dikmeBoyu: netBoy,
            kutuTipi: poz.kutuTipi!,
            ortaDikmeVar: poz.bolmeSayisi > 1,
          );
          urunler.add(
            HesaplananUrun(
              stokKodu: 'FTL.KIL.001',
              stokAdi: 'Kıl Fitil',
              miktar: fitilMetraj,
              birim: 'Metre',
              bolmeNo: bolme.bolmeNo,
            ),
          );
        }
      }

      // Kutu kiti
      if (poz.kutuTipi != null && poz.panjurTipi != PanjurTipi.pano) {
        final kutuUrunler = CalculationEngine.kutuKitiHesapla(
          kutuTipi: poz.kutuTipi!,
          bolmeSayisi: poz.bolmeSayisi,
          kutuOlcusu: poz.kutuOlcusu,
        );
        for (final u in kutuUrunler) {
          urunler.add(
            HesaplananUrun(
              stokKodu: u['kod'],
              stokAdi: u['ad'],
              miktar: (u['adet'] as int).toDouble(),
            ),
          );
        }
      }

      // Makaslı ek donanım
      if (poz.panjurTipi == PanjurTipi.makasli) {
        final toplamEn = poz.bolmeler.fold(0, (s, b) => s + b.enMm);
        final makasUrunler = CalculationEngine.makasEkDonanim(
          toplamEnMm: toplamEn,
        );
        for (final u in makasUrunler) {
          urunler.add(
            HesaplananUrun(
              stokKodu: u['kod'],
              stokAdi: u['ad'],
              miktar: (u['adet'] as int).toDouble(),
            ),
          );
        }
      }

      poz.hesaplananUrunler = urunler;
    } catch (e) {
      _hata = e.toString();
    }

    _yukleniyor = false;
    notifyListeners();
  }

  // ─── Kaydetme
  Future<String?> siparisKaydet() async {
    if (_musteriAdi.isEmpty) {
      _hata = 'Müşteri adı zorunludur.';
      notifyListeners();
      return null;
    }
    _yukleniyor = true;
    notifyListeners();

    try {
      final siparis = Siparis(
        id: '',
        siparisNo: '',
        musteriAdi: _musteriAdi,
        siparisReferansi: _siparisReferansi,
        olusturmaTarihi: DateTime.now(),
        pozlar: _pozlar,
        genelIskonto: _genelIskonto,
      );
      final id = await _service.siparisOlustur(siparis);
      _yukleniyor = false;
      notifyListeners();
      return id;
    } catch (e) {
      _hata = e.toString();
      _yukleniyor = false;
      notifyListeners();
      return null;
    }
  }

  void sifirla() {
    _musteriAdi = '';
    _siparisReferansi = '';
    _secilenRenk = '';
    _ozelRenk = '';
    _pozlar = [];
    _genelIskonto = 0;
    _hata = null;
    notifyListeners();
  }

  // Toplamlar
  double get toplamMaliyet => _pozlar.fold(
    0,
    (s, p) =>
        s + p.hesaplananUrunler.fold(0, (s2, u) => s2 + u.maliyet * u.miktar),
  );
}

// ════════════════════════════════════════════════════════════
// STOK PROVIDER
// ════════════════════════════════════════════════════════════
class StokProvider extends ChangeNotifier {
  final FirebaseService _service;
  List<StokKarti> _stokKartlari = [];
  List<RenkTanim> _renkler = [];
  bool _yukleniyor = false;
  String _aramaMetni = '';
  String _filtreGrubu = '';

  StokProvider(this._service);

  List<StokKarti> get stokKartlari => _stokKartlari;
  List<RenkTanim> get renkler => _renkler;
  bool get yukleniyor => _yukleniyor;

  List<StokKarti> get filtrelenmisKartlar {
    var liste = _stokKartlari;
    if (_aramaMetni.isNotEmpty) {
      liste = liste
          .where(
            (k) =>
                k.stokAdi.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
                k.stokKodu.toLowerCase().contains(_aramaMetni.toLowerCase()),
          )
          .toList();
    }
    if (_filtreGrubu.isNotEmpty) {
      liste = liste.where((k) => k.urunGrubu == _filtreGrubu).toList();
    }
    return liste;
  }

  List<String> get urunGruplari =>
      _stokKartlari.map((k) => k.urunGrubu).toSet().toList()..sort();

  List<StokKarti> get kritikStoklar =>
      _stokKartlari.where((k) => k.mevcutStok <= k.minimumStok).toList();

  void ara(String metin) {
    _aramaMetni = metin;
    notifyListeners();
  }

  void filtreGrubu(String grup) {
    _filtreGrubu = grup;
    notifyListeners();
  }

  void stokKartlariDinle() {
    _service.stokKartlariStream().listen((liste) {
      _stokKartlari = liste;
      notifyListeners();
    });
  }

  void renklerDinle() {
    _service.renklerStream().listen((liste) {
      _renkler = liste;
      notifyListeners();
    });
  }

  Future<void> stokKartiKaydet(StokKarti kart) async {
    _yukleniyor = true;
    notifyListeners();
    try {
      if (kart.id.isEmpty) {
        await _service.stokKartiOlustur(kart);
      } else {
        await _service.stokKartiGuncelle(kart);
      }
    } finally {
      _yukleniyor = false;
      notifyListeners();
    }
  }

  Future<void> renkEkle(RenkTanim renk) async {
    await _service.renkEkle(renk);
  }

  Future<void> renkGuncelle(RenkTanim renk) async {
    await _service.renkGuncelle(renk);
  }

  RenkTanim? renkKoduIleGetir(String kod) {
    try {
      return _renkler.firstWhere((r) => r.renkKodu == kod);
    } catch (_) {
      return null;
    }
  }
}

// ════════════════════════════════════════════════════════════
// NAVIGATION PROVIDER
// ════════════════════════════════════════════════════════════
class NavigationProvider extends ChangeNotifier {
  String _aktifRota = '/dashboard';

  String get aktifRota => _aktifRota;

  void rotaDegistir(String rota) {
    _aktifRota = rota;
    notifyListeners();
  }
}
