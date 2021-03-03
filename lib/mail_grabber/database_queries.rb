# frozen_string_literal: true

module MailGrabber
  module DatabaseQueries
    # Create mail table if it is not exist.
    #
    # @param [SQLite3::Database] db to execute create table query
    def create_mail_table(db)
      db.execute(<<-SQL)
        CREATE TABLE IF NOT EXISTS mail (
          id INTEGER PRIMARY KEY,
          subject TEXT,
          senders TEXT,
          recipients TEXT,
          carbon_copy TEXT,
          blind_carbon_copy TEXT,
          raw BLOB,
          created_at DATETIME DEFAULT CURRENT_DATETIME
        )
      SQL
    end

    # Create mail part table if it is not exist.
    #
    # @param [SQLite3::Database] db to execute create table query
    def create_mail_part_table(db)
      db.execute(<<-SQL)
        CREATE TABLE IF NOT EXISTS mail_part (
          id INTEGER PRIMARY KEY,
          mail_id INTEGER NOT NULL,
          cid TEXT,
          mime_type TEXT,
          is_attachment INTEGER,
          is_inline INTEGER,
          filename TEXT,
          charset TEXT,
          body BLOB,
          size INTEGER,
          created_at DATETIME DEFAULT CURRENT_DATETIME,
          FOREIGN KEY (mail_id) REFERENCES mail(id) ON DELETE CASCADE
        )
      SQL
    end

    # Insert mail query.
    #
    # @return [Srting] with the insert mail query
    def insert_into_mail_query
      <<-SQL
        INSERT INTO mail (
          subject,
          senders,
          recipients,
          carbon_copy,
          blind_carbon_copy,
          raw,
          created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
      SQL
    end

    # Insert mail part query.
    #
    # @return [Srting] with the insert mail part query
    def insert_into_mail_part_query
      <<-SQL
        INSERT INTO mail_part (
          mail_id,
          cid,
          mime_type,
          is_attachment,
          is_inline,
          filename,
          charset,
          body,
          size,
          created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
      SQL
    end

    # Select messages with pagination query.
    #
    # @return [Srting] with the select messages query
    def select_messages_with_pagination_query
      <<-SQL
        SELECT id, subject, senders, created_at
        FROM mail
        WHERE id NOT IN (
          SELECT id
          FROM mail
          ORDER BY id DESC, created_at DESC
          LIMIT ?
        )
        ORDER BY id DESC, created_at DESC
        LIMIT ?
      SQL
    end
  end
end
