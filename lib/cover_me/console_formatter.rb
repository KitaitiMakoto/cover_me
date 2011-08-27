require 'test/unit/color'

class CoverMe::ConsoleFormatter < CoverMe::Formatter

  def format_report(report)
  end

  def format_index(index)
    template_file = File.join(File.dirname(__FILE__), 'templates', 'console.erb')
    config = CoverMe.config.console_formatter

    if config.use_color
      tuc = Test::Unit::Color
      colors = {
        'reset' => (tuc.new('reset')).escape_sequence,
        'hit'   => (tuc.new('green',  foreground: false) +
                    tuc.new('white',  bold: true)).escape_sequence,
        'near'  => (tuc.new('yellow', bold: true) +
                    tuc.new('black',  foreground: false)).escape_sequence,
        'miss'  => (tuc.new('red',    foreground: false) +
                    tuc.new('white',  bold: true)).escape_sequence
      }
    else
      colors = {}
    end

    # To do:
    #   Here is the presentation logic instead of business logic
    template('console.erb', '-').run(binding)
    return if index.percent_tested == 100

    index.reports.sort.each do |report|
      template('console.file.erb', '-').run(binding)
      next unless config.verbose
      $stdout.puts '    Untested line(s):' unless report.executed_percent == 100.0
      sl = report.source.length
      sls = sl.to_s.length
      last_rendered = nil
      report.coverage.each_with_index do |count, i|
        next unless count == 0

        unless last_rendered == i - 1
          line = i - 1
          status = report.coverage[i - 1] == 0 ? 'miss' : 'hit'
          template('console.line.erb', '-').run(binding)

          line = i
          status = report.coverage[i] == 0 ? 'miss' : 'hit'
          template('console.line.erb', '-').run(binding)
        end

        line = i + 1
        status = report.coverage[i + 1] == 0 ? 'miss' : 'hit'
        template('console.line.erb', '-').run(binding)

        $stdout.puts "" unless report.coverage[i + 1] == 0
        last_rendered = i
      end
    end
  end
end
