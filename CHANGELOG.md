# Change log

## 1.4.1 (2025-01-07)

### Bug fixes

* Add base64 gem as a dependency because from Ruby 3.4 this is not a standard gem.


## 1.4.0 (2025-01-07)

### Changes

* Upgrade sqlite3 to version 2.0.4
* Add Ruby 3.4 support.
* Drop Ruby 2.7 support.
* Update bundler and gems.


## 1.3.7 (2024-09-25)

### Changes

* Update webrick to version 1.8.2 because of security issues.
* Upgrade rackup to version 2.1.0
* Update gems.


## 1.3.6 (2024-03-05)

### Changes

* Update rack to version 3.0.9.1 because of security issues.
* Update gems.


## 1.3.5 (2024-02-20)

### Changes

* Add Ruby 3.3 support.
* Update bundler and gems.
* Replace apparition gem to cuprite gem.


## 1.3.4 (2023-05-19)

### Changes

* Add Ruby 3.2 support.
* Update bundler and gems.


## 1.3.3 (2023-03-19)

### Changes

* Update rack to version 3.0.7 because of security issues.
* Update gem description.
* Update gems.


## 1.3.2 (2023-03-11)

### Changes

* Update rack to version 3.0.4.2 because of security issues.
* Update bundler and gems.


## 1.3.1 (2023-01-25)

### Changes

* Update rack to version 3.0.4.1 because of security issues.
* Update bundler and gems.

### Bug fixes

* Fix the Ruby version problem in the GitHub Actions workflow file.


## 1.3.0 (2022-10-04)

### Changes

* Replace rack to rackup gem as a dependency.
  In the rack 3.x gem it was extracted rackup command, Rack::Server, Rack::Handler, Rack::Lobster and related code into a separate gem.
* Update bundler and gems.

### Bug fixes

* Fix infinite scroll.
  In the new Chrome browser, the scrollTop is a float and not an integer. Because of that, the infinite scroll was stopped working.
* Override webrick server for capybara in RSpec configuration.
  At this moment capybara does not support the new rack/rackup changes.


## 1.2.1 (2022-05-27)

### Changes

* Update rack to version 2.2.3.1 because of security issues.


## 1.2.0 (2022-05-26)

### Changes

* Drop Ruby 2.6 support.
* Fix some grammar issues and typos.
* Update bundler and gems.


## 1.1.0 (2021-12-31)

### Changes

* Add Ruby 3.1 support.
* Drop Ruby 2.5 support.
* Replace Travis with GitHub Actions.
* Update bundler and gems.

### Bug fixes

* Update apparition gem from github to fix issues.


## 1.0.0 (2021-04-02)

### Changes

* Update documentation.
* Change JavaScript to hide HTML tab if mail does not have HTML part.
* Refactoring the JavaScript code.
* Change the documentation uri in the gemspec file.
* Update .rubocop.yml.
* Update gems.

### Bug fixes

* Fix 3x load message list when reload tab and infinite scroll was used.


## 1.0.0.rc1 (2021-03-20)

* Implement MailGrabber methods and functionality. See [README.md](https://github.com/MailToolbox/mail_grabber/blob/main/README.md)
