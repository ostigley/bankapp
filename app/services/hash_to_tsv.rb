
class HashToTsv
  def self.convert(hash, headers)
    tsv_array = [headers]
    hash.map do |k, v|
      tsv_array << "#{k}\\t#{v}"
    end

    tsv_array.join('\n').downcase
  end
end
