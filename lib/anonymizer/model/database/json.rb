# Basic class to communication with databese
class Database
  # Class to anonymize json data type
  class Json < Database
    def self.query(table_name, column_name, info)
      field = info['field']

      querys = []

      query = "UPDATE #{table_name} " \
       'SET ' \
        "#{column_name} = JSON_REPLACE( #{column_name}, " \
          "\"#{field['path']}\", ("

      query << manage_type(field['type'])

      query << ')'

      querys.push query

      querys
    end

    def self.manage_type(type)
      query = ''

      if type == 'id'
        query << 'SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) '
      else
        query << prepare_select_for_query(type)
        query << 'FROM fake_user ORDER BY RAND() LIMIT 1) '
      end

      query
    end
  end
end
