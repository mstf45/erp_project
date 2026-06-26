import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../../core/utils/app_logger.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── VERİ DEZENFEKTANI (WEB ÇÖKMELERİNİ ÖNLER) ───
  dynamic _sanitize(dynamic value) {
    if (value is num) {
      if (value.isNaN || value.isInfinite) return 0;
      return value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitize(v)));
    }
    if (value is Iterable) {
      return value.map((e) => _sanitize(e)).toList();
    }
    return value;
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────
  Future<UserCredential> girisYap(String email, String sifre) =>
      _auth.signInWithEmailAndPassword(email: email, password: sifre);

  Future<void> cikisYap() => _auth.signOut();
  User? get mevcutKullanici => _auth.currentUser;
  Stream<User?> get authDurumu => _auth.authStateChanges();

  // ─── SİPARİŞLER ─────────────────────────────────────────────────────────
  CollectionReference get _siparisler => _db.collection('siparisler');

  Stream<List<Siparis>> siparislerStream({String? durum}) {
    Query q = _siparisler.orderBy('olusturmaTarihi', descending: true);
    if (durum != null) q = q.where('durum', isEqualTo: durum);
    return q.snapshots().map((s) => s.docs.map((d) => Siparis.fromFirestore(d)).toList());
  }

  Future<String> siparisOlustur(Siparis siparis) async {
    try {
      final no = await _siparisNoUret();

      final yeniSiparis = Siparis(
        id: '',
        siparisNo: no,
        musteriAdi: siparis.musteriAdi,
        siparisReferansi: siparis.siparisReferansi,
        olusturmaTarihi: DateTime.now(),
        durum: 'taslak',
        pozlar: siparis.pozlar,
        genelIskonto: siparis.genelIskonto,
        siparisNotu: siparis.siparisNotu,
        createdBy: mevcutKullanici?.uid ?? '',
      );

      // JSON'u al ve DEZENFEKTE ET (Bütün Infinity ve NaN değerleri temizlenir)
      final rawData = yeniSiparis.toFirestore();
      final safeData = _sanitize(rawData);

      // ─── İŞTE BURASI: GİDEN VERİYİ TERMİNALE YAZDIRIYORUZ ───
      AppLogger.info("====== FİREBASE'E GÖNDERİLECEK HAM VERİ (PAYLOAD) ======");
      AppLogger.debug(safeData.toString());
      AppLogger.info("==========================================================");

      final ref = await _siparisler.add(safeData);

      AppLogger.info("✅ Firebase Kaydı BAŞARILI! Yeni Doküman ID: ${ref.id}");
      return ref.id;
    } catch (e, stack) {
      AppLogger.error("❌ Firestore Kayıt (Add) işlemi başarısız!", e, stack);
      rethrow;
    }
  }

  Future<void> siparisGuncelle(Siparis siparis) =>
      _siparisler.doc(siparis.id).update(_sanitize(siparis.toFirestore()));

  Future<void> siparisSil(String id) => _siparisler.doc(id).delete();

  Future<Siparis?> siparisBul(String id) async {
    final doc = await _siparisler.doc(id).get();
    if (!doc.exists) return null;
    return Siparis.fromFirestore(doc);
  }

  // ─── WEB İÇİN ÇÖKMEYEN SİPARİŞ NO ÜRETİCİ (TRANSACTION SİLİNDİ) ───
  Future<String> _siparisNoUret() async {
    try {
      final yil = DateTime.now().year.toString();
      final sayacRef = _db.collection('sayaclar').doc('siparisNo');

      await sayacRef.set({yil: FieldValue.increment(1)}, SetOptions(merge: true));
      final snap = await sayacRef.get();
      final data = snap.data() as Map<String, dynamic>?;

      int mevcut = 1;
      if (data != null && data[yil] != null) {
        mevcut = (data[yil] as num).toInt();
      }

      return 'PNJ-$yil-${mevcut.toString().padLeft(4, '0')}';
    } catch (e, stack) {
      AppLogger.error("Sipariş No Üretme Hatası", e, stack);
      final fallbackId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      return 'PNJ-${DateTime.now().year}-$fallbackId';
    }
  }

  // ─── STOK KARTLARI ──────────────────────────────────────────────────────
  CollectionReference get _stokKartlari => _db.collection('stokKartlari');

  Stream<List<StokKarti>> stokKartlariStream({String? urunGrubu}) {
    Query q = _stokKartlari.where('aktif', isEqualTo: true);
    if (urunGrubu != null) q = q.where('urunGrubu', isEqualTo: urunGrubu);
    return q.orderBy('stokKodu').snapshots().map((s) => s.docs.map((d) => StokKarti.fromFirestore(d)).toList());
  }

  Future<StokKarti?> stokKoduIleGetir(String stokKodu) async {
    final q = await _stokKartlari.where('stokKodu', isEqualTo: stokKodu).limit(1).get();
    if (q.docs.isEmpty) return null;
    return StokKarti.fromFirestore(q.docs.first);
  }

  Future<String> stokKartiOlustur(StokKarti kart) async {
    final ref = await _stokKartlari.add(_sanitize(kart.toFirestore()));
    return ref.id;
  }

  Future<void> stokKartiGuncelle(StokKarti kart) =>
      _stokKartlari.doc(kart.id).update(_sanitize(kart.toFirestore()));

  Future<void> stokDus({required String stokKodu, required double miktar}) async {
    final q = await _stokKartlari.where('stokKodu', isEqualTo: stokKodu).limit(1).get();
    if (q.docs.isEmpty) throw Exception('Stok kartı bulunamadı: $stokKodu');
    final doc = q.docs.first;
    final mevcut = (doc.data() as Map)['mevcutStok'] ?? 0;
    await _stokKartlari.doc(doc.id).update({'mevcutStok': mevcut - miktar});
  }

  Future<String?> ikameStokBul({required String stokKodu, required String renkKodu}) async {
    final ikameQ = await _db.collection('ikameKurallari').where('orijinalKokKod', isEqualTo: stokKodu).limit(1).get();
    if (ikameQ.docs.isEmpty) return null;
    final ikame = ikameQ.docs.first.data();

    final birincil = ikame['birincilIkame'] as String? ?? '';
    final birincilKodu = birincil.endsWith('.') ? '$birincil$renkKodu' : birincil;
    final birincilStok = await stokKoduIleGetir(birincilKodu);
    if (birincilStok != null && birincilStok.mevcutStok > 0) return birincilKodu;

    final ikincil = ikame['ikincilIkame'] as String? ?? '';
    if (ikincil.isNotEmpty) {
      final ikincilKodu = ikincil.endsWith('.') ? '$ikincil$renkKodu' : ikincil;
      final ikincilStok = await stokKoduIleGetir(ikincilKodu);
      if (ikincilStok != null && ikincilStok.mevcutStok > 0) return ikincilKodu;
    }

    return null;
  }

  // ─── RENK HAVUZU VE DİĞERLERİ ──────────────────────────────────────────
  Stream<List<RenkTanim>> renklerStream() => _db.collection('renkler').orderBy('renkKodu').snapshots().map((s) => s.docs.map((d) => RenkTanim.fromFirestore(d)).toList());
  Future<void> renkGuncelle(RenkTanim renk) => _db.collection('renkler').doc(renk.id).update(renk.toFirestore());
  Future<String> renkEkle(RenkTanim renk) async {
    final ref = await _db.collection('renkler').add(renk.toFirestore());
    return ref.id;
  }

  Future<List<KapasteMatris>> kapasteMatrisGetir() async {
    final q = await _db.collection('kapasteMatrisi').get();
    return q.docs.map((d) => KapasteMatris.fromFirestore(d)).toList();
  }

  Future<Map<String, dynamic>> dashboardIstatistikleri() async {
    final tumSiparisler = await _siparisler.get();
    return {
      'toplamSiparis': tumSiparisler.size,
      'buAySiparis': 0,
      'bekleyenSiparis': 0,
      'uretimde': 0,
    };
  }
}