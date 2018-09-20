# frozen_string_literal: true

require 'spec_helper'

require './lib/anonymizer/model/database/static.rb'
RSpec.describe Database::Static, '#static' do
  it 'should exists class Static' do
    expect(Object.const_defined?('Database::Static')).to be true
  end

  it 'should return valid query for some value' do
    info = {}
    table_name = 'zupa'
    column_name = 'zupa'
    info['action'] = 'set_static'
    info['value'] = 'zupa'

    expect(Database::Static.query(table_name, column_name, info).is_a?(Array)).to be true
    expect(Database::Static.query(table_name, column_name, info)).to eq(
      ["UPDATE #{table_name} SET #{column_name} = '#{info['value']}'"]
    )
  end

  it 'should return valid query for empty value' do
    info = {}
    table_name = 'zupa'
    column_name = 'zupa'
    info['action'] = 'empty'

    expect(Database::Static.query(table_name, column_name, info).is_a?(Array)).to be true
    expect(Database::Static.query(table_name, column_name, info)).to eq(
      ["UPDATE #{table_name} SET #{column_name} = ''"]
    )
  end
end
