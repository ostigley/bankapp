
class HashToTsv
  attr_accessor :hash, :headers

  def initialize(hash, headers)
    @hash = hash
    @headers = headers
  end

  def tsv
    tsv_array = [headers]
    hash.map do |k, v|
      tsv_array << "#{k}\\t#{v}"
    end

    tsv_array.join('\n').downcase
  end
end
