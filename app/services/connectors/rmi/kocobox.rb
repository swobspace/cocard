module Connectors
  class RMI
    class Kocobox < Base
      Result = Struct.new(:success?, :message, :value, keyword_init: true)

      def available_actions
        %i( reboot )
      end

      def supported?
        true
      end

      def reboot(params = {})
        #
        # credentials present?
        #
        if koco_admin.blank? or koco_passwd.blank?
          return Result.new(success?: false,
                            message: "Fehlende Zugangsdaten: KOCO_PASSWD " +
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
        begin
          r1 = conn.post('/j_security_check') do |req|
            params = { j_username: koco_admin, j_password: koco_passwd }
            req.body = URI.encode_www_form(params)
            req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          end
        rescue Faraday::Error => e
          errmsg = "Login failed - #{e.response_body}"
          return Result.new(success?: false, message: errmsg)
        end

        #
        # simulate redirect
        #
        begin
          r2 = conn.get('/administration/start.htm')
        rescue Faraday::Error => e
          errmsg = "/administration/start.htm - #{e.response_body}"
          return Result.new(success?: false, message: errmsg)
        end

        #
        # get infoservice to access X-TOKEN
        #
        begin
          r3 = conn.get('/administration/json-retrieve/infoservice') do |req|
            req.headers['Content-Type'] = 'application/json'
          end
        rescue Faraday::Error => e
          errmsg = "Get X-TOKEN - #{e.response_body}"
          return Result.new(success?: false, message: errmsg)
        end

        if r3.status != 200
          return Result.new(success?: false, message: r3.inspect, value: r3.status)
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
          connector.update(rebooted_at: Time.current)
          return Result.new(success?: true, message: r3, value: r3.status) 
        end

        #
        # finally: reboot
        #
        r4 = conn.post('/administration/perform/reboot') do |req|
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-TOKEN'] = xtoken
        end

        if r4.status == 200
          connector.update(rebooted_at: Time.current)
          Result.new(success?: true, message: "Reboot ausgelöst, der Konnektor wird neu gestartet")
        else
          Result.new(success?: false, message: r3.inspect)
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

