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
class Chef::Knife::OraclevmVmMessage < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm message VMNAME (options)"
  
  option :key,
    :short => "-k VALUE",
	:long => "--key VALUE",
	:description => "The name of the key."
  
  option :message,
    :short => "-m VALUE",
	:long => "--message VALUE",
	:description => "The value of the message."
  
  get_common_options  
  
  def run
  
    $stdout.sync = true

    vmname = @name_args[0]
	
	key=get_config(:key)
	message=get_config(:message)

    current=send_message(vmname, key, message)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")

    if current[:status]!="Success"
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end

  end
end