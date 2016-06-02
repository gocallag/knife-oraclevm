#
# Author:: Geoff O'Callaghan (<geoffocallaghan@gmail.com>)
# Contributor:: 
# License:: Apache License, Version 2.0
#

require 'chef/knife'

# Base class for OracleVM knife commands
class Chef
	class Knife
		class BaseOraclevmCommand < Knife

			deps do
				require 'chef/knife/bootstrap'
				Chef::Knife::Bootstrap.load_deps
				require 'fog'
				require 'socket'
				require 'net/ssh'
				require 'readline'
				require 'chef/json_compat'
			end

			def self.get_common_options
				unless defined? $default
					$default = Hash.new
				end

				option :ovmmgr_user,
					:short => "-u USERNAME",
					:long => "--ovmmgruser USERNAME",
					:description => "The username for OracleVM Manager"
				$default[:ovmmgr_user] = "admin"

				option :ovmmgr_pass,
					:short => "-p PASSWORD",
					:long => "--ovmmgrpass PASSWORD",
					:description => "The password for OracleVM Manager"

				option :ovmmgr_host,
					:long => "--ovmmgrhost HOST",
					:description => "The OracleVM Manager host"

				option :ovmmgr_port,
					:long => "--ovmmgrport PORT",
					:description => "The OracleVM Manager CLI port number to use"
				$default[:ovmmgr_port] = 10000
			end

			def get_config(key)
				key = key.to_sym
				rval = config[key] || Chef::Config[:knife][key] || $default[key]
				Chef::Log.debug("value for config item #{key}: #{rval}")
				rval
			end

			def get_cli_connection

				conn_opts = {
					:host => get_config(:ovmmgr_host),
					:path => get_config(:ovmmgr_path),
					:port => get_config(:ovmmgr_port),
					:user => get_config(:ovmmgr_user),
					:password => get_config(:ovmmgr_pass),
				}
				
				# Grab the ovmmgr host  from the command line
				# if tt is not in the config file
				if not conn_opts[:host]
                                  conn_opts[:host] = get_host
                                end
				# Grab the password from the command line
				# if tt is not in the config file
				if not conn_opts[:password]
                                  conn_opts[:password] = get_password
                                end
				if conn_opts[:port] 
				  Chef::Log.debug("Waiting for port #{conn_opts[:port]} on #{conn_opts[:host]}...")
				  tcp_test_port(conn_opts[:host],conn_opts[:port])
				end
			        return conn_opts
			end
			
			def get_host
			  @host ||= ui.ask("Enter your OVM Mgr Host: ") { |q| q.echo = true }
			end

			def get_password
			  @password ||= ui.ask("Enter your password: ") { |q| q.echo = false }
			end

			def get_vm(vmname)
                          return retval
                        end 


			def fatal_exit(msg)
				ui.fatal(msg)
				exit 1
			end

			def tcp_test_port(hostname,port)
			  tcp_socket = TCPSocket.new(hostname, port)
			  readable = IO.select([tcp_socket], nil, nil, 5)
			  if readable
			    Chef::Log.debug("accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
			    true
			  else
			    false
			  end
			  rescue Errno::ETIMEDOUT
			    false
			  rescue Errno::EPERM
			    false
			  rescue Errno::ECONNREFUSED
			    sleep 2
			    false
			  rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
			    sleep 2
			    false
			  ensure
			    tcp_socket && tcp_socket.close
			end
	
#
#                       show_vm_status, given a vmname return the operational status of the vm
#
			def show_vm_status(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("show vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/ Status = /)
                                    current[:vmstatus]=line.split('=')[1].strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end

#
#                       start_vm, given a vmname issue a start request
#
			def start_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("start vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       stop_vm, given a vmname issue a stop request
#
			def stop_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("stop vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       suspend_vm, given a vmname issue a suspend request
#
			def suspend_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("suspend vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       resume_vm, given a vmname issue a resume request
#
			def resume_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("resume vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       restart_vm, given a vmname issue a restart request
#
			def restart_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("restart vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       list_vm, display all vm's
#
			def list_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           if not vmname 
                              Chef::Log.debug("#{conn_opts[:host]}...list vm")
                              Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                                 output = ssh.exec!("list vm")
                                 output.each_line do |line|
                                    if line.match(/Status:/)
                                       current[:status]=line.split[1].strip
                                    elsif line.match(/Time:/)
                                       line["Time: "]=""
                                       current[:time]=line.strip
                                    elsif line.match(/ id:/)
                                       puts line.split(':')[2].strip
                                    elsif line.match(/Error Msg:/)
                                       line["Error Msg: "]=""
                                       current[:errormsg]=line.strip
                                    end
                                 end
                              end
                              return current
                           else
                              Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{vmname}")
                              Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                                 output = ssh.exec!("show vm name=#{vmname}")
                                 output.each_line do |line|
                                    if line.match(/Status:/)
                                       current[:status]=line.split[1].strip
                                    elsif line.match(/Time:/)
                                       line["Time: "]=""
                                       current[:time]=line.strip
                                    elsif line.match(/Error Msg:/)
                                       line["Error Msg: "]=""
                                       current[:errormsg]=line.strip
                                    elsif line.match(/  /)
                                       puts line
                                    end
                                 end
                              end
                              return current
                           end
                        end
#
#                       list_serverpool, display all server pool's
#
			def list_serverpool(pool)
                           current = {:errormsg => "", :status => "", :time => "", :poolstatus => ""}

                           conn_opts=get_cli_connection
                           if not  pool
                              Chef::Log.debug("#{conn_opts[:host]}...list serverpool")
                              Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                                 output = ssh.exec!("list serverpool")
                                 output.each_line do |line|
                                    if line.match(/Status:/)
                                       current[:status]=line.split[1].strip
                                    elsif line.match(/Time:/)
                                       line["Time: "]=""
                                       current[:time]=line.strip
                                    elsif line.match(/ id:/)
                                       puts line.split(':')[2].strip
                                    elsif line.match(/Error Msg:/)
                                       line["Error Msg: "]=""
                                       current[:errormsg]=line.strip
                                    end
                                 end
                              end
                              return current
                           else
                              Chef::Log.debug("#{conn_opts[:host]}...show serverpool name=#{pool}")
                              Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                                 output = ssh.exec!("show serverpool name=#{pool}")
                                 output.each_line do |line|
                                    if line.match(/Status:/)
                                       current[:status]=line.split[1].strip
                                    elsif line.match(/Time:/)
                                       line["Time: "]=""
                                       current[:time]=line.strip
                                    elsif line.match(/Error Msg:/)
                                       line["Error Msg: "]=""
                                       current[:errormsg]=line.strip
                                    elsif line.match(/  /)
                                       puts line
                                    end
                                 end
                              end
                              return current
                           end
                        end
#
#                       delete_vm, delete VM
#
			def delete_vm(vmname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...delete vm name=#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("delete vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
						
#
#                       clone_vm, clone VM
#
			def clone_vm(vmname, desttype, destname, serverpool)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}
						   
                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...clone vm name=#{vmname},#{desttype},#{destname},#{serverpool}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("clone vm name=#{vmname} destType=#{desttype} destname=#{destname} serverPool=#{serverpool}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       edit_vm, edit VM cpu and memory
#
			def edit_vm(vmname, memory, memorylimit, cpucount, cpucountlimit)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}
						   
                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...edit vm name=#{vmname},#{memory},#{memorylimit},#{cpucount},#{cpucountlimit}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("edit vm name=#{vmname} memory=#{memory} memorylimit=#{memorylimit} cpucount=#{cpucount} cpucountlimit=#{cpucountlimit}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end						
#
#                       add_vnic, add vnic on vm 
#
			def add_vnic(vmname, network, vnicname)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}
						   
                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...create vnic name=#{vnicname},#{network},#{vmname}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("create vnic name=#{vnicname} network=#{network} on vm name=#{vmname}")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end					
#
#                       send_message, send a vm message to a vm
#
			def send_message(vmname, key, message)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}
						   
                           conn_opts=get_cli_connection
                           Chef::Log.debug("#{conn_opts[:host]}...sendvmmessage vm  name=#{vmname},#{key},#{message}")
                           Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                              output = ssh.exec!("sendvmmessage vm name=#{vmname} key=#{key} message=#{message} log=no")
                              output.each_line do |line|
                                 if line.match(/Status:/)
                                    current[:status]=line.split[1].strip
                                 elsif line.match(/Time:/)
                                    line["Time: "]=""
                                    current[:time]=line.strip
                                 elsif line.match(/Error Msg:/)
                                    line["Error Msg: "]=""
                                    current[:errormsg]=line.strip
                                 end
                              end
                           end
                           return current
                        end
#
#                       List TAG
#
			def list_tag(tag)
                           current = {:errormsg => "", :status => "", :time => "", :vmstatus => ""}

                           conn_opts=get_cli_connection
                           if not tag 
                              Chef::Log.debug("#{conn_opts[:host]}...list vm")
                              Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                                 output = ssh.exec!("list tag")
                                 output.each_line do |line|
                                    if line.match(/Status:/)
                                       current[:status]=line.split[1].strip
                                    elsif line.match(/Time:/)
                                       line["Time: "]=""
                                       current[:time]=line.strip
                                    elsif line.match(/ id:/)
                                       puts line.split(':')[2].strip
                                    elsif line.match(/Error Msg:/)
                                       line["Error Msg: "]=""
                                       current[:errormsg]=line.strip
                                    end
                                 end
                              end
                              return current
                           else
                              Chef::Log.debug("#{conn_opts[:host]}...show vm name=#{tag}")
                              Net::SSH.start( conn_opts[:host], conn_opts[:user], :password => conn_opts[:password], :port => conn_opts[:port] ) do|ssh|
                                 output = ssh.exec!("show tag name='#{tag}'")
                                 output.each_line do |line|
                                    if line.match(/Status:/)
                                       current[:status]=line.split[1].strip
                                    elsif line.match(/Time:/)
                                       line["Time: "]=""
                                       current[:time]=line.strip
                                    elsif line.match(/Error Msg:/)
                                       line["Error Msg: "]=""
                                       current[:errormsg]=line.strip
                                    elsif line.match(/  /)
                                       puts line
                                    end
                                 end
                              end
                              return current
                           end
                        end						
		end
	end
end
