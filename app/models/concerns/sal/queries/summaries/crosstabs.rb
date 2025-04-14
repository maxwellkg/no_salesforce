module SAL::Queries::Summaries::Crosstabs
  extend ActiveSupport::Concern

  private

    # the return types for Postgres aggregate functions do not always match the input types
    # for example, SUM(integer_field) will return a bigint and SUM(bigint) returns a numeric
    # 
    # see a full list here: https://www.postgresql.org/docs/8.2/functions-aggregate.html
    #
    # this is important to us because we have to declare the crosstab column types explicitly
    # and so to do so accurately we need to determine what the aggregate function return type for
    # the column is
    #
    # TODO MKG 10/08/2024
    # COUNT will always return bigint, regardless of the type of the field
    # for now, add a field in the metric hash to explicity state a return type
    # but we should return to this and find a way to determine if the metric uses count
    # and account for that here rather than having to put that in the metric hash each time

    def crosstab_cols_sql_type
      return @metric[:return_type] if @metric[:return_type].present?

      metric_dim = SAL::Dimension.find_by_name(
        klass,
        @metric[:field]
      )

      sql_type = metric_dim.column.sql_type

      case sql_type
      when 'integer'
        'bigint'
      when 'bigint'
        'numeric'
      else
        sql_type
      end
    end

    # the crosstab function will turn rows into columns 
    # each unique value in the data for the selected db column will become its own
    # query column in the crosstab output
    #
    # e.g.
    # SELECT account_id, DATE_TRUNC(close_date) AS month, SUM(amount) AS amt
    # FROM opportunities
    # GROUP BY 1, 2
    # ORDER BY 1, 2
    #
    # returns something like:
    #
    # account_id | month | amt
    # -------------------------
    # 1          | 2024-11-01 00:00:00 | 1000
    # 1          | 2024-12-01 00:00:00 | 2000
    # 2          | 2024-11-01 00:00:00 | 3000
    # 2          | 2024-12-01 00:00:00 | 4000
    #
    # and then the crosstab query would transform that into
    #
    # account_id | 2024-11-01 | 2024-12-01
    # ------------------------------------
    # 1          | 1000       | 2000
    # 2          | 3000       | 4000
    #
    # but when constructing the crosstab query, we have to specify the columns
    # which we don't know ahead of time since the query will be dynamic based on
    # what the user has input
    #
    # the way to achieve what we want is to actually run the joined and filtered query
    # and get the distinct results of the column that will be transformed into columns
    # in the crosstab (e.g. in the above it would be account_id)

    def crosstab_col_names
      @_crosstab_col_names ||= begin

        # determine what to pluck:
        #
        # if the dim is a reflection and is in our conditions, then the table will have been aliased
        # by active record as the reflection name, in which case write the raw sql
        # to reference the column
        #
        # if a reflection and not in the conditions, then use the reflection's arel table
        #
        # else, just use the columns attribute

        pluck_sql = if col_dim.reflection?
                      if dim_in_conditions?(col_dim)
                        "#{col_dim.reflection.name}.#{col_dim.column_name}"
                      else
                        col_dim.reflection.klass.arel_table[col_dim.column_name]
                      end
                    else


                      @columns
                    end

        # the col names may be dates, numbers, or whatever else
        # return them all as strings

        joined_and_filtered_query
          .distinct
          .order(pluck_sql)
          .pluck(pluck_sql)
          .map(&:to_s)
      end
    end

    def ct_col_node(col_name, sql_type)
      Arel::Nodes::TableAlias.new(
        Arel::Table.new(col_name),
        Arel.sql(sql_type)
      )
    end

    def ct_cols
      ctc = crosstab_col_names.map do |cn|
        ct_col_node(cn, crosstab_cols_sql_type)
      end

      if has_cols_no_rows?
        ctc.prepend(ct_col_node('total', 'text'))
      else
        # always cast as text so that we can combine with "TOTAL" in the total row
        ctc.prepend(ct_col_node(alias_for_dim_name(rows), 'text'))
      end

      ctc
    end

    def replace_binds(ar_relation)
      sql, binds = ActiveRecord::Base.connection.send(:to_sql_and_binds, ar_relation)

      binds.each_with_index do |b, i|
        sql = sql.gsub("$#{i+1}", b)
      end

      sql  
    end

    def crosstab_query(crosstab_func_query, crosstab_cols)
      ct_sql =  case crosstab_func_query
                when ActiveRecord::Relation
                  crosstab_func_query.to_sql
                when Arel::SelectManager
                  replace_binds(crosstab_func_query)
                end

      tbl = Arel::Table.new('ct')

      ct = Arel::Nodes::NamedFunction.new('ct', crosstab_cols)

      crosstab = Arel::Nodes::As.new(
        Arel::Nodes::NamedFunction.new(
          'CROSSTAB',
          [Arel.sql("$$#{ct_sql}$$")]
        ),
        ct
      )

      tbl
        .project(tbl[Arel.star])
        .from(crosstab)
    end

end
