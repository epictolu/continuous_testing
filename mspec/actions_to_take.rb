require "rubygems"
require "ruby_gntp"

@message = ""

def when_a_file_is_created(file)
	report_on_build_result
end

def when_a_file_is_modified(file)
	report_on_build_result
end

def when_a_file_is_deleted(file)
	report_on_build_result
end

def report_on_build_result
	@message = get_errors_from_build

	if @message.empty?
		@message = get_errors_from_tests
	end

	if @message.empty?
		@message = "all tests succeeded"
	end

	puts @message

	send_notification 
end

def get_errors_from_build
	errors = ""

	build_solution.split("\r\n").each do |m|
		if m.match("error")
			errors += "#{m}\n\n\n"
		end
	end

	return errors
end

def get_errors_from_tests
	errors = ""
	parsing_error_details = false

	run_tests.split("\r\n").each do |m|
		if parsing_error_details == true && !(m.start_with? "\xAF")
			errors += "#{m}\n"
		elsif
			if !(errors.empty?)
				errors += "\n\n\n"
			end

			parsing_error_details = false
		end

		if m.match("FAIL")
			errors += "#{m}\n"
			parsing_error_details = true
		end
	end

	return errors
end

def run_tests
	`#{@test_command}`
end

def build_solution
	`#{@build_command}`
end

def send_notification
	if (@message.match("\r\n"))
		@message.gsub!("\r\n", "\n")
	end
	if (@message.match("\257"))
		@message.gsub!("\257", "")
	end

	growl = GNTP.new "Continuous Testing Script", @growl_hostname, @growl_password
	growl.register({
		:notifications => [{
			:name => "continuous testing script",
			:enabled => true,
		}]
	})

	growl.notify({
		:name  => "continuous testing script",
		:title => "build status",
		:text  => @message,
		:icon  => "growl.jpg",
	})
end
