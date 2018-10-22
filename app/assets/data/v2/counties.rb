require "csv"
csv_options = { col_sep: ',', quote_char: '"', headers: :first_row, encoding:'iso-8859-1:utf-8' }

def median(array)
  sorted = array.sort
  len = sorted.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

counties = []
CSV.foreach('counties.csv', csv_options) do |row|
  counties << row.to_hash
end

final_data = counties

# Population

population = []
CSV.foreach('population-alldata.csv', csv_options) do |row|
  population << row.to_hash
end

final_data.each do |row|
  census_row = population.find { |population_row| population_row['STATE'] == row['state'] && population_row['COUNTY'] == row['county'] }
  row['population'] = census_row['POPESTIMATE2017'] unless census_row.nil?
end

## dd_population_quartile
all_populations = []
final_data.each do |row|
  all_populations << row['population'].to_i unless row['population'].nil?
end

quartile2 = median(all_populations)
lower = all_populations.find_all { |value| value <= quartile2 }
upper = all_populations.find_all { |value| value > quartile2 }
quartile1 = median(lower)
quartile3 = median(upper)

final_data.each do |row|
  population = row['population'].to_i
  if population <= quartile1
    row['dd_population_quartile'] = 1
  elsif population <= quartile2
    row['dd_population_quartile'] = 2
  elsif population <= quartile3
    row['dd_population_quartile'] = 3
  else
    row['dd_population_quartile'] = 4
  end
end

# Voting Machines
voting_machines = []
CSV.foreach('voting_machines.csv', csv_options) do |row|
  voting_machines << row.to_hash
end

final_data.each do |row|
  voting_row = voting_machines.find { |population_row| population_row['CountyID'].to_i == row['fips'].to_i }
  unless voting_row.nil?
    row['2016_registration'] = voting_row['Reg_Tot']
    row['dd_reg_percentage'] = (row['2016_registration'].to_i.fdiv( row['population'].to_i) * 100
                               ).round
    row['2016_ballots_cast'] = '?'
    row['dd_2016_turnout'] = '?'
    row['dd_2016_participation'] = '?'
    row['dd_xyz'] ='?'
    row['2016_vbm'] = '?'
  end
end

invalid = []
grouped_voting_machines = voting_machines.group_by { |element| element['CountyID'] }
grouped_voting_machines.each do |fips, group|
  dates = []
  group.each do |entry|
    begin
      dates << Date.strptime(entry['Begin use'], "%m/%d/%Y")
    rescue
      invalid << entry['Begin use']
    end
  end

  sorted = dates.sort
  oldest = sorted[0]

  row = final_data.find { |datum| datum['fips'].to_i == fips.to_i }
  year = oldest.year < 20 ? oldest.year + 2000 : oldest.year + 1900
  row['equipment_age'] = "#{year}-#{oldest.month}-#{oldest.day}" unless row.nil? || oldest.nil?
end

# Paper Status

vvpats = []
CSV.foreach('vs-products-by-county.csv', csv_options) do |row|
  vvpats << row.to_hash
end

grouped_vvpats = vvpats.group_by { |element| element['FIPS code'].to_i / 10**5 }

grouped_vvpats.each do |fips, group|
  row = final_data.find { |datum| datum['fips'].to_i == fips.to_i }

  if group.any? { |datum| datum['VVPAT'] == 'No' }
    row['paper_status'] = 'some_paperless' unless row.nil?
  elsif group.any? { |datum| datum['VVPAT'] == 'Yes' }
    row['paper_status'] = 'vvpat_provided_not_paperless' unless row.nil?
  elsif group.all? { |datum| datum['VVPAT'] == 'N/A' }
    row['paper_status'] = 'paper_only' unless row.nil?
  end
end

# Toss Ups

states = []
CSV.foreach('statesV-05-Oct20.csv', csv_options) do |row|
  states << row.to_hash
end

final_data.each do |row|
  selected = states.find { |state| row['state'].to_i == state['FIPS_State'].to_i }
  row['senate_toss_up'] == selected["Senate_Toss_Up"] unless selected.nil?
end


cdcounties = []
CSV.foreach('counties-within-cds.csv', csv_options) do |row|
  cdcounties << row.to_hash
end

final_data.each do |row|
  selected = cdcounties.find { |cd_row| row['state'].to_i == cd_row['STATEFP'].to_i && row['county'].to_i == cd_row['COUNTFP'].to_i }
  row['cd'] == cd['CD115FP'] unless selected.nil?
end

cds = []
CSV.foreach('CDs-V4-Oct19.csv', csv_options) do |row|
  cds << row.to_hash
end

final_data.each do |row|
  cd = cds.find { |cd_row| cd_row['STATE_FIPS'].to_i == row['state'].to_i && cd_row['CD_115_FIPS'].to_i == row['cd'].to_i }
  row['senate_toss_up'] == cd['CD_TossUp'] unless cd.nil?
end

CSV.open('counties-transformed.csv', 'wb', csv_options) do |csv|
  csv << final_data[final_data.length/2].keys
  final_data.each do |row|
    csv << row.values
  end
end

