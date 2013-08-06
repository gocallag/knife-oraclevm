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
			
		end
	end
end
