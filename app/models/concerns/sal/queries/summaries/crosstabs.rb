module SAL::Queries::Summaries::Crosstabs
  extend ActiveSupport::Concern

  private

    def crosstab_cols_sql_type
      return @metric[:return_type] if @metric[:return_type].present?

      metric_dim = SAL::Dimension.find_by_name(
        klass,
        @metric[:field]
      )

      sql_type = metric_dim.column.sql_type

      # the return types for Postgres aggregate functions do not always match the input types
      # see documentation here: https://www.postgresql.org/docs/8.2/functions-aggregate.html
      # 
      # TODO MKG 05/08/2024 should update this to account for the various different possibilities
      #
      # TODO MKG 10/08/2024
      # COUNT will always return bigint, regardless of the type of the field, how should we account for this?
      # for now, add a field in the metric hash to explicity state a return type

      case sql_type
      when 'integer'
        'bigint'
      when 'bigint'
        'numeric'
      else
        sql_type
      end
    end

    def crosstab_col_names
      @_crosstab_col_names ||= begin
        # each unique value in the data in the selected column
        # will become its own column in the crosstab output

        pluck_sql = if col_dim.reflection?
              if dim_in_conditions?(col_dim)
                "#{col_dim.reflection.name}.#{col_dim.column_name}"
              else
                col_dim.reflection.klass.arel_table[col_dim.column_name]
              end
            else
              @columns
            end

        ct_col_names =  joined_and_filtered_query
                          .distinct
                          .order(pluck_sql)
                          .pluck(pluck_sql)

        ct_col_names.map(&:to_s)
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
