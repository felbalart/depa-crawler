module DepaCrawler
  require 'net/http'
  require 'uri'
  require 'json'

  class GpCrawler


    GP_HOST = ENV.fetch('GP_HOST')
    GP_QUERY = ENV.fetch('GP_QUERY')
    GP_COOKIE = ENV.fetch('GP_COOKIE')

    def self.run
      results = []
      (1..100).each do |page_num|
        puts "Crawleando GP, página #{page_num}..."
        result = fetch_page page_num
        puts result
        results << result
        break if result[:status] == 'finished'
      end
      results
    end

    def self.fetch_page(page_num)
      url = GP_HOST + GP_QUERY + page_num.to_s
      cookie = GP_COOKIE
      fetch url, cookie
    end


    def self.fetch(url, cookie)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request['Cookie'] = cookie
      http.use_ssl = true
      r = http.request(request)
      data = JSON.parse r.body
      ids = data['response']['ids']
      return { status: 'finished' } if ids.empty?
      ids.map! { |id| "GP" + id.to_s }
      { status: 'success', ids: ids }
    rescue StandardError => ex
      { status: 'error', content: (r.nil? ? "nil http response" : r.body),
        exception: "#{ex.class}: #{ex.message}-\n#{ex.backtrace.join("\n")}" }
    end
  end
end