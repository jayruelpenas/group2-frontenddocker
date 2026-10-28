
USE copc_record_management;

-- 1. Academic programs
CREATE TABLE programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_name VARCHAR(200) NOT NULL UNIQUE,
    degree_code VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users and accounts
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM(
        'COPC Coordinator',
        'Program Head',
        'Faculty',
        'Office Representative',
        'Dean'
    ) NOT NULL,
    profile_photo_path VARCHAR(500),
    account_status ENUM('Active', 'Inactive')
        NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id)
        REFERENCES programs(program_id)
        ON DELETE SET NULL
);

-- 3. COPC requirements
CREATE TABLE requirements (
    requirement_id INT AUTO_INCREMENT PRIMARY KEY,
    requirement_name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Individual requirement records
CREATE TABLE requirement_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    requirement_id INT NOT NULL,
    record_name VARCHAR(200) NOT NULL,
    description TEXT,
    target_count INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requirement_id)
        REFERENCES requirements(requirement_id),
    UNIQUE (requirement_id, record_name)
);

-- 5. Uploaded documents
CREATE TABLE documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT NOT NULL,
    uploaded_by INT NOT NULL,
    previous_version_id INT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50),
    file_size_bytes BIGINT,
    version_number INT NOT NULL DEFAULT 1,
    status ENUM(
        'Requested',
        'For Review',
        'Approved',
        'For Revision',
        'Rejected'
    ) NOT NULL DEFAULT 'For Review',
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id)
        REFERENCES requirement_records(record_id),
    FOREIGN KEY (uploaded_by)
        REFERENCES users(user_id),
    FOREIGN KEY (previous_version_id)
        REFERENCES documents(document_id)
        ON DELETE SET NULL,
    UNIQUE (record_id, version_number)
);

-- 6. Document reviews
CREATE TABLE document_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    document_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    decision ENUM(
        'Approved',
        'For Revision',
        'Rejected'
    ) NOT NULL,
    comments TEXT,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id)
        REFERENCES documents(document_id),
    FOREIGN KEY (reviewer_id)
        REFERENCES users(user_id)
);

-- 7. Document requests
CREATE TABLE document_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    requirement_id INT NOT NULL,
    record_id INT NULL,
    requested_by INT NOT NULL,
    assigned_to INT NULL,
    request_message TEXT,
    due_date DATE,
    status ENUM(
        'Open',
        'Submitted',
        'Completed',
        'Cancelled'
    ) NOT NULL DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requirement_id)
        REFERENCES requirements(requirement_id),
    FOREIGN KEY (record_id)
        REFERENCES requirement_records(record_id)
        ON DELETE SET NULL,
    FOREIGN KEY (requested_by)
        REFERENCES users(user_id),
    FOREIGN KEY (assigned_to)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);

-- 8. Notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM(
        'Document Request',
        'Revision Request',
        'New Submission',
        'Document Approval',
        'General'
    ) NOT NULL DEFAULT 'General',
    related_document_id INT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (related_document_id)
        REFERENCES documents(document_id)
        ON DELETE SET NULL
);

-- 9. Dashboard activity logs
CREATE TABLE activity_logs (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    related_document_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL,
    FOREIGN KEY (related_document_id)
        REFERENCES documents(document_id)
        ON DELETE SET NULL
);

-- 10. Notification preferences
CREATE TABLE user_notification_preferences (
    preference_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    document_requests BOOLEAN NOT NULL DEFAULT TRUE,
    revision_requests BOOLEAN NOT NULL DEFAULT TRUE,
    new_submissions BOOLEAN NOT NULL DEFAULT TRUE,
    document_approvals BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- 11. User display settings
CREATE TABLE user_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    theme ENUM('Light', 'Dark') NOT NULL DEFAULT 'Light',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_documents_record
    ON documents(record_id);

CREATE INDEX idx_documents_status_date
    ON documents(status, uploaded_at);

CREATE INDEX idx_notifications_user_read
    ON notifications(user_id, is_read);

CREATE INDEX idx_activity_created
    ON activity_logs(created_at);
