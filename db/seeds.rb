require 'date'

Account.create(first_name: 'Jorge', last_name: 'Navarro', email: 'jnavarr56@gmail.com', password: 'password', dob: Date.new(1995,2,19), time_logged: 'n/a', verify_code: 'n/a', verified: true)
hashtagsArray = ["LGBQT", "Environment", "Gun Control", "Organizing", "Immigration", "Elections", "National Security", "Economy", "Women's Rights", "Disability Rights", "Police Reform", "Military", "Death Penalty", "Discrimination", "Education", "Drug Reform"]
hashtagsArray.each do |builtintag| 
    Hashtag.create(hashtag: builtintag);
end
interactsArray = ["heart", "share", "thumbs-down"]
interactsArray.each do |reaction| 
    Interact.create(interact_type: reaction);
end

