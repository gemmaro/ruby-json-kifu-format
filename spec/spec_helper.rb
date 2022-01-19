# frozen_string_literal: true

require 'simplecov'

SimpleCov.start

require 'kconv'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'jkf'

module ExtendHelper
  def fixtures(type)
    Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
  end

  def error_fixtures(type)
    Dir[File.expand_path("../error_fixtures/#{type}/**", __FILE__)]
  end
end

module IncludeHelper
  def pos(coordinate_x, coordinate_y)
    { 'x' => coordinate_x, 'y' => coordinate_y }
  end

  def hms(hour, minute, second)
    { 'h' => hour, 'm' => minute, 's' => second }
  end

  def ms(minute, second)
    { 'm' => minute, 's' => second }
  end

  def fixtures(type)
    Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
  end

  def error_fixtures(type)
    Dir[File.expand_path("../error_fixtures/#{type}/**", __FILE__)]
  end
end

RSpec.configure do |config|
  config.extend ExtendHelper
  config.include IncludeHelper
end
