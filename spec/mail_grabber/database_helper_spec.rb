# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::DatabaseHelper do
  before do
    stub_const('TestClass', Class.new { include MailGrabber::DatabaseHelper })
    stub_const('MailGrabber::DatabaseHelper::DATABASE', dbconfig)
  end

  after { File.delete("#{dbconfig[:folder]}/#{dbconfig[:filename]}") }

  let(:dbconfig) do
    {
      folder: 'tmp',
      filename: 'mail_grabber_test.sqlite3',
      params: {
        type_translation: true,
        results_as_hash: true
      }
    }
  end
  # rubocop:disable RSpec/VariableDefinition, RSpec/VariableName
  let(:message) do
    Mail.new do
      from    'from@example.com'
      to      'to@example.com'
      subject 'This is the message subject'

      text_part do
        body 'This is plain text'
      end

      html_part do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1>'
      end
    end
  end
  # rubocop:enable RSpec/VariableDefinition, RSpec/VariableName

  describe '#connection' do
    context 'when it gets wrong request' do
      subject(:connection_method) do
        TestClass.new.connection { |db| db.execute('SELECT * FROM not_exist') }
      end

      it 'raises with MailGrabber::Error::DatabaseHelperError error' do
        expect { connection_method }
          .to raise_error(MailGrabber::Error::DatabaseHelperError)
      end
    end

    context 'when it gets good request' do
      subject(:connection_method) do
        TestClass.new.connection { |db| db.execute('SELECT * FROM mail') }
      end

      it 'does NOT raise error' do
        expect { connection_method }.not_to raise_error
      end
    end
  end

  describe '#connection_execute' do
    context 'when it gets wrong request' do
      subject(:connection_execute_method) do
        TestClass.new.connection_execute('SELECT * FROM not_exist')
      end

      it 'raises with MailGrabber::Error::DatabaseHelperError error' do
        expect { connection_execute_method }
          .to raise_error(MailGrabber::Error::DatabaseHelperError)
      end
    end

    context 'when it gets good request' do
      subject(:connection_execute_method) do
        TestClass.new.connection_execute('SELECT * FROM mail')
      end

      it 'does NOT raise error' do
        expect { connection_execute_method }.not_to raise_error
      end

      it 'returns back with the requested data' do
        expect(connection_execute_method).to eq([])
      end
    end
  end

  describe '#connection_execute_transaction' do
    context 'when it gets wrong request' do
      subject(:connection_execute_transaction_method) do
        TestClass.new.connection_execute_transaction do |db|
          db.execute('SELECT * FROM not_exist')
        end
      end

      it 'raises with MailGrabber::Error::DatabaseHelperError error' do
        expect { connection_execute_transaction_method }
          .to raise_error(MailGrabber::Error::DatabaseHelperError)
      end
    end

    context 'when it gets good request' do
      subject(:connection_execute_transaction_method) do
        TestClass.new.connection_execute_transaction do |db|
          db.execute('SELECT * FROM mail')
        end
      end

      it 'does NOT raise error' do
        expect { connection_execute_transaction_method }.not_to raise_error
      end
    end
  end

  describe '#delete_all_messages' do
    subject(:delete_all_messages_method) { TestClass.new.delete_all_messages }

    before { TestClass.new.store_mail(message) }

    it 'deletes all stored messages' do
      expect(TestClass.new.select_all_messages.count).to eq(1)
      expect(delete_all_messages_method).to eq([])
      expect(TestClass.new.select_all_messages.count).to eq(0)
    end
  end

  describe '#delete_message_by' do
    subject(:delete_message_by_method) { TestClass.new.delete_message_by(1) }

    before { TestClass.new.store_mail(message) }

    it 'deletes the message' do
      expect(TestClass.new.select_all_messages.count).to eq(1)
      expect(delete_message_by_method).to eq([])
      expect(TestClass.new.select_all_messages.count).to eq(0)
    end
  end

  describe '#select_all_messages' do
    subject(:select_all_messages_method) { TestClass.new.select_all_messages }

    before { TestClass.new.store_mail(message) }

    it 'returns all stored messages' do
      expect(select_all_messages_method.count).to eq(1)
    end
  end

  describe '#select_message_by' do
    subject(:select_message_by_method) { TestClass.new.select_message_by(1) }

    before { TestClass.new.store_mail(message) }

    it 'returns with the message' do
      expect(select_message_by_method['id']).to eq(1)
    end
  end

  describe '#select_message_parts_by' do
    subject(:select_message_parts_by_method) do
      TestClass.new.select_message_parts_by(1)
    end

    before { TestClass.new.store_mail(message) }

    it 'returns with the message parts' do
      expect(select_message_parts_by_method.count).to eq(2)
    end
  end

  describe '#select_messages_by' do
    subject(:select_messages_by_method) do
      TestClass.new.select_messages_by(page, per_page)
    end

    before { TestClass.new.store_mail(message) }

    context 'when both page and per_page parameters are wrong' do
      let(:page) { nil }
      let(:per_page) { nil }

      it 'returns with empty Array' do
        expect(select_messages_by_method).to eq([])
      end
    end

    context 'when one of the page or per_page parameter is wrong' do
      let(:page) { 1 }
      let(:per_page) { nil }

      it 'returns with empty Array' do
        expect(select_messages_by_method).to eq([])
      end
    end

    context 'when both page and per_page parameters are good' do
      let(:page) { 1 }
      let(:per_page) { 1 }

      it 'returns with the messages' do
        expect(select_messages_by_method.count).to eq(1)
      end
    end
  end

  describe '#store_mail' do
    subject(:store_mail_method) { TestClass.new.store_mail(message) }

    it 'creates the message' do
      expect(store_mail_method).to be true
    end
  end
end
