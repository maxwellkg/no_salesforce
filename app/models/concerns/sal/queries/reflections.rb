module SAL::Queries::Reflections
  extend ActiveSupport::Concern

  private

    # TODO 09/06/2024 MKG
    # clean this up
    def reflections_for_dims(*dims)
      dims
        .flatten
        .compact
        .uniq
        .map do |param|
          dim_name = param.is_a?(Hash) ? param[:dim_name] : param

          begin
            dim = SAL::Dimension.find_by_name(klass, dim_name)

            dim.reflection.name if dim.reflection?
          rescue
            nil
          end
        end
        .compact
    end

end
