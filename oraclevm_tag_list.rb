#
# Code copied from Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# Author:: Michael Huisman michhuis@gmail.com
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# list tag 
class Chef::Knife::OraclevmTagList < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm tag list <name>"

  get_common_options

  def run
  
    $stdout.sync = true

    tag = @name_args[0]

    current=list_tag(tag)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end
