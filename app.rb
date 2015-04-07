require 'sinatra/base'
require 'erubis'
require 'pp'
require 'json'
require 'set'
# require 'sass'
# require 'coffee-script'

require_relative 'lib/web_a_p_i_func.rb'
require_relative 'lib/calil_func.rb'
# require_relative 'models/init'


class Server < Sinatra::Base
  set :erubis, :escape_html => true

  get '/' do
    erubis :index
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
  	# searchType = 'plain'  	
  	searchType = 'departure'  	
  	time = '1000'
  	func = WebAPIFunc::Func.new('/search/course/extreme')
  	func.args[:viaList] = vias.join(':')
  	func.args[:searchType] = searchType
  	func.args[:time] = time
  	func.call
  	#必要な情報だけを抽出
  	course_list = func.response.xpath('//Course').collect {|course|
  		course_hash = {}
  		course_txt = ''
  		lines = course.xpath('.//Line')
  		points = course.xpath('.//Point')
  		points.each_with_index{|point, index|
  			course_txt += point.xpath('./Station/Name/text()').to_s
  			if (index < lines.length)
  				course_txt += '[' + lines[index].xpath('./Name/text()').to_s + ']'
  			end
  		}
  		course_hash[:Text] = course_txt
  		course_hash[:SerializeData] = course.xpath('./SerializeData/text()').to_s
  		course_hash
  	}
	erubis :select_result, :locals => {:course_list => course_list}
  end

  get '/result' do
  	if params[:serializeData].nil?
  		raise ParameterError
  	end
  	serializeData = params[:serializeData];
  	# func = WebAPIFunc::Func.new('/closed/course/edit')
  	func = WebAPIFunc::Func.new('/course/edit')
  	func.args[:serializeData] = serializeData
  	# func.args[:addStopStation] = 'true'
  	func.call
  	route = func.response.xpath('//Course/Route')
  	points = route.xpath('./Point')
  	lines  = route.xpath('./Line')
  	res_stations = []
  	points.each_with_index{|point, index|
  		res_station = {}
  		res_station[:name] = point.xpath('./Station/Name/text()').to_s
  		res_station[:geopoint] =  point.xpath('./GeoPoint/@longi_d').to_s
  		res_station[:geopoint] += ',' + point.xpath('./GeoPoint/@lati_d').to_s
  		res_station[:primary] = true
  		res_stations << res_station
  		# 停車駅
  		if (index < lines.length) 	  		
  			temp_func = WebAPIFunc::Func.new('/course/station')
  			temp_func.args[:serializeData] = serializeData
  			temp_func.args[:sectionIndex] = (index+1).to_s
  			temp_func.call
  			points = temp_func.response.xpath('//Point')
	  		points.each_with_index{|point, index2|
	  			if (index2 == 0 || index2+1 == points.length)
	  				next
	  			end 
	  			res_station = {}
		  		res_station[:name] = point.xpath('./Station/Name/text()').to_s
				res_station[:geopoint] =  point.xpath('./GeoPoint/@longi_d').to_s
				res_station[:geopoint] += ',' + point.xpath('./GeoPoint/@lati_d').to_s
		  		res_station[:primary] = false
		  		res_stations << res_station
	  		}
  		end
  	}
  	erubis :result, :locals => {:stations => res_stations}
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

  get '/test' do
  	erubis :test
  end

end