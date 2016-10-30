class Brew < ApplicationRecord

  def self.handle_request(params)
    if params["text"] == "#how"
      Brew.how_to_brew(params)
    elsif params["text"] == "#out"
      Brew.we_are_out_of_coffee(params)
    elsif params["text"] == "#anon"
      brew = Brew.create_new_anonymous_brew(params)
    else
      brew = Brew.create_new_brew(params)
    end
  end

  def self.create_new_brew(params)
    text = params["text"].split(' ')
    location = text.shift || "Blake"
    brew = Brew.create!(
        user_name: params["user_name"],
        location: location,
        description: text.join(' ')
    )
    Brew.brewed_coffee_response(params, brew)
  end
  
  def self.create_new_anonymous_brew(params)
    text = params["text"].split(' ')
    location = text[1] || "a secret location"
    brew = Brew.create!(
        user_name: "Someone at Turing",
        location: location
    )
    Brew.brewed_coffee_response(params, brew)
  end

  def self.brewed_coffee_response(params, brew)
    time = brew.created_at.strftime("%I:%M:%S %p")
    {
      "text": "Hey #{brew.user_name} thanks for brewing coffee! You're a hero!",
      "attachments": [
        {
          "text":"#{brew.description}"
              }
            ]
    }
  end
  
  def self.get_last_brewed(limit)
    list = ''
    Brew.order(created_at: :desc).limit(limit).each do |brew|
      time = brew.created_at.strftime("%I:%M:%S %p")
      if brew.description.nil?
        list << "#{brew.user_name} brewed coffee in #{brew.location} at #{time}.\n"
      else
        list << "#{brew.user_name} brewed coffee in #{brew.location} at #{time}. | #{brew.description}\n"
      end
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
      "text": "Hey #{params["user_name"]}  thanks for asking! Here's how to brew coffee:",
      "attachments": [
        {
          "text":"Delicious instructions will go here."
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

end
