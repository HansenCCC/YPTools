#!/usr/bin/ruby
require 'pathname'

def yp_install_template
    path = Pathname.new(File.dirname(__FILE__)).realpath
    puts type(path)
    path = path.sub("\n","")
    puts path.length
    puts path
#    `cd path`
#    puts `sh install-template.sh`
end

