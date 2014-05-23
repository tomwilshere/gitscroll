module MetricsHelper

	def generate_metrics(fileContents, file_name)
		metrics = Hash.new
		Metric.all.each do |metric|
			if (metric[:extension_list].empty?) || (metric[:extension_list].include? file_name.split(".").last)
				metrics[metric.name] = method(metric.name.to_sym).call(fileContents)
			end
		end
		return metrics
	end

	def createTempFile(fileContents, fileName)
		tempFile = Tempfile.new(fileName)
		tempFile.write(fileContents.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'}))
		tempFile.rewind
		return tempFile
	end

	def flog(file)
		require 'fileutils'
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
		return lines.size > 0 ? lines.map{ |line| line[/\A\s*/].size}.sum()/lines.size : nil
	end

	def rubocop(file)
		tempFile = createTempFile(file, "rubocop")
		res = `rubocop #{tempFile.path}`
		return res.split("\n").size
	end

	def checkstyle(file)
		tempFile = createTempFile(file, "checkstyle")
		res = `java -jar metric_scripts/checkstyle/checkstyle-5.7-all.jar -c metric_scripts/checkstyle/sun_checks.xml #{tempFile.path}`
		return res.split("\n").size() - 2
	end

	def comment_count(file)
		count = 0
		require 'syntax'
		require 'boolean_ints'
		tokenizer = Syntax.load("ruby")
		file.split("\n").each do |line|
			comment_found = false
			tokenizer.tokenize(line) do |token|
				if token.group == "comment"
					comment_found = true
				end
			end
			count = count + comment_found.to_i
		end
		return count
	end

end
