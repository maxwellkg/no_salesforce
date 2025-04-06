module UserTracked
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by, class_name: "User", optional: true
    belongs_to :last_updated_by, class_name: "User", optional: true
  end

end