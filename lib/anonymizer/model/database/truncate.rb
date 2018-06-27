# Basic class to communication with databese
class Database
  # Class to anonymize static data
  class Truncate
    def self.query(table_name, _column_name, _info)
      querys = ['SET FOREIGN_KEY_CHECKS = 0;',
                "TRUNCATE #{table_name};",
                'SET FOREIGN_KEY_CHECKS = 1;']

      querys
    end
  end
end
