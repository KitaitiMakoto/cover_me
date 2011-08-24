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

    template('console.erb', '-').run(binding)
    unless index.percent_tested == 100
      index.reports.sort.each do |report|
        template('console.file.erb', '-').run(binding)
        next unless config.verbose
        report.coverage.each_with_index do |count, i|
          if count == 0
            sl = report.source.length
            sls = sl.to_s.length
            template('console.verbose.erb', '-').run(binding)
          end
        end
      end
    end
  end

end
