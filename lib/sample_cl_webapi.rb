require_relative 'web_a_p_i_func'
require 'pp'

func = WebAPIFunc::Func.new('/station')
func.args[:code] = '22828'

pp func.call 
