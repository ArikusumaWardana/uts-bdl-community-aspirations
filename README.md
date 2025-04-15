# 📚 Dokumentasi Skema Database: Community Aspirations

## 1. 👥 Nama Anggota Kelompok

|                  Nama                 |     NIM      |
|---------------------------------------|--------------|
|   I Gusti Ngurah Agung Adi Aryasuta   |  2301020032  |
|   Kadek Agus Arikusuma Wardana        |  2301020033  |
|   I Kadek Momet Dwika Putra           |  2301020037  |

---

## 2. 📝 Deskripsi Singkat

Skema database **Community Aspirations** dirancang untuk menangani proses pengelolaan aduan masyarakat secara digital. Sistem ini memungkinkan warga untuk mengirim aduan ke instansi terkait, memantau status aduan, serta menerima respon atau tanggapan dari petugas instansi.

---

## 3. 🚀 Fitur Utama Skema Database

- Pencatatan aduan masyarakat lengkap dengan status dan lampiran
- Manajemen pengguna: admin, warga, dan petugas instansi
- Komentar & respon aduan oleh warga dan petugas
- Notifikasi untuk pelaporan, respon, dan perubahan status
- Sistem log aktivitas pengguna
- Soft delete & timestamp untuk keperluan audit
- View untuk dashboard dan laporan cepat

---

## 4. ⚙️ Function

| Nama Function | Deskripsi |
|---------------|-----------|
| `get_user_name_by_role` | Mengambil nama pengguna berdasarkan `role` (admin, citizen, officer) dan `user_id` |
| `get_user_email_by_role` | Mengambil email pengguna berdasarkan `role` dan `user_id` |

---

## 5. 🔎 View

| Nama View | Deskripsi |
|-----------|-----------|
| `view_complaint_detail` | Menampilkan detail lengkap aduan termasuk nama pelapor, instansi, dan status |
| `view_officer_complaint` | Menyediakan data aduan untuk masing-masing petugas |
| `view_agency_complaint_summary` | Statistik jumlah aduan per instansi |
| `view_citizen_complaint_activity` | Ringkasan aktivitas pengaduan yang dilakukan oleh warga |
| `view_response_summary` | Statistik jumlah respon terhadap aduan yang ada |

---

## 6. 📦 Stored Procedure

| Nama Stored Procedure | Deskripsi |
|------------------------|-----------|
| `add_complaint` | Menambahkan aduan baru dari warga ke database |
| `respond_to_complaint` | Menambahkan respon petugas terhadap aduan dan update statusnya ke `diproses` atau `selesai` jika perlu |

---

## 7. 🔁 Trigger

| Nama Trigger | Deskripsi |
|--------------|-----------|
| `after_complaint_insert` | Setelah aduan ditambahkan, trigger ini membuat notifikasi kepada petugas instansi terkait |
| `after_response_insert` | Setelah petugas memberikan respon, trigger ini mengirim notifikasi ke warga yang mengadukan |
| `after_comment_insert` | Setelah komentar ditambahkan pada aduan, trigger ini membuat notifikasi ke pihak yang relevan (warga atau petugas) |

---
