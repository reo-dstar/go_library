
module GoLibrary
	module Error
		class GoLibraryError < StandardError; end
		class ParameterError < GoLibraryError
	      def initialize(error_message = nil)
	        super(error_message)
	      end
		end
	end
end