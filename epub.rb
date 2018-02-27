require 'epub/parser'
require 'curses'

def init_app
  Curses.init_screen
  Curses.noecho
  Curses.cbreak
  Curses.curs_set(0) 

  @filename = ARGV[0]
  @bookmark_chapter = ARGV[1].to_i
  @bookmark_char = ARGV[2].to_i
  @bookmark_cur_pos = @bookmark_char
  @bookmark_cur_chap = @bookmark_chapter

  @book = EPUB::Parser.parse(@filename)

  @win = Curses.stdscr
  @win.keypad = true
  @max_x = @win.maxx
  @max_y = @win.maxy
  @area = (@max_x -2 ) * (@max_y -3)
end  

def set_header
  @win.setpos(0, 0)
  @win.addstr("#{@book.metadata.title} - Chapter #{@bookmark_cur_chap} of #{@parser.count}")
end  

def page_down
  @bookmark_cur_pos += @area

  if @bookmark_cur_pos >= @chapter.content_document.nokogiri.text.length
    @chapter = @parser.next
    @bookmark_cur_chap += 1
    @bookmark_cur_pos = 0
  end

  set_header

  @win.setpos(2, 0)
  @win.addstr(@chapter.content_document.nokogiri.text[(@bookmark_cur_pos)..(@bookmark_cur_pos + @area)])
  @win.refresh
end  

def page_up
  @bookmark_cur_pos -= @area

  if @bookmark_cur_pos < 0
    @parser.rewind
    @bookmark_cur_chap -= 1
    if @bookmark_cur_chap < 0
      @bookmark_cur_chap = 0
    end  
    for i in 1..@bookmark_cur_chap
      @chapter = @parser.next 
    end 
    @bookmark_cur_pos = @chapter.content_document.nokogiri.text.length - @area
  end

  set_header

  @win.setpos(2, 0)
  @win.addstr(@chapter.content_document.nokogiri.text[(@bookmark_cur_pos)..(@bookmark_cur_pos + @area)])
  @win.refresh
end  

begin
  init_app

  @parser = @book.each_page_on_spine

  for i in 1..@bookmark_chapter
    @chapter = @parser.next 
  end  

  set_header

  @win.setpos(2, 0)
  @win.addstr(@chapter.content_document.nokogiri.text[@bookmark_cur_pos..(@bookmark_cur_pos + @area)])
  @win.refresh

  while true
    @input = @win.getch
    
    if @input == 258
      page_down
    elsif @input == 259
      page_up  
    elsif @input == "q" or @input == 27
      break  
    end  
  end  

  # while true
  #   @input = @win.getch
  #   case @input
  #    when Curses::Key::DOWN
  #      page_down
  #    when "q"
  #      break  
  #    else
  #      puts ""
  #    end  
  #  end
ensure
  Curses.close_screen
end