# frozen_string_literal: true

# Basic class to communication with databese
class Database
  # Class to anonymize EAV data type
  class Column < Database
    def self.query(table_name, column_name, info)
      column_type = info['type']

      querys = []

      query = "UPDATE #{table_name} SET #{column_name} = ("
      query += manage_type(column_type)
      query += "WHERE #{table_name}.#{column_name} IS NOT NULL"
      query += fill_where_clause(info, table_name)

      querys.push query

      querys
    end

    def self.manage_type(type)
      if respond_to?(:"manage_type_#{type}")
        query = send("manage_type_#{type}")
      else
        query = prepare_select_for_query(type)
        query += 'FROM fake_user ORDER BY RAND() LIMIT 1) '
      end

      query
    end

    private_class_method

    def self.manage_type_id
      'SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) '
    end

    def self.manage_type_uniq_email
      'SELECT CONCAT(MD5(FLOOR((NOW() + RAND()) * (RAND() * RAND() / RAND()) + ' \
      'RAND())), "@", MD5(FLOOR((NOW() + RAND()) * (RAND() * RAND() / RAND()) + RAND())), ".pl")) '
    end

    def self.manage_type_uniq_login
      'SELECT CONCAT(MD5(FLOOR((NOW() + RAND()) * (RAND() * RAND() / RAND()) + RAND())))) '
    end

    def self.fill_where_clause(info, table_name)
      query = ''

      if info.key?('where')
        raise ArgumentError, 'Where MUST be an array with proper fields' unless info['where'].is_a?(Array)
        info['where'].each do |where_info|
          check_where_clause(where_info)
          query += " #{where_info['logical_operator']} "
          query += "#{table_name}.#{where_info['column']} #{where_info['operator']} '#{where_info['value']}'"
        end
      end

      query
    end

    def self.check_where_clause(where_clause)
      require_fields = %w[logical_operator column operator value]
      require_fields.each do |required_field|
        raise ArgumentError, "#{required_field} is required in WHERE clause" unless where_clause.key?(required_field)
      end
    end
  end
end
