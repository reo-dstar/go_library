#!/bin/env ruby
# -*- coding: utf-8 -*-

require "nkf"
require "yaml"

module WebAPIFunc
  class Environment
    @@env = {
      # 'rootDir'=>File.dirname(__FILE__)+'/..',
      'rootDir'=>File.dirname(__FILE__),
    }
    
    # system 情報み込み
    hash = YAML.load(File.read("#{@@env['rootDir']}/conf/env.yml", :encoding => Encoding::UTF_8))
    if (hash.class != Hash)
      raise "システムファイルのフォーマットが正しくありません"
    end
    hash.each{|key, value|
      @@env[key] = value
    }
    def self.get_env(name)
      return @@env[name]
    end

    def self.set_env(name, value)
      @@env[name] = value
    end
    
  end
end
