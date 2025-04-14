# Search & Analytics Library (SAL)

module SAL

	def self.all_configs
		SAL::Config.descendants
	end

	def self.find_config(config_name)
		matching = all_configs.detect do |config|
			config.name == config_name
		end

		raise "Couldn't find a SAL config with name #{config_name}" unless matching.present?

		matching
	end

end
