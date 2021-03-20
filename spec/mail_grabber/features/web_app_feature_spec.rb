# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MailGrabber Web App', type: :feature do
  before do
    TestDbClass.new.store_mail(message)

    visit '/'
  end

  after { File.delete('tmp/LICENSE.txt') if File.exist?('tmp/LICENSE.txt') }

  # rubocop:disable RSpec/VariableDefinition, RSpec/VariableName
  let(:message) do
    mail =
      Mail.new do
        from    'from@example.com'
        to      'to@example.com'
        cc      'cc@example.com'
        bcc     'bcc@example.com'
        subject 'This is the message subject'

        add_file File.expand_path('../../LICENSE.txt', File.dirname(__dir__))
      end

    mail.attachments.inline['mail_grabber515x500.png'] =
      File.read(File.expand_path('../../images/mail_grabber515x500.png',
                                 File.dirname(__dir__)))

    text_part =
      Mail::Part.new do
        body 'This is plain text'
      end

    html_part =
      Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body "<!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv=\"Content-Type\" content=\"text/html;
                charset=utf-8\" />
              <style>
                p { color: red; }
              </style>
            </head>

            <body>
              <h1>This is HTML</h1>
              <img src=\"#{mail.attachments['mail_grabber515x500.png'].url}\"/>
              <p>Test email body</p>
            </body>
          </html>"
      end

    mail.text_part = text_part
    mail.html_part = html_part

    mail
  end
  # rubocop:enable RSpec/VariableDefinition, RSpec/VariableName

  def message_count
    TestDbClass.new.connection_execute('SELECT COUNT(*) AS count FROM mail')
  end

  # rubocop:disable RSpec/ExampleLength
  it 'loads MailGrabber' do
    expect(page).to have_css('h1', text: 'Grabber')
    expect(page).to have_css('li', text: 'Reload')
    expect(page).to have_css('li', text: 'Clear')
  end

  it 'loads the message list' do
    within(:xpath, '//ul[@data-content-type="message-list"]') do
      expect(page).to have_content('from@example.com')
      expect(page).to have_content('This is the message subject')
    end
  end

  it 'does NOT load the message content' do
    within(:xpath, '//div[@data-content-type="message-content"]') do
      expect(page).to have_content('')
    end
  end

  context 'when clicks one of the message from the list' do
    before { find(:xpath, '//ul[@data-content-type="message-list"]/li').click }

    it 'loads the message content' do
      within(:xpath, '//div[@data-content-type="message-content"]') do
        expect(page).to have_content('This is the message subject')

        expect(page).to have_content('from@example.com')
        expect(page).to have_content('to@example.com')
        expect(page).to have_content('cc@example.com')
        expect(page).to have_content('bcc@example.com')

        expect(page).to have_content('LICENSE.txt')

        expect(page).to have_css('li', text: 'HTML')
        expect(page).to have_css('li', text: 'Plain text')
        expect(page).to have_css('li', text: 'Raw')
        expect(page).to have_css('li', text: 'Delete')
        expect(page).to have_css('li', text: 'Close')
      end
    end

    it 'shows the HTML message content by default' do
      within_frame(:xpath,
                   '//iframe[@data-content-type="message-html-body"]') do
        expect(page).to have_content('This is HTML')
      end

      expect(
        find(
          :xpath,
          '//pre[@data-content-type="message-text-body"]',
          visible: false
        )['class']
      )
        .to include('hide')

      expect(
        find(
          :xpath,
          '//pre[@data-content-type="message-raw-body"]',
          visible: false
        )['class']
      )
        .to include('hide')
    end

    it 'shows inline attachment' do
      within_frame(:xpath,
                   '//iframe[@data-content-type="message-html-body"]') do
        expect(find(:xpath, '//img')['src']).to match(%r{data:image/png;base64})
      end
    end

    it 'downloads attachment' do
      within(:xpath, '//ul[@data-content-type="message-attachments"]') do
        click_link('LICENSE.txt')
        sleep 1
        expect(File.exist?('tmp/LICENSE.txt')).to be true
      end
    end

    context 'when clicks Plain text tab' do
      before { find(:xpath, '//li[@data-message-tab="text"]').click }

      it 'shows the Plain text message content' do
        within(:xpath, '//pre[@data-content-type="message-text-body"]') do
          expect(page).to have_content('This is plain text')
        end

        expect(
          find(
            :xpath,
            '//iframe[@data-content-type="message-html-body"]',
            visible: false
          )['class']
        )
          .to include('hide')

        expect(
          find(
            :xpath,
            '//pre[@data-content-type="message-raw-body"]',
            visible: false
          )['class']
        )
          .to include('hide')
      end
    end

    context 'when clicks Raw tab' do
      before { find(:xpath, '//li[@data-message-tab="raw"]').click }

      it 'shows the Raw message content' do
        within(:xpath, '//pre[@data-content-type="message-raw-body"]') do
          expect(page).to have_content('From: from@example.com')
        end

        expect(
          find(
            :xpath,
            '//iframe[@data-content-type="message-html-body"]',
            visible: false
          )['class']
        )
          .to include('hide')

        expect(
          find(
            :xpath,
            '//pre[@data-content-type="message-text-body"]',
            visible: false
          )['class']
        )
          .to include('hide')
      end
    end

    context 'when clicks Delete tab' do
      it 'deletes the message' do
        expect(message_count.first['count']).to eq(1)

        find(:xpath, '//li[@data-content-type="message-delete-tab"]').click

        within(:xpath, '//ul[@data-content-type="message-list"]') do
          expect(page).to have_content('')
        end

        within(:xpath, '//div[@data-content-type="message-content"]') do
          expect(page).to have_content('')
        end

        expect(message_count.first['count']).to eq(0)
      end
    end

    context 'when clicks Close tab' do
      it 'closes the message' do
        expect(message_count.first['count']).to eq(1)

        find(:xpath, '//li[@data-content-type="message-close-tab"]').click

        within(:xpath, '//div[@data-content-type="message-content"]') do
          expect(page).to have_content('')
        end

        expect(message_count.first['count']).to eq(1)
      end
    end

    context 'when clicks Reload tab' do
      before do
        find(:xpath, '//li[@data-content-type="message-reload-tab"]').click
      end

      it 'loads the message list' do
        within(:xpath, '//ul[@data-content-type="message-list"]') do
          expect(page).to have_content('from@example.com')
          expect(page).to have_content('This is the message subject')
        end
      end

      it 'returns to the default state' do
        within(:xpath, '//div[@data-content-type="message-content"]') do
          expect(page).to have_content('')
        end
      end
    end

    context 'when clicks Clear tab' do
      it 'deletes all messages' do
        expect(message_count.first['count']).to eq(1)

        find(:xpath, '//li[@data-content-type="message-clear-tab"]').click

        within(:xpath, '//ul[@data-content-type="message-list"]') do
          expect(page).to have_content('')
        end

        within(:xpath, '//div[@data-content-type="message-content"]') do
          expect(page).to have_content('')
        end

        expect(message_count.first['count']).to eq(0)
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
