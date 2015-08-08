class Hash
  def symbolize_keys
    inject({}) do |memo,(k,v)|
      memo[k.to_sym] = v
      memo
    end
  end
end
