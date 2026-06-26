import 'package:erp_frontend_project/core/utils/calculation_engine.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/models.dart';
import '../../data/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';

final _uuid = const Uuid();

// ════════════════════════════════════════════════════════════
// AUTH PROVIDER
// ════════════════════════════════════════════════════════════
class AuthProvider extends ChangeNotifier {
  final FirebaseService _service;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._service);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _service.mevcutKullanici != null;
  String get userEmail => _service.mevcutKullanici?.email ?? '';

  Future<bool> login(String email, String password) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      await _service.girisYap(email, password);
      _isLoading = false; notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Giriş başarısız.";
      _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() => _service.cikisYap();
}

// ════════════════════════════════════════════════════════════
// ORDER (SİPARİŞ) PROVIDER - Ana İş Mantığı
// ════════════════════════════════════════════════════════════
class SiparisProvider extends ChangeNotifier {
  final FirebaseService _service;
  List<Siparis> _orders = [];

  // İŞTE SENİN YAKALADIĞIN HATANIN ÇÖZÜMÜ!
  // Hesaplama ve Kaydetme işlemlerini AYIRDIK ki UI saçmalamasın.
  bool _isCalculating = false;
  bool _isSaving = false;

  String? _errorMessage;

  String _customerName = '';
  String _orderReference = '';
  String _globalColorCode = '';
  List<SiparisPoz> _positions = [];
  double _globalDiscount = 0;

  SiparisProvider(this._service);

  List<Siparis> get siparisler => _orders;
  bool get hesaplaniyor => _isCalculating; // Sadece hesaplarken döner
  bool get kaydediliyor => _isSaving; // Sadece kaydederken döner
  String? get hata => _errorMessage;
  String get musteriAdi => _customerName;
  String get secilenRenk => _globalColorCode;
  List<SiparisPoz> get pozlar => _positions;
  double get genelIskonto => _globalDiscount;

  void fetchOrdersStream() {
    _service.siparislerStream().listen((list) {
      _orders = list; notifyListeners();
    });
  }

  void updateCustomerName(String name) { _customerName = name; notifyListeners(); }
  void updateOrderReference(String ref) { _orderReference = ref; notifyListeners(); }
  void updateGlobalDiscount(double discount) { _globalDiscount = discount; notifyListeners(); }

  void selectGlobalColor(String colorCode) {
    _globalColorCode = colorCode;
    for (var position in _positions) { position.renk = colorCode; }
    notifyListeners();
  }

  void addNewPosition() {
    _positions.add(SiparisPoz(id: _uuid.v4(), renk: _globalColorCode, siraNo: _positions.length));
    notifyListeners();
  }

  void removePosition(String positionId) {
    _positions.removeWhere((p) => p.id == positionId);
    for (int i = 0; i < _positions.length; i++) { _positions[i].siraNo = i; }
    notifyListeners();
  }

  SiparisPoz? _findPositionById(String id) {
    try { return _positions.firstWhere((p) => p.id == id); } catch (_) { return null; }
  }

  void updatePositionType(String positionId, PanjurTipi type) {
    final position = _findPositionById(positionId);
    if (position == null) return;
    position.panjurTipi = type;
    if (type == PanjurTipi.manuel) { position.motorMarkasi = ''; position.motorTipi = ''; }
    if (type == PanjurTipi.pano) { position.kutuTipi = null; }
    notifyListeners();
  }

  void updateBoxType(String id, KutuTipi? type) { _findPositionById(id)?.kutuTipi = type; notifyListeners(); }
  void updateLamelType(String id, LamelTipi type) { _findPositionById(id)?.lamelTipi = type; notifyListeners(); }

  void updateSegmentCount(String positionId, int count) {
    final position = _findPositionById(positionId);
    if (position == null) return;
    final oldCount = position.bolmeSayisi;
    position.bolmeSayisi = count;
    if (count > oldCount) {
      for (int i = oldCount; i < count; i++) { position.bolmeler.add(Bolme(bolmeNo: i + 1)); }
    } else if (count < oldCount) {
      position.bolmeler = position.bolmeler.sublist(0, count);
    }
    notifyListeners();
  }

  void updateSegmentDimensions(String positionId, int segmentNo, int width, int height) {
    final position = _findPositionById(positionId);
    if (position == null) return;
    final segment = position.bolmeler.firstWhere((b) => b.bolmeNo == segmentNo);
    segment.enMm = width; segment.boyMm = height;
    if (!position.lamelSinirKaldir) {
      position.lamelTipi = CalculationEngine.lamelOtomatikYukselt(
        mevcutLamel: position.lamelTipi, enMm: width, boyMm: height, sinirKaldir: position.lamelSinirKaldir,
      );
    }
    notifyListeners();
  }

