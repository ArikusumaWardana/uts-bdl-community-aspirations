CREATE TABLE citizen (
    citizen_id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    no_telepon VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE agency (
    agency_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_instansi VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    alamat VARCHAR(255),
    no_telepon VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE agency_officer (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    agency_id INT NOT NULL,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    no_telepon VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_officer_agency FOREIGN KEY (agency_id) REFERENCES agency(agency_id),
    CONSTRAINT unique_officer_email UNIQUE (email)
);

CREATE TABLE admin (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    no_telepon VARCHAR(20),
    role ENUM('admin', 'super_admin') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE complaint_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE complaint (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    citizen_id INT NOT NULL,
    agency_id INT NOT NULL,
    category_id INT NOT NULL,
    judul VARCHAR(255) NOT NULL,
    deskripsi TEXT NOT NULL,
    status ENUM('diajukan', 'diproses', 'selesai') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_complaint_citizen FOREIGN KEY (citizen_id) REFERENCES citizen(citizen_id),
    CONSTRAINT fk_complaint_agency FOREIGN KEY (agency_id) REFERENCES agency(agency_id),
    CONSTRAINT fk_complaint_category FOREIGN KEY (category_id) REFERENCES complaint_category(category_id)
);

CREATE TABLE response (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    officer_id INT NOT NULL,
    deskripsi TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_response_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id),
    CONSTRAINT fk_response_officer FOREIGN KEY (officer_id) REFERENCES agency_officer(officer_id)
);

CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    citizen_id INT NULL,
    officer_id INT NULL,
    complaint_id INT NOT NULL,
    pesan TEXT NOT NULL,
    status_dibaca BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_notification_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id),
    CONSTRAINT fk_notification_citizen FOREIGN KEY (citizen_id) REFERENCES citizen(citizen_id),
    CONSTRAINT fk_notification_officer FOREIGN KEY (officer_id) REFERENCES agency_officer(officer_id),
    CONSTRAINT ck_one_user CHECK (
        (citizen_id IS NOT NULL AND officer_id IS NULL) OR
        (citizen_id IS NULL AND officer_id IS NOT NULL)
    )
);

CREATE TABLE attachment (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_attachment_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id)
);

CREATE TABLE complaint_comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    citizen_id INT NULL,
    officer_id INT NULL,
    comment_text TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME DEFAULT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_comment_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id),
    CONSTRAINT fk_comment_citizen FOREIGN KEY (citizen_id) REFERENCES citizen(citizen_id),
    CONSTRAINT fk_comment_officer FOREIGN KEY (officer_id) REFERENCES agency_officer(officer_id),
    CONSTRAINT ck_one_commenter CHECK (
        (citizen_id IS NOT NULL AND officer_id IS NULL) OR
        (citizen_id IS NULL AND officer_id IS NOT NULL)
    )
);

CREATE TABLE log_activity (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    citizen_id INT NULL,
    officer_id INT NULL,
    admin_id INT NULL,
    aktivitas VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_only_one_actor CHECK (
        (citizen_id IS NOT NULL AND officer_id IS NULL AND admin_id IS NULL) OR
        (citizen_id IS NULL AND officer_id IS NOT NULL AND admin_id IS NULL) OR
        (citizen_id IS NULL AND officer_id IS NULL AND admin_id IS NOT NULL)
    ),
    CONSTRAINT fk_log_citizen FOREIGN KEY (citizen_id) REFERENCES citizen(citizen_id),
    CONSTRAINT fk_log_officer FOREIGN KEY (officer_id) REFERENCES agency_officer(officer_id),
    CONSTRAINT fk_log_admin FOREIGN KEY (admin_id) REFERENCES admin(admin_id)
);

INSERT INTO citizen (nama, email, password, alamat, no_telepon) VALUES
('Andi Setiawan', 'andi1@mail.com', SHA2('password123', 256), 'Jl. Merpati No. 10', '081234567891'),
('Budi Hartono', 'budi2@mail.com', SHA2('rahasia123', 256), 'Jl. Kenanga No. 15', '081234567892'),
('Citra Lestari', 'citra3@mail.com', SHA2('citra456', 256), 'Jl. Dahlia No. 7', '081234567893'),
('Dewi Anggraini', 'dewi4@mail.com', SHA2('dewi789', 256), 'Jl. Mawar No. 23', '081234567894'),
('Eka Putra', 'eka5@mail.com', SHA2('eka321', 256), 'Jl. Melati No. 3', '081234567895'),
('Fajar Prasetyo', 'fajar6@mail.com', SHA2('fajar456', 256), 'Jl. Anggrek No. 18', '081234567896'),
('Gita Sari', 'gita7@mail.com', SHA2('gita999', 256), 'Jl. Kamboja No. 2', '081234567897'),
('Hendra Gunawan', 'hendra8@mail.com', SHA2('hendra1010', 256), 'Jl. Cendana No. 12', '081234567898'),
('Indah Permata', 'indah9@mail.com', SHA2('indah000', 256), 'Jl. Teratai No. 20', '081234567899'),
('Joko Santoso', 'joko10@mail.com', SHA2('joko1234', 256), 'Jl. Flamboyan No. 1', '081234567900');


