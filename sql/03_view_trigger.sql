-- =====================================================================
-- 03_view_trigger.sql — KUNCI JAWABAN
-- Pemilik : Kenzie
-- Dua view dan empat trigger sesuai PRD bagian 8.1 dan 8.2.
-- =====================================================================
USE klinik_pratama;

DROP VIEW IF EXISTS v_kunjungan_lengkap;
DROP VIEW IF EXISTS v_pendapatan_poli;

CREATE VIEW v_kunjungan_lengkap AS
SELECT
  k.id_kunjungan,
  k.tanggal_kunjungan,
  k.no_antrean,
  k.status_kunjungan,
  p.id_pasien,
  p.nama_pasien,
  d.id_dokter,
  d.nama_dokter,
  d.tipe_dokter,
  po.nama_poli,
  j.ruangan,
  j.jam_mulai,
  j.jam_selesai,
  COALESCE(b.status_bayar, 'Belum Ada Tagihan') AS status_bayar,
  b.total_tagihan
FROM kunjungan k
JOIN pasien p          ON p.id_pasien = k.id_pasien
JOIN jadwal_praktik j  ON j.id_jadwal = k.id_jadwal
JOIN dokter d          ON d.id_dokter = j.id_dokter
JOIN poli po           ON po.id_poli = d.id_poli
LEFT JOIN pembayaran b ON b.id_kunjungan = k.id_kunjungan;

CREATE VIEW v_pendapatan_poli AS
SELECT
  po.nama_poli,
  DATE_FORMAT(k.tanggal_kunjungan, '%Y-%m') AS bulan,
  COUNT(*) AS jumlah_kunjungan,
  SUM(b.total_tagihan) AS total_pendapatan
FROM kunjungan k
JOIN jadwal_praktik j ON j.id_jadwal = k.id_jadwal
JOIN dokter d         ON d.id_dokter = j.id_dokter
JOIN poli po          ON po.id_poli = d.id_poli
JOIN pembayaran b     ON b.id_kunjungan = k.id_kunjungan
WHERE b.status_bayar = 'Lunas'
GROUP BY po.nama_poli, DATE_FORMAT(k.tanggal_kunjungan, '%Y-%m');

DROP TRIGGER IF EXISTS trg_cek_kuota_jadwal;
DROP TRIGGER IF EXISTS trg_cek_bentrok_jadwal;
DROP TRIGGER IF EXISTS trg_cek_stok_obat;
DROP TRIGGER IF EXISTS trg_kurangi_stok;

DELIMITER $$

CREATE TRIGGER trg_cek_kuota_jadwal
BEFORE INSERT ON kunjungan
FOR EACH ROW
BEGIN
  DECLARE v_kuota INT;
  DECLARE v_terpakai INT;

  IF NEW.status_kunjungan <> 'Batal' THEN
    SELECT kuota INTO v_kuota FROM jadwal_praktik WHERE id_jadwal = NEW.id_jadwal;
    SELECT COUNT(*) INTO v_terpakai
      FROM kunjungan
     WHERE id_jadwal = NEW.id_jadwal
       AND status_kunjungan <> 'Batal';
    IF v_terpakai >= v_kuota THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kuota jadwal sudah penuh';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_cek_bentrok_jadwal
BEFORE INSERT ON jadwal_praktik
FOR EACH ROW
BEGIN
  DECLARE v_bentrok INT;

  SELECT COUNT(*) INTO v_bentrok
    FROM jadwal_praktik
   WHERE id_dokter = NEW.id_dokter
     AND tanggal = NEW.tanggal
     AND jam_mulai < NEW.jam_selesai
     AND jam_selesai > NEW.jam_mulai;

  IF v_bentrok > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jadwal dokter bentrok';
  END IF;
END$$

CREATE TRIGGER trg_cek_stok_obat
BEFORE INSERT ON detail_resep
FOR EACH ROW
BEGIN
  DECLARE v_stok INT;

  SELECT stok INTO v_stok FROM obat WHERE id_obat = NEW.id_obat;
  IF NEW.jumlah > v_stok THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok obat tidak cukup';
  END IF;
END$$

CREATE TRIGGER trg_kurangi_stok
AFTER INSERT ON detail_resep
FOR EACH ROW
BEGIN
  UPDATE obat SET stok = stok - NEW.jumlah WHERE id_obat = NEW.id_obat;
END$$

DELIMITER ;

SELECT COUNT(*) AS view_terdaftar
FROM information_schema.views
WHERE table_schema = 'klinik_pratama';

SELECT COUNT(*) AS trigger_terdaftar
FROM information_schema.triggers
WHERE trigger_schema = 'klinik_pratama';
