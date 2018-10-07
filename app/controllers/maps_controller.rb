class MapsController < ApplicationController
  def index
    @states = 'https://www.nohrsc.noaa.gov/data/vector/master/st_us.kmz'
  end
end
