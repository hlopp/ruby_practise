#!/usr/bin/env ruby

def init_command
  Command::ALL_COMMANDS.push(HelpCommand, UptimeCommand, DateCommand, EchoCommand)
end

class Command
  ALL_COMMANDS = []
  def self.name
    'base'
  end
  def self.description
    'Base command description'
  end  
  def self.command_by_name(name_command)
    begin
    exec_command = Command::ALL_COMMANDS.find { |i| i.name == name_command }
    raise MyError.msg(name_command) if exec_command.nil? 
    return exec_command unless  exec_command.nil?
    end
  end
  protected
  def self.say(*param)
    puts '*' * 20
    p Time.now
    puts "Exec script: #{$0}"
    puts '*' * 20
    puts param
  end
end

class MyError < StandardError
  def self.msg(command)
    puts "Exeption: command #{command} is not found"
  end
end

class HelpCommand < Command
  def self.name
    'help'
  end
  def self.description
    'Display help docs'
  end
  def self.run
    say 'Available commands:'
    Command::ALL_COMMANDS.each { |i| puts "#{i.name}  -  #{i.description}" }
  end
end

class UptimeCommand < Command
  def self.name
    'uptime'
  end
  def self.description
    'Display processor uptime'
  end
  def self.run
    begin
#    a = File.read('/proc/uptime')
    a = File.read('/proc/up')
    puts "#{a.chomp} sec"
    rescue Errno::ENOENT
    puts 'No such file /proc/uptime'
    end
  end
end

class DateCommand < Command
  def self.name
    'date'
  end
  def self.description
    'Display current date and time'
  end
  def self.run
    puts "Current date:  #{Time.now}"
  end
end

class EchoCommand < Command
  def self.name
    'echo'
  end
  def self.description
    'Display last passed argument'
  end
  def self.run_echo
    yield('Hi! Say something:', 'true')
  end
  
  def self.run(m = '')
    if !m.empty?
      puts "Your echo: #{m}"
    else
      run_echo do |message, wait_answer|
      puts message
      print '> '
      user_input = gets.chomp if wait_answer
      puts "Your echo: #{user_input}"
    end
   end
  end
end

init_command

loop do
  begin
  print '> '
  cmd_input = gets.chomp.split
  next if cmd_input.empty?
  cmd_command = cmd_input.shift.downcase
  cmd_argument = cmd_input[0]
  abort('Bye!') if cmd_command  == 'exit'
    begin
  current_command = Command.command_by_name(cmd_command)
  rescue  => e
  File.write('/tmp/ruby.log', e.inspect)
  next
    end
   if cmd_argument == 'help'
     p current_command.description
   elsif current_command == EchoCommand && cmd_argument
     current_command.run(cmd_argument)
   else
     current_command.run
   end
  rescue Interrupt, NoMethodError
  abort('Bye, sweetty!')
 end
end


