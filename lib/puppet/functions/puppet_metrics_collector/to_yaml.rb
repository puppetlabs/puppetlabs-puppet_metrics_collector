require 'yaml'
# Function: to_yaml
#
# Description: Converts the content of the passed array or hash to YAML
Puppet::Functions.create_function(:'puppet_metrics_collector::to_yaml') do
  # @return [String] YAML representation of the passed array or hash
  dispatch :to_yaml do
    param 'Hash', :hash_or_array
  end
  # @return [String] YAML representation of the passed array or hash
  dispatch :to_yaml do
    param 'Array', :hash_or_array
  end
  # @return [String] YAML representation of the passed array or hash
  def to_yaml(hash_or_array)
    hash_or_array.to_yaml
  end
end
