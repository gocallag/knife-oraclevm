#
# Code copied from Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# Author:: Michael Huisman michhuis@gmail.com
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# Add vnic on a virtual machine
class Chef::Knife::OraclevmVmAddvnic < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm addvnic VMNAME (options)"
  
  option :network,
    :short => "-n VALUE",
	:long => "--network VALUE",
	:description => "The name of the network."
  
  option :vnicname,
    :short => "-s VALUE",
	:long => "--vnicname VALUE",
	:description => "The name of the vnic."
  
  get_common_options  
  
  def run
  
    $stdout.sync = true

    vmname = @name_args[0]
	
	network=get_config(:network)
	vnicname=get_config(:vnicname)

    current=add_vnic(vmname, network, vnicname)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end