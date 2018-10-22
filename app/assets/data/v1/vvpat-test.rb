require "csv"

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
filepath    = 'vs-products-by-county.csv'

data = []
equipments = []

CSV.foreach(filepath, csv_options) do |row|
  data << {equipment: row['Equipment Type'], vvpat: row['VVPAT']}
  equipments << row['Equipment Type']
end

puts 'Printing equipment types'
puts equipments.uniq

puts 'Are all DRE devices coded with a yes or no VVPAT?'
puts data.all? do |datum|
  if datum.equipment == 'DRE-Touchscreen' || datum.equipment == 'DRE-Push Button' || datum.equipment == 'DRE-Dial'
    datum.vvpat == 'yes' || datum.vvpat == 'no'
  end
end
