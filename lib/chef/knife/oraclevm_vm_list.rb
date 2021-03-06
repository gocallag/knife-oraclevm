#
# Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# Manage power state of a virtual machine
class Chef::Knife::OraclevmVmList < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm list <name>"

  get_common_options

  def run
  
    $stdout.sync = true

    vmname = @name_args[0]

    current=list_vm(vmname)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end
