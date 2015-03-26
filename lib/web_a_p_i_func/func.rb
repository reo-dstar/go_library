#!/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "connecter"
require_relative "environment"
require_relative "error"

module WebAPIFunc
  #
  # WebAPIにリクエストを行いレスポンスを受け取るには継承して callメソッド  を実装する必要がある
  #
  class Func
    @@a_p_i_key = nil
    @@logger = nil
    # debug 0 無効  1 WebAPIへのリクエストをmessage配列にプッシュ 2 WebAPIからのレスポンスをmessage配列にプッシュ
    def initialize(path, debug=0, message=nil)
      @path = path
      @args = {}
      @debug = debug.to_i
      @message = message if message != nil
      @response = nil
    end
    attr_accessor :args
    attr_reader :response
    
    def call
      if @@logger
        if @@logger.level <= Logger::Severity::DEBUG
          str = ''
          @args.each{|key, value|
            str += "&#{key}=#{value}"
          }
          @@logger.debug "CALL_WEB_SERVICE PATH:#{@path} ARGS:#{str}"
        end
      end
      _call
    end

    # APIへの通信量計算用途
    def self.set_logger(logger)
      @@logger = logger
    end
    def self.get_logger
      @@logger
    end

    # APIへのkey
    def self.set_a_p_i_key(key)
      @@a_p_i_key = key
    end
    def self.get_a_p_i_key
      return @@a_p_i_key
    end

    private
    #
    # WebAPIを実行（リクエスト）し結果（レスポンス）を保持する
    #
    def _call(uri_encode=true)
      a_p_i_mode = Environment.get_env('web_a_p_i_mode')
      a_p_i_host = Environment.get_env('web_a_p_i_host')
      a_p_i_version = Environment.get_env('web_a_p_i_version')
      a_p_i_key     = Environment.get_env('web_a_p_i_key') ? Environment.get_env('web_a_p_i_key') : @@a_p_i_key.to_s
      a_p_i_format = 'xml'
      req_args = @args.clone
      #２バイトコードだけをURIエンコード
      if (uri_encode)
        @args.each{|key,value|
          if (/[^ -~｡-ﾟ]/ =~ value) != nil
            # 複数指定パラメータは分解してエンコード
            if (value =~ /:/) != nil
              array = value.split(':')
              new_array = []
              array.each{|elm|
                if (/[^ -~｡-ﾟ]/ =~ elm) != nil
                  new_array.push(URI.escape(elm))
                else
                  new_array.push(elm)
                end
              }
              req_args[key] = new_array.join(':')
            else
              req_args[key] = URI.escape(value)
            end
          end
        }
      end
      # シリアライズデータのURIに利用できない文字が置き換わるまで修正まで一時的にURIエンコード処理を入れる
      if req_args[:serializeData]
        req_args[:serializeData] = URI.escape(req_args[:serializeData])
      end
      
      connecter = WebAPIFunc::Connecter.new(a_p_i_mode,
                                                       a_p_i_host,
                                                       @path,
                                                       req_args,
                                                       a_p_i_key,
                                                       a_p_i_version,
                                                       a_p_i_format)
      # リクエストの内容を保管
      if (@debug == 1)
        last_request = connecter.get_request
        @message.push(last_request[0].to_s)
        @message.push("headers:#{last_request[1].to_s}")
      end
      result = connecter.get(nil, 300)
      # レスポンスの内容を保管
      if (@debug == 2)
        @message.push(@path)
        @message.push(result.to_s)
      end
      @response = result
      err_hash = nil
      if @response.xpath('./ResultSet/Error').length > 0
        err_hash = {
          :code=>@response.xpath('./ResultSet/Error').attribute('code').value,
          :Message=>{
            :text=>@response.xpath('./ResultSet/Error/Message').text
          }
        }
      end
      if err_hash != nil
        raise Error::WebAPI::WebAPIResponseError.new("#{@path}:#{err_hash[:Message][:text]}", err_hash[:code])
      end

      return self
    end
  end
end