INSERT INTO agency (nama_instansi, deskripsi, alamat, no_telepon, email) VALUES
('Dinas Kebersihan Kota', 'Mengelola kebersihan dan pengelolaan sampah kota.', 'Jl. Kebersihan No. 1', '0211234567', 'kebersihan@dinas.go.id'),
('Dinas Perhubungan', 'Mengatur lalu lintas dan transportasi umum.', 'Jl. Transportasi No. 10', '0212345678', 'perhubungan@dinas.go.id'),
('Dinas Kesehatan', 'Pelayanan dan pengawasan kesehatan masyarakat.', 'Jl. Kesehatan No. 5', '0213456789', 'kesehatan@dinas.go.id'),
('Dinas Pendidikan', 'Mengelola pendidikan dan sekolah negeri.', 'Jl. Pendidikan No. 12', '0214567890', 'pendidikan@dinas.go.id'),
('Dinas Pekerjaan Umum', 'Pembangunan infrastruktur dan jalan.', 'Jl. Infrastruktur No. 3', '0215678901', 'pu@dinas.go.id'),
('Dinas Lingkungan Hidup', 'Menjaga kelestarian lingkungan dan penghijauan.', 'Jl. Hijau No. 8', '0216789012', 'lingkungan@dinas.go.id'),
('Dinas Sosial', 'Pelayanan bantuan sosial dan kesejahteraan masyarakat.', 'Jl. Sosial No. 7', '0217890123', 'sosial@dinas.go.id'),
('Dinas Pariwisata', 'Promosi pariwisata dan pengembangan destinasi wisata.', 'Jl. Pariwisata No. 4', '0218901234', 'pariwisata@dinas.go.id'),
('Dinas Pemadam Kebakaran', 'Penanggulangan kebakaran dan bencana.', 'Jl. Damkar No. 9', '0219012345', 'damkar@dinas.go.id'),
('Dinas Catatan Sipil', 'Pencatatan kelahiran, kematian, dan dokumen kependudukan.', 'Jl. Sipil No. 6', '0210123456', 'dukcapil@dinas.go.id');


INSERT INTO agency_officer (agency_id, nama, email, password, no_telepon) VALUES
(1, 'Agus Santoso', 'agus.santoso@dinas.go.id', SHA2('password123', 256), '081234567001'),
(2, 'Rina Wijaya', 'rina.wijaya@dinas.go.id', SHA2('securepass', 256), '081234567002'),
(3, 'Dedi Prasetyo', 'dedi.prasetyo@dinas.go.id', SHA2('admin456', 256), '081234567003'),
(4, 'Siti Aminah', 'siti.aminah@dinas.go.id', SHA2('education789', 256), '081234567004'),
(5, 'Bambang Sutrisno', 'bambang.sutrisno@dinas.go.id', SHA2('pujalan123', 256), '081234567005'),
(6, 'Yuni Kartika', 'yuni.kartika@dinas.go.id', SHA2('greenworld', 256), '081234567006'),
(7, 'Anton Subagyo', 'anton.subagyo@dinas.go.id', SHA2('sosialcare', 256), '081234567007'),
(8, 'Dewi Lestari', 'dewi.lestari@dinas.go.id', SHA2('tourismlife', 256), '081234567008'),
(9, 'Fajar Nugroho', 'fajar.nugroho@dinas.go.id', SHA2('firefighter', 256), '081234567009'),
(10, 'Mega Ayu', 'mega.ayu@dinas.go.id', SHA2('sipilsecure', 256), '081234567010');


