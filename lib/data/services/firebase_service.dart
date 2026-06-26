// lib/data/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    return q.snapshots().map(
      (s) => s.docs.map((d) => Siparis.fromFirestore(d)).toList(),
    );
  }

  Future<String> siparisOlustur(Siparis siparis) async {
    final no = await _siparisNoUret();
    final yeniSiparis = Siparis(
      id: '',
      siparisNo: no,
      musteriAdi: siparis.musteriAdi,
      siparisReferansi: siparis.siparisReferansi,
      olusturmaTarihi: DateTime.now(),
      durum: 'taslak',
      pozlar: siparis.pozlar,
      siparisNotu: siparis.siparisNotu,
      createdBy: mevcutKullanici?.uid ?? '',
    );
    final ref = await _siparisler.add(yeniSiparis.toFirestore());
    return ref.id;
  }

  Future<void> siparisGuncelle(Siparis siparis) =>
      _siparisler.doc(siparis.id).update(siparis.toFirestore());

  Future<void> siparisSil(String id) => _siparisler.doc(id).delete();

  Future<Siparis?> siparisBul(String id) async {
    final doc = await _siparisler.doc(id).get();
    if (!doc.exists) return null;
    return Siparis.fromFirestore(doc);
  }

  Future<String> _siparisNoUret() async {
    final yil = DateTime.now().year;
    final sayac = await _db.runTransaction((t) async {
      final sayacRef = _db.collection('sayaclar').doc('siparisNo');
      final snap = await t.get(sayacRef);
      int mevcut = snap.exists ? (snap.data()!['$yil'] ?? 0) : 0;
      mevcut++;
      t.set(sayacRef, {'$yil': mevcut}, SetOptions(merge: true));
      return mevcut;
    });
    return 'PNJ-$yil-${sayac.toString().padLeft(4, '0')}';
  }

  // ─── STOK KARTLARI ──────────────────────────────────────────────────────
  CollectionReference get _stokKartlari => _db.collection('stokKartlari');

  Stream<List<StokKarti>> stokKartlariStream({String? urunGrubu}) {
    Query q = _stokKartlari.where('aktif', isEqualTo: true);
    if (urunGrubu != null) q = q.where('urunGrubu', isEqualTo: urunGrubu);
    return q
        .orderBy('stokKodu')
        .snapshots()
        .map((s) => s.docs.map((d) => StokKarti.fromFirestore(d)).toList());
  }

  Future<StokKarti?> stokKoduIleGetir(String stokKodu) async {
    final q = await _stokKartlari
        .where('stokKodu', isEqualTo: stokKodu)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return StokKarti.fromFirestore(q.docs.first);
  }

  Future<String> stokKartiOlustur(StokKarti kart) async {
    final ref = await _stokKartlari.add(kart.toFirestore());
    return ref.id;
  }

  Future<void> stokKartiGuncelle(StokKarti kart) =>
      _stokKartlari.doc(kart.id).update(kart.toFirestore());

  Future<void> stokDus({
    required String stokKodu,
    required double miktar,
  }) async {
    final q = await _stokKartlari
        .where('stokKodu', isEqualTo: stokKodu)
        .limit(1)
        .get();
    if (q.docs.isEmpty) throw Exception('Stok kartı bulunamadı: $stokKodu');
    final doc = q.docs.first;
    final mevcut = (doc.data() as Map)['mevcutStok'] ?? 0;
    await _stokKartlari.doc(doc.id).update({'mevcutStok': mevcut - miktar});
  }

  /// Otomatik ikame: stok yoksa matrise göre alternatif bul
  Future<String?> ikameStokBul({
    required String stokKodu,
    required String renkKodu,
  }) async {
    // İkame matrisini kontrol et
    final ikameQ = await _db
        .collection('ikameKurallari')
        .where('orijinalKokKod', isEqualTo: stokKodu)
        .limit(1)
        .get();

    if (ikameQ.docs.isEmpty) return null;
    final ikame = ikameQ.docs.first.data();

    // Birincil ikameyi dene
    final birincil = ikame['birincilIkame'] as String? ?? '';
    final birincilKodu = birincil.endsWith('.')
        ? '$birincil$renkKodu'
        : birincil;
    final birincilStok = await stokKoduIleGetir(birincilKodu);
    if (birincilStok != null && birincilStok.mevcutStok > 0)
      return birincilKodu;

    // İkincil ikameyi dene
    final ikincil = ikame['ikincilIkame'] as String? ?? '';
    if (ikincil.isNotEmpty) {
      final ikincilKodu = ikincil.endsWith('.') ? '$ikincil$renkKodu' : ikincil;
      final ikincilStok = await stokKoduIleGetir(ikincilKodu);
      if (ikincilStok != null && ikincilStok.mevcutStok > 0) return ikincilKodu;
    }

    // Üçüncül ikameyi dene
    final ucuncul = ikame['ucuncülIkame'] as String? ?? '';
    if (ucuncul.isNotEmpty) {
      final ucunculKodu = ucuncul.endsWith('.') ? '$ucuncul$renkKodu' : ucuncul;
      final ucunculStok = await stokKoduIleGetir(ucunculKodu);
      if (ucunculStok != null && ucunculStok.mevcutStok > 0) return ucunculKodu;
    }

    return null;
  }

  // ─── RENK HAVUZU ────────────────────────────────────────────────────────
  Stream<List<RenkTanim>> renklerStream() => _db
      .collection('renkler')
      .orderBy('renkKodu')
      .snapshots()
      .map((s) => s.docs.map((d) => RenkTanim.fromFirestore(d)).toList());

  Future<void> renkGuncelle(RenkTanim renk) =>
      _db.collection('renkler').doc(renk.id).update(renk.toFirestore());

  Future<String> renkEkle(RenkTanim renk) async {
    final ref = await _db.collection('renkler').add(renk.toFirestore());
    return ref.id;
  }

  // ─── KAPASİTE MATRİSİ ──────────────────────────────────────────────────
  Future<List<KapasteMatris>> kapasteMatrisGetir() async {
    final q = await _db.collection('kapasteMatrisi').get();
    return q.docs.map((d) => KapasteMatris.fromFirestore(d)).toList();
  }

  Future<int?> maxLamelAdetiGetir({
    required String kutuTipi,
    required String kutuOlcusu,
    required String lamelTipi,
  }) async {
    final q = await _db
        .collection('kapasteMatrisi')
        .where('kutuTipi', isEqualTo: kutuTipi)
        .where('kutuOlcusu', isEqualTo: kutuOlcusu)
        .where('lamelTipi', isEqualTo: lamelTipi)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.data()['maxLamelAdeti'] as int?;
  }

  // ─── İSTATİSTİKLER (Dashboard) ──────────────────────────────────────────
  Future<Map<String, dynamic>> dashboardIstatistikleri() async {
    final now = DateTime.now();
    final buAyin = DateTime(now.year, now.month, 1);

    final tumSiparisler = await _siparisler.get();
    final buAy = await _siparisler
        .where(
          'olusturmaTarihi',
          isGreaterThanOrEqualTo: Timestamp.fromDate(buAyin),
        )
        .get();
    final bekleyen = await _siparisler
        .where('durum', isEqualTo: 'taslak')
        .get();
    final uretimde = await _siparisler
        .where('durum', isEqualTo: 'uretimde')
        .get();

    return {
      'toplamSiparis': tumSiparisler.size,
      'buAySiparis': buAy.size,
      'bekleyenSiparis': bekleyen.size,
      'uretimde': uretimde.size,
    };
  }
}
