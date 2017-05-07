module DepaCrawler

  require 'dotenv/load'
  require 'txt_interface'
  require 'crawler'
  require 'notifier'

  class Program

    DOMAIN_URL = ENV.fetch('DOMAIN_URL')
    QUERY_STR = ENV.fetch('QUERY_STR')

    def run
      puts "Iniciando Crawl a las #{Time.new}"
      @errors = []
      @new_ids = []
      last_page = 1

      (1..100).each do |page_num|
        puts "Crawleando página #{page_num}..."
        last_page = page_num
        continue = crawl_page page_num
        break unless continue
      end

      puts "Fin de iteración en página #{last_page}"
      Notifier.gmail_setup
      notifier.send_errors(@errors).deliver unless @errors.empty?
      notifier.send_new_ids(@new_ids).deliver unless @new_ids.empty?
      notifier.send_result(@new_ids, @errors, last_page).deliver
      puts "New ids: #{@new_ids.count} - Errors: #{@errors.count}"
      puts "Reporte(s) enviado(s)\nFinalizando Ejecución..."
    end

    private

    def crawl_page(page_num)
      result = Crawler.run(DOMAIN_URL + QUERY_STR + page_num.to_s)
      puts "Resultado página #{page_num}: #{result}"
      case result[:status]
      when 'error'
        @errors << result.to_json
        true
      when 'finished'
        false
      when 'success'
        ids = result[:ids]
        ids.each do |id|
          @new_ids << id unless txt_interface.find_or_add(id)
        end
        true
      end
    end

    def notifier
      @notifier ||= Notifier.new
    end

    def txt_interface
      @txt_interface ||= TxtInterface.new
    end
  end
end




