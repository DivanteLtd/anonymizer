# Basic class to communication with databese
class Database
  # Class to anonymize multiple tables at onces with the same data
  class Multiple < Database
    def self.query(table_name, column_name, info)
      column_type = info['type']

      querys = []

      query = "UPDATE #{table_name} SET #{column_name} = ("
      query += manage_type(column_type)
      query += "WHERE #{table_name}.#{column_name} IS NOT NULL"

      querys.push query
      querys = manage_linked_tables(info['linked_tables'], table_name, column_name, querys)

      querys
    end

    def self.manage_type(type)
      query = ''

      if type == 'id'
        query += 'SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) '
      else
        query += prepare_select_for_query(type)
        query += 'FROM fake_user ORDER BY RAND() LIMIT 1) '
      end

      query
    end

    def self.manage_linked_tables(linked_tables, table_name, column_name, querys)
      linked_tables.each do |linked_table, linked_data|
        query = "UPDATE #{linked_table} as t1"
        query += " INNER JOIN #{table_name} as t2 ON t1.#{linked_data['column']}"
        query += " SET t1.#{column_name} = t2.#{column_name}"
        query += " WHERE t1.#{column_name} IS NOT NULL"
        querys.push query
      end

      querys
    end
  end
end
