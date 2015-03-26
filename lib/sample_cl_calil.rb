require_relative 'calil_func'
require 'pp'

func = CalilFunc::Func.new('/library')
# func.args[:pref] = '埼玉県'
func.args[:geocode] = "139.7275,35.623055555555552"

pp func.call 
