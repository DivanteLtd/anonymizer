require 'system_spec_helper'

require 'net/scp'

RSpec.describe '#anonymize magento 2.1 sample' do
  context 'all' do
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
        "rm -rf #{ROOT_DIR}/#{CONFIG['web_data_path']}/#{@project_name}_#{@random_string}.sql.gz"
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
          ROOT_DIR + '/' + CONFIG['web_data_path']
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0
      expect(File.exist?("#{ROOT_DIR}/#{CONFIG['web_data_path']}/#{@project_name}_#{@random_string}.sql.gz")).to be true
    end

    after do
      system(
        ShellHelper.drop_database(
          @project_name,
          @database
        )
      )

      system(
        "rm -rf #{ROOT_DIR}/#{CONFIG['web_data_path']}/#{@project_name}_#{@random_string}.sql.gz"
      )
    end
  end
end
