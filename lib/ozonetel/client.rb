require 'httparty'

module Ozonetel
  class Client
    include HTTParty
    MANUAL_DIAL_URL = "https://in1-ccaas-api.ozonetel.com/CAServices/PhoneManualDial.php"
    ADD_DATA_URL = "https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/addCamapaignData"
    SCHEDULE_DIAL_URL = "https://in1-ccaas-api.ozonetel.com/CAServices/scheduleCampaignData/scheduleCampaignData.php?"

    def initialize(api_key, user_name)
      @api_key = api_key
      @user_name = user_name
    end

    def schedule_dial(customer_number, agent_id, time_to_call, uui, skill, priority, campaign_name)
      bulk_data ={
        "map" => [
          "PhoneNumber",                    # required
          "ScheduledTime",                  # required
          "AgentID",                        # required for AgentWise Campaigns
          "Name",
          "skill",
          "Priority"
        ],
        "data" => [
          [
            customer_number,
            time_to_call,
            agent_id,
            uui,
            skill,
            priority
          ]
        ]
      }
      data = {
        'userName' => @user_name,           # required: (CloudAgent account name)
        'api_key' => @api_key,              # required: (CloudAgent account name)
        'campaign_name' => campaign_name,   # required: (Available in CloudAgent Admin login)
        'bulkData' => bulk_data,            # required: Number from which calls are dialed out
      }
      call_response = HTTParty.post(MANUAL_DIAL_URL, :body => data)
      parse_response(call_response, 'json')
    end

    def manual_dial(customer_number, did, agent_name, uui)
      data = {
        'userName' => @user_name,           # required: (CloudAgent account name)
        'apiKey' => @api_key,               # required: (Available in CloudAgent Admin login)
        'did' => did,                       # required: Number from which calls are dialed out
        'phoneName' => agent_name,          # required: Name of the offline agent to which Outbound calls are to be assigned
        'custNumber' => customer_number,    # required: no to be dialed out
        # 'callLimit' => call_max_limit,    # maximum talktime in seconds
        'uui' => uui,                       # additional info
      }
      call_response = HTTParty.post(MANUAL_DIAL_URL, :body => data)
      parse_response(call_response, 'json')
    end

    def add_campaign_call(customer_number, agent_id, uui, campaign_name, skill, priority, expiry, check_duplicate = false)
      raise ArgumentsError.new("[add_campaign_call] : customer_number is required") if customer_number.nil?
      data = {
        'userName' => @user_name,                   # required: (CloudAgent account name)
        'api_key' => @api_key,                      # required: (Available in CloudAgent Admin login)
        'campaign_name' => campaign_name,           # required: (Respective campaign name where data to be added)
        'PhoneNumber' => customer_number,           # required: (data/leads that is to be inserted in Campaign)
        'agentId' => agent_id,                      # (Parameter to be used for agentwise campaign as per Header in map file)
        'Name' => uui,                              # (optional name to the PhoneNumber/Lead adding. These details reflect in UUI column of callback, screenpop and CDR report)
        'checkDuplicate' => check_duplicate,        # (avoids adding duplicate numbers to the Campaign)
        'action' => "start",                        # (Starts the campaign simultaneous to adding data)
        'skill' => skill,                           # (Name of the skill through which the calls are to be routed in Skillswise campaigns)
        'Priority' => priority,                     # (Higher the priority value(1-99) assigned to the phoneNumber, faster the number gets dialed)
        'ExpiryDate' => expiry.strftime('%Y-%m-%d'),             # (YYYY-MM-DD is the last date the number to be valid in the dialer)
        'format' => "json",                         # (json/xml)
      }

      call_response = HTTParty.post(ADD_DATA_URL, :body => data)
      parse_response(call_response, 'json')
    end

    private
    def parse_response(call_response, format = 'xml')
      begin
        if format == 'json'
          return {:status => call_response["status"], :code => call_response.code, :message => call_response["message"]}
        end
        return {:status => call_response["xml"]["status"], :code => call_response.code, :message => call_response['xml']['message']}
      rescue Exception => e
        raise StandardError.new("Server error at Ozonetel Helper: " + e.message)
      end
    end
  end
end
