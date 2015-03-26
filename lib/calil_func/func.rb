#!/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "connecter"
require_relative "environment"
require_relative "error"

module CalilFunc
  #
  # Calilにリクエストを行いレスポンスを受け取るには継承して callメソッド  を実装する必要がある
  #
  class Func
    @@app_key = nil
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
          @@logger.debug "CALL_Calil PATH:#{@path} ARGS:#{str}"
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
    # def self.set_key(key)
    #   @@app_key = key
    # end
    # def self.get_key
    #   return @@app_key
    # end

    private
    #
    # Calilを実行（リクエスト）し結果（レスポンス）を保持する
    #
    def _call(uri_encode=true)
      begin 
        key     = Environment.get_env('app_key')
        req_args = @args.clone
        #２バイトコードだけをURIエンコード
        if (uri_encode)
          @args.each{|key,value|
            if (/[^ -~｡-ﾟ]/ =~ value) != nil
              # 複数指定パラメータは分解してエンコード
              # if (value =~ /:/) != nil
              #   array = value.split(':')
              #   new_array = []
              #   array.each{|elm|
              #     if (/[^ -~｡-ﾟ]/ =~ elm) != nil
              #       new_array.push(URI.escape(elm))
              #     else
              #       new_array.push(elm)
              #     end
              #   }
              #   req_args[key] = new_array.join(':')
              # else
                req_args[key] = URI.escape(value)
              # end
            end
          }
        end
        connecter = CalilFunc::Connecter.new('rest',
                                             @path,
                                             req_args,
                                             key,
                                             'xml')
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
        # if @response.xpath('./ResultSet/Error').length > 0
        #   err_hash = {
        #     :code=>@response.xpath('./ResultSet/Error').attribute('code').value,
        #     :Message=>{
        #       :text=>@response.xpath('./ResultSet/Error/Message').text
        #     }
        #   }
        # end
        return self
      rescue => e
        raise Error::CalilResponseError.new("#{@path}:#{e.message}")
      end
    end
  end
end

