require_relative 'DSL'
require 'pathname'
require 'etc'

module Pod
  # Podfile parse
  class Podfile
    include Pod::Podfile::DSL

    attr_accessor :internal_hash

    HASH_KEYS = %w[
      sources
      platform
      denpendencies
    ].freeze

    def initialize(_path, &block)
      @internal_hash = {}
      instance_eval(&block) if block
    end

    def set_hash_value(key, value)
      raise StandardError, "Unsupported hash key #{key}" unless HASH_KEYS.include?(key)

      internal_hash[key] = value
    end

    def get_hash_value(key, default = nil)
      raise StandardError, "Unsupported hash key #{key}" unless HASH_KEYS.include?(key)

      internal_hash.fetch(key, default)
    end

    # parse 'podfile_path' 的 podfile
    def self.analyze(podfile_path)
      path = Pathname.new(podfile_path)
      raise Informative, "No Podfile in #{podfile_path}" unless path.exist?

      case path.extname
      when '', '.podfile', '.rb'
        podfile = Podfile.from_ruby(path)
      when '.yaml'
        podfile = Podfile.from_yaml(path)
      else
        raise Informative, "Unsupported Podfile format in #{path}"
      end
      podfile
    end

    def self.from_ruby(path)
      content = File.open(path, 'r:utf-8', &:read)
      content.encode!('UTF-8') if content.respond_to?(:encode) && content.encoding.name != 'UTF-8'
      Podfile.new(path) do
        begin
          eval(content, nil, path.to_s)          
        rescue Exception => e
          message = "Invalid `#{path.basename}` file: #{e.message}"
          raise StandardError, message
        end
      end
    end

    def self.from_yaml(_path)
      raise StandardError, 'Unsupported yaml Podfile'
    end
  end
end
