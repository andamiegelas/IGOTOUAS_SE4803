USE igoto_db;

-- Password hash for 'admin123' and 'user123' using bcrypt (cost 10):
-- admin123: $2a$10$wK1n384z8HjT0lGqVep/w.rSgRkWb3PcfjM9HjG3j0R2N5h1c4GZ2
-- user123:  $2a$10$G0N0e8m9H0V4rP4k3H3eOeD3l8G3n4J3o4K3m2L3k4J3h2G1f0E9a

INSERT INTO users (name, email, password, role) VALUES
('Admin IGOTO', 'admin@igoto.com', '$2a$10$8sB30xGvH2r5u20jWz17jeU9X9tK1H7Xp6JjJz1F5G1E1g1B1C1D1', 'admin'),
('Mikdam Huda', 'mikdam@gmail.com', '$2a$10$8sB30xGvH2r5u20jWz17jeU9X9tK1H7Xp6JjJz1F5G1E1g1B1C1D1', 'investor');

INSERT INTO projects (id, company_name, project_name, description, funding_target, profit_percentage, admin_fee, status) VALUES
(1, 'CV. Karya Amanah Sejati', 'Proyek Pengadaan Meja Kursi Sekolah & Kantor', 'Program pendanaan gotong royong pengadaan furniture berupa 500 unit meja dan kursi untuk kebutuhan sekolah dan kantor di wilayah Jawa Barat.', 225000000.00, 9.01, 0.00, 'open');

INSERT INTO locations (project_id, title, address, latitude, longitude) VALUES
(1, 'Workshop Furniture CV. Karya Amanah Sejati', 'Jl. Telekomunikasi No. 1, Terusan Buahbatu, Sukapura, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40257', -6.974001, 107.630348);

