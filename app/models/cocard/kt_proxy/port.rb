module Cocard
  module KTProxy
    class Port
      attr_reader :port_range, :min_port, :max_port, :used_ports

      def initialize(port_range:, used_ports:)
        @port_range = port_range
        @used_ports = used_ports
        (@min_port, @max_port) = port_range.split(/:/).map(&:to_i)
      end

      def next_port
        mport = @used_ports.max
        if mport.nil? || mport < min_port
          min_port
        elsif mport < max_port
          mport += 1
        else
          first_unused_port
        end
      end

      def unused_ports
        # (8..16).select{|x| ![1,9,17,16,4].include?(x)}
        (min_port..max_port).select{|x| !used_ports.include?(x)}.sort
      end

      def first_unused_port
        unused_ports.first || -1
      end
    end
  end
end
