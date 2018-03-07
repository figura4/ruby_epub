class BookReader

  def initialize(file_name)
    Curses.init_screen
    Curses.noecho
    Curses.cbreak
    Curses.curs_set(0)

    @save_file = "./#{file_name}.yml"
    @filename = file_name

    @log = Logger.new('log.txt')

    @win = Curses.stdscr
    @win.keypad = true
    @max_x = @win.maxx
    @max_y = @win.maxy
    @area = (@max_x) * (@max_y)
    @rows_in_page = @max_y - 3
    @row_length = @max_x - 3

    @book_converter = BookConverter.new(file_name, @row_length)
    @text = @book_converter.get_converted_text
    @book_title = @book_converter.get_title

    @current_row = 0
    @page = ""
  end

  def getch
    @win.getch
  end

  def page_up
    @current_row = [0, @current_row  - @rows_in_page].max

    @page = @text[@current_row..@current_row + @rows_in_page].join("\n")

    save_bookmark

    refresh_page
  end

  def page_down
    @current_row = [@current_row  + @rows_in_page, @text.count].min

    @page = @text[@current_row..[@current_row + @rows_in_page, @text.count].min].join("\n")

    save_bookmark

    refresh_page
  end

  def refresh_page
    @win.clear

    @win.setpos(0, 0)
    @win.addstr("#{@book_title} - "  + ((@current_row.to_f / @text.count.to_f) * 100).round(0).to_s + "%") #/

    @win.setpos(2, 0)
    @win.addstr(@page)
    @win.refresh
  end

  def load_bookmark
    if File.exist?("#{@filename}.yml")
      bookmark = Psych.load_file(@save_file)
      @current_row = [bookmark['current_row'], @text.count].min
    else
      @current_row = 0
    end

    @page = @text[@current_row..[@current_row + @rows_in_page, @text.count].min].join("\n")

    refresh_page
  end

  def save_bookmark
    File.open("#{@filename}.yml", 'w') do |file|
    file.write(Psych.dump({ 'current_row' => @current_row }))
  end
  end

end