class Dropbox < Fog::Bin
  class << self

    def class_for(key)
      case key
      when :storage
        Fog::Storage::Dropbox
      else
        raise ArgumentError, "Unrecognized service: #{key}"
      end
    end

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :storage
          Fog::Logger.warning("Dropbox[:storage] is deprecated, use Storage[:dropbox] instead")
          Fog::Storage.new(:provider => 'Dropbox')
        else
          raise ArgumentError, "Unrecognized service: #{key.inspect}"
        end
      end
      @@connections[service]
    end

    def services
      Fog::Dropbox.services
    end

  end
end
