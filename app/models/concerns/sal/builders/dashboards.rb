module SAL::Builders::Dashboards
	extend ActiveSupport::Concern

	included do

		def dashboard_name
			params[:dashboard_name]
		end

	end

end
