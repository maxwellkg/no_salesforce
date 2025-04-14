# misc shared methods

module SAL::Queries::General
  extend ActiveSupport::Concern

  def convert_to_arel(arel_or_relation)
    case arel_or_relation
    when ActiveRecord::Relation
      arel_or_relation.arel
    when Arel::SelectManager
      arel_or_relation
    else
      raise "#{arel_or_relation.class} is not a recognized type!"
    end
  end

  def exec_query(query)
    sql, binds =  ActiveRecord::Base.connection.send(
                    :to_sql_and_binds,
                    convert_to_arel(query)
                  )

    klass.connection.exec_query(sql, "SQL", binds)
  end

end