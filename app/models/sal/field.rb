class SAL::Field
  delegate_missing_to :column

  attr_reader :model, :column

  def initialize(model, column)
    @model = model
    @column = column
  end

  def self.find_by_name(model, field_name, type: nil)
    type = :field if type.nil?
    raise "#{type} is not a valid type" unless [:dimension, :measure, :field].include?(type)
    raise "Cannot find without a model" if model.blank?
    raise "Cannot find without a name" if field_name.blank?

    fieldset_method = case type
                      when :field
                        :fields
                      when :dimension
                        :dimensions_including_reflected
                      when :measure
                        :measures
                      end

    field = model.sal_fieldset.send(fieldset_method).detect { |field| field.name == field_name.to_s }

    raise "Could not find a field named #{field_name} on #{model.to_s}" if field.nil?

    field
  end

  def date_col?
    column.type == :date
  end

  def column_name
    column.name
  end

  def dimension?
    self.is_a?(SAL::Dimension)
  end

  def measure?
    self.is_a?(SAL::Measure)
  end
end
