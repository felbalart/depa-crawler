require 'clockwork'
require_relative 'program'

module Clockwork
  every(1.hour, 'depa.crawl') do
    DepaCrawler::Program.new.run
  end
end
