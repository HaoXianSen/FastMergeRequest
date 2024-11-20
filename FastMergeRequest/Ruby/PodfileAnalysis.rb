require 'json'
require_relative 'DSL'
require_relative 'podfile'

# tool of pod
class PodfileAnalysis
  
  def self.output_json(path)
    if File.file?(path)
      podfile_hash = Pod::Podfile.analyze(path).get_hash_value('denpendencies', [])
      podfile_json = JSON.pretty_generate(podfile_hash)
      puts podfile_json
    else
      puts 'need Podfile Path!!!'
    end
  end

end

PodfileAnalysis.output_json(ARGV[0])
