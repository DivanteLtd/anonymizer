# frozen_string_literal: true

require 'spec_helper'

require './lib/anonymizer/model/database/truncate.rb'
RSpec.describe Database::Truncate, '#eav' do
  it 'should exists class Truncate' do
    expect(Object.const_defined?('Database::Truncate')).to be true
  end

  it 'should return valid query for empty value' do
    info = {}
    table_name = 'zupa'
    column_name = 'email'
    info['column_type'] = 'email'

    expect(Database::Truncate.query(table_name, column_name, info).is_a?(Array)).to be true
    expect(Database::Truncate.query(table_name, column_name, info)).to eq(
      [
        'SET FOREIGN_KEY_CHECKS = 0;',
        "TRUNCATE #{table_name};",
        'SET FOREIGN_KEY_CHECKS = 1;'
      ]
    )
  end
end
