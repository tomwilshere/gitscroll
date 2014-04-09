module MetricsHelper
	require 'FileUtils'
	def flog(file)
		require 'flog'
		# flog some stuff
	    old_stdin = $stdin
	    $stdin = StringIO.new file
	    $stdin.rewind
	    result = nil
	    begin
	    	flogger = Flog.new :parser => RubyParser
	    	flogger.flog "-"
	    	result = flogger.total_score
	    rescue

	    end
	    $stdin = old_stdin
	    return result
	end

	def num_lines(file)
		return file.split("\n").size
	end

	def wilt(file)
		lines = file.split("\n")
		return lines.size > 0 ? lines.map{ |line| line[/\A */].size}.sum()/lines.size : nil
	end

	# def rubocop(file)
	# 	tempFile = Tempfile.new("rubocop")
	# 	tempFile.write(file)
	# 	tempFile.rewind
	# 	res = `rubocop %{tempFile.path}`
	# 	puts res
	# 	return res.size
	# end

	def generate_metrics(file)
		metrics = Hash.new
		metrics[:flog] = flog(file)
		metrics[:num_lines] = num_lines(file)
		metrics[:wilt] = wilt(file)
		metrics[:rubocop] = rubocop(file)
		return metrics
	end

	def generate_metrics(fileContents, file_name)
		metrics = Hash.new
		all_metrics().each do |metric_name, metric|
			if (metric[:extension_list].empty?) || (metric[:extension_list].include? file_name.split(".").last)
				metrics[metric_name] = metric[:function].call(fileContents)
			end
		end
		return metrics
	end

	def all_metrics()
		metrics = {:flog => {:function => method(:flog), 
							:extension_list => ["rb"]},
					:num_lines => {:function => method(:num_lines), 
							:extension_list => []},
					:wilt => {:function => method(:wilt),
							:extension_list => []},
					# :rubocop => {:function => method(:rubocop),
							# :extension_list => ["rb", "erb", "haml"]}
				}
	end

end
