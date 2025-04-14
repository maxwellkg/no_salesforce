module SAL::Queries::Reflections
  extend ActiveSupport::Concern

  private

    def reflections_for_dims(*dims)
      unique_dims = dims
                      .flatten
                      .compact
                      .uniq


      refs = unique_dims.map do |param|
        dim_name = param.is_a?(Hash) ? param[:dim_name] : param

        begin
          dim = SAL::Dimension.find_by_name(klass, dim_name)

          dim.reflection.name if dim.reflection?
        rescue
          nil
        end
      end

      refs.compact
    end

end
