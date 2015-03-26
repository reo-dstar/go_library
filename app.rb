require 'sinatra/base'
require 'haml'
require 'pp'
require 'json'
# require 'sass'
# require 'coffee-script'

require_relative 'lib/web_a_p_i_func.rb'
require_relative 'lib/calil_func.rb'
# require_relative 'models/init'

class Server < Sinatra::Base
  get '/' do
    haml :index
  end

  get '/search' do
  	if params[:viaList].nil?
  		raise ParameterError
  	end
	viaList = params[:viaList]
	vias = viaList.split(':')
	if (vias.size() < 2)
		raise ParameterError
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
    	raise ParameterError
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

  get '/ajax/library' do
  	if !params[:geocode]
  		raise ParameterError
  	end
  	func = CalilFunc::Func.new('/library')
  	func.args[:geocode] = params[:geocode]
  	func.call
  	librarys = func.response.xpath('//Library')
  	res = librarys.collect{|library|
  		{
  			:name => library.xpath('./formal/text()').to_s,
  			:url_pc => library.xpath('./url_pc/text()').to_s,
  			:address => library.xpath('./address/text()').to_s,
  			:tel => library.xpath('./tel/text()').to_s,
  			:geocode => library.xpath('./geocode/text()').to_s,
  			:distance => library.xpath('./distance/text()').to_s,
  		}
  	}
  	JSON.generate(res).to_s
  end
end