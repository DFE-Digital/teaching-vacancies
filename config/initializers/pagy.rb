require "pagy/extras/overflow"

Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT[:size] = [1, 1, 1, 1] # Design system recommendation

Pagy::DEFAULT[:overflow] = :last_page

# When you are done setting your own default freeze it, so it will not get changed accidentally
Pagy::DEFAULT.freeze
