require 'spec_helper'

require './lib/anonymizer/model/notifier/mail.rb'

RSpec.describe Notifier::Mail, '#notifier::mail' do
  it 'should exists class Notifier::Mail' do
    expect(Object.const_defined?('Notifier::Mail')).to be true
  end

  it 'should send email' do
    mailer = Notifier::Mail.new

    # expect_any_instance_of(::Mail).to receive(:to)

    # mailer.send('Some message', { 'enabled' => true, 'method' => :stmp } )
  end
end
