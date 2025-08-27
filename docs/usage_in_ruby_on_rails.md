# How to use MailGrabber in Ruby on Rails

Add the `mail_grabber` gem to the `Gemfile` and run `bundle install`.

Then change `config/environments/development.rb` file.

```ruby
config.action_mailer.delivery_method = :mail_grabber
```

Also, add a route that we can reach the MailGrabber web interface. Let's change the `config/routes.rb` file.

```ruby
require 'mail_grabber/web'

Rails.application.routes.draw do
  mount MailGrabber::Web => '/mail_grabber'
end
```

So now we should add a mailer method. Let's create the `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

Then we should add views (the body) of this email, so create the `app/views/test_mailer/send_test.html.erb`

```erb
<p>Test email body</p>
```

and the `app/views/test_mailer/send_test.text.erb` files.

```erb
Test email body
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (2.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 84.8ms
#Sent mail to to@example.com (34.8ms)
#Date: Sat, 20 Mar 2021 16:56:34 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60561b32d6d5a_12424ebdc947a5@local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60561b32d4370_12424ebdc946bb";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60561b32d4370_12424ebdc946bb
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60561b32d4370_12424ebdc946bb
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_60561b32d4370_12424ebdc946bb--
#
#=> #<Mail::Message:61160, Multipart: true, Headers: <Date: Sat, 20 Mar 2021 16:56:34 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60561b32d6d5a_12424ebdc947a5@local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60561b32d4370_12424ebdc946bb"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Then we can check the grabbed emails on the web interface. If the Rails server is running, then open a browser and visit on the `http://localhost:3000/mail_grabber` page.
