class BookConverter
  def initialize(filename, row_length)
    @book = EPUB::Parser.parse(filename)
    @book_title = @book.metadata.title
    @text = ""
    @row_length = row_length
    @filename = filename

    @log = Logger.new('log.txt')

    convert
  end

  def convert
    if File.exist?("#{@filename}.txt")
        lines = File.readlines("#{@filename}.txt")
        lines.map! {|x| x.chomp }
    else
        @parser = @book.each_page_on_spine.each do |page|
          @text += page.content_document.nokogiri.text
        end

        @splitted_text = @text
            .gsub(".\n",  '. #.# ')
            .gsub("”\n",  '” #c# ')
            .gsub("\n\n", '” #p# ')
            .split(/\s+/)

        lines = []
        line = ""

        @splitted_text.each do |word|
          if word == "#.#"
            lines << line
            lines << [""]
            line = ""
          elsif word == "#c#"
            lines << line
            lines << [""]
            line = ""
          elsif word == "#p#"
            lines << line
            lines << ["", ""]
            line = ""
          elsif line && line.size + word.size >= @row_length
            lines << line
            line = word
          elsif line && line.empty?
            line = word
          else
            line << " " << word
          end
        end

        lines << line if line

        File.open("#{@filename}.txt", "w+") do |f|
          f.puts(lines)
        end
    end

    return lines
  end

  def get_title
    @book_title
  end

  def get_converted_text
    convert
  end
end