require 'spec_helper'
require './lib/anonymizer/helper/logger_helper.rb'

RSpec.describe '#logger_helper' do
  context 'check configuration' do
    before do
      @file_name = 'test'
      @path = LOG_DIR + "/#{@file_name}.log"
    end

    it 'shuold be setted file as a logger' do
      stub_const('CONFIG', 'logger' => { 'enabled' => true })

      expect(STDERR).to receive(:reopen).with(@path, 'w')
      expect(STDOUT).to receive(:reopen).with(@path, 'w')

      LoggerHelper.file(@file_name)
    end

    it 'shuoldn\'t be setted file as a logger' do
      stub_const('CONFIG', 'logger' => { 'enabled' => false })

      expect(STDERR).not_to receive(:reopen).with(@path, 'w')
      expect(STDOUT).not_to receive(:reopen).with(@path, 'w')

      LoggerHelper.file(@file_name)
    end
  end
end