INSERT INTO admin (nama, email, password, no_telepon, role) VALUES
('Ahmad Fauzi', 'ahmad.fauzi@admin.go.id', SHA2('password123', 256), '0811111111', 'admin'),
('Linda Pratiwi', 'linda.pratiwi@admin.go.id', SHA2('secureadmin', 256), '0811111112', 'super_admin'),
('Rizky Hidayat', 'rizky.hidayat@admin.go.id', SHA2('adminpass456', 256), '0811111113', 'admin'),
('Sari Wulandari', 'sari.wulandari@admin.go.id', SHA2('passsuper', 256), '0811111114', 'admin'),
('Bayu Setiawan', 'bayu.setiawan@admin.go.id', SHA2('adminsecure', 256), '0811111115', 'super_admin'),
('Nina Rachmawati', 'nina.rachmawati@admin.go.id', SHA2('topadmin', 256), '0811111116', 'admin'),
('Teguh Prakoso', 'teguh.prakoso@admin.go.id', SHA2('ultraadmin', 256), '0811111117', 'super_admin'),
('Desi Amelia', 'desi.amelia@admin.go.id', SHA2('security456', 256), '0811111118', 'admin'),
('Budi Hartono', 'budi.hartono@admin.go.id', SHA2('administrator', 256), '0811111119', 'admin'),
('Yulia Safitri', 'yulia.safitri@admin.go.id', SHA2('myadminpass', 256), '0811111120', 'super_admin');


INSERT INTO complaint_category (nama_kategori, deskripsi) VALUES
('Infrastruktur', 'Pengaduan terkait kerusakan jalan, jembatan, trotoar, dan fasilitas umum lainnya.'),
('Kebersihan', 'Masalah sampah, saluran air tersumbat, dan kebersihan lingkungan.'),
('Penerangan Jalan', 'Lampu jalan rusak atau tidak menyala.'),
('Air dan Sanitasi', 'Keluhan mengenai air bersih, sanitasi buruk, atau saluran pembuangan.'),
('Pelayanan Publik', 'Pengaduan terhadap layanan administrasi, pelayanan kesehatan, atau pelayanan publik lainnya.'),
('Keamanan', 'Masalah keamanan lingkungan, tindakan kriminal, atau gangguan ketertiban umum.'),
('Transportasi Umum', 'Keluhan mengenai angkutan umum, halte, atau jadwal transportasi.'),
('Lingkungan Hidup', 'Polusi udara, pencemaran sungai, pembakaran liar, dan sejenisnya.'),
('Pendidikan', 'Masalah fasilitas sekolah, guru, atau layanan pendidikan lainnya.'),
('Kesehatan', 'Fasilitas kesehatan, tenaga medis, atau pelayanan di puskesmas/rumah sakit.');


INSERT INTO complaint (citizen_id, agency_id, category_id, judul, deskripsi, status)
VALUES
(1, 1, 1, 'Jalan Berlubang di Jalan Raya', 'Terdapat lubang besar di jalan raya yang membahayakan pengendara.', 'diajukan'),
(2, 2, 2, 'Sampah Menumpuk di Pinggir Jalan', 'Sampah tidak diangkut selama seminggu terakhir.', 'diproses'),
(3, 3, 3, 'Lampu Jalan Mati', 'Lampu jalan di area kompleks perumahan mati sejak dua minggu lalu.', 'diajukan'),
(4, 4, 4, 'Air PDAM Tidak Mengalir', 'Sudah tiga hari air PDAM tidak mengalir di wilayah saya.', 'diajukan'),
(5, 5, 5, 'Pelayanan di Puskesmas Lambat', 'Antrian panjang dan hanya satu dokter yang melayani.', 'diproses'),
(1, 2, 1, 'Trotoar Rusak', 'Trotoar di depan sekolah rusak dan membahayakan anak-anak.', 'selesai'),
(2, 3, 2, 'Sungai Tercemar Limbah', 'Air sungai berwarna hitam dan berbau menyengat.', 'diproses'),
(3, 4, 3, 'Halte Bus Rusak', 'Atap halte bus roboh dan tidak ada perbaikan.', 'diajukan'),
(4, 5, 4, 'Tidak Ada Air di Sekolah', 'Kamar mandi di sekolah tidak memiliki air.', 'diajukan'),
(5, 1, 5, 'Rumah Sakit Kekurangan Obat', 'Obat-obatan dasar tidak tersedia di IGD.', 'diajukan');


INSERT INTO response (complaint_id, officer_id, deskripsi)
VALUES
(1, 1, 'Kami telah mengirim tim ke lokasi untuk meninjau kondisi jalan.'),
(2, 2, 'Petugas kebersihan akan dijadwalkan ke lokasi besok pagi.'),
(3, 3, 'Lampu jalan akan diganti dalam minggu ini.'),
(4, 4, 'Kami sedang menyelidiki penyebab gangguan air.'),
(5, 5, 'Manajemen Puskesmas telah diberi teguran dan akan menambah tenaga medis.'),
(6, 1, 'Perbaikan trotoar telah selesai dilakukan.'),
(7, 2, 'Dinas Lingkungan Hidup telah mengambil sampel air untuk uji laboratorium.'),
(8, 3, 'Halte akan diperbaiki oleh kontraktor minggu depan.'),
(9, 4, 'Kami telah memasang tangki air sementara di sekolah.'),
(10, 5, 'Permintaan obat telah diajukan ke gudang farmasi pusat.');


