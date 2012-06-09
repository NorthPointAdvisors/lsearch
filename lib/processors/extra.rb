class LineProcessor

  def process_extra
    line.gsub! /\ \[XTRA\|(.*)\|\]$/ do |str|
      $1.split('|').map { |x| x.split(':') }.each do |k,v|
        result[k.to_sym] = v
      end
      ''
    end
  end

end

LineProcessor.register_step :extra