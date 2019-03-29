# frozen_string_literal: true

# Helper to generate shell command used in application
module ShellHelper
  def self.drop_database(project_name, database)
    command = "echo \"DROP DATABASE IF EXISTS #{escaped_database_name project_name} \" | " \
      "mysql#{mysql_options(database)}"

    remove_white_space(command)
  end

  def self.create_database(project_name, database)
    command = "echo \"CREATE DATABASE #{escaped_database_name project_name} \" | " \
      "mysql#{mysql_options(database)}"

    remove_white_space(command)
  end

  def self.restore_database(project_name, database, dir)
    command = "gunzip -c #{dir}/#{project_name}.sql.gz | " \
      "sed -e 's/DEFINER=[^*]*\\*/\\*/' | " \
      "sed -e 's/ROW_FORMAT=FIXED//g' | " \
      "mysql#{mysql_options(database)} #{project_name}"

    remove_white_space(command)
  end

  def self.dump_database(project_name, database, tmp_dir)
    random_string = "_#{database[:random_string]}" if database[:random_string]
    command = "mysqldump#{mysql_options(database)} #{project_name} | " \
      'grep -av "SQL SECURITY DEFINER" | sed -e \'s/DEFINER[ ]*=[ ]*[^*]*\*/\*/\' | ' \
      "gzip > #{tmp_dir}/#{project_name}#{random_string}.sql.gz"

    remove_white_space(command)
  end

  def self.output_query_result(project_name, table, where, database, file)
    params = ' --skip-opt --no-create-info --compact --single-transaction'
    cmd = if table.nil?
            "mysqldump #{mysql_options(database)} #{project_name} #{params}  >> #{file}"
          elsif !where.nil?
            "mysqldump #{mysql_options(database)} #{project_name} #{table} --where='#{where}' #{params} >> #{file}"
          else
            "mysqldump #{mysql_options(database)} #{project_name} #{table} --skip-opt #{params}  >> #{file}"
          end

    remove_white_space(cmd)
  end

  def self.upload_to_web(project_name, database, web_server, tmp_dir, options = '')
    random_string = "_#{database[:random_string]}" if database[:random_string]
    command = "rsync -a #{ssh_option(web_server[:port])} #{options} " \
      "#{tmp_dir}/#{project_name}#{random_string}.sql.gz " \
      "#{host_and_user(web_server[:host], web_server[:user])}#{web_server[:path]}/"

    remove_white_space(command)
  end

  def self.mysql_options(database)
    "#{create_host_string database[:host]}#{create_user_string database[:user]}#{create_pass_string database[:pass]}"
  end

  def self.download_dump(project_name, dump_server, tmp_dir, options = '')
    options = " #{options} " if options

    command = "rsync -a #{ssh_option(dump_server[:port])} #{options} " \
      "#{host_and_user(dump_server[:host], dump_server[:user])}#{dump_server[:dump_dir]}" \
      "/#{project_name}.sql.gz #{tmp_dir}/"

    remove_white_space(command)
  end

  def self.remove_dump(project_name, tmp_dir)
    command = "rm -rf #{tmp_dir}/#{project_name}.sql.gz"

    remove_white_space(command)
  end

  def self.remove_anonymized_dump(project_name, random_string, tmp_dir)
    random_string = "_#{random_string}" if random_string
    command = "rm -rf #{tmp_dir}/#{project_name}#{random_string}.sql.gz"

    remove_white_space(command)
  end

  private_class_method

  def self.escaped_database_name(project_name)
    database_name = "`#{project_name}`"
    Shellwords.escape(database_name)
  end

  def self.create_host_string(host)
    (" -h #{host}" if host.to_s != '') || ''
  end

  def self.create_user_string(user)
    (" -u #{user}" if user.to_s != '') || ''
  end

  def self.create_pass_string(pass)
    (" -p#{pass}" if pass.to_s != '') || ''
  end

  def self.remove_white_space(string)
    string.tr("\n", ' ').squeeze(' ')
  end

  def self.ssh_option(port)
    (" -e \"ssh -p #{port} -o 'StrictHostKeyChecking no'\" " unless port.to_s.empty?) || ''
  end

  def self.host_and_user(host, user)
    user = user.to_s
    user += '@' if user != ''

    host = host.to_s
    host += ':' if host != ''

    user + host
  end
end
