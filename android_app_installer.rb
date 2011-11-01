#!/usr/bin/env ruby
#
# StadiumVision Mobile:
# Android App Installer Script
#
# Mark Craig (mlcraig@cisco.com)
#

# import the required libraries
require 'optparse'
require 'fileutils'

# define the default options
options = {
	:app_apk_file => nil,
	:app_package => 'com.cisco.sv',
	:android_sdk_path => nil,
	:adb_exec => nil,
	:device_id_list => [],
	:launch_activity => nil
}

def command?(name)
  `which #{name}`
  $?.success?
end

# define the command-line options to parse
optparse = OptionParser.new do |opts|
	# get this script's name
	script_name = File.basename($0)
	
	# define the banner displayed as the help screen
	opts.banner = "\nusage: #{script_name} --apk-file [APP-APK-FILE] --app-package [APP-PACKAGE]\n\n"
	
	# define the command-line options
	opts.on( '--apk-file <APP-APK-FILE>', 'Android app .apk file' ) do |file|
		options[:app_apk_file] = file
	end
	
	opts.on( '--app-package <APP-PACKAGE>', 'Android app package' ) do |package|
		options[:app_package] = package
	end
	
	opts.on( '--sdk-path <SDK-PATH>', 'Android SDK path' ) do |path|
		options[:android_sdk_path] = path
	end
	
	opts.on( '--launch-activity <ACTIVITY-NAME>', 'Android app launch activity name' ) do |activity|
		options[:launch_activity] = activity
	end
	
	opts.on( '--help', 'Display this screen' ) do
		puts "#{opts}\n"
		exit 1
	end
end

# parse the command-line options
optparse.parse!

# build the 'adb' executable path
adb_exec = nil
if options[:android_sdk_path].nil? == false
	options[:adb_exec] = "#{options[:android_sdk_path]}/platform-tools/adb"
else
	options[:adb_exec] = 'adb'
end

# validate that the 'adb' executable exists
if command?(options[:adb_exec]) == false
	puts "\nCould not find the 'adb' executable. Use the --sdk-path option.\n\n"
	exit 1
end

# validate that an Android apk file was given
if options[:app_apk_file].nil?
	puts "\nNo Android .apk app file given\n\n"
	exit 1
end

# validate that the Android apk app file exists
if File.exists?(options[:app_apk_file]) == false ||
	File.directory?(options[:app_apk_file]) == true
	puts "\nCould not find Android apk app file: #{options[:app_apk_file]}\n\n"
	exit 1
end

# display the run-time options being used
puts
puts "Using 'adb' executable: #{options[:adb_exec]}"
puts "Using Android SDK path: #{options[:android_sdk_path]}"
puts "Using Android APK file: #{options[:app_apk_file]}"
puts "Using Android app package: #{options[:app_package]}"
puts

# get the list of connected android devices
puts "Getting list of connected Android devices"
IO.popen("#{options[:adb_exec]} devices") do |io|
	# get the system command's output
	output = io.read

	# if no output was generated
	if output.empty?
		puts "\nNo Android devices connected\n\n"
		exit 0
	end
	
	# split the command output into lines
	lines = output.split(/\r?\n/)
	
	# spin through each line (skipping the first line)
	lines[1..-1].each do |line|
		# split the line into a name / value pair
		device_tokens = line.split(/\s+/)
		device_id = device_tokens[0]
		device_keyword = device_tokens[1]
		
		# if the tokens are valid
		if !device_keyword.nil? && !device_keyword.empty? && device_keyword == "device"
			# add the device id to the device list
			puts "Detected Android device: #{device_tokens[0]}"
			options[:device_id_list] << device_id
		end
	end
end

# if no android device are connected
if options[:device_id_list].length == 0
	puts "No Android devices connected\n\n"
	exit 0
end

# install the Android apk app file to each connected Android device
options[:device_id_list].each do |device_id|
	# build the system command to uninstall any existing app
	uninstall_command = "#{options[:adb_exec]} -s #{device_id} uninstall #{options[:app_package]}"
	
	# uninstall any existing app from the device
	puts "\nUninstalling '#{options[:app_package]}' app from device '#{device_id}'"
	IO.popen("#{uninstall_command}") do |io|
		output = io.read
	end	
	
	# build the system command to install the app
	install_command = "#{options[:adb_exec]} -s #{device_id} install #{options[:app_apk_file]}"
	
	# install the Android apk app file to the next device
	puts "\nInstalling '#{File.basename(options[:app_apk_file])}' app to device '#{device_id}'"
	IO.popen("#{install_command}") do |io|
		output = io.read
	end	

	# if a launch activity is given
	if !options[:launch_activity].nil?
		puts "\nLaunching Android activity '#{options[:launch_activity]}' on device '#{device_id}'"
		
		# build the system command to launch the android activity
		launch_command = "#{options[:adb_exec]} -s #{device_id} shell am start -a android.intent.action.MAIN -n #{options[:app_package]}/#{options[:launch_activity]}"
		
		# launch the given activity on the device
		IO.popen("#{launch_command}") do |io|
			output = io.read
		end	
	end
end
puts
	