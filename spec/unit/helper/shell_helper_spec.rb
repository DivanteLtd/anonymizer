require 'spec_helper'
require './lib/anonymizer/helper/shell_helper.rb'

RSpec.describe '#shell_helper' do
  context 'check mysql options' do
    before do
      @project_name = 'magento_1_9'
      @host = 'localhost'
      @user = 'someuser'
      @pass = '!@#$%^&*FFFazad12345'
    end

    it 'should return command without host, user and pass' do
      database = { host: '', user: '', pass: '' }
      expect(ShellHelper.mysql_options(database)).to eq('')
    end

    it 'should return command with host and without user and pass' do
      database = { host: @host, user: '', pass: '' }
      expect(ShellHelper.mysql_options(database)).to eq(" -h #{@host}")
    end

    it 'should return command with user and without host and pass' do
      database = { host: '', user: @user, pass: '' }
      expect(ShellHelper.mysql_options(database)).to eq(" -u #{@user}")
    end

    it 'should return command with pass and without user and host' do
      database = { host: '', user: '', pass: @pass }
      expect(ShellHelper.mysql_options(database)).to eq(" -p#{@pass}")
    end

    it 'should return command with pass and host and without user' do
      database = { host: @host, user: '', pass: @pass }
      expect(ShellHelper.mysql_options(database)).to eq(" -h #{@host} -p#{@pass}")
    end

    it 'should return command with pass and user and without host' do
      database = { host: '', user: @user, pass:  @pass }
      expect(ShellHelper.mysql_options(database)).to eq(" -u #{@user} -p#{@pass}")
    end

    it 'should return command with host and user and without pass' do
      database = { host: @host, user: @user, pass: '' }
      expect(ShellHelper.mysql_options(database)).to eq(" -h #{@host} -u #{@user}")
    end

    it 'should return command with host, user and pass' do
      database = { host: @host, user: @user, pass: @pass }
      expect(ShellHelper.mysql_options(database)).to eq(" -h #{@host} -u #{@user} -p#{@pass}")
    end
  end

  context 'check shell command to drop database' do
    before do
      @project_name = 'magento_1_9'
      @host = 'localhost'
      @user = 'someuser'
      @pass = '!@#$%^&*FFFazad12345'
      @database = { host: @host, user: @user, pass: @pass }
    end

    it 'should return command with host, user and pass' do
      expect(ShellHelper.drop_database(@project_name, @database)).to eq(
        "echo \"DROP DATABASE IF EXISTS #{Shellwords.escape("`#{@project_name}`")} \" " \
        "| mysql -h #{@host} -u #{@user} -p#{@pass}"
      )
    end
  end

  context 'check shell command to create database' do
    before do
      @project_name = 'magento_1_9'
      @host = 'localhost'
      @user = 'someuser'
      @pass = '!@#$%^&*FFFazad12345'
      @database = { host: @host, user: @user, pass: @pass }
    end

    it 'should return command with host, user and pass' do
      expect(ShellHelper.create_database(@project_name, @database)).to eq(
        "echo \"CREATE DATABASE #{Shellwords.escape("`#{@project_name}`")} \" " \
        "| mysql -h #{@host} -u #{@user} -p#{@pass}"
      )
    end
  end

  context 'check shell command to restore database' do
    before do
      @project_name = 'magento_1_9'
      @dump_dir = '/tmp'
      @host = 'localhost'
      @user = 'someuser'
      @pass = '!@#$%^&*FFFazad12345'
      @database = { host: @host, user: @user, pass: @pass }
    end

    it 'should return command with host, user and pass' do
      expect(ShellHelper.restore_database(@project_name, @database, @dump_dir)).to eq(
        "gunzip -c #{@dump_dir}/#{@project_name}.sql.gz | sed -e 's/DEFINER=[^*]*\\*/\\*/' | " \
        "mysql -h #{@host} -u #{@user} -p#{@pass} #{@project_name}"
      )
    end
  end

  context 'check shell command to dump database' do
    before do
      @project_name = 'magento_1_9'
      @dump_dir = './web/data'
      @host = 'localhost'
      @user = 'someuser'
      @pass = '!@#$%^&*FFFazad12345'
      @random_string = '2949d3e2173b25a55968f45518e4779d'
      @database = { host: @host, user: @user, pass: @pass, random_string: @random_string }
    end

    it 'should return command with host, user and pass' do
      expect(ShellHelper.dump_database(@project_name, @database, @dump_dir)).to eq(
        "mysqldump -h #{@host} -u #{@user} -p#{@pass} #{@project_name} | " \
        'grep -v "SQL SECURITY DEFINER" | sed -e \'s/DEFINER[ ]*=[ ]*[^*]*\*/\*/\' | ' \
        "gzip > #{@dump_dir}/#{@project_name}_#{@random_string}.sql.gz"
      )

      @database.delete(:random_string)
      expect(ShellHelper.dump_database(@project_name, @database, @dump_dir)).to eq(
        "mysqldump -h #{@host} -u #{@user} -p#{@pass} #{@project_name} | " \
        'grep -v "SQL SECURITY DEFINER" | sed -e \'s/DEFINER[ ]*=[ ]*[^*]*\*/\*/\' | ' \
        "gzip > #{@dump_dir}/#{@project_name}.sql.gz"
      )
    end
  end

  context 'check shell command to get database dump from remote system' do
    before do
      @dump_dir = '/var/backups/mysql/sqldump'
      @tmp_dir = '/tmp'
      @project_name = 'magento_1_9'
      @host = 'localhost'
      @port = '60022'
      @user = 'anonymizer'
      @dump_server = {
        host: @host,
        port: @port,
        user: @user,
        dump_dir: @dump_dir
      }
    end

    it 'should return rsync command between local dirs' do
      dump_server = {
        host: '',
        port: '',
        user: '',
        dump_dir: @dump_dir
      }

      expect(
        ShellHelper.download_dump(
          @project_name,
          dump_server,
          @tmp_dir
        )
      ).to eq(
        "rsync -a #{@dump_dir}/#{@project_name}.sql.gz #{@tmp_dir}/"
      )
    end

    it 'should return rsync command with host and user and ssh port' do
      expect(
        ShellHelper.download_dump(
          @project_name,
          @dump_server,
          @tmp_dir
        )
      ).to eq(
        "rsync -a -e \"ssh -p #{@port} -o 'StrictHostKeyChecking no'\" "\
        "#{@user}@#{@host}:#{@dump_dir}/#{@project_name}.sql.gz #{@tmp_dir}/"
      )
    end

    it 'should return rsync command with host and user and ssh port and rsync option' do
      expect(
        ShellHelper.download_dump(
          @project_name,
          @dump_server,
          @tmp_dir,
          '--rsync-path="sudo rsync"'
        )
      ).to eq(
        "rsync -a -e \"ssh -p #{@port} -o 'StrictHostKeyChecking no'\" --rsync-path=\"sudo rsync\" " \
        "#{@user}@#{@host}:#{@dump_dir}/#{@project_name}.sql.gz #{@tmp_dir}/"
      )
    end
  end

  context 'remove database dump from temp director' do
    before do
      @tmp_dir = '/tmp'
      @project_name = 'magento_1_9'
    end

    it 'should return valid rm command' do
      expect(
        ShellHelper.remove_dump(
          @project_name,
          @tmp_dir
        )
      ).to eq(
        "rm -rf #{@tmp_dir}/#{@project_name}.sql.gz"
      )
    end
  end
end
