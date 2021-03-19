# frozen_string_literal: true

require_relative 'lib/mail_grabber/version'

Gem::Specification.new do |spec|
  spec.name          = 'mail_grabber'
  spec.version       = MailGrabber::VERSION
  spec.authors       = ['Norbert Szivós']
  spec.email         = ['sysqa@yahoo.com']

  spec.summary       = 'Grabs mails to inspect with MailGrabber.'
  spec.description   = 'Delivery Method to grab emails and inspect on a web ' \
                       'interface. We can use this Delivery Method with ' \
                       'Ruby on Rails ActionMailer or other solutions.'
  spec.homepage      = 'https://github.com/MailToolbox/mail_grabber'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.extra_rdoc_files = ['LICENSE.txt', 'README.md']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] =
    'https://github.com/MailToolbox/mail_grabber'
  spec.metadata['changelog_uri'] =
    'https://github.com/MailToolbox/mail_grabber/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] =
    'https://github.com/MailToolbox/mail_grabber/issues'
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/mail_grabber'

  spec.files = %w[README.md CHANGELOG.md LICENSE.txt] + Dir.glob('lib/**/*')
  spec.require_paths = ['lib']

  spec.add_dependency 'mail', '~> 2.5'
  spec.add_dependency 'rack', '~> 2.2'
  spec.add_dependency 'sqlite3', '~> 1.4'
end
