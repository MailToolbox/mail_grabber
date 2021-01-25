# frozen_string_literal: true

require 'sqlite3'

module MailGrabber
  module DatabaseHelper
    def store_message(message)
      insert_into_mail.execute(
        message.to&.join(', '),
        message.cc&.join(', '),
        message.bcc&.join(', '),
        message.subject,
        message.from&.join(', '),
        message.to_s
      )

      store_message_part(message)
    end

    def store_message_part(message)
      extract_message_parts(message).each do |part|
        body = part.body.to_s

        insert_into_mail_part.execute(
          database.last_insert_row_id,
          extract_cid(part),
          extract_mime_type(part),
          attachment?(part),
          inline?(part),
          part.filename,
          part.charset,
          body,
          body.length
        )
      end
    end

    def all_message
      select_all_mail.execute.map { |row| row }
    end

    private

    def attachment?(object)
      object.attachment? ? 1 : 0
    end

    def extract_cid(object)
      object.cid if object.respond_to?(:cid)
    end

    def extract_message_parts(message)
      message.multipart? ? message.all_parts : [message]
    end

    def extract_mime_type(object)
      object.mime_type || 'text/plain'
    end

    def inline?(object)
      object.respond_to?(:inline) && object.inline? ? 1 : 0
    end

    def database
      Dir.mkdir('tmp') unless Dir.exist?('tmp')

      @database ||= begin
        SQLite3::Database.new('tmp/mail_grabber.sqlite3',
                              type_translation: true,
                              results_as_hash: true).tap do |db|
          create_mail_table(db)
          create_mail_part_table(db)
        end
      end
    end

    def create_mail_table(db)
      db.execute(<<-SQL)
        CREATE TABLE IF NOT EXISTS mail (
          id INTEGER PRIMARY KEY ASC,
          mail_to TEXT,
          mail_cc TEXT,
          mail_bcc TEXT,
          mail_subject TEXT,
          mail_from TEXT,
          raw_mail BLOB,
          created_at DATETIME DEFAULT CURRENT_DATETIME
        )
      SQL
    end

    def create_mail_part_table(db)
      db.execute(<<-SQL)
        CREATE TABLE IF NOT EXISTS mail_part (
          id INTEGER PRIMARY KEY ASC,
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
          FOREIGN KEY (mail_id) REFERENCES mail (id) ON DELETE CASCADE
        )
      SQL
    end

    def insert_into_mail
      @insert_into_mail ||=
        database.prepare(<<-SQL)
          INSERT INTO mail (
            mail_to,
            mail_cc,
            mail_bcc,
            mail_subject,
            mail_from,
            raw_mail,
            created_at
          )
          VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
        SQL
    end

    def insert_into_mail_part
      @insert_into_mail_part ||=
        database.prepare(<<-SQL)
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

    def select_all_mail
      @select_all_mail ||=
        database.prepare('SELECT * FROM mail ORDER BY created_at DESC')
    end
  end
end
