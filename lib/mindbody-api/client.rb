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

        merged_params = auth_params
        merged_params.merge!(user_params) if MindBody.configuration.bUserParams

         params = {:message => {'Request' => merged_params.merge(locals)}}
        # params = {:message => {'Request' => auth_params.merge(user_params).merge(locals)}}

        # Run the request
        response = super(operation_name, params, &block)
        Response.new(response)
      end

      private
      def auth_params
        {'SourceCredentials'=>{'SourceName'=>MindBody.configuration.source_name,
                               'Password'=>MindBody.configuration.source_key,
                               'SiteIDs'=>{'int'=>MindBody.configuration.site_ids}}}
      end

      def user_params
        # {'UserCredentials'=>{'Username'=>"_#{MindBody.configuration.source_name}",
        #                        'Password'=>MindBody.configuration.source_key,
        #                        'SiteIDs'=>{'int'=>MindBody.configuration.site_ids}}}
        {'UserCredentials'=>{'Username'=>"owner",
                               'Password'=>"gold3333",
                               'SiteIDs'=>{'int'=>MindBody.configuration.site_ids}}}
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
