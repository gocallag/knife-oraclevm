#
# Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# list a server pool
class Chef::Knife::OraclevmServerpoolList < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm serverpool list <name>"

  get_common_options

  def run
  
    $stdout.sync = true

    pool = @name_args[0]

    current=list_serverpool(pool)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:poolstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end
