# frozen_string_literal: true

require 'spec_helper'

require './lib/anonymizer/model/database.rb'
# rubocop:disable Metrics/BlockLength
RSpec.describe Database, '#database' do
  it 'should exists class Database' do
    expect(Object.const_defined?('Database')).to be true
  end

  context 'work with config' do
    before do
      @name = 'magento_1_9'
      @table_name = 'customer_entity'
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

    it 'should has setable class variables config' do
      db = Database.new @config

      expect(db.config['tables'][@table_name][@column_name]['type']).to eq(@column_type)
    end
  end

  context 'work with email type' do
    before do
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
    end

    it 'should be a sql returned by anonymize_column_query' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          'SELECT fake_user.email FROM fake_user ' \
          "ORDER BY RAND() LIMIT 1) WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with uniq email type' do
    before do
      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'email'
      @column_type = 'uniq_email'
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
    end

    it 'should be a sql returned by anonymize_column_query' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          'SELECT CONCAT(MD5(FLOOR((NOW() + RAND()) * (RAND() * RAND() / RAND()) + ' \
          'RAND())), "@", MD5(FLOOR((NOW() + RAND()) * (RAND() * RAND() / RAND()) + RAND())), ".pl")) ' \
          "WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with firstname type' do
    before do
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
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

  context 'work with login type' do
    before do
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          "SELECT fake_user.#{@column_type} FROM fake_user " \
          "ORDER BY RAND() LIMIT 1) WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with uniq login type' do
    before do
      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'name'
      @column_type = 'uniq_login'
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
    end

    it 'should be a sql returned by anonymize_column' do
      db = Database.new @config

      expect(db.column_query(@table_name, @config['tables'][@table_name])).to eq(
        [
          "UPDATE #{@table_name} SET #{@column_name} = (" \
          'SELECT CONCAT(MD5(FLOOR((NOW() + RAND()) * (RAND() * RAND() / RAND()) + RAND())))) ' \
          "WHERE #{@table_name}.#{@column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with id type' do
    before do
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run)

      db.anonymize
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run).exactly(3).times

      db.anonymize
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

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run).exactly(2).times

      db.anonymize
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

  context 'work with custom query' do
    before do
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
          },
          "custom_queries": {
            "before": [
              "DELETE FROM some_column WHERE date > \'2019-12-25\'",
              "INSERT INTO some_column2 SET table = \'value\'"
            ],
            "after": [
              "INSERT INTO some_column SET name = \'admin\', pass = \'1234567890\'",
              "DELETE FROM some_column2 WHERE id < 10000"
            ]
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::Mysql2, insert and remove fake data, run custome queries' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:run).exactly(4).times

      db.anonymize
    end

    it 'should run all custome queries' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(
        Sequel::Mysql2::Database
      ).to receive(:run).with('INSERT INTO some_column2 SET table = \'value\'')
      expect_any_instance_of(
        Sequel::Mysql2::Database
      ).to receive(:run).with('DELETE FROM some_column WHERE date > \'2019-12-25\'')
      expect_any_instance_of(
        Sequel::Mysql2::Database
      ).to receive(:run).with('DELETE FROM some_column2 WHERE id < 10000')
      expect_any_instance_of(
        Sequel::Mysql2::Database
      ).to receive(:run).with(
        'INSERT INTO some_column SET name = \'admin\', pass = \'1234567890\''
      )

      db.anonymize
    end
  end

  context 'insert fake data' do
    before do
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

    it 'should call method create_table' do
      db = Database.new @config

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:create_table)
      expect_any_instance_of(Sequel::Mysql2::Dataset).to receive(:insert).exactly(100).times

      db.insert_fake_data
    end
  end

  context 'remove fake data' do
    before do
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

    it 'should call method drop_table' do
      db = Database.new @config

      expect_any_instance_of(Sequel::Mysql2::Database).to receive(:drop_table)

      db.remove_fake_data
    end
  end
end
# rubocop:enable Metrics/BlockLength
