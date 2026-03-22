-- ============================================================
-- SnippetVault MySQL Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS snippetvault
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE snippetvault;

CREATE TABLE IF NOT EXISTS snippets (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    title      VARCHAR(255) NOT NULL,
    content    TEXT         NOT NULL,
    tags       VARCHAR(500) NOT NULL DEFAULT '',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                            ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- Seed data – safe to run multiple times (INSERT IGNORE)
-- ---------------------------------------------------------------
INSERT IGNORE INTO snippets (id, title, content, tags) VALUES
(1,
 'Hello World in Go',
 'package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("Hello, World!")\n}',
 'go,beginner,hello-world'),
(2,
 'SQL Parameterised Query',
 'stmt, err := db.Prepare("SELECT * FROM users WHERE id = ?")\nif err != nil {\n\tlog.Fatal(err)\n}\ndefer stmt.Close()\n\nrow := stmt.QueryRow(userID)',
 'sql,security,go'),
(3,
 'Python List Comprehension',
 'squares = [x**2 for x in range(10) if x % 2 == 0]\nprint(squares)  # [0, 4, 16, 36, 64]',
 'python,tips,one-liner');