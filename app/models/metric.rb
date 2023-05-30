class Metric
  include ActiveGraph::Node
  property :name, type: String
  property :key, type: String
  property :value, type: Integer
  property :timestamp, type: Integer
end
