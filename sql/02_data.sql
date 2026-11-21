-- =====================================================================
-- 02_data.sql — KUNCI JAWABAN
-- Pemilik : Dapa
-- Data contoh: poli 5, dokter 6, jadwal 8, pasien 10, kunjungan 14,
-- rekam 10, tindakan 6, detail_tindakan 16, obat 8, detail_resep 12,
-- pembayaran 10. Keadaan khusus sesuai PRD bagian 9.
-- =====================================================================
USE klinik_pratama;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE pembayaran;
TRUNCATE TABLE detail_resep;
TRUNCATE TABLE detail_tindakan;
TRUNCATE TABLE rekam_medis;
TRUNCATE TABLE kunjungan;
TRUNCATE TABLE jadwal_praktik;
TRUNCATE TABLE dokter;
TRUNCATE TABLE pasien;
TRUNCATE TABLE obat;
TRUNCATE TABLE tindakan;
TRUNCATE TABLE poli;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO poli (id_poli, nama_poli, lantai) VALUES
(1, 'Poli Umum', '1'),
(2, 'Poli Anak', '1'),
(3, 'Poli Gigi', '2'),
(4, 'Poli Penyakit Dalam', '2'),
(5, 'Poli Mata', '3');

INSERT INTO dokter (id_dokter, id_poli, nama_dokter, no_sip, email, no_telp, tipe_dokter) VALUES
(1, 1, 'dr. Budi Santoso', 'SIP-001-2026', 'budi.santoso@klinik.id', '0812000001', 'Umum'),
(2, 2, 'dr. Andi Pratama', 'SIP-002-2026', 'andi.pratama@klinik.id', '0812000002', 'Spesialis'),
(3, 3, 'dr. Citra Dewi', 'SIP-003-2026', 'citra.dewi@klinik.id', '0812000003', 'Spesialis'),
(4, 4, 'dr. Dedi Kurniawan', 'SIP-004-2026', 'dedi.kurniawan@klinik.id', '0812000004', 'Spesialis'),
(5, 5, 'dr. Eka Lestari', 'SIP-005-2026', 'eka.lestari@klinik.id', '0812000005', 'Spesialis'),
(6, 1, 'dr. Fajar Nugroho', 'SIP-006-2026', 'fajar.nugroho@klinik.id', '0812000006', 'Umum');

INSERT INTO jadwal_praktik (id_jadwal, id_dokter, tanggal, jam_mulai, jam_selesai, ruangan, kuota) VALUES
(1, 1, '2026-08-05', '08:00:00', '12:00:00', 'R-01', 6),
(2, 2, '2026-08-06', '08:00:00', '12:00:00', 'R-02', 5),
(3, 3, '2026-08-07', '09:00:00', '12:00:00', 'R-03', 5),
(4, 4, '2026-08-10', '09:00:00', '12:00:00', 'R-04', 5),
(5, 5, '2026-08-11', '08:00:00', '11:00:00', 'R-05', 5),
(6, 6, '2026-08-12', '08:00:00', '11:00:00', 'R-06', 5),
(7, 2, '2026-10-07', '08:00:00', '12:00:00', 'R-02', 4),
(8, 4, '2026-10-08', '09:00:00', '12:00:00', 'R-04', 5);

