require 'clockwork'
require_relative 'program'

module Clockwork
  every(10.minute, 'depa.crawl') do
    DepaCrawler::Program.new.run
  end
end
