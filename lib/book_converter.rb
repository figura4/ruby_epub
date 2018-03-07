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
#    ['In the week before their departure to ',
#    'Arrakis, when all the final scurrying ',
#    'about had reached a nearly unbearable ',
#    'frenzy, an old crone came to visit ',
#    'the mother of the boy, Paul.',
#    '',
#    'It was a warm night at Castle ',
#    'Caladan, and the ancient pile of ',
#    'stone that had served the Atreides ',
#    'family as home for twenty-six ',
#    'generations bore that cooled-sweat ',
#    'feeling it acquired before a change ',
#    'in the weather.',
#    '',
#    'The old woman was let in by the ',
#    'side door down the vaulted passage ',
#    'by Paul\'s room and she was allowed ',
#    'a moment to peer in at him where ',
#    'he lay in his bed.',
#    '',
#    'By the half-light of a suspensor ',
#    'lamp, dimmed and hanging near the ',
#    'floor, the awakened boy could see ',
#    'a bulky female shape at his door, ',
#    'standing one step ahead of his ',
#    'mother. The old woman was a witch ',
#    'shadow - hair like matted spiderwebs, ',
#    'hooded \'round darkness of features, ',
#    'eyes like glittering jewels.',
#    '',
#    '"Is he not small for his age, ',
#    'Jessica?" the old woman asked. ',
#    'Her voice wheezed and twanged ',
#    'like an untuned baliset.',
#    '',
#    'Paul\'s mother answered in her ',
#    'soft contralto: "The Atreides ',
#    'are known to start late getting ',
#    'their growth, Your Reverence."',
#    '',
#    '"So I\'ve heard, so I\'ve heard," ',
#    'wheezed the old woman. "Yet ',
#    'he\'s already fifteen."',
#    '',
#    '"Yes, Your Reverence."',
#    '',
#    '"He\'s awake and listening to ',
#    'us," said the old woman. ',
#    '"Sly little rascal." She ',
#    'chuckled. "But royalty has ',
#    'need of slyness. And if ',
#    'he\'s really the Kwisatz ',
#    'Haderach... well..."',
#    '',
#    'Within the shadows of his bed,',
#    'Paul held his eyes open ',
#    'to mere slits. Two bird-bright ',
#    'ovals - the eyes of the old ',
#    'woman - seemed to expand and ',
#    'glow as they stared ',
#    'into his.',
#    '',
#    '"Sleep well, you sly little ',
#    'rascal," said the old woman. ',
#    '"Tomorrow you\'ll need all ',
#    'your faculties to meet ',
#    'my gom jabbar."']
  end
end