INSERT INTO pasien (id_pasien, nama_pasien, nik, email, no_telp, tanggal_lahir, alamat) VALUES
(1, 'Aisyah Putri', '3273010101850001', 'aisyah.putri@mail.id', '0813000001', '1985-03-11', 'Jl. Melati 1'),
(2, 'Bagas Wirawan', '3273010101900002', 'bagas.wirawan@mail.id', '0813000002', '1990-07-21', 'Jl. Melati 2'),
(3, 'Citra Ayu', '3273010101920003', 'citra.ayu@mail.id', '0813000003', '1992-01-05', 'Jl. Kenanga 3'),
(4, 'Dinda Larasati', '3273010101980004', 'dinda.larasati@mail.id', '0813000004', '1998-11-30', 'Jl. Kenanga 4'),
(5, 'Gilang Ramadhan', '3273011802800005', 'gilang.ramadhan@mail.id', '0813000005', '1980-02-18', 'Jl. Anggrek 5'),
(6, 'Ahmad Fauzi', '3273010101880006', 'ahmad.fauzi@mail.id', '0813000006', '1988-04-14', 'Jl. Anggrek 6'),
(7, 'Nisa Rahma', '3273010101950007', 'anisa.rahma@mail.id', '0813000007', '1995-06-23', 'Jl. Dahlia 7'),
(8, 'Bagus Setiawan', '3273010101930008', 'bagus.setiawan@mail.id', '0813000008', '1993-09-02', 'Jl. Dahlia 8'),
(9, 'Dewi Anggraini', '3273010101910009', 'dewi.anggraini@mail.id', '0813000009', '1991-12-17', 'Jl. Flamboyan 9'),
(10, 'Rifqi Budiman', '3273010101970010', 'arif.budiman@mail.id', '0813000010', '1997-08-29', 'Jl. Flamboyan 10');

INSERT INTO kunjungan (id_kunjungan, id_pasien, id_jadwal, tanggal_kunjungan, no_antrean, status_kunjungan) VALUES
(1, 1, 7, '2026-10-07', 1, 'Selesai'),
(2, 2, 7, '2026-10-07', 2, 'Selesai'),
(3, 3, 2, '2026-08-06', 1, 'Selesai'),
(4, 5, 7, '2026-10-07', 3, 'Selesai'),
(5, 6, 7, '2026-10-07', 4, 'Selesai'),
(6, 4, 2, '2026-08-06', 2, 'Selesai'),
(7, 7, 3, '2026-08-07', 1, 'Selesai'),
(8, 8, 3, '2026-08-07', 2, 'Selesai'),
(9, 9, 4, '2026-08-10', 1, 'Selesai'),
(10, 10, 4, '2026-08-10', 2, 'Diperiksa'),
(11, 1, 6, '2026-08-12', 1, 'Batal'),
(12, 2, 6, '2026-08-12', 2, 'Batal'),
(13, 3, 5, '2026-08-11', 1, 'Menunggu'),
(14, 4, 5, '2026-08-11', 2, 'Menunggu');

INSERT INTO rekam_medis (id_rekam, id_kunjungan, keluhan, diagnosis, tekanan_darah, suhu, berat_badan, tinggi_badan, tanggal_periksa) VALUES
(1, 1, 'Demam tiga hari', 'Infeksi saluran napas atas', '120/80', 38.2, 72.0, 170.0, '2026-10-07'),
(2, 2, 'Nyeri gigi', 'Karies dentin', '118/76', 36.8, 65.0, 168.0, '2026-10-07'),
(3, 3, 'Nyeri ulu hati', 'Gastritis', '125/82', 36.5, 58.0, 160.0, '2026-08-06'),
(4, 4, 'Batuk berdahak', 'Bronkitis akut', '110/70', 37.8, 80.0, 175.0, '2026-10-07'),
(5, 5, 'Pusing berulang', 'Vertigo', '130/85', 36.6, 61.0, 158.0, '2026-10-07'),
(6, 6, 'Sakit kepala', 'Migrain', '115/75', 36.9, 55.0, 162.0, '2026-08-06'),
(7, 7, 'Mata merah', 'Konjungtivitis', '120/78', 37.1, 70.0, 172.0, '2026-08-07'),
(8, 8, 'Nyeri sendi', 'Artritis', '135/88', 36.7, 85.0, 178.0, '2026-08-07'),
(9, 9, 'Sesak napas', 'Asma bronkial', '128/84', 37.4, 68.0, 166.0, '2026-08-10'),
(10, 10, 'Gatal kulit', 'Dermatitis alergi', '112/72', 36.4, 59.0, 155.0, '2026-08-10');

INSERT INTO tindakan (id_tindakan, nama_tindakan, tarif) VALUES
(1, 'Konsultasi Umum', 50000.00),
(2, 'Pemeriksaan Gigi', 100000.00),
(3, 'Tambal Gigi', 150000.00),
(4, 'Cek Darah', 75000.00),
(5, 'Fisioterapi', 120000.00),
(6, 'Pemasangan Infus', 90000.00);

