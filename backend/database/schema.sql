CREATE DATABASE IF NOT EXISTS igoto_db;
USE igoto_db;

DROP TABLE IF EXISTS investments;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('investor', 'admin') DEFAULT 'investor',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    project_name VARCHAR(150) NOT NULL,
    description TEXT,
    funding_target DECIMAL(15, 2) NOT NULL,
    profit_percentage DECIMAL(5, 2) NOT NULL,
    admin_fee DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    status ENUM('open', 'funded', 'completed') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE investments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    user_id INT NOT NULL,
    investor_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    bank_name VARCHAR(50) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    profit_percentage DECIMAL(5, 2) NOT NULL,
    gross_profit DECIMAL(15, 2) NOT NULL,
    admin_fee DECIMAL(15, 2) NOT NULL,
    net_profit DECIMAL(15, 2) NOT NULL,
    total_return DECIMAL(15, 2) NOT NULL,
    transfer_proof_path VARCHAR(255) NOT NULL,
    status ENUM('pending', 'verified', 'rejected', 'completed') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at DATETIME NULL,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

