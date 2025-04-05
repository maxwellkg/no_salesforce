class SAL::ChangeOverTimeResult

	attr_reader :query, :ar_result

	attr_accessor :total_results

	delegate :rows, to: :ar_result
	delegate_missing_to :ar_result

	def initialize(query, ar_result)
		@query = query
		@ar_result = ar_result
	end

	def objectified_rows
	  @_objectified_rows ||= begin
	  	if query.has_rows?
		    if query.row_dim.reflection?
		      objectified_rows_for_reflection
		    elsif query.row_dim.date_col?
		      change_first_in_row(-> (date_val) { date_val == 'TOTAL' ? date_val : date_val.to_date })
		    else
		      rows
		    end
		  else
		  	rows
		  end
	  end
	end

	private

    def match_to_key(key, collection, attribute_to_match, return_key_if_missing: false)
      mtch = collection.detect { |i| attribute_to_match.to_proc.call(i) == key }

      mtch.blank? && return_key_if_missing ? key : mtch
    end	

    def get_objects_for_dimension(dimension, ids)
      dimension.reflection.klass.find(ids)
    end	

	  def change_first_in_row(update_proc)
	    rows.map do |r|
	      # duplicate as we don't want to override the original
	      new_r = r.dup

	      new_r[0] = update_proc.call(r.first)

	      new_r
	    end
	  end

	  def objectified_rows_for_reflection
	    ids = rows.map(&:first)

	    objects = get_objects_for_dimension(query.row_dim, ids)

	    change_first_in_row(-> (r) { match_to_key(r, objects, :id, return_key_if_missing: true) })
	  end

end