  void batchUpdateProperties({String? color, PanjurTipi? panjurType, KutuTipi? boxType, LamelTipi? lamelType}) {
    for (final position in _positions) {
      if (color != null) position.renk = color;
      if (panjurType != null) position.panjurTipi = panjurType;
      if (boxType != null) position.kutuTipi = boxType;
      if (lamelType != null) position.lamelTipi = lamelType;
    }
    notifyListeners();
  }

  // ─── HESAPLAMA (BOM PATLATMA) ───
  Future<void> calculateBillOfMaterials(String positionId) async {
    final position = _findPositionById(positionId);
    if (position == null) return;

    // Sadece Hesaplama animasyonunu tetikliyoruz
    _isCalculating = true; _errorMessage = null; notifyListeners();

    try {
      final generatedItems = <HesaplananUrun>[];
      for (final segment in position.bolmeler) {
        final segmentType = segment.panjurTipi ?? position.panjurTipi;
        final netHeight = CalculationEngine.netDikmeBoyuHesapla(girilenBoy: segment.boyMm, opsiyonu: position.boyOlcuOpsiyonu, kutuPay: 165);
        segment.netDikmeBoy = netHeight;
        final netWidth = CalculationEngine.netLamelEniHesapla(girilenEn: segment.enMm, opsiyonu: position.enOlcuOpsiyonu, sagDikmePay: 44, solDikmePay: 44, tekDikmePay: 44, dikmeDusumu: 44);
        segment.netLamelEni = netWidth;

        if (segmentType == PanjurTipi.pano) {
          final panoResult = CalculationEngine.panoPozHesapla(toplamEnMm: segment.enMm, toplamBoyMm: segment.boyMm, lamelTipi: position.lamelTipi, netLamelEniMm: netWidth, dikmeTipi: segment.yanDikme ?? 'Pano U', dikmeDusumu: 44);
          segment.askiAdeti = panoResult['askiAdeti'];
        } else {
          final lamelCount = CalculationEngine.lamelAdetiHesapla(netDikmeBoy: netHeight, lamelTipi: position.lamelTipi);
          segment.lamelAdeti = lamelCount;
          final tapaCount = CalculationEngine.tapaAdetiHesapla(lamelAdeti: lamelCount, gozluLamel: segment.gozluLamelAdet > 0);
          segment.tapaAdeti = tapaCount; segment.zimbaAdeti = tapaCount;
          final askiCount = CalculationEngine.askiAdetiHesapla(netLamelEniMm: netWidth, lamelTipi: position.lamelTipi);
          segment.askiAdeti = askiCount;

          final colorCode = position.ozelRenk.isNotEmpty ? position.ozelRenk : position.renk;
          final lamelCode = CalculationEngine.stokKoduOlustur(kokKod: 'LAM.0${position.lamelTipi.mm}.', rengeGoreDegisir: true, renkKodu: colorCode);
          final lamelStok = await _service.stokKoduIleGetir(lamelCode);

          generatedItems.add(HesaplananUrun(stokKodu: lamelCode, stokAdi: '${position.lamelTipi.label} Alüminyum Lamel ($colorCode)', miktar: lamelCount.toDouble(), birim: 'Adet', alisFiyati: lamelStok?.alisFiyati ?? 0, bolmeNo: segment.bolmeNo));
          generatedItems.add(HesaplananUrun(stokKodu: 'TAP.0${position.lamelTipi.mm}.PLT.001', stokAdi: '${position.lamelTipi.label} Standart Tapa', miktar: tapaCount.toDouble(), birim: 'Adet', bolmeNo: segment.bolmeNo));
          generatedItems.add(HesaplananUrun(stokKodu: position.lamelTipi == LamelTipi.mm77 ? 'ASK.077.CEL.001' : 'ASK.039.CEL.001', stokAdi: '${position.lamelTipi.label} Çelik Askı', miktar: askiCount.toDouble(), birim: 'Adet', bolmeNo: segment.bolmeNo));
        }

        if (position.kutuTipi != null && segmentType != PanjurTipi.pano) {
          final fitilLength = CalculationEngine.fitilMetrajiHesapla(dikmeBoyu: netHeight, kutuTipi: position.kutuTipi!, ortaDikmeVar: position.bolmeSayisi > 1);
          generatedItems.add(HesaplananUrun(stokKodu: 'FTL.KIL.001', stokAdi: 'Kıl Fitil', miktar: fitilLength, birim: 'Metre', bolmeNo: segment.bolmeNo));
        }
      }

      if (position.kutuTipi != null && position.panjurTipi != PanjurTipi.pano) {
        final boxItems = CalculationEngine.kutuKitiHesapla(kutuTipi: position.kutuTipi!, bolmeSayisi: position.bolmeSayisi, kutuOlcusu: position.kutuOlcusu);
        for (final item in boxItems) { generatedItems.add(HesaplananUrun(stokKodu: item['kod'], stokAdi: item['ad'], miktar: (item['adet'] as int).toDouble())); }
      }

      position.hesaplananUrunler = generatedItems;
    } catch (e, stack) {
      _errorMessage = "Calculation Error: ${e.toString()}";
    } finally {
      // Sadece hesaplamayı kapat
      _isCalculating = false;
      notifyListeners();
    }
  }

