require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    criteria = params.values
    wheres = params.keys.map do |key|
      "#{key} = ?"
    end.join(" AND ")

    results = DBConnection.execute(<<-SQL, *criteria)
      SELECT *
      FROM #{self.table_name}
      WHERE #{wheres}
    SQL

    results.map{ |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
