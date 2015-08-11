require 'httparty'

module Ozonetel
  class Client
    include HTTParty
    MANUAL_DIAL_URL = "http://cloudagent.in/CAServices/AgentManualDial.php"

    def initialize(customer, api_key, campaign_name)
      @user_name = customer
      @api_key = api_key
      @campaign_name = campaign_name
    end

    def agent_manual_dial(agent_id, customer_number)
      data = {
        'username' => @user_name,
        'api_key' => @api_key,
        'agentID' => agent_id,
        'customerNumber' => customer_number,
        'campaignName' => @campaign_name
      }
      call_response = HTTParty.post(MANUAL_DIAL_URL, :body => data)
      parse_response(call_response)
    end

    private
    def parse_response(call_response)
      message = Hash.from_xml(call_response.parsed_response)['status']
      {:status => call_response.code, :message => message}
    end
  end
end