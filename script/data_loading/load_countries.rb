# this script uses a CSV file containing a list of all ISO-3166 countries
# to populate the countries table (Locations::Country model)
#
# the path to this file should be provided in the arguments when calling this script
# e.g. `rails runner script/data_loading/load_countries.rb path/to/file`
#
# the file can be downloaded here: https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv

require 'csv'

fpath = File.expand_path(ARGV[0])

# map the columns in the file to columns on Locations::Country

COLUMN_MAPPING = {
  name: :name,
  alpha2: :alpha_2,
  alpha3: :alpha_3,
  countrycode: :country_code,
  iso_31662: :iso_3166__2,
  region: :region,
  subregion: :sub_region,
  intermediateregion: :intermediate_region,
  regioncode: :region_code,
  subregioncode: :sub_region_code,
  intermediateregioncode: :intermediate_region_code 
}

# create a Locations::Country instance for each row in the file

countries = []

csv = CSV.read(fpath, headers: true, header_converters: :symbol)

csv.each do |row|
  countries << COLUMN_MAPPING.each_with_object({}) do |(k, v), hsh|
    hsh[v] = row[k]
  end
end

Locations::Country.create!(countries)
