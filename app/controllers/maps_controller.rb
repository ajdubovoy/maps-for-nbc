class MapsController < ApplicationController
  def index
    @states = 'https://www.nohrsc.noaa.gov/data/vector/master/st_us.kmz'
    @counties = 'https://www.nohrsc.noaa.gov/data/vector/master/cnt_us.kmz'
  end
end