INSERT INTO notification (citizen_id, officer_id, complaint_id, pesan, status_dibaca)
VALUES
(1, NULL, 1, 'Pengaduan Anda sedang kami proses.', FALSE),
(NULL, 1, 2, 'Anda mendapat pengaduan baru.', TRUE),
(2, NULL, 3, 'Tanggapan telah diberikan untuk pengaduan Anda.', TRUE),
(NULL, 2, 4, 'Pengaduan baru telah ditugaskan kepada Anda.', FALSE),
(3, NULL, 5, 'Pengaduan Anda sudah selesai ditangani.', TRUE),
(NULL, 3, 6, 'Ada pengaduan yang membutuhkan perhatian Anda.', FALSE),
(4, NULL, 7, 'Status pengaduan Anda telah diperbarui.', FALSE),
(NULL, 4, 8, 'Pengaduan masuk terkait kebersihan kota.', TRUE),
(5, NULL, 9, 'Kami telah menanggapi keluhan Anda.', TRUE),
(NULL, 5, 10, 'Tugas Anda dalam pengaduan telah selesai.', TRUE);


INSERT INTO attachment (complaint_id, file_path)
VALUES
(1, '/uploads/lampiran/bukti_1.jpg'),
(2, '/uploads/lampiran/bukti_2.jpg'),
(3, '/uploads/lampiran/bukti_3.jpg'),
(4, '/uploads/lampiran/bukti_4.jpg'),
(5, '/uploads/lampiran/bukti_5.jpg'),
(6, '/uploads/lampiran/bukti_6.jpg'),
(7, '/uploads/lampiran/bukti_7.jpg'),
(8, '/uploads/lampiran/bukti_8.jpg'),
(9, '/uploads/lampiran/bukti_9.jpg'),
(10, '/uploads/lampiran/bukti_10.jpg');


INSERT INTO complaint_comment (complaint_id, citizen_id, officer_id, comment_text)
VALUES
(1, 1, NULL, 'Saya berharap laporan ini segera ditindaklanjuti.'),
(2, NULL, 1, 'Laporan Anda sedang kami proses, mohon bersabar.'),
(3, 2, NULL, 'Terima kasih telah merespons laporan saya.'),
(4, NULL, 2, 'Kami telah mengirim petugas ke lokasi.'),
(5, 3, NULL, 'Masalah ini sangat mengganggu aktivitas warga.'),
(6, NULL, 3, 'Sudah dilakukan pengecekan awal, akan dilanjutkan.'),
(7, 4, NULL, 'Apakah ada update terkait laporan ini?'),
(8, NULL, 4, 'Akan kami tindaklanjuti segera.'),
(9, 5, NULL, 'Saya ingin laporan ini diproses lebih cepat.'),
(10, NULL, 5, 'Silakan lampirkan bukti tambahan jika ada.');


INSERT INTO log_activity (citizen_id, officer_id, admin_id, aktivitas, deskripsi)
VALUES
(1, NULL, NULL, 'Login', 'Warga melakukan login ke sistem'),
(2, NULL, NULL, 'Mengajukan Aduan', 'Warga mengajukan aduan tentang jalan berlubang di Jalan Merdeka'),
(3, NULL, NULL, 'Mengedit Profil', 'Warga memperbarui informasi nomor telepon'),
(NULL, 1, NULL, 'Menanggapi Aduan', 'Petugas memberikan respon pada aduan #5'),
(NULL, 2, NULL, 'Login', 'Petugas berhasil login ke dashboard instansi'),
(NULL, 3, NULL, 'Memperbarui Status Aduan', 'Petugas mengubah status aduan #7 menjadi "diproses"'),
(NULL, NULL, 1, 'Login', 'Admin melakukan login ke sistem'),
(NULL, NULL, 2, 'Menambahkan Kategori', 'Admin menambahkan kategori baru: "Lingkungan"'),
(NULL, NULL, 3, 'Menghapus Komentar', 'Admin menghapus komentar pada aduan #9 karena mengandung SARA'),
(NULL, NULL, 1, 'Menonaktifkan Akun Citizen', 'Admin menonaktifkan akun milik citizen_id #4 karena pelanggaran aturan');



