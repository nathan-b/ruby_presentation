#!/usr/bin/ruby

require './PresentationGui.rb'
require './FilenameParser.rb'

#ARGV is the stuff passed in on the command line. 
#Note that code outside any class is executed when the program is run
pg = PresentationGui.new(FilenameParser.Parse(ARGV))
pg.main

