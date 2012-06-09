require 'date'

class LineProcessor

  def process_base
    line.gsub! /^(\w{3}) (\d{1,2}) (\d{2})\:(\d{2})\:(\d{2}) (\w+) (\w+)\[(\d+)\]\: / do |str|
      now = Time.new
      year = now.year
      month = Date::ABBR_MONTHNAMES.index $1

      result[:time] = Time.new year, month, $2.to_i, $3.to_i, $4.to_i, $5.to_i
      result[:box] = $6
      result[:app] = $7
      result[:pid] = $8

      ''
    end
  end

end

LineProcessor.register_step :base