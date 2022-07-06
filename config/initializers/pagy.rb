Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT[:size] = [1, 1, 1, 1] # Design system recommendation

# When you are done setting your own default freeze it, so it will not get changed accidentally
Pagy::DEFAULT.freeze
