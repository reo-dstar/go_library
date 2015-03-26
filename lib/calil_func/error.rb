#
# CalilFunc エラーオブジェクト
# 
#
#
module CalilFunc
  module Error
    class CalilError < StandardError; end
    
    class CalilResponseError < CalilError
      # def initialize(error_message = nil, calil_err_code)
      def initialize(error_message = nil)
        super(error_message)
        # @calil_err_code = calil_err_code
      end
      # attr_reader :calil_err_code
    end
  end
end

