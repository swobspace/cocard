module Connectors
  class RMI
    class Kocobox < Base
      def available_actions
        %i( reboot )
      end

      def reboot(params = {})
        #
        # credentials present?
        #
        if koco_admin.blank? or koco_passwd.blank?
          return Result.new(success?: false,
                            response: "Fehlende Zugangsdaten: KOCO_PASSWD " +
                                      "oder KOCO_ADMIN nicht gesetzt")
        end
        #
        # setup connection
        #
        conn = Faraday.new(faraday_options) do |f|
                 f.adapter :net_http_persistent, pool_size: 5 do |http|
                             http.idle_timeout = 120
                           end
                 f.use :cookie_jar
               end

        #
        # authentication
        #
        r1 = conn.post('/j_security_check') do |req|
          params = { j_username: koco_admin, j_password: koco_passwd }
          req.body = URI.encode_www_form(params)
        end

        #
        # simulate redirect
        #
        r2 = conn.get('/administration/start.htm')

        #
        # get infoservice to access X-TOKEN
        #
        r3 = conn.get('/administration/json-retrieve/infoservice') do |req|
          req.headers['Content-Type'] = 'application/json'
        end

        if r3.status != 200
          return Result.new(success?: false, response: r3.inspect)
        end

        begin
          xtoken = r3.headers['set-cookie'].split(/;/)[0].split(/=/)[1]
        rescue
          xtoken = nil
        end

        #
        # if RAILS_ENV=test don't really reboot
        #
        if Rails.env.test?
          return Result.new(success?: true, response: r3)
        end

        #
        # finally: reboot
        #
        r4 = conn.post('/administration/perform/reboot') do |req|
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-TOKEN'] = xtoken
        end

        if r4.status == 200
          Result.new(success?: true, response: "Reboot successful triggered")
        else
          Result.new(success?: false, response: r3.inspect)
        end
      end

    private
      def faraday_options
        {
          url: "https://#{connector.ip}:9443",
          ssl: { verify: false },
          request: { open_timeout: 15, timeout: 30 }
         }
      end

      def koco_admin
        ENV['KOCO_ADMIN']
      end

      def koco_passwd
        ENV['KOCO_PASSWD']
      end

    end
  end
end

