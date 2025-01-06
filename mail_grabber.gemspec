# frozen_string_literal: true

require_relative 'lib/mail_grabber/version'

Gem::Specification.new do |spec|
  spec.name          = 'mail_grabber'
  spec.version       = MailGrabber::VERSION
  spec.authors       = ['Norbert Szivós']
  spec.email         = ['sysqa@yahoo.com']

  spec.summary       = 'Grab mails to inspect with MailGrabber.'
  spec.description   = 'MailGrabber is yet another solution to inspect sent ' \
                       'emails.'
  spec.homepage      = 'https://github.com/MailToolbox/mail_grabber'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  spec.extra_rdoc_files = ['LICENSE.txt', 'README.md']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] =
    'https://github.com/MailToolbox/mail_grabber'
  spec.metadata['changelog_uri'] =
    'https://github.com/MailToolbox/mail_grabber/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] =
    'https://github.com/MailToolbox/mail_grabber/issues'
  spec.metadata['documentation_uri'] =
    'https://rubydoc.info/github/MailToolbox/mail_grabber/main'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = %w[README.md CHANGELOG.md LICENSE.txt] + Dir.glob('lib/**/*')
  spec.require_paths = ['lib']

  spec.add_dependency 'mail', '~> 2.5'
  spec.add_dependency 'rackup', '~> 2.1'
  spec.add_dependency 'sqlite3', '~> 2.0'
end
