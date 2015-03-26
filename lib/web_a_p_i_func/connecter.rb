#!/bin/env ruby
# -*- coding: utf-8 -*-

require_relative "http_custom"
require_relative "environment"
require 'nokogiri'


module WebAPIFunc
  # WebAPIConnecter
  # 
  # WebAPI にリクエストを行いレスポンスを戻り値として返却します
  # また HTTP通信を行わなずに WebAPI からの戻り値を返却する機能を実装する予定
  class Connecter < Http_custom
  @@protocol='http'
  #
  #==mode
  #  'rest' or '???'(HTTP通信をしないモード)
  #
  def initialize(mode, host, path, query, key=nil, version='v1', format='xml', headers={})
    @mode = mode
    @host = host
    @version = version
    @format = format
    @key = key
    @headers = headers
    url = @@protocol + '://' + @host + '/' + @version  + '/' + @format + path + '?key=' + @key
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
    if Environment.get_env('web_a_p_i_connect_proxy')
      proxys = ENV['http_proxy'].sub(/\Ahttp:\/\//,'').split(':')
      @proxy = proxys[0]
      @proxy_port = proxys[1]
    end
  end

  public

  #
  # webapi の処理を実行する
  # 
  # path  webapi処理のパス
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
  # rest で WebAPIを利用
  def rest(url, headers, open_timeout, read_timeout)
    #WebAPIのRESTは get のみ受け付け]
    res = get_with_timeout(url, open_timeout, read_timeout, headers)
    return res
  end
  # http通信を使わないで WebAPIを利用
  #def hogehoget
  #end

  end
end


# if __FILE__ == $0
#   begin
#     webapi = 'http://192.168.30.228/webapi'
#     webapi_version = 'v1'
#     webapi_format = 'xml'
#     #webapi_url =  webapi + '/' + webapi_version + '/' + webapi_format
#     webapi_key = 'test_A5LQcgQuZNu'
#     httpHeaders = {'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
#     'Accept-Charset' => 'Shift_JIS,utf-8;q=0.7,*;q=0.3',
#     'Accept-Encoding' => 'gzip,deflate,sdch',
#     'Accept-Language' => 'ja,en-US;q=0.8,en;q=0.6',
#     'Cache-Control' => 'max-age=0',
#     'Connection' => 'keep-alive',
#     'Host' => '192.168.30.228',
#     'User-Agent' => 'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30'}
#     w_api = WebAPIFunc::Connecter.new('rest', webapi, webapi_version, webapi_format, webapi_key, httpHeaders)
#     webapi_path = '/dataversion'

#     xml = w_api.get(webapi_path, nil)
#     node = xml.xpath("/ResultSet/Copyrights") 
#     puts(node.text)
#   rescue =>e
#     puts e.to_s
#   end
# end
