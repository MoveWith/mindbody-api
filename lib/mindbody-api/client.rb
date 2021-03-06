require 'mindbody-api/response'

module MindBody
  module Services
    class Client < Savon::Client

      def call(operation_name, locals = {}, &block)
        # Inject the auth params into the request and setup the
        # correct request structure
        @globals.log_level(MindBody.configuration.log_level)
        locals = locals.has_key?(:message) ? locals[:message] : locals
        locals = fixup_locals(locals)
        # set test post if so asked...
        locals.merge!({"Test" => true}) if MindBody.configuration.bTest
        params = {:message => {'Request' => auth_params.merge(locals)}}

        # Run the request
        response = super(operation_name, params, &block)
        Response.new(response)
      end

      private

      def auth_params
        ap = {'SourceCredentials'=>{'SourceName'=>MindBody.configuration.source_name,
                               'Password'=>MindBody.configuration.source_key,
                               'SiteIDs'=>{'int'=>MindBody.configuration.site_ids}}}
        if MindBody.configuration.bUserParams
          ap.merge!(
          {'UserCredentials'=>{'Username'=>MindBody.configuration.user_name,
                                         'Password'=>MindBody.configuration.user_key,
                                         'SiteIDs'=>{'int'=>MindBody.configuration.site_ids}}}
          )
        end

        ap
      end

      def fixup_locals(locals)
        # TODO this needs fixed to support various list types
        locals.each_pair do |key, value|
          if value.is_a? Array
            locals[key] = {'int' => value}
          end
        end
      end
    end
  end
end
