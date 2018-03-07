require 'epub/parser'
require 'curses'
require 'psych'
require 'logger'
require_relative 'lib/book_reader.rb'
require_relative 'lib/book_converter.rb'

begin
  reader = BookReader.new ARGV[0]

  reader.load_bookmark

  while true
    @input = reader.getch

    if @input == 258
      reader.page_down
    elsif @input == 259
      reader.page_up
    elsif @input == "q" or @input == 27
      reader.save_bookmark
      break
    end
  end
ensure
  Curses.close_screen
end