  // ─── KAYDETME VE SIFIRLAMA ───
  Future<String?> saveOrder() async {
    if (_customerName.trim().isEmpty) { _errorMessage = 'Müşteri adı zorunludur.'; notifyListeners(); return null; }

    // Sadece Kaydetme animasyonunu tetikliyoruz
    _isSaving = true; notifyListeners();

    try {
      final newOrder = Siparis(
        id: '', siparisNo: '', musteriAdi: _customerName, siparisReferansi: _orderReference,
        olusturmaTarihi: DateTime.now(), pozlar: _positions, genelIskonto: _globalDiscount,
      );
      final id = await _service.siparisOlustur(newOrder);
      _isSaving = false; notifyListeners();
      return id;
    } catch (e, stack) {
      _errorMessage = e.toString();
      _isSaving = false; notifyListeners();
      return null;
    }
  }

  void resetOrderData() {
    _customerName = ''; _orderReference = ''; _globalColorCode = '';
    _positions = []; _globalDiscount = 0; _errorMessage = null;
    notifyListeners();
  }

  double get toplamMaliyet => _positions.fold(0, (s, p) => s + p.hesaplananUrunler.fold(0, (s2, u) => s2 + u.maliyet * u.miktar));
}

// ════════════════════════════════════════════════════════════
// STOK PROVIDER VE NAVIGATION PROVIDER
// ════════════════════════════════════════════════════════════
class StokProvider extends ChangeNotifier {
  final FirebaseService _service;
  List<StokKarti> _stokKartlari = [];
  List<RenkTanim> _renkler = DefaultRenkler.renkler.map((e) => RenkTanim(id: e['kod'].toString(), renkKodu: e['kod'].toString(), renkAdi: e['ad'].toString(), ortaDikmeVar: e['ortaDikmeVar'] as bool)).toList();
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterGroup = '';

  StokProvider(this._service);
  List<StokKarti> get stokKartlari => _stokKartlari;
  List<RenkTanim> get renkler => _renkler;
  bool get yukleniyor => _isLoading;
  List<StokKarti> get filtrelenmisKartlar {
    var list = _stokKartlari;
    if (_searchQuery.isNotEmpty) list = list.where((k) => k.stokAdi.toLowerCase().contains(_searchQuery.toLowerCase()) || k.stokKodu.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (_filterGroup.isNotEmpty) list = list.where((k) => k.urunGrubu == _filterGroup).toList();
    return list;
  }
  List<String> get urunGruplari => _stokKartlari.map((k) => k.urunGrubu).toSet().toList()..sort();
  List<StokKarti> get kritikStoklar => _stokKartlari.where((k) => k.mevcutStok <= k.minimumStok).toList();

  void ara(String query) { _searchQuery = query; notifyListeners(); }
  void filtreGrubu(String group) { _filterGroup = group; notifyListeners(); }
  void stokKartlariDinle() { _service.stokKartlariStream().listen((list) { _stokKartlari = list; notifyListeners(); }); }
  void renklerDinle() { _service.renklerStream().listen((list) { _renkler = list; notifyListeners(); }); }

  Future<void> stokKartiKaydet(StokKarti kart) async {
    _isLoading = true; notifyListeners();
    try {
      if (kart.id.isEmpty) await _service.stokKartiOlustur(kart); else await _service.stokKartiGuncelle(kart);
    } finally { _isLoading = false; notifyListeners(); }
  }
}

class NavigationProvider extends ChangeNotifier {
  String _activeRoute = '/dashboard';
  String get aktifRota => _activeRoute;
  void rotaDegistir(String route) { _activeRoute = route; notifyListeners(); }
}