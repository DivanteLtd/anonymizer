require 'json'

require 'spec_helper'

RSpec.describe '#project_magento_1_9' do
  context 'check if config file is valid' do
    before do
      @project_file_path = './lib/anonymizer/project/basic/magento_1_9.json'
      @data = JSON.parse File.read @project_file_path
    end

    it 'should exists default configuration file for Magento 1.9' do
      expect(File.exist?(@project_file_path)).to be true
    end

    it 'should be a valid json file' do
      config = File.read @project_file_path
      expect(JSONHelper.valid_json?(config)).to be true
    end

    it 'should exists project type variable' do
      expect(@data['type']).to eq('basic')
    end

    it 'should exists database tables to anonymize variable' do
      expect(@data['tables'].is_a?(Hash)).to be true
    end

    it 'all column should set action' do
      no_action = true

      @data['tables'].each do |_table_name, columns|
        columns.each do |_column_name, info|
          no_action = false unless info['action']
        end
      end

      expect(no_action).to be true
    end
  end
end
