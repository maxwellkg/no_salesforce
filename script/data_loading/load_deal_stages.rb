STAGES = %w(  
  Connecting
  Qualification
  Scoping
  Proposal
  Negotiation
  Closed\ Won
  Closed\ Lost
)

stages_to_create = STAGES.map { |stage| { name: stage } }

DealStage.find_or_create_by!(stages_to_create)
