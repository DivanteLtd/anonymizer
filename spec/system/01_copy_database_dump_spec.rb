require 'system_spec_helper'

require 'net/scp'
require 'open-uri'

RSpec.describe '#import database' do
  context 'copy dump' do
    before(:context) do
      @project_name = 'magento_1_9_sample'
      @project_file_path = ROOT_DIR + '/config/project/' + @project_name + '.json'
      @random_string = '2949d3e2173b25a55968f45518e4779d'
      @table_name = 'sales_flat_order_address'
      @column_name = 'postcode'
      @column_type = 'firstname'
      @new_table_name = 'some_new_table'
      @new_column_name = 'some_column'
      @new_column_type = 'firstname'
      @default_action = 'update'

      open('/tmp/' + @project_name + '.sql.gz', 'wb') do |f|
        f << open('https://github.com/DivanteLtd/anonymizer/files/2135881/' + @project_name + '.sql.gz').read
      end

      config = JSON.parse(
        '{
          "type": "extended",
          "basic_type": "magento_1_9",
          "random_string": "' + @random_string + '",
          "dump_server": {
            "host": "",
            "user": "",
            "port": "",
            "passphrase": "",
            "path": "/tmp",
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

      File.open(@project_file_path, 'w') do |f|
        f.write(config.to_json)
      end

      @anonymizer = Anonymizer.new @project_name
    end

    # it 'should exists user private key' do
    #   expect(File.exist?(ENV['HOME'] + '/.ssh/id_rsa')).to be true
    # end

    it 'should be loadded extension net/ssh and net/scp' do
      expect(Object.const_defined?('Net::SSH')).to be true
      expect(Object.const_defined?('Net::SCP')).to be true
    end

    it 'should has data necessary to connect to remote server' do
      expect(@anonymizer.config['dump_server']['host'].is_a?(String)).to be true
      expect(@anonymizer.config['dump_server']['user'].is_a?(String)).to be true
      expect(@anonymizer.config['dump_server']['port'].is_a?(String)).to be true
    end

    # it 'should be possible connect to remote server' do
    #   expected = expect do
    #     Net::SSH.start(
    #       @anonymizer.config['dump_server']['host'],
    #       @anonymizer.config['dump_server']['user'],
    #       port: @anonymizer.config['dump_server']['port'],
    #       passphrase: @anonymizer.config['dump_server']['passphrase']
    #     )
    #   end

    #   expected.not_to raise_error
    # end

    it 'should be possible copy project dump' do
      system(
        ShellHelper.download_dump(
          @project_name,
          {
            host: @anonymizer.config['dump_server']['host'],
            port: @anonymizer.config['dump_server']['port'],
            user: @anonymizer.config['dump_server']['user'],
            dump_dir: @anonymizer.config['dump_server']['path']
          },
          '/tmp',
          @anonymizer.config['dump_server']['rsync_options']
        )
      )

      expect(File.exist?("/tmp/#{@project_name}.sql.gz")).to be true
    end

    after(:context) do
      FileUtils.rm_f(@project_file_path)
      FileUtils.rm_f('/tmp/' + @project_name + '.sql.gz')
    end
  end
end
