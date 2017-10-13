require 'spec_helper'
require './lib/anonymizer/model/anonymizer.rb'
require './lib/anonymizer/model/database.rb'

RSpec.describe Anonymizer, '#anonymizer' do
  it 'should exists class Anonymizer' do
    expect(Object.const_defined?('Anonymizer')).to be true
  end

  context 'check if anonymizer is ready to work' do
    before do
      @database = double('Database')

      @empty_project_name = nil
      @real_project_name = 'magento_1_9_sample'
      @fake_project_name = 'fake_project_name'

      @real_project_file_path = "./config/project/#{@real_project_name}.json"
    end

    it 'should check if config file for project name exists' do
      expect { Anonymizer.new }.to raise_error(ArgumentError)
      expect { Anonymizer.new @empty_project_name }.to raise_error(RuntimeError, 'Invalid project name')
      expect { Anonymizer.new @fake_project_name }.to raise_error(RuntimeError, 'Project not exists')
      expect { Anonymizer.new @real_project_name }.not_to raise_error
    end

    it 'should has valid config' do
      anonymizer = Anonymizer.new @real_project_name
      expect(anonymizer.config['database']['name']).to eq(@real_project_name)
    end
  end

  context 'work with extended project type' do
    before do
      @name = 'magento_1_9_sample'
      @random_string = '2949d3e2173b25a55968f45518e4779d'
      @table_name = 'sales_flat_order_address'
      @column_name = 'postcode'
      @column_type = 'firstname'
      @new_table_name = 'some_new_table'
      @new_column_name = 'some_column'
      @new_column_type = 'firstname'
      @default_action = 'update'
      @config = JSON.parse(
        '{
          "type": "extended",
          "basic_type": "magento_1_9",
          "random_string": "' + @random_string + '",
          "dump_server": {
            "host": "test-lin-4.divante.pl",
            "user": "mkoszutowski",
            "port": "60022",
            "passphrase": "",
            "path": "/home/users/mkoszutowski",
            "rsync_options": ""
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "' + @default_action + '"
              }
            },
            "' + @new_table_name + '": {
              "' + @new_column_name + '": {
                "type": "' + @new_column_type + '",
                "action": "' + @default_action + '"
              }
            }
          }
        }'
      )
    end

    it 'should throw exception if column hasn\'t setted action' do
      @config['tables'][@new_table_name][@new_column_name].delete('action')

      expect { Anonymizer.new @name, @config }.to raise_error(
        RuntimeError,
        'In project config file founded column without defined action'
      )
    end

    it 'should throw exception if dump server hasn\'t setted host' do
      @config['dump_server'] = ''

      expect { Anonymizer.new @name, @config }.to raise_error(
        RuntimeError,
        'In project config file dump_server is not valid'
      )

      @config['dump_server'].delete('action')

      expect { Anonymizer.new @name, @config }.to raise_error(
        RuntimeError,
        'In project config file dump_server is not valid'
      )
    end

    # it 'should throw exception if dump server hasn\'t setted host' do
    #   @config['dump_server']['host'].delete('action')

    #   expect { Anonymizer.new @name, @config }.to raise_error(
    #     RuntimeError,
    #     'In project config file dump_server host is not valid'
    #   )
    # end

    # it 'should throw exception if dump server hasn\'t setted user' do
    #   @config['dump_server']['user'].delete('action')

    #   expect { Anonymizer.new @name, @config }.to raise_error(
    #     RuntimeError,
    #     'In project config file dump_server user is not valid'
    #   )
    # end

    # it 'should throw exception if dump server hasn\'t setted port' do
    #   @config['dump_server']['port'].delete('action')

    #   expect { Anonymizer.new @name, @config }.to raise_error(
    #     RuntimeError,
    #     'In project config file dump_server port is not valid'
    #   )
    # end

    # it 'should throw exception if dump server hasn\'t setted path' do
    #   @config['dump_server']['path'].delete('action')

    #   expect { Anonymizer.new @name, @config }.to raise_error(
    #     RuntimeError,
    #     'In project config file dump_server path is not valid'
    #   )
    # end

    it 'should be a valid config for extended project' do
      allow_any_instance_of(Anonymizer).to receive(:project_file_path).and_wrap_original { |m, args|
        if args == @name + '.json'
          @name + '.json'
        else
          m.call(args)
        end
      }

      allow_any_instance_of(Anonymizer).to receive(:read_config).and_wrap_original { |m, args|
        if args == @name + '.json'
          @config
        else
          m.call(args)
        end
      }

      anonymizer = Anonymizer.new @name

      expect(anonymizer.config['type']).to eq(@config['type'])
      expect(anonymizer.config['basic_type']).to eq(@config['basic_type'])
      expect(anonymizer.config['random_string']).to eq(@config['random_string'])
      expect(anonymizer.config['database']['name']).to eq(@name)

      expect(anonymizer.config['dump_server'].is_a?(Hash)).to be true
      expect(anonymizer.config['dump_server'].key?('host')).to be true
      expect(anonymizer.config['dump_server']['host'].empty?).to be false
      expect(anonymizer.config['dump_server'].key?('user')).to be true
      expect(anonymizer.config['dump_server']['user'].empty?).to be false
      expect(anonymizer.config['dump_server'].key?('port')).to be true
      expect(anonymizer.config['dump_server']['port'].empty?).to be false
      expect(anonymizer.config['dump_server'].key?('path')).to be true
      expect(anonymizer.config['dump_server']['path'].empty?).to be false

      expect(anonymizer.config['tables'][@table_name][@column_name]['action']).to eq(@default_action)
      expect(anonymizer.config['tables'][@table_name][@column_name]['type']).to eq(@column_type)
      expect(anonymizer.config['tables'][@new_table_name][@new_column_name]['type']).to eq(@new_column_type)
      expect(anonymizer.config['tables']['sales_flat_invoice_grid']['billing_name']['type']).to eq('fullname')
    end
  end
end
