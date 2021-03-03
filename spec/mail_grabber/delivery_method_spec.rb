# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::DeliveryMethod do
  describe '#deliver!' do
    context 'without deliver! method paramemter' do
      subject(:deliver) { described_class.new.deliver! }

      it 'raises error' do
        expect { deliver }.to raise_error(ArgumentError)
      end
    end

    context 'when deliver! method has paramemter' do
      subject(:deliver) { described_class.new.deliver!(message) }

      context 'and message paramemter does NOT a Mail::Message object' do
        let(:message) { nil }

        it 'raises error' do
          expect { deliver }
            .to raise_error(MailGrabber::Error::WrongParameter)
        end
      end

      context 'and message paramemter is a Mail::Message object' do
        let(:message) { Mail.new }

        # rubocop:disable RSpec/AnyInstance
        it 'does NOT raise error' do
          allow_any_instance_of(described_class).to receive(:store_mail)
          expect { deliver }.not_to raise_error
        end

        it 'calls store_mail method' do
          expect_any_instance_of(described_class).to receive(:store_mail)
          deliver
        end
        # rubocop:enable RSpec/AnyInstance
      end
    end
  end
end
