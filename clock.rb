require 'clockwork'
require_relative 'program'

module Clockwork
  every(1.day, 'depa.crawl', at: ["10:00", "18:00"]) do
    DepaCrawler::Program.new.run
  end
end
