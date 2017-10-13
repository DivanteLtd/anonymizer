require 'system_spec_helper'

require 'net/scp'

RSpec.describe '#work with dump' do
  context 'check if can remove db' do
    it 'should be possible to drop database' do
      @project_name = 'magento_1_9'
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
      expect($CHILD_STATUS.exitstatus).to be 0
    end
  end

  context 'check if can restore dump' do
    before do
      @project_name = 'magento_1_9'
      @random_string = '2949d3e2173b25a55968f45518e4779d'
      @dump_dir = './spec/files'
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
    end

    it 'should be possible to create database' do
      system(
        ShellHelper.create_database(
          @project_name,
          @database
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0
    end

    it 'should be possible to restore database' do
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
          @dump_dir
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0
    end

    it 'should be possible to remove database dump from temp dir' do
      system("touch #{@tmp_dir}/#{@project_name}.sql.gz")
      system(
        ShellHelper.remove_dump(
          @project_name,
          @tmp_dir
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0
    end

    after do
      system(
        ShellHelper.drop_database(
          @project_name,
          @database
        )
      )
    end
  end

  context 'check if can create anonymized dump' do
    before do
      @project_name = 'magento_1_9'
      @database = {
        host: CONFIG['database']['host'],
        user: CONFIG['database']['user'],
        pass: CONFIG['database']['pass'],
        random_string: @random_string
      }
    end

    it 'should be possible to create database dump' do
      system(
        ShellHelper.create_database(
          @project_name,
          @database
        )
      )
      system(
        ShellHelper.dump_database(
          @project_name,
          @database,
          ROOT_DIR + '/' + CONFIG['web_data_path']
        )
      )
      expect($CHILD_STATUS.exitstatus).to be 0
    end

    after do
      system(
        ShellHelper.drop_database(
          @project_name,
          @database
        )
      )
    end
  end

  context 'check if web data directory' do
    it 'should exists' do
      expect(File.exist?(ROOT_DIR + '/' + CONFIG['web_data_path'])).to be true
    end
  end
end
