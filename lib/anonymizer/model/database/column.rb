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
  end
end
