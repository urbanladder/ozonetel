require 'httparty'

module Ozonetel
  class Client
    include HTTParty
    MANUAL_DIAL_URL = "http://cloudagent.in/CAServices/AgentManualDial.php"
    ADD_DATA_URL = "http://cloudagent.in/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/addCamapaignData"

    def initialize(customer, api_key, campaign_name, did = nil)
      @user_name = customer
      @api_key = api_key
      @campaign_name = campaign_name
      @did = did
    end

    def manual_dial_online(agent_id, customer_number)
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

    def manual_dial_skill(skill, customer_number, uui = nil)
      data = {
        'username' => @user_name,
        'api_key' => @api_key,
        'did' => @did,
        'campaignName' => @campaign_name,
        'skill' => skill,
        'customerNumber' => customer_number,
        'uui' => uui
      }
      call_response = HTTParty.get(MANUAL_DIAL_URL, :query => call_data)
      parse_response(call_response)
    end

    def trigger_cod_confirmation_call(call_data)
      call_data.merge!({ 'api_key' => @api_key, 'campaign_name' => @campaign_name })
      call_response = HTTParty.get(ADD_DATA_URL, :query => call_data)
    end

    private
    def parse_response(call_response)
      message = Hash.from_xml(call_response.parsed_response)['status']
      {:status => call_response.code, :message => message}
    end
  end
end