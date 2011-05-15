class DataHelper
  
  def self.prepares_data(hash_nodes)
    @array_of_node = Array.new
    hash_nodes.each do | node |
      nodeId = node.values_at('self')[0].split('/').last
      text = node.values_at('data')[0].values_at('name')
      @array_of_node << { :nodeId => nodeId, :text => text } 
    end

    return @array_of_node
  end
end
