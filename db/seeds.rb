# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

i1 = Ingredient.create(name: "Carrot", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/george-clooney.jpg")
i2 = Ingredient.create(name: "Courgett", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/matt-damon.jpg")
i3 = Ingredient.create(name: "Potato", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/brad-pitt.jpg")
i4 = Ingredient.create(name: "Brocilli", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/elliot-gould.jpg")
i5 = Ingredient.create(name: "Leek", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/julia-roberts.jpg")
i6 = Ingredient.create(name: "Artichoke", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/mark-wahlberg.jpg")
i7 = Ingredient.create(name: "Asparagus", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/marion-cotillard.jpg")
i8 = Ingredient.create(name: "Bean sprouts", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/laurence-fishburne.jpg")
i9 = Ingredient.create(name: "Black beans", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/jude-law.jpg")
i10 = Ingredient.create(name: "Chickpeas", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/gwyneth-paltrow.jpg")
i11 = Ingredient.create(name: "Green beans", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/kate-winslet.jpg")
i12 = Ingredient.create(name: "Lentils", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/bryan-cranston.jpg")
i13 = Ingredient.create(name: "Mung beans", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/leonardo-dicaprio.jpg")
i14 = Ingredient.create(name: "Pinto beans", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/jack-nicholson.jpg")
i15 = Ingredient.create(name: "Runner beans", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/joseph-gordon-levitt.jpg")
i16 = Ingredient.create(name: "Split peas", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/tom-hardy.jpg")
i17 = Ingredient.create(name: "Soy beans", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/cillian-murphy.jpg")
i18 = Ingredient.create(name: "Mangetout", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/christian-bale.jpg")
i19 = Ingredient.create(name: "Bok choy", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/morgan-freeman.jpg")
i20 = Ingredient.create(name: "Brussel sprouts", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/rdj.jpg")
i21 = Ingredient.create(name: "Cabbage", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/terrence-howard.jpg")
i22 = Ingredient.create(name: "Cauliflower", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/jeff-bridges.jpg")
i23 = Ingredient.create(name: "Celery", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/rachel-mcadams.jpg")
i24 = Ingredient.create(name: "Chard", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/mark-strong.jpg")
i25 = Ingredient.create(name: "Beetroot", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/diane-lane.jpg")
i26 = Ingredient.create(name: "Fennel", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/ellen-page.jpg")
i27 = Ingredient.create(name: "Basil", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/anne-hathaway.jpg")
i28 = Ingredient.create(name: "Lemon grass", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/michael-caine.jpg")
i29 = Ingredient.create(name: "Kale", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/natalie-portman.png")
i30 = Ingredient.create(name: "Lettuce", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/clive-owen.jpg")
i31 = Ingredient.create(name: "Okra", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/matthew-mcconaughey.jpg")

m1 = Meal.create(title: "Caprese Pasta Salad", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/oceans-11.jpg")
m2 = Meal.create(title: "Spaghetti Squash Burrito Bowls", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/the-perfect-storm.jpg")
m3 = Meal.create(title: "Vegetarian Tortilla Soup", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/contagion.jpg")
m4 = Meal.create(title: "Simple Kale and Black Bean Burritos", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/the-departed")
m5 = Meal.create(title: "Spicy Kale and Coconut Stir Fry", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/inception.jpg")
m6 = Meal.create(title: "Broccolli, Cheddar and Quinoa Gratin", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/dark-knight-rises.jpg")
m7 = Meal.create(title: "Quick Chana Masala", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/iron-man.jpg")
m8 = Meal.create(title: "Super Kale, Hemp and Flaxseed Oil Pesto", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/sherlock-holmes.jpg")
m9 = Meal.create(title: "Raw Kale and Brussels Sprouts Salad with Tahini-Maple Dressing", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/closer.jpg")
m10 = Meal.create(title: "Curried Coconut Quinoa and Greens with Roasted Cauliflower", image: "http://s3.amazonaws.com/codecademy-content/courses/learn-rails/img/interstellar.jpg")

m1.ingredients << [i1, i2, i3, i4, i5]
m2.ingredients << [i1, i6, i25]
m3.ingredients << [i7, i8, i9, i10, i11, i12, i4, i2]
m4.ingredients << [i2, i13, i14, i6]
m5.ingredients << [i13, i26, i15, i16, i7, i17, i28]
m6.ingredients << [i18, i19, i28, i16, i7, i17, i15, i27]
m7.ingredients << [i20, i21, i22, i10]
m8.ingredients << [i20, i9, i23, i24]
m9.ingredients << [i5, i9, i29, i30]
m10.ingredients << [i31, i27, i28, i2]

c1 = Cupboard.create(location: "Fridge Door")
c2 = Cupboard.create(location: "Fridge Bottom Drawer")
c3 = Cupboard.create(location: "Fridge Top Shelf")
c4 = Cupboard.create(location: "Cupboard by the Oven")

c1.ingredients << [i5, i7, i8]
c2.ingredients << [i6, i12, i13, i16]
c3.ingredients << [i18, i19, i20, i21]
c4.ingredients << [i24, i25, i26, i28, i31]