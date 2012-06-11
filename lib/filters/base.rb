class LineFilter

  def process_base
    if params[:main]
      rx = Regexp.new params[:main]
      @ok = line =~ rx
      #puts "Filtered by #{rx.inspect} : [#{@ok ? 'OK' : 'missed'}] : #{line}"
    else
      #puts "Not filtering, no filter ..."
    end
  end

end

LineFilter.register_step :base