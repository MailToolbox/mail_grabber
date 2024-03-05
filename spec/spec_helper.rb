# frozen_string_literal: true

# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'capybara/cuprite'
require 'capybara/rspec'
require 'mail_grabber'
require 'mail_grabber/web'
require 'mail'

Capybara.register_server :webrick do |app, port, host, **options|
  require 'rackup/handler/webrick'

  options = {
    Host: host,
    Port: port,
    AccessLog: [],
    Logger: WEBrick::Log.new(nil, 0)
  }.merge(options)

  Rackup::Handler::WEBrick.run(app, **options)
end
Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, process_timeout: 30, timeout: 15)
end
Capybara.javascript_driver = :cuprite
Capybara.default_driver = Capybara.javascript_driver
Capybara.save_path = 'tmp'
Capybara.app = MailGrabber::Web
Capybara.server = :webrick

DBCONFIG = {
  folder: 'tmp',
  filename: 'mail_grabber_test.sqlite3',
  params: {
    type_translation: true,
    results_as_hash: true
  }
}.freeze

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    stub_const('TestDbClass', Class.new { include MailGrabber::DatabaseHelper })
    stub_const('MailGrabber::DatabaseHelper::DATABASE', DBCONFIG)
  end

  config.after { TestDbClass.new.delete_all_messages }

  config.after(:suite) do
    db_location = "#{DBCONFIG[:folder]}/#{DBCONFIG[:filename]}"

    FileUtils.rm_f(db_location)
  end
end
