# frozen_string_literal: true

require 'system_spec_helper'

require 'net/scp'
require 'open-uri'

RSpec.describe '#anonymize magento 2.1 sample' do
  context 'all' do
    before(:context) do
      @project_name = 'magento_2_1_sample'
      @project_file_path = ROOT_DIR + '/config/project/' + @project_name + '.json'
      @random_string = '2949d3e2173b25a55968f45518e4779d'
      @default_action = 'update'

      open('/tmp/' + @project_name + '.sql.gz', 'wb') do |f|
        f << open('https://github.com/DivanteLtd/anonymizer/files/2135882/' + @project_name + '.sql.gz').read
      end

      config = JSON.parse(
        '{
          "type": "extended",
          "basic_type": "magento_2_0",
          "random_string": "' + @random_string + '",
          "dump_server": {
            "host": "",
            "user": "",
            "port": "",
            "passphrase": "",
            "path": "/tmp",
            "rsync_options": ""
          },
          "tables": {}
        }'
      )

      File.open(@project_file_path, 'w') do |f|
        f.write(config.to_json)
      end
    end

    before do
      @project_name = 'magento_2_1_sample'
      @random_string = 'cfcd208495d565ef66e7dff9f98764da'
      @tmp_dir = '/tmp'
      @database = {
        host: CONFIG['database']['host'],
        user: CONFIG['database']['user'],
        pass: CONFIG['database']['pass'],
        random_string: @random_string
      }

      system(
        ShellHelper.drop_database(
          @project_name,
          @database
        )
      )

      system(
        "rm -rf #{@tmp}/#{@project_name}_#{@random_string}.sql.gz"
      )
    end

    it 'should anonymize magento 2.1 sample' do
      anonymizer = Anonymizer.new @project_name

      system(
        ShellHelper.download_dump(
          @project_name,
          {
            host: anonymizer.config['dump_server']['host'],
            port: anonymizer.config['dump_server']['port'],
            user: anonymizer.config['dump_server']['user'],
            dump_dir: anonymizer.config['dump_server']['path']
          },
          @tmp_dir,
          anonymizer.config['dump_server']['rsync_options']
        )
      )

      expect($CHILD_STATUS.exitstatus).to be 0
      expect(File.exist?("/tmp/#{@project_name}.sql.gz")).to be true

      system(
        ShellHelper.create_database(
          @project_name,
          @database
        )
      )
      system(
        ShellHelper.restore_database(
          @project_name,
          @database,
          @tmp_dir
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0

      db = Database.new anonymizer.config
      db.anonymize

      system(
        ShellHelper.dump_database(
          @project_name,
          @database,
          @tmp_dir
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0
      expect(File.exist?("#{@tmp_dir}/#{@project_name}_#{@random_string}.sql.gz")).to be true
    end

    after do
      system(
        ShellHelper.drop_database(
          @project_name,
          @database
        )
      )

      system(
        "rm -rf #{@tmp_dir}/#{@project_name}_#{@random_string}.sql.gz"
      )
    end

    after(:context) do
      FileUtils.rm_f(@project_file_path)
      FileUtils.rm_f('/tmp/' + @project_name + '.sql.gz')
    end
  end
end
