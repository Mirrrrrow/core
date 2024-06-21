ALTER TABLE users ADD COLUMN IF NOT EXISTS has_identity_card boolean DEFAULT false;

CREATE TABLE IF NOT EXISTS bank_cards (
    id INT PRIMARY KEY,
    owner LONGTEXT NOT NULL,
    disabled BOOLEAN NOT NULL DEFAULT false,
    pin INT NOT NULL
);
