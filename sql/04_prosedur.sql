-- =====================================================================
-- 04_prosedur.sql — KUNCI JAWABAN
-- Pemilik : Agit
-- sp_daftar_kunjungan dan sp_bayar_kunjungan sesuai PRD bagian 8.3.
-- =====================================================================
USE klinik_pratama;

DROP PROCEDURE IF EXISTS sp_daftar_kunjungan;
DROP PROCEDURE IF EXISTS sp_bayar_kunjungan;

DELIMITER $$

CREATE PROCEDURE sp_daftar_kunjungan(
  IN p_id_pasien INT,
  IN p_id_jadwal INT
)
BEGIN
  DECLARE v_tanggal DATE;
  DECLARE v_antrean INT;
  DECLARE v_id INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT tanggal INTO v_tanggal FROM jadwal_praktik WHERE id_jadwal = p_id_jadwal;
  IF v_tanggal IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jadwal tidak ditemukan';
  END IF;
  IF v_tanggal < CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jadwal sudah lewat, tidak bisa didaftari';
  END IF;

  SELECT COALESCE(MAX(no_antrean), 0) + 1 INTO v_antrean
    FROM kunjungan WHERE id_jadwal = p_id_jadwal;

  INSERT INTO kunjungan (id_pasien, id_jadwal, tanggal_kunjungan, no_antrean, status_kunjungan)
  VALUES (p_id_pasien, p_id_jadwal, v_tanggal, v_antrean, 'Menunggu');

  SET v_id = LAST_INSERT_ID();
  COMMIT;

  SELECT v_id AS id_kunjungan_baru, v_antrean AS no_antrean;
END$$

CREATE PROCEDURE sp_bayar_kunjungan(
  IN p_id_kunjungan INT,
  IN p_metode VARCHAR(20)
)
BEGIN
  DECLARE v_sudah INT;
  DECLARE v_total DECIMAL(12,2);
  DECLARE v_tindakan DECIMAL(12,2);
  DECLARE v_resep DECIMAL(12,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT COUNT(*) INTO v_sudah FROM pembayaran WHERE id_kunjungan = p_id_kunjungan;
  IF v_sudah > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kunjungan sudah dibayar';
  END IF;

  SELECT COALESCE(SUM(dt.jumlah * t.tarif), 0) INTO v_tindakan
    FROM detail_tindakan dt
    JOIN tindakan t ON t.id_tindakan = dt.id_tindakan
   WHERE dt.id_kunjungan = p_id_kunjungan;

  SELECT COALESCE(SUM(dr.jumlah * o.harga), 0) INTO v_resep
    FROM detail_resep dr
    JOIN rekam_medis rm ON rm.id_rekam = dr.id_rekam
    JOIN obat o         ON o.id_obat = dr.id_obat
   WHERE rm.id_kunjungan = p_id_kunjungan;

  SET v_total = v_tindakan + v_resep;

  INSERT INTO pembayaran (id_kunjungan, tanggal_bayar, metode, total_tagihan, status_bayar)
  VALUES (p_id_kunjungan, CURDATE(), p_metode, v_total, 'Lunas');

  COMMIT;

  SELECT v_total AS total_dibayar;
END$$

DELIMITER ;

SELECT COUNT(*) AS prosedur_terdaftar
FROM information_schema.routines
WHERE routine_schema = 'klinik_pratama' AND routine_type = 'PROCEDURE';
