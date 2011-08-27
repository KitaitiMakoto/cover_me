require 'test/unit/color'

class CoverMe::ConsoleFormatter < CoverMe::Formatter

  Color = Test::Unit::Color

  def format_report(report)
  end

  def format_index(index)
    template_file = File.join(File.dirname(__FILE__), 'templates', 'console.erb')
    config = CoverMe.config.console_formatter
    colors = config.use_color ? self.colors : {}

    template('console.erb', '-').run(binding)
    return if index.percent_tested == 100

    index.reports.sort.each do |report|
      template('console.file.erb', '-').run(binding)
      next unless config.verbose

      $stdout.puts '    Untested line(s):' unless report.executed_percent == 100.0
      sls = (report.source.length + 1).to_s.length
      last_rendered = nil
      report.coverage.each_with_index do |count, line|
        next unless report.coverage[line - 1] == 0 || count == 0 || report.coverage[line + 1] == 0
        # $stdout.puts '' unless count == 0 || report.coverage[line - 1] == 0

        status = count == 0 ? 'miss' : 'hit'
        template('console.line.erb', '-').run(binding)
        $stdout.puts '' unless count == 0 || report.coverage[line + 1] == 0
      end
      $stdout.puts '' if config.verbose && index.percent_tested == 100
    end
  end

  def colors
    {
      'reset' => (Color.new('reset')).escape_sequence,
      'hit'   => (Color.new('green',  foreground: false) +
                  Color.new('white',  bold: true)).escape_sequence,
      'near'  => (Color.new('yellow', bold: true) +
                  Color.new('black',  foreground: false)).escape_sequence,
      'miss'  => (Color.new('red',    foreground: false) +
                  Color.new('white',  bold: true)).escape_sequence
    }
  end
end
