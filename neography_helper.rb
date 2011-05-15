require 'rubygems'
require 'neography'

class NeographyHelper
  def self.neo
      @neo ||= Neography::Rest.new({:server => 'localhost'})
      return @neo
  end
end
