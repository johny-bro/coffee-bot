class Brew < ApplicationRecord
  
  belongs_to :teams_brews

  def self.handle_request(params)
    if params["text"].include?("#how")
      Brew.how_to_brew(params)
    elsif params["text"].include?("#out")
      Brew.we_are_out_of_coffee(params)
    else
      Brew.create_new_brew(params)
    end
  end

  def self.create_new_brew(params)
    text = params["text"].split(' ')
    location = text.shift || "Blake"
    brew = Brew.create!(
        user_name: params["user_name"],
        location: location,
        description: text.join(' '),
        team: create_team_if_necessary(params)
    )
    brew.brewed_coffee_response(params)
  end
  
  def brewed_coffee_response(params)
    time = created_at.strftime("%I:%M:%S %p")
    {
      "text": "Hey #{user_name} thanks for brewing coffee! You're a hero!",
      "attachments": [
        {
          "text": "#{description}"
              }
            ]
    }
  end
  
  def self.get_last_brewed(limit)
    list = ''
    Brew.order(created_at: :desc).limit(limit).each do |brew|
      time = brew.created_at.strftime("%I:%M:%S %p")
      list << "Coffee was brewed in #{brew.location} at #{time}. | #{brew.description}\n"
    end
    {
      "text": "Last coffee brew(s):",
      "attachments": [
        {
          "text": list
        }
      ]
    }
  end
  
  def self.how_to_brew(params)
    {
      "text": "Hey #{params["user_name"]}  thanks for asking!",
      "attachments": [
        {
          "text": 
                 "These instructions work for Blake. To see info for all\n
                  Turing locations, visit https://turingcoffee.herokuapp.com/how_to_brew\n
                  Here's how to brew coffee:\n
                  1. Make sure coffee pot and grounds basket are empty and rinsed out.\n
                  2. Set grinder to medium (or one notch below).\n
                  3. Grind beans and fill filter until it is just over half full.\n
                  4. Check area on brewer where the basket will go for grounds. Clean if necessary!\n
                  5. Put filter into basket. Place basket into brewer.\n
                  6. Place coffee pot in its usual place.\n
                  7. Press the start button (or equivalent).\n
                  8. Let everyone know there's a new pot with /coffee_brewing! :)"
              }
            ]
    }
  end
  
  def self.we_are_out_of_coffee(params)
    {
      "text": "Hey #{params["user_name"]} thanks for letting us know!",
      "attachments": [
        {
          "text":"For now, please let your SAB reps know so they can update the trello board."
              }
            ]
    }
  end

  def self.get_limit(input)
    input.to_i != 0 ? input.to_i : 1
  end
  
  private
  
  def self.create_team_if_necessary(params)
    team = Team.find_by(team_id: params["team_id"])
    if team.nil?
      team = Team.create(team_name: params["team_domain"], team_id: params["team_id"])
    else 
      team = team
    end
    team
  end
    

end
