module DepaCrawler
  class TxtInterface

    FILENAME = 'depas.txt'

    def find_or_add(id)
      line = get_line(id)
      if line
        line
      else
        add_line(id)
        nil
      end
    end

    private

    def get_line(id)
      text.each_line do |line|
        return line if line.split(';').first == id.to_s
      end
      nil
    end

    def add_line(id)
      new_line = "#{id};#{Time.new}\n"
      open(FILENAME, 'a') do |f|
        f.puts new_line
      end
      @text += new_line
    end

    def text
      @text ||= File.open(FILENAME, 'a+').read
    end
  end
end
