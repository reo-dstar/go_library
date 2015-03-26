#
# WebAPIFunc エラーオブジェクト
# 
#
#


module WebAPIFunc
  module Error
    
    module WebAPI
      class WebAPIError < StandardError; end
      
      class WebAPIResponseError < WebAPIError
        def initialize(error_message = nil, web_s_err_code)
          super(error_message)
          @web_s_err_code = web_s_err_code
        end
        attr_reader :web_s_err_code
      end
    end

    # class TeikiParamError < StandardError; end #定期オブジェクトのイニシャライズに必要なパラメータがない

  end
end


=begin
if __FILE__ == $0
  error_obj = WebAPIFunc::Error.new(WebAPIFunc::ERRCODELIST[:http_get], "test")
  puts(error_obj.code)
  puts(error_obj.message)
  puts(error_obj.string)
end
=end

