# frozen_string_literal: true

require 'spec_helper'

require './lib/anonymizer/model/database/eav.rb'

RSpec.describe Database::Eav, '#eav' do
  it 'should exists class Eav' do
    expect(Object.const_defined?('Database::Eav')).to be true
  end

  it 'should return valid query for eav' do
    info = {}
    table_name = 'customer_address_entity_varchar'
    column_name = 'value'
    attr_code = 'firstname'
    entity_type = 'customer_address'
    column_type = 'firstname'
    info['attributes'] = [{
      'code' => attr_code,
      'type' => column_type,
      'entity_type' => entity_type
    }]

    expect(Database::Eav.query(table_name, column_name, info).is_a?(Array)).to be true
    expect(Database::Eav.query(table_name, column_name, info)).to eq(
      ["UPDATE #{table_name} " \
        'SET ' \
          "#{column_name} = (SELECT fake_user.#{column_type} FROM fake_user ORDER BY RAND() LIMIT 1) " \
        'WHERE ' \
          'attribute_id = (SELECT ' \
            'attribute_id ' \
              'FROM ' \
                'eav_attribute ' \
              'WHERE ' \
                "attribute_code = '#{attr_code}' " \
                'AND entity_type_id = (SELECT ' \
                  'entity_type_id ' \
                    'FROM ' \
                      'eav_entity_type ' \
                    'WHERE ' \
                      "entity_type_code = '#{entity_type}'));"]
    )
  end
end
