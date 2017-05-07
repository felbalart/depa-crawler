module DepaCrawler

  require 'dotenv/load'
  require_relative 'txt_interface'
  require_relative 'pi_crawler'
  require_relative 'gp_crawler'
  require_relative 'notifier'

  class Program

    PI_HOST = ENV.fetch('PI_HOST')
    PI_QUERY = ENV.fetch('PI_QUERY')

    def run
      puts "Iniciando Crawl a las #{Time.new}"
      @errors = []
      @new_ids = []
      pi_results =  PiCrawler.run
      gp_results = GpCrawler.run
      @page_count = {pi: pi_results.count - 1, gp: gp_results.count - 1}
      @results = pi_results + gp_results
      @results.each { |result| process_result result }
      notify

      puts "New ids: #{@new_ids.count} - Errors: #{@errors.count}"
      puts "Reporte(s) enviado(s)\nFinalizando Ejecución..."
    end

    private

    def notify
      Notifier.gmail_setup
      notifier.send_errors(@errors).deliver unless @errors.empty?
      notifier.send_new_ids(@new_ids).deliver unless @new_ids.empty?
      notifier.send_result(@new_ids, @errors, @page_count).deliver
    end

    def process_result(result)
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




