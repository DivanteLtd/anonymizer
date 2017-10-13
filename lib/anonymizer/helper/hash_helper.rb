# Extended native Hash
class Hash
  def deep_merge(second)
    merger = proc do |_key, v1, v2|
      if v1.is_a?(Hash) && v2.is_a?(Hash)
        v1.merge(v2, &merger)
      elsif v1.is_a?(Array) && v2.is_a?(Array)
        v1 | v2
      else
        [:undefined, nil, :nil].include?(v2) ? v1 : v2
      end
    end
    merge(second.to_h, &merger)
  end
end
