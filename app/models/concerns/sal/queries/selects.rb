module SAL::Queries::Selects
  extend ActiveSupport::Concern

  included do

    private

      def alias_for_dim_name(dim_name)
        dim_name.gsub('.', '_')
      end

      def total_text_col?(col_name)
        return false unless self.class.const_defined? :TOTAL_COL_TEXT

        col_name == self.class::TOTAL_COL_TEXT
      end

      def dim_in_conditions?(dim)
        conditions.keys.map(&:to_sym).include?(dim.reflection.name)
      end

      def group_by_select(gb)
        if total_text_col?(gb)
          gb
        else
          dim_name = gb.is_a?(Hash) ? gb[:dim_name] : gb
          dim = SAL::Dimension.find_by_name(klass, dim_name)

          table = if dim.reflection?
                    # when the dim is a reflection, AR will not alias the table
                    # unless the same reflection is used as a condition, in which case
                    # the table is aliased as the association's name
                    #
                    # not quite sure why it's done this way, but we need to account
                    # for this when creating the select statement
                    t = dim.reflection.klass.arel_table

                    if dim_in_conditions?(dim)
                      t = t.alias(dim.reflection.name)
                    end

                    t
                    
                  else
                    klass.arel_table
                  end

          col = table[dim.column_name]

          sql = gb.is_a?(Hash) ? gb[:func].to_proc.call(col) : col

          select_alias = gb.is_a?(Hash) ? gb[:alias] : alias_for_dim_name(dim.name)

          sql.as(select_alias)
        end
      end

      def metric_select(metric_hsh:, should_alias: true, sql_alias: nil, filter: nil)
        col = klass.arel_table[metric_hsh[:field]]

        m = metric_hsh[:func].to_proc.call(col)

        m = m.filter(filter) if filter.present?

        if should_alias
          al = sql_alias || metric_hsh[:alias]
          m = m.as(al)
        end

        m
      end

  end

end
