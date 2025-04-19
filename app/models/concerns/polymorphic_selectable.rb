module PolymorphicSelectable
  extend ActiveSupport::Concern

  included do
    
    def to_sgid_for_polymorphic_select
      to_sgid(for: :polymorphic_select)
    end

  end

end
