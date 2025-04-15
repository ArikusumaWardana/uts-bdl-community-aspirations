# 📚 Dokumentasi Skema Database: Community Aspirations

## 1. 👥 Nama Anggota Kelompok

|                  Nama                 |     NIM      |
|---------------------------------------|--------------|
|   I Gusti Ngurah Agung Adi Aryasuta   |  2301020032  |
|   Kadek Agus Arikusuma Wardana        |  2301020033  |
|   I Kadek Momet Dwika Putra           |  2301020037  |

---

## 2. 📝 Deskripsi Singkat

Skema database **Community Aspirations** digunakan untuk menangani sistem pengelolaan pengaduan masyarakat secara digital. Warga dapat mengirim aduan ke instansi terkait, menerima notifikasi serta tanggapan, dan memantau perkembangan aduan mereka.

---

## 3. 🚀 Fitur Utama Skema Database

- Pengiriman dan pemrosesan pengaduan dari warga ke instansi
- Sistem notifikasi untuk warga dan petugas instansi
- Fungsi pelaporan dan statistik melalui view
- Log aktivitas secara otomatis dengan trigger
- Soft delete untuk menjaga integritas data
- Otomatisasi status pengaduan saat mendapat tanggapan

---

## 4. ⚙️ Function

| Nama Function | Deskripsi |
|---------------|-----------|
| `get_complaint_status(p_complaint_id)` | Mengembalikan status pengaduan berdasarkan ID |
| `count_unread_notifications_by_citizen(citizenId)` | Menghitung jumlah notifikasi belum dibaca oleh warga tertentu |
| `count_unread_notifications_by_officer(officerId)` | Menghitung jumlah notifikasi belum dibaca oleh petugas tertentu |

---

## 5. 🔎 View

| Nama View | Deskripsi |
|-----------|-----------|
| `view_citizen_complaints` | Menampilkan daftar aduan lengkap dari warga, termasuk nama warga, instansi, kategori, dan status |
| `view_unread_notifications_citizen` | Menampilkan notifikasi yang belum dibaca oleh warga beserta informasi aduan terkait |
| `view_complaint_with_responses` | Menampilkan detail pengaduan beserta respon dari petugas, jika ada |

---

## 6. 📦 Stored Procedure

| Nama Stored Procedure | Deskripsi |
|------------------------|-----------|
| `add_complaint(...)` | Menambahkan aduan baru dari warga ke database |
| `respond_to_complaint(...)` | Menambahkan respon dari petugas terhadap pengaduan dan memperbarui status jika perlu |
| `soft_delete_complaint(p_complaint_id)` | Menandai pengaduan sebagai dihapus tanpa benar-benar menghapusnya dari database (soft delete) |

---

## 7. 🔁 Trigger

| Nama Trigger | Deskripsi |
|--------------|-----------|
| `trg_log_add_complaint` | Setelah aduan ditambahkan, log aktivitas dicatat untuk warga tersebut |
| `trg_notify_agency_officer` | Setelah aduan ditambahkan, notifikasi otomatis dikirim ke petugas instansi terkait |
| `trg_notify_citizen_response` | Setelah respon dari petugas dimasukkan, warga yang melaporkan akan menerima notifikasi bahwa pengaduannya telah direspon |

---
