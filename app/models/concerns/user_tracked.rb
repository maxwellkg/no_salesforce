module UserTracked
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by, class_name: "User", optional: true
    belongs_to :last_updated_by, class_name: "User", optional: true

    before_create :set_created_by, unless: :created_by_changed?
    before_update :set_last_updated_by, unless: :last_updated_by_changed?

    private

      def set_created_by
        self.created_by = Current.user
      end

      def set_last_updated_by
        self.last_updated_by = Current.user
      end
  end

end