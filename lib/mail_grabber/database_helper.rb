# frozen_string_literal: true

require 'base64'
require 'sqlite3'

require 'mail_grabber/database_queries'

module MailGrabber
  module DatabaseHelper
    include DatabaseQueries

    DATABASE = {
      folder: 'tmp',
      filename: 'mail_grabber.sqlite3',
      params: {
        type_translation: true,
        results_as_hash: true
      }
    }.freeze

    # Create connection to the SQLite3 database. Use foreign_keys pragmas that
    # we can use DELETE CASCADE option. It accepts block to execute queries.
    # If something goes wrong, then it raises a database helper error.
    # Also ensure to close the database (important to close database if we don't
    # want to see database busy errors).
    def connection
      database = open_database
      database.foreign_keys = 'ON'

      yield database
    rescue SQLite3::Exception => e
      raise Error::DatabaseHelperError, e
    ensure
      database&.close
    end

    # Create connection and execute a query.
    #
    # @param [String] query which query we would like to execute
    # @param [Array] args any arguments which we will use in the query
    def connection_execute(query, args = [])
      connection { |db| db.execute(query, args) }
    end

    # Create connection and execute many queries in transaction. It accepts
    # block to execute queries. If something goes wrong, it rolls back the
    # changes and raises a database helper error.
    def connection_execute_transaction
      connection do |db|
        db.transaction

        yield db

        db.commit
      rescue SQLite3::Exception => e
        db.rollback

        raise Error::DatabaseHelperError, e
      end
    end

    # Helper method to delete all messages.
    def delete_all_messages
      connection_execute('DELETE FROM mail')
    end

    # Helper method to delete a message.
    #
    # @param [String/Integer] id the identifier of the message
    def delete_message_by(id)
      connection_execute('DELETE FROM mail WHERE id = ?', [id.to_i])
    end

    # Helper method to get all messages.
    def select_all_messages
      connection_execute('SELECT * FROM mail ORDER BY id DESC, created_at DESC')
    end

    # Helper method to get a message.
    #
    # @param [String/Integer] id the identifier of the message
    def select_message_by(id)
      connection_execute('SELECT * FROM mail WHERE id = ?', [id.to_i]).first
    end

    # Helper method to get a message part.
    #
    # @param [String/Integer] id the identifier of the message part
    def select_message_parts_by(id)
      connection_execute('SELECT * FROM mail_part WHERE mail_id = ?', [id.to_i])
    end

    # Helper method to get a specific number of messages. We can specify which
    # part of the table we need and how many messages want to see.
    #
    # @param [String/Integer] page which part of the table want to see
    # @param [String/Integer] per_page how many messages gives back
    def select_messages_by(page, per_page)
      page = page.to_i
      per_page = per_page.to_i

      connection_execute(
        select_messages_with_pagination_query,
        [
          per_page * (page - 1),
          per_page
        ]
      )
    end

    # Helper method to store a message in the database.
    #
    # @param [Mail::Message] message which we would like to store
    def store_mail(message)
      connection_execute_transaction do |db|
        insert_into_mail(db, message)

        insert_into_mail_part(db, message)
      end
    end

    private

    # Check that the given Mail::Part is an attachment or not.
    #
    # @param [Mail::Part] object
    #
    # @return [Integer] 1 if it is an attachment, else 0
    def attachment?(object)
      object.attachment? ? 1 : 0
    end

    # Convert the given message or body to utf8 string. Needs this that we can
    # send it as JSON.
    #
    # @param [Mail::Message/Mail::Body] object
    #
    # @return [String] which we can store in the database and send as JSON
    def convert_to_utf8_string(object)
      object.to_s.force_encoding('UTF-8')
    end

    # Encode the given decoded body with base64 encoding if Mail::Part is an
    # attachment.
    #
    # @param [Mail::Part] object
    # @param [String] string the decoded body of the Mail::Part
    #
    # @return [String] with the encoded or the original body
    def encode_if_attachment(object, string)
      object.attachment? ? Base64.encode64(string) : string
    end

    # Extract cid value from the Mail::Part.
    #
    # @param [Mail::Part] object
    #
    # @return [String] the cid value
    def extract_cid(object)
      object.cid if object.respond_to?(:cid)
    end

    # Extract all parts from the Mail::Message object. If it is not multipart,
    # then it returns with the original object in an Array.
    #
    # @param [Mail::Message] message
    #
    # @return [Array] with all parts of the message or an Array with the message
    def extract_mail_parts(message)
      message.multipart? ? message.all_parts : [message]
    end

    # Extract MIME type of the Mail::Part object. If it is nil, then it returns
    # with text/plain value.
    #
    # @param [Mail::Part] object
    #
    # @return [String] with MIME type of the part
    def extract_mime_type(object)
      object.mime_type || 'text/plain'
    end

    # Check that the given Mail::Part is an inline attachment or not.
    #
    # @param [Mail::Part] object
    #
    # @return [Integer] 1 if it is an inline attachment, else 0
    def inline?(object)
      object.respond_to?(:inline?) && object.inline? ? 1 : 0
    end

    # Store Mail::Message in the database.
    #
    # @param [SQLite::Database] db
    # @param [Mail::Message] message
    def insert_into_mail(db, message)
      db.execute(
        insert_into_mail_query,
        [
          message.subject,
          message.from&.join(', '),
          message.to&.join(', '),
          message.cc&.join(', '),
          message.bcc&.join(', '),
          convert_to_utf8_string(message)
        ]
      )
    end

    # Store Mail::Part in the database.
    #
    # @param [SQLite::Database] db
    # @param [Mail::Message] message
    def insert_into_mail_part(db, message)
      mail_id = db.last_insert_row_id

      extract_mail_parts(message).each do |part|
        body = part.decoded

        db.execute(
          insert_into_mail_part_query,
          [
            mail_id,
            extract_cid(part),
            extract_mime_type(part),
            attachment?(part),
            inline?(part),
            part.filename,
            part.charset,
            encode_if_attachment(part, body),
            body.length
          ]
        )
      end
    end

    # Open a database connection with the database. Also, it checks that the
    # database is existing or not. If it does not exist, then it creates a new
    # one.
    #
    # @return [SQLite3::Database] a database object
    def open_database
      db_location = "#{DATABASE[:folder]}/#{DATABASE[:filename]}"

      if File.exist?(db_location)
        SQLite3::Database.new(db_location, **DATABASE[:params])
      else
        FileUtils.mkdir_p(DATABASE[:folder])

        SQLite3::Database.new(db_location, **DATABASE[:params]).tap do |db|
          create_mail_table(db)
          create_mail_part_table(db)
        end
      end
    end
  end
end
