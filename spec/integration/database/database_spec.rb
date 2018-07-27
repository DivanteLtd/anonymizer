require 'spec_helper'

require './lib/anonymizer/model/database.rb'
require './lib/anonymizer/model/fake.rb'
require './lib/anonymizer/model/fake/pesel.rb'
require './lib/anonymizer/model/database/column.rb'
require './lib/anonymizer/model/database/eav.rb'
require './lib/anonymizer/model/database/json.rb'
require './lib/anonymizer/model/database/static.rb'
require './lib/anonymizer/model/database/truncate.rb'

RSpec.describe Database, '#database' do
  context 'work with email type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'email'
      @column_type = 'email'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column_query' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          "SELECT REPLACE(fake_user.email, '$uniq$', CONCAT('+', UUID_SHORT())) FROM fake_user " \
          "ORDER BY RAND() LIMIT 1) WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with firstname type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'firstname'
      @column_type = 'firstname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column_query' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} " \
          "SET #{@column_name} = (SELECT fake_user.#{@column_type} FROM fake_user ORDER BY RAND() LIMIT 1) " \
          "WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with fullname type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_grid'
      @column_name = 'billing_name'
      @column_type = 'fullname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          "SELECT CONCAT_WS(' ', fake_user.firstname, fake_user.lastname) FROM fake_user ORDER BY RAND() LIMIT 1) " \
          "WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with postcode type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'postcode'
      @column_type = 'postcode'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} " \
          "SET #{@column_name} = (SELECT fake_user.#{@column_type} FROM fake_user ORDER BY RAND() LIMIT 1) " \
          "WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with uniq login type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'name'
      @column_type = 'login'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          "SELECT REPLACE(fake_user.#{@column_type}, '$uniq$', CONCAT('+', UUID_SHORT())) FROM fake_user " \
          "ORDER BY RAND() LIMIT 1) WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with id type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'name'
      @column_type = 'id'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} " \
          "SET #{@column_name} = (SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) "\
          "WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with column to truncate' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'log_url'
      @column_name = 'postcode'
      @action = 'truncate'
      @eav_table_name = 'customer_address_entity_varchar'
      @eav_column_name = 'value'
      @eav_action = 'eav_update'
      @eav_attr_code = 'firstname'
      @eav_entity_type = 'customer_address'
      @eav_column_type = 'firstname'

      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "action": "' + @action + '"
              },
              "other_column": {
                "type": "postcode",
                "action": "update"
              },
              "' + @eav_table_name + '": {
                "' + @eav_column_name + '": {
                  "action": "' + @eav_action + '",
                  "attributes": [
                    {
                      "code": "' + @eav_attr_code + '",
                      "type": "' + @eav_column_type + '",
                      "entity_type": "' + @eav_entity_type + '"
                    }
                  ]
                }
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          'SET FOREIGN_KEY_CHECKS = 0;',
          "TRUNCATE #{@table_name};",
          'SET FOREIGN_KEY_CHECKS = 1;'
        ]
      )
    end
  end

  context 'work with magento EAV model' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'customer_address_entity_varchar'
      @column_name = 'value'
      @action = 'eav_update'
      @attr_code = 'firstname'
      @entity_type = 'customer_address'
      @column_type = 'firstname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "action": "' + @action + '",
                "attributes": [
                  {
                    "code": "' + @attr_code + '",
                    "type": "' + @column_type + '",
                    "entity_type": "' + @entity_type + '"
                  },
                  {
                    "code": "lastname",
                    "type": "lastname",
                    "entity_type": "customer_address"
                  }
                ]
              }
            }
          }
        }'
      )
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} " \
          'SET ' \
            "#{@column_name} = (SELECT fake_user.#{@column_type} FROM fake_user ORDER BY RAND() LIMIT 1) " \
          'WHERE ' \
            'attribute_id = (SELECT ' \
              'attribute_id ' \
                'FROM ' \
                  'eav_attribute ' \
                'WHERE ' \
                  "attribute_code = '#{@attr_code}' " \
                  'AND entity_type_id = (SELECT ' \
                    'entity_type_id ' \
                      'FROM ' \
                        'eav_entity_type ' \
                      'WHERE ' \
                        "entity_type_code = '#{@entity_type}'));",
          'UPDATE customer_address_entity_varchar ' \
          'SET ' \
            'value = (SELECT fake_user.lastname FROM fake_user ORDER BY RAND() LIMIT 1) ' \
          'WHERE ' \
            'attribute_id = (SELECT ' \
              'attribute_id ' \
                'FROM ' \
                  'eav_attribute ' \
                'WHERE ' \
                  "attribute_code = 'lastname' " \
                  'AND entity_type_id = (SELECT ' \
                    'entity_type_id ' \
                      'FROM ' \
                        'eav_entity_type ' \
                      'WHERE ' \
                        "entity_type_code = 'customer_address'));"
        ]
      )
    end
  end
end
