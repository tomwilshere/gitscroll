module MetricsHelper

  def generate_metrics(fileContents, file_name)
    metrics = {}
    Metric.all.each do |metric|
      if (metric[:extension_list].empty?) ||
         (metric[:extension_list].include? file_name.split('.').last)
        metrics[metric.name] = method(metric.name.to_sym).call(fileContents)
      end
    end
    metrics
  end

  def create_temp_file(fileContents, fileName)
    temp_file = Tempfile.new(fileName)
    temp_file.write(fileContents
      .encode('UTF-8', { invalid: :replace, undef: :replace, replace: '?' }))
    temp_file.rewind
    temp_file
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
      flogger = Flog.new parser: RubyParser
      flogger.flog '-'
      result = flogger.total_score
    rescue

    end
    $stdin = old_stdin
    result
  end

  def num_lines(file)
    file.split("\n").size
  end

  def wilt(file)
    lines = file.split("\n")
    if lines.size > 0
      return lines.map { |line| line[/\A\s*/].size }.sum / lines.size
    else
      return nil
    end
  end

  def rubocop(file)
    temp_file = create_temp_file(file, 'rubocop')
    res = `rubocop #{temp_file.path}`
    res.split("\n").size
  end

  def checkstyle(file)
    temp_file = create_temp_file(file, 'checkstyle')
    res = `java -jar metric_scripts/checkstyle/checkstyle-5.7-all.jar -c metric_scripts/checkstyle/sun_checks.xml #{temp_file.path}`
    res.split("\n").size - 2
  end

end
