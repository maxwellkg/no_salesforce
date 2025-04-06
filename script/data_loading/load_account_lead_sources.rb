# this script creates the default AccountLeadSource instances

sources = %W(
  Web
  Phone\ Inquiry
  Partner\ Referral
  External\ Referral
  Partner
  Public\ Relations
  Trade\ Show
  Word\ of\ mouth
  Employee\ Referral
  Purchased\ List
  Other
)

sources_to_create = sources.map do |s|
  { name: s }
end

AccountLeadSource.create!(sources_to_create)
