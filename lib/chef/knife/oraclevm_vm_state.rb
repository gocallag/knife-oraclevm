#
# Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# License:: Apache License, Version 2.0
#

require 'chef/knife'
require 'chef/knife/BaseOraclevmCommand'
require 'netaddr'
require 'net/ssh'

# Manage power state of a virtual machine
class Chef::Knife::OraclevmVmState < Chef::Knife::BaseOraclevmCommand

  banner "knife oraclevm vm state VMNAME (options)"

  get_common_options

  option :state,
  :short => "-s STATE",
  :long => "--state STATE",
  :description => "The power state to transition the VM into; one of on|off|suspend|resume|restart"


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
   
    state=get_config(:state)

    if current[:status]=="Success"
        if not state 
           puts "Virtual machine #{vmname} is in state #{current[:vmstatus]}"
        else
        case current[:vmstatus]
        when 'Running'
           case state
           when 'on'
                 puts "Virtual machine #{vmname} was already powered on"
           when 'off'
                 result=stop_vm(vmname)
                 puts "Power off virtual machine #{vmname} : #{result[:status]}"
           when 'suspend'
                 result=suspend_vm(vmname)
                 puts "Suspend virtual machine #{vmname} : #{result[:status]}"
           when 'restart'
                 result=restart_vm(vmname)
                 puts "Restart virtual machine #{vmname} : #{result[:status]}"
           when 'resume'
                 puts "Cannot Resume virtual machine #{vmname} as it is on"
           else
                 show_usage
           end
        when 'Stopped'
           case state
           when 'on'
                 result=start_vm(vmname)
                 puts "Power on virtual machine #{vmname} : #{result[:status]}"
           when 'off'
                 puts "virtual machine #{vmname} was already off"
           when 'suspend'
                 puts "Cannot Suspend virtual machine #{vmname} as it is off"
           when 'restart'
                 puts "Cannot Restrt virtual machine #{vmname} as it is off"
           when 'resume'
                 puts "Cannot Resume virtual machine #{vmname} as it is off"
           else
                 show_usage
           end
        when 'Stopping'
           case state
           when 'on'
                 puts "Cannot power on virtual machine #{vmname} as it is Stopping"
           when 'off'
                 puts "Cannot power off virtual machine #{vmname} as it is Stopping"
           when 'suspend'
                 puts "Cannot Suspend virtual machine #{vmname} as it is Stopping"
           when 'restart'
                 puts "Cannot Restrt virtual machine #{vmname} as it is Stopping"
           when 'resume'
                 puts "Cannot Resume virtual machine #{vmname} as it is Stopping"
           else
                 show_usage
           end
        when 'Suspended'
           case state
           when 'on'
                 puts "Cannot Power on virtual machine #{vmname} as it is suspended"
           when 'off'
                 puts "Cannot Power off virtual machine #{vmname} as it is suspended"
           when 'suspend'
                 puts "Cannot Suspend virtual machine #{vmname} as it is already suspended"
           when 'restart'
                 puts "Cannot Restart virtual machine #{vmname} as it is suspended"
           when 'resume'
                 result=resume_vm(vmname)
                 puts "Resume virtual machine #{vmname} : #{result[:status]}"
           else
                 show_usage
           end
        else
            puts "I don't know what a state of  #{current[:vmstatus]} is on #{vmname}"
        end
        end
    else
      puts "Call to OVM CLI Failed with #{current[:errormsg]}"
    end
  end
end
