require 'spec_helper'

require './lib/anonymizer/model/notifier.rb'

RSpec.describe Notifier, '#notifier' do
  it 'should exists class Notifier' do
    expect(Object.const_defined?('Notifier')).to be true
  end

  it 'should send email for enabled email notification in config' do
    stub_const('CONFIG', 'notifier' => { 'mail' => { 'enabled' => true } })

    notifier = Notifier.new

    expect_any_instance_of(Notifier::Mail).to receive(:send)

    notifier.send('Some message')
  end

  it 'shouldn\'t send email for disabled email notification in config' do
    stub_const('CONFIG', 'notifier' => { 'mail' => { 'enabled' => false } })

    notifier = Notifier.new

    expect_any_instance_of(Notifier::Mail).to receive(:send).never

    notifier.send('Some message')
  end
end
