class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.random(limit = 1)
    records = order(Arel.sql('RANDOM()')).limit(limit)

    limit == 1 ? records.first : records
  end

end
