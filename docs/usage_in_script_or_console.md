# How to use MailGrabber in a Ruby script or IRB console

First you should be able to `require 'mail'` and `require 'mail_grabber'` to get started.

To send emails we can use the `MailGrabber::DeliveryMethod` directly.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:2100, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

MailGrabber::DeliveryMethod.new.deliver!(message)
# => true
```

Or add `MailGrabber::DeliveryMethod` to `mail.delivery_method`.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:2100, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method MailGrabber::DeliveryMethod
# => #<MailGrabber::DeliveryMethod:0x00007fa25698e400>

mail.deliver
# => #<Mail::Message:2100, Multipart: false, Headers: <Date: Sat, 20 Mar 2021 16:03:34 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60560ec6c7ab9_110087e4-53b@local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>

# or

mail.deliver!
# => #<Mail::Message:2100, Multipart: false, Headers: <Date: Sat, 20 Mar 2021 16:13:05 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60561101cd2b5_113b37e4309b5@local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>
```

Then we can check grabbed emails on the web interface. To do that we need a `config.ru` file with the following content.

```ruby
require 'mail_grabber/web'

run MailGrabber::Web
```

After that we can start the server with the `rackup` command. If the server is running then open a browser and visit on the `http://localhost:9292` page.
