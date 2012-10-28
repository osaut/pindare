module Model

  def set_params pp
    pp.each { |key,value|
      @params[key]=value
    }

  end

  def show_params(stream=$stdout)
      params.each do |key,value|
        stream.print "#{key} = #{ value } ;"
      end
      stream.puts
  end

  def save_params fname
    JSON::dump(params,File.new(fname, 'w'))
  end

  def load_params fname
    # JSON::parse?
  end

end
