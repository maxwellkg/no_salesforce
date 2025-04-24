require 'csv'

# create the countries

countries_csv = CSV.read(Rails.root.join("db", "seed_data", "countries.csv"), headers: true)

countries = countries_csv.map(&:to_h)

Locations::Country.upsert_all(countries)

# create the states/region subtypes

subdivision_types = CSV.read(Rails.root.join("db", "seed_data", "subdivision_types.csv"), headers: true).map(&:to_h)

Locations::StateRegionType.upsert_all(subdivision_types, unique_by: :name)

# create the state/regions

country_mapper = Locations::Country.pluck(:alpha_2, :id).to_h
sr_type_mapper = Locations::StateRegionType.pluck(:name, :id).to_h

state_regions = CSV.read(Rails.root.join("db", "seed_data", "state_regions.csv"), headers: true, header_converters: :symbol).map(&:to_h)

state_regions.each do |sr|
	sr[:country_id] = country_mapper[sr[:country_short_code]]

	type = sr.delete(:region_type)

	sr[:type_id] = sr_type_mapper[type]
end

Locations::StateRegion.upsert_all(state_regions)

# create the account lead sources

sources = %w(
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

account_lead_sources = sources.map { |s| { name: s } }

AccountLeadSource.upsert_all(account_lead_sources)

# create industries

naics_sectors = [
  { code: "11", name: "Agriculture, Forestry, Fishing and Hunting" },
  { code: "21", name: "Mining, Quarrying, and Oil and Gas Extraction" },
  { code: "22", name: "Utilities" },
  { code: "23", name: "Construction" },
  { code: "31-33", name: "Manufacturing" },
  { code: "42", name: "Wholesale Trade" },
  { code: "44-45", name: "Retail Trade" },
  { code: "48-49", name: "Transportation and Warehousing" },
  { code: "51", name: "Information" },
  { code: "52", name: "Finance and Insurance" },
  { code: "53", name: "Real Estate and Rental and Leasing" },
  { code: "54", name: "Professional, Scientific, and Technical Services" },
  { code: "55", name: "Management of Companies and Enterprises" },
  { code: "56", name: "Administrative and Support and Waste Management and Remediation Services" },
  { code: "61", name: "Educational Services" },
  { code: "62", name: "Health Care and Social Assistance" },
  { code: "71", name: "Arts, Entertainment, and Recreation" },
  { code: "72", name: "Accommodation and Food Services" },
  { code: "81", name: "Other Services (except Public Administration)" },
  { code: "92", name: "Public Administration" }
]

Industry.upsert_all(naics_sectors)

# create the initial Deal Stages

stages = %w(  
  Connecting
  Qualification
  Scoping
  Proposal
  Negotiation
  Closed\ Won
  Closed\ Lost
)

deal_stages = stages.map { |s| { name: s } }

DealStage.upsert_all(deal_stages)

# create the reminder types

types = %w(
  call
  note
  meeting
  email
)

reminder_types = types.map { |t| { name: t } }

ReminderType.upsert_all(reminder_types)
