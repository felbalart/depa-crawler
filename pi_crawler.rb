module DepaCrawler
  require 'net/http'
  require 'uri'
  require 'pry'

  class PiCrawler

    PI_HOST = ENV.fetch('PI_HOST')
    PI_QUERY = ENV.fetch('PI_QUERY')

    def self.run
      results = []
      (1..100).each do |page_num|
        puts "Crawleando PI, página #{page_num}..."
        result = fetch_page page_num
        puts result
        results << result
        break if result[:status] == 'finished'
      end
      results
    end

    def self.fetch_page(page_num)
      url = PI_HOST + PI_QUERY + page_num.to_s
      fetch url
    end

    def self.fetch(url)
      rgx = /data-product-id="\d*"/
      content = Net::HTTP.get(URI.parse(url))
      ids = content.scan(rgx).map {|x| "PI" + x[/\d+/]}
      return { status: 'finished' } if ids.empty?
      { status: 'success', ids: ids }
    rescue StandardError => ex
      { status: 'error', content: content, exception: "#{ex.class}: #{ex.message}-\n#{ex.backtrace.join("\n")}" }
    end
  end
end