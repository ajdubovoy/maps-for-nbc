require "csv"

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
filepath    = 'vs-products-by-county.csv'

raw_data = []

CSV.foreach(filepath, csv_options) do |row|
  raw_data << row
end

grouped_data = raw_data.group_by { |element| element['FIPS code'] }

final_data = grouped_data.map do |fips, group|
  first = group[0]
  new_element = {fips: fips, state: first['State'], county: first['Jurisdiction'], division: first['Division'], vvpat: 'error', color_bucket: 'error'}

  if group.any? { |datum| datum['VVPAT'] == 'No' }
    new_element[:vvpat] = 'some_paperless'
    new_element[:color_bucket] = 0
  elsif group.any? { |datum| datum['VVPAT'] == 'Yes' }
    new_element[:vvpat] = 'vvpat_provided_not_paperless'
    new_element[:color_bucket] = 1
  elsif group.all? { |datum| datum['VVPAT'] == 'N/A' }
    new_element[:vvpat] = 'paper_only'
    new_element[:color_bucket] = -1
  end
  new_element
end

CSV.open('vvpat-data.csv', 'wb', csv_options) do |csv|
  csv << %w[fips state county division vvpat color_bucket]
  final_data.each do |row|
    csv << [row[:fips], row[:state], row[:county], row[:division], row[:vvpat], row[:color_bucket]]
  end
end
