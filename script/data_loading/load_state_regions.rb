# this script uses a CSV file containing all ISO-3166-2 subdivisions to create
# a Location::StateRegionType instance for each unique subdivision type
# and a Location::StateRegion for each row in the file
#
# the file should be given as an argument when calling this script using the rails runner
# e.g. `rails runner script/data_loading/load_state_regions.rb path/to/file`
#
# the file can be downloaded here: https://github.com/ravinsharma12345/ISO-3166/blob/master/ISO-3166-2.csv

require 'csv'


# get the file path from the cl arguments

fpath = File.expand_path(ARGV[0])


# map the files in the column to the columns on the Locations::StateRegion model

COLUMN_MAPPING = {
  country_short_code: :country_short_code,
  region_name: :name,
  region_type: :state_region_type_id,
  regional_code: :alpha_code,
  regional_number_code: :numeric_code  
}


csv = CSV.read(fpath, headers: true, header_converters: :symbol, col_sep: ";")


# normalize the region type names in the file by converting spaces and dashes to underscores
# and removing parentheses
#
# note that the region_type may be null

csv[:region_type] = csv[:region_type].map do |t|
  t.nil? ? t : t.downcase.gsub(/\s|-/, "_").gsub(/\(|\)/, "")
end


ActiveRecord::Base.transaction do

  # create a Location::StateRegionType instance for each unique region type in the file

  subdivision_types = csv[:region_type].uniq.reject(&:nil?).map { |r| { name: r } }
  Locations::StateRegionType.create!(subdivision_types)


  # create a Location::StateRegion instance for each row in the file

  subdivisions = []

  # the subdivisions csv file gives the subdivision type by name (converted above)
  # but we need to set subdivision_type_id based on the id that matches that name
  # start by creating a hash to map the values

  subdivision_mapper = Locations::StateRegionType.pluck(:name, :id).to_h

  # we'll also want to assign country_id by finding the Locations::Country that has
  # an alpha_2 code matching the country_short_code given in the file

  countries_mapper = Locations::Country.pluck(:alpha_2, :id).to_h

  csv.each do |row|
    hsh = {}

    COLUMN_MAPPING.each do |k, v|
      if k == :region_type
        # use the id from the mapper hash rather than the name from the file
        hsh[v] = subdivision_mapper[row[k]]
      else
        hsh[v] = row[k]
      end
    end

    hsh[:country_id] = countries_mapper[row[:country_short_code]]

    subdivisions << hsh
  end

  Locations::StateRegion.create!(subdivisions)

end
