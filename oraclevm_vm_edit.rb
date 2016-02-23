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
class Chef::Knife::OraclevmVmEdit < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm edit VMNAME (options)"
  
  option :memory,
    :short => "-m VALUE",
	:long => "--memory VALUE",
	:description => "The memory size the virtual machine is allocated in MB."
  
  option :memorylimit,
    :short => "-l VALUE",
	:long => "--memoryLimit VALUE",
	:description => "The maximum memory size the virtual machine can be allocated in MB."
	
  option :cpucount,
    :short => "-c VALUE",
	:long => "--cpucount VALUE",
	:description => "The number of processors the virtual machine is allocated."
  
  option :cpucountlimit,
    :short => "-x VALUE",
	:long => "--cpucountlimit VALUE",
	:description => "The maximum number of processors the virtual machine can be allocated."	
  
  get_common_options  
  
  def run
  
    $stdout.sync = true

    vmname = @name_args[0]
	
	memory=get_config(:memory)
	memorylimit=get_config(:memorylimit)
	cpucount=get_config(:cpucount)
	cpucountlimit=get_config(:cpucountlimit)

    current=edit_vm(vmname, memory, memorylimit, cpucount, cpucountlimit)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end