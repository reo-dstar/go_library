#!/bin/env ruby
# -*- coding: utf-8 -*-

require_relative "http_custom"
require_relative "environment"
require 'nokogiri'


module CalilFunc
  # CalilConnecter
  # 
  # Calil にリクエストを行いレスポンスを戻り値として返却します
  # path は '/' から入力
  class Connecter < Http_custom
  @@protocol='http'
  #
  #==mode
  #  'rest'のみ
  #
  def initialize(mode, path, query, appkey=nil,format='xml', headers={})
    @mode = mode
    @host = 'api.calil.jp'
    # @version = version
    @format = format
    @appkey = appkey
    @headers = headers
    url = @@protocol + '://' + @host + path + '?appkey=' + @appkey + '&' + "format=#{@format}"
    if  (query != nil) then
      if (query.class == String)
        url += '&' + query
      elsif(query.class == Hash)
        query.each do |key, value|
          raise "#{key}:String ではない 値をリクエストしようとしています。" if value.class != String
          url += "&#{key}=#{value}"
        end
      end
    end
    @request_url = url
    if Environment.get_env('connect_proxy')
      proxys = ENV['http_proxy'].sub(/\Ahttp:\/\//,'').split(':')
      @proxy = proxys[0]
      @proxy_port = proxys[1]
    end
  end

  public

  #
  # calil の処理を実行する
  # 
  # path  calilのapiパス
  # query String or Hash
  # 
  #
  def get(open_timeout=nil, read_timeout=5)
    if (@mode == 'rest') then
      res = rest(@request_url, @headers, open_timeout, read_timeout)
      if (@format == 'xml')
        return Nokogiri::XML(res.body)
      else
        return res
      end
    else
      return false
    end
  end
  
  def get_request
    return [@request_url, @headers.clone]
  end

  private
  def rest(url, headers, open_timeout, read_timeout)
    res = get_with_timeout(url, open_timeout, read_timeout, headers)
    return res
  end

  end
end


