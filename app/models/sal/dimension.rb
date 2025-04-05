class SAL::Dimension < SAL::Field
  attr_reader :model, :type, :opts

  # Model specifies the model on which the dim has been set
  # klass specifies the model which the dim's column actually belongs to
  #
  # So, for a base dim, the model and the klass will be the same
  # but for a reflected dim, the klass will be the model/class associated with the reflection
  def initialize(model, column, type: :base, opts: {})
    raise ArgumentError.new("#{type} is not valid") unless [:base, :reflection].include?(type)
    raise ArgumentError.new("Must specify a reflection if type is reflection") if type == :reflection && opts[:reflection].blank?
    raise ArgumentError.new("Type must equal :reflection in order to specify a reflection") if opts[:reflection].present? && type != :reflection

    super(model, column)
    @type = type
    @opts = opts
  end

  def name
    if reflection?
      "#{opts[:reflection].name}.#{super}"
    else
      super
    end
  end

  def display_name(hide_reflection: false)
    if opts[:display_name]
      opts[:display_name]
    elsif reflection?
      if hide_reflection
        name.split('.').last.titleize
      else
        name.split('.').map(&:titleize).join(': ')
      end
    else
      name.titleize
    end
  end

  def reflection
    return nil if !reflection?

    opts[:reflection]
  end

  def reflection?
    type == :reflection
  end

  def klass
    reflection? ? reflection.klass : model
  end

  def table_alias
    reflection? ? reflection.name.to_s.pluralize : model.table_name
  end

  def self.find_by_name(model, dim_name)
    super(model, dim_name, type: :dimension)
  end
end
