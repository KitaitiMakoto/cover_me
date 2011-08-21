require 'test/unit/color-scheme'

class CoverMe::ConsoleFormatter < CoverMe::Formatter

  def format_report(report)
  end

  def format_index(index)
    template_file = File.join(File.dirname(__FILE__), 'templates', 'console.erb')
    tuc = Test::Unit::Color
    colors = {
      'reset' => (tuc.new('reset')).escape_sequence,
      'hit'   => (tuc.new('green',foreground: false) +
                  tuc.new('white', bold: true)).escape_sequence,
      'near'  => (tuc.new('yellow',bold: true) +
                  tuc.new('black', foreground: false)).escape_sequence,
      'miss'  => (tuc.new('red', foreground: false) +
                  tuc.new('white', bold: true)).escape_sequence
    }

    puts ERB.new(File.read(template_file), nil, '-').result(binding)
  end

end
