module DepaCrawler
  require 'net/http'
  require 'uri'
  require 'pry'

  class Crawler


    def self.run(url)
      rgx = /data-product-id="\d*"/
      content = Net::HTTP.get(URI.parse(url))
      ids = content.scan(rgx).map {|x| x[/\d+/]}
      return { status: 'finished' } if ids.empty?
      { status: 'success', ids: ids }
    rescue StandardError => ex
      { status: 'error', content: content, exception: "#{ex.class}: #{ex.message}-\n#{ex.backtrace.join("\n")}" }
    end
  end
end