#!/bin/env ruby
# -*- coding: utf-8 -*-

require 'uri'
require 'net/http'
Net::HTTP.version_1_2

module WebAPIFunc
  class Http_custom
    def initialize
      @proxy = nil
      @proxy_port = nil
    end

    def get_with_timeout(uri,open_timeout=nil,read_timeout=nil,headers=nil,options=nil)
      #uri = URI.parse(URI.escape(uri)) if uri.respond_to? :to_str
      uri = URI.parse(uri) if uri.respond_to? :to_str
      Net::HTTP.Proxy(@proxy, @proxy_port).start(uri.host,uri.port) do |http|
        http.open_timeout= open_timeout if open_timeout
        http.read_timeout= read_timeout if read_timeout
        path_query = uri.path + (uri.query ? ( '?' + uri.query) : '')
        res = http.get(path_query, headers)
        return res
      end
    end

    def post_with_timeout(uri,open_timeout=nil,read_timeout=nil,headers=nil,options=nil)
      uri = URI.parse(uri) if uri.respond_to? :to_str
      Net::HTTP.Proxy(@proxy, @proxy_port).start(uri.host,uri.port) do |http|
        http.open_timeout= open_timeout if open_timeout
        http.read_timeout= read_timeout if read_timeout
        res = http.post(uri.path, uri.query, headers)
        return res
      end
    end
  end  
end

