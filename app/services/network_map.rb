# frozen_string_literal: true

# NetworkMap builds a graph representation of the Reticulum network
# from peer and node discovery data.
#
class NetworkMap
  Node = Struct.new(:id, :name, :hops, :status, :services, keyword_init: true)
  Edge = Struct.new(:source, :target, :quality, :metric, keyword_init: true)

  def initialize(rns_adapter = nil)
    @rns = rns_adapter || RnsAdapter.new
    @rns.connect unless @rns.connected?
  end

  def graph
    nodes = build_nodes
    edges = build_edges(nodes)
    { nodes: nodes, edges: edges }
  end

  def path(from_hash, to_hash)
    # Simple BFS pathfinding through the network graph
    graph_data = graph
    adjacency = Hash.new { |h, k| h[k] = [] }
    graph_data[:edges].each do |edge|
      adjacency[edge.source] << edge.target
      adjacency[edge.target] << edge.source
    end

    queue = [ [ from_hash ] ]
    visited = Set.new([ from_hash ])

    until queue.empty?
      path = queue.shift
      node = path.last
      return path if node == to_hash

      adjacency[node].each do |neighbor|
        next if visited.include?(neighbor)

        visited.add(neighbor)
        queue << (path + [ neighbor ])
      end
    end

    nil # No path found
  end

  def node_details(destination_hash)
    nodes = @rns.nodes
    peers = @rns.peers
    all = nodes + peers
    all.find { |n| n[:destination_hash] == destination_hash }
  end

  private

  def build_nodes
    peers = @rns.peers
    nodes = @rns.nodes

    all = (peers + nodes).uniq { |n| n[:destination_hash] }
    all.map do |data|
      Node.new(
        id: data[:destination_hash],
        name: data[:name] || data[:destination_hash],
        hops: data[:hops] || 0,
        status: data[:status] || "unknown",
        services: data[:services] || []
      )
    end
  end

  def build_edges(nodes)
    # Build edges based on hop count and link quality
    # In a real implementation this would use actual path data from rnsd
    edges = []
    nodes.each do |node|
      next if node.hops == 0

      # Connect to a "closer" node (lower hops)
      closer = nodes.select { |n| n.hops < node.hops && n.id != node.id }
                     .min_by { |n| (n.hops - node.hops).abs }

      if closer
        edges << Edge.new(
          source: closer.id,
          target: node.id,
          quality: node.status == "active" ? 0.9 : 0.5,
          metric: node.hops
        )
      end
    end
    edges
  end
end
