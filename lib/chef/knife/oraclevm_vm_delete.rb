#
# Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# delete a VM
class Chef::Knife::OraclevmVmDelete < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm delete VMNAME"

  get_common_options


  def run
  
    $stdout.sync = true

    vmname = @name_args[0]
    if vmname.nil?
      show_usage
      ui.fatal("You must specify a virtual machine name")
      exit 1
    end
    current=show_vm_status(vmname)
    Chef::Log.debug("Status = #{current[:status]}.  Time = #{current[:time]}. VM Status = #{current[:vmstatus]}.")
   
    if current[:status]=="Success"
       dstatus=delete_vm(vmname)
       if dstatus[:status] == "Success"
          puts "#{dstatus[:status]}"
       else
          puts "Failed with #{dstatus[:errormsg]}"
       end
    else
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end
  end
end
