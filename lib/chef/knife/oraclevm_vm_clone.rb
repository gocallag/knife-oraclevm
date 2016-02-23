#
# Code copied from Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# Author:: Michael Huisman michhuis@gmail.com
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# Clone a virtual machine
class Chef::Knife::OraclevmVmClone < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm clone VMNAME (options)"

  option :desttype,
    :short => "-t VALUE",
	:long => "--desttype VALUE",
	:description => "The object to create from the virtual machine can be a virtual machine or a template."
  
  option :destname,
    :short => "-n VALUE",
	:long => "--destname VALUE",
	:description => "The name of the cloned virtual machine or template."
	
  option :serverpool,
    :short => "-p VALUE",
	:long => "--serverpool VALUE",
	:description => "The server pool on which to deploy the cloned virtual machine or template." 
  
  get_common_options

  def run
  
    $stdout.sync = true

    vmname = @name_args[0]
	
	desttype=get_config(:desttype)
	destname=get_config(:destname)
	serverpool=get_config(:serverpool)

    current=clone_vm(vmname, desttype, destname, serverpool)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end
