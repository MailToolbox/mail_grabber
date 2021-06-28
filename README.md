# M<img src="https://raw.githubusercontent.com/MailToolbox/mail_grabber/main/images/mail_grabber515x500.png" height="22" />ilGrabber

[![Gem Version](https://badge.fury.io/rb/mail_grabber.svg)](https://badge.fury.io/rb/mail_grabber)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen)](https://github.com/MailToolbox/mail_grabber/blob/main/LICENSE.txt)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![MailGrabber CI](https://github.com/MailToolbox/mail_grabber/actions/workflows/mail_grabber_ci.yml/badge.svg)](https://github.com/MailToolbox/mail_grabber/actions/workflows/mail_grabber_ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/97deed5c1fbd003ca810/maintainability)](https://codeclimate.com/github/MailToolbox/mail_grabber/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/97deed5c1fbd003ca810/test_coverage)](https://codeclimate.com/github/MailToolbox/mail_grabber/test_coverage)

**MailGrabber** is yet another solution to inspect sent emails.

It has two part:
- delivery method to grab emails and store into a database
- simple rack web interface to check those emails

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail_grabber'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mail_grabber

## Usage

- [How to use MailGrabber in a Ruby script or IRB console](https://github.com/MailToolbox/mail_grabber/blob/main/docs/usage_in_script_or_console.md)
- [How to use MailGrabber in Ruby on Rails](https://github.com/MailToolbox/mail_grabber/blob/main/docs/usage_in_ruby_on_rails.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:

- Update [CHANGELOG.md](https://github.com/MailToolbox/mail_grabber/blob/main/CHANGELOG.md)
- Update the version number in `version.rb` manually or use `gem-release` gem and run `gem bump -v major|minor|patch|rc|beta`.
- Build gem with `bundle exec rake build`.
- Run `bundle install` to update gemfiles and commit the changes.
- Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome. Please read [CONTRIBUTING.md](https://github.com/MailToolbox/mail_grabber/blob/main/CONTRIBUTING.md) if you would like to contribute to this project.

## Inspiration

- [MailCatcher](https://github.com/sj26/mailcatcher)
- [letter_opener_web](https://github.com/fgrehm/letter_opener_web)
- [Rack](https://github.com/rack/rack)
- [Rack::Router](https://github.com/pjb3/rack-router)
- [Sidekiq](https://github.com/mperham/sidekiq)
- and other solutions regarding in this topic

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/MailToolbox/mail_grabber/blob/main/LICENSE.txt).
