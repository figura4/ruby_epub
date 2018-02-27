require 'epub/parser'
require 'curses'

Curses.init_screen
Curses.noecho
Curses.cbreak
Curses.curs_set(0)

begin
  filename = ARGV[0]
  bookmark_chapter = ARGV[1].to_i
  bookmark_char = ARGV[2].to_i

  book = EPUB::Parser.parse(filename)

  puts "Number of rows: #{@nb_lines}"
  puts "Number of columns: #{@nb_cols}"

  win = Curses.stdscr
  max_x = win.maxx
  max_y = win.maxy
  area = (max_x -2 ) * (max_y -3)

  win.setpos(1, 1)
  win.addstr(book.metadata.title)

  parser = book.each_page_on_spine

  for i in 1..bookmark_chapter
    chapter = parser.next 
  end  

  win.setpos(3, 1)
  win.addstr(chapter.content_document.nokogiri.text[bookmark_char..(bookmark_char + area)])
  win.refresh

  input = win.getch
ensure
  Curses.close_screen
end