class Connection
  def self.internal_api(*args)
    self.faraday(*args) do |f|
      f.headers['authorization'] =  'api-token'
    end
  end

  def self.faraday(*args)
    Faraday.new(*args) do |f|
      yield(f) if block_given?
    end
  end
end
