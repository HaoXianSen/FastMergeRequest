# platform :ios, '11.0'
# use_modular_headers!
# source 'https://github.com/CocoaPods/Specs.git'
# source 'git@gitlab.corp.youdao.com:luna-ios-framework/youdaospecrepository.git'

# GZUIKit_VERSION = 'Fix/hyh_fix_um"
# YDCommon_VERSION = 'ai-v1.0.0'
# UI_OC_VERSION = '1.0.0'

# target 'AICourse-iOS' do

#   # private pod - 基础组件 #
#   pod 'GZUIKit_iOS', :git =>'git@gitlab.corp.youdao.com:hikari/app/ios/LSFoundationGroup_iOS/gzuikit_ios.git', :branch => GZUIKit_VERSION
#   pod 'JPKUI-iOS/All', :git => 'git@gitlab.corp.youdao.com:course/JPKUI-iOS.git', :tag => UI_OC_VERSION
#   pod 'YDCommon', :git => 'git@gitlab.corp.youdao.com:luna-ios-framework/YDCommon.git', :tag => YDCommon_VERSION, :subspecs => [
#     'YDSocialImplByUmeng',
#     'FoundationExtension',
#     'UI'
#   ]

#   # public pods swift #
#   pod 'RxSwift', '~> 5.0'
#   pod 'RxCocoa', '~> 5.0'
#   pod "RxGesture"
#   pod 'Alamofire', '4.9.1'
#   pod 'SnapKit', '~> 4.2.0'
#   pod 'Tiercel', '3.2.0'
#   pod 'LookinServer', '~> 1.2.8', :configurations => ['Debug']
#   pod 'MLeaksFinder', :git => "https://github.com/Tencent/MLeaksFinder.git", :configurations => ['Debug']
#   pod 'FLEX', :configurations => ['Debug']

#   target 'AICourse-iOSTests' do
#     inherit! :search_paths
#   end
# end

# post_install do |installer|
#   dev_team = ""
#      project = installer.aggregate_targets[0].user_project
#      project.targets.each do |target|
#          target.build_configurations.each do |config|
#              if dev_team.empty? and !config.build_settings['DEVELOPMENT_TEAM'].nil?
#                  dev_team = config.build_settings['DEVELOPMENT_TEAM']
#              end
#          end
#      end
#   installer.pods_project.targets.each do |target|
#     target.build_configurations.each do |config|
#       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
#       config.build_settings['DEVELOPMENT_TEAM'] = dev_team
#       if config.name == 'Release'
#         config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'NDEBUG=1']
#       end
#     end
#   end
# end

module Pod
  class Podfile
    # Podfile DSL
    module DSL
      def install!(installation_name, options = {}); end
      def platform(platform_name, platform_version); end
      def ensure_bundler!(version = nil); end
      def script_phase(options); end

      def pod(name = nil, *requirements)
        raise StandardError, 'A denpendency need a name' unless name

        pod = { podName: name, requirements: requirements }
        denpendencies = get_hash_value('denpendencies', []) << pod
        set_hash_value('denpendencies', denpendencies)
      end

      def target(name, options = nil)
        if options
          raise Informative, "Unsupported options `#{options}` for " \
          "target `#{name}`."
        end
        yield if block_given?
      end

      def abstract_target(name)
        target(name) do
          abstract!
          yield if block_given?
        end
      end

      def platform(name, target = nil)
        target = target[:development_target] if target.is_a?(Hash)
        name = :osx if name == :macos
        unless %i[ios osx tvos vesionos watchos].include?(name)
          raise StandardError,
                "Unsupported platform #{name}. Platform mast be `:ios`, `:osx`, `:tvos`, `:vesionos`, `:watchos`"
        end

        pod = if target
              { name.to_s => target }
            else
              name.to_s
            end
        set_hash_value('platform', pod)
      end

      def source(source)
        hash_sources = get_hash_value('sources', [])
        hash_sources << source
        set_hash_value('sources', hash_sources.uniq)
      end

      def inherit!(inheritance); end

      def abstract!(abstract = true); end

      def podspec(options = nil); end

      def project(path, build_configurations = {}); end
      def inhibit_all_warnings!; end
      def use_modular_headers!; end
      def use_frameworks!(option = true); end
      def supports_swift_versions(*requirements); end
      def workspace(path); end
      def generate_bridge_support!; end
      def plugin(name, options = {}); end
      def pre_install(&block); end
      def pre_integrate(&block); end
      def post_install(&block); end
      def post_integrate(&block); end
    end
  end
end
