class FlashMessage
	attr_reader :type, :message

	def initialize(type, message)
		@type = type.to_sym
		@message = message
	end

  def self.collection_from_flash_hash(flash_hash)
    flash_hash.map { |type, message| new(type, message) }
  end

  # at this time, tailwind won't automatically include any dynamically-assigned classes (unless they are also
  # used statically somewhere else in the application)
  # so it is best to add any classes that might be generated through this method to the safelist
  # included in the tailwind.config.js file

  def display_color
    case type
    when :success
      "green"
    when :error
      "red"
    when :alert
      "amber"
    when :notice
      "blue"
    else
      "gray"
    end
  end

  def flash_class
    "flash-#{display_color}"
  end

end
