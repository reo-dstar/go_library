require 'sinatra/base'
require 'haml'
require 'pp'
require 'json'
# require 'sass'
# require 'coffee-script'

require_relative 'lib/web_a_p_i_func.rb'
# require_relative 'models/init'

class Server < Sinatra::Base
  get '/' do
    haml :index
  end

  get '/search' do
  	if params[:viaList].nil?
  		raise
  	end
	viaList = params[:viaList]
	vias = viaList.split(':')
	if (vias.size() < 2)
		raise
	end
  	searchType = 'plain'  	
  	func = WebAPIFunc::Func.new('/search/course/extreme')
  	func.args[:viaList] = vias.join(':')
  	func.args[:searchType] = searchType
  	func.call
  	pp func.response
  end

  get '/ajax/station' do
    if !params[:name] 
    	raise
    end
    func = WebAPIFunc::Func.new('/station/light')
	func.args[:name] = params[:name]
	func.call
	stations = func.response.xpath('//Point/Station')
	res = stations.collect{|station|
		{
			:name=>station.xpath('./Name/text()').to_s,
			:code=>station.xpath('./@code').to_s
		}
	}
	JSON.generate(res).to_s
  end
end