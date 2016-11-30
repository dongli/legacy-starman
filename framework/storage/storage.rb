module STARMAN
  class Storage
    class << self
      def tar_name package
        "#{package.tag}.tgz"
      end

      def init adapter_name
        @@adapter_name = adapter_name.to_s.capitalize
        @@adapter = eval "#{@@adapter_name}Adapter"
        @@adapter.init
      end

      def adapter_name
        @@adapter_name
      end

      def check_connection
        @@adapter.check_connection
      end

      [:uploaded?, :upload!, :delete!, :download].each do |action|
        class_eval <<-EOT
          def #{action} package
            @@adapter.#{action} package
          end
        EOT
      end
    end
  end
end