INSERT INTO detail_tindakan (id_kunjungan, id_tindakan, jumlah) VALUES
(1, 1, 1), (1, 4, 1),
(2, 3, 1),
(3, 2, 1), (3, 6, 1),
(4, 1, 1), (4, 6, 1),
(5, 1, 1),
(6, 2, 1),
(7, 1, 1), (7, 4, 1), (7, 5, 1),
(8, 1, 1),
(9, 5, 1),
(10, 1, 1), (10, 3, 1);

INSERT INTO obat (id_obat, nama_obat, satuan, harga, stok) VALUES
(1, 'Paracetamol 500mg', 'Tablet', 500.00, 100),
(2, 'Amlodipine 5mg', 'Tablet', 1000.00, 60),
(3, 'Amoxicillin 500mg', 'Kapsul', 1500.00, 40),
(4, 'Ibuprofen 400mg', 'Tablet', 800.00, 35),
(5, 'Cetirizine 10mg', 'Tablet', 700.00, 25),
(6, 'Omeprazole 20mg', 'Kapsul', 1200.00, 30),
(7, 'Vitamin B Complex', 'Tablet', 600.00, 50),
(8, 'Obat Batuk Sirup', 'Botol', 15000.00, 5);

INSERT INTO detail_resep (id_rekam, id_obat, jumlah, aturan_pakai) VALUES
(1, 1, 10, '3x1 tablet'),
(1, 2, 30, '1x1 tablet'),
(2, 3, 10, '3x1 kapsul'),
(3, 4, 10, '2x1 tablet'),
(4, 1, 5, '3x1 tablet'),
(4, 6, 7, '1x1 kapsul'),
(5, 5, 10, '1x1 tablet'),
(6, 2, 30, '1x1 tablet'),
(7, 1, 6, '3x1 tablet'),
(8, 7, 10, '1x1 tablet'),
(9, 3, 10, '3x1 kapsul'),
(10, 1, 4, '3x1 tablet');

INSERT INTO pembayaran (id_pembayaran, id_kunjungan, tanggal_bayar, metode, total_tagihan, status_bayar) VALUES
(1, 1, '2026-10-07', 'Tunai', 160000.00, 'Lunas'),
(2, 2, '2026-10-07', 'Transfer', 165000.00, 'Lunas'),
(3, 3, '2026-08-06', 'Tunai', 148000.00, 'Lunas'),
(4, 4, '2026-10-07', 'BPJS', 150900.00, 'Lunas'),
(5, 5, '2026-10-07', 'Tunai', 57000.00, 'Lunas'),
(6, 6, '2026-08-06', 'Transfer', 80000.00, 'Lunas'),
(7, 7, '2026-08-07', 'Tunai', 248000.00, 'Lunas'),
(8, 8, NULL, 'Tunai', 56000.00, 'Belum Lunas'),
(9, 9, NULL, 'Transfer', 135000.00, 'Belum Lunas'),
(10, 10, NULL, 'BPJS', 202000.00, 'Belum Lunas');

SELECT 'poli' AS tabel, COUNT(*) AS baris FROM poli
UNION ALL SELECT 'dokter', COUNT(*) FROM dokter
UNION ALL SELECT 'jadwal_praktik', COUNT(*) FROM jadwal_praktik
UNION ALL SELECT 'pasien', COUNT(*) FROM pasien
UNION ALL SELECT 'kunjungan', COUNT(*) FROM kunjungan
UNION ALL SELECT 'rekam_medis', COUNT(*) FROM rekam_medis
UNION ALL SELECT 'tindakan', COUNT(*) FROM tindakan
UNION ALL SELECT 'detail_tindakan', COUNT(*) FROM detail_tindakan
UNION ALL SELECT 'obat', COUNT(*) FROM obat
UNION ALL SELECT 'detail_resep', COUNT(*) FROM detail_resep
UNION ALL SELECT 'pembayaran', COUNT(*) FROM pembayaran;
