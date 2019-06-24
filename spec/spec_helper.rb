require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 95
end

require 'rack/test'
require_relative '../dependency'
