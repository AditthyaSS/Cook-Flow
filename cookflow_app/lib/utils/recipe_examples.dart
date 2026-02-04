// Example recipes for quick testing

class RecipeExamples {
  static const List<Map<String, String>> examples = [
    {
      'name': '🍝 Classic Pasta Carbonara',
      'difficulty': 'Medium',
      'text': '''Classic Pasta Carbonara

Serves: 4 people
Difficulty: Medium
Cuisine: Italian

Ingredients:
- 400g spaghetti
- 200g pancetta or guanciale, diced
- 4 large eggs
- 100g Pecorino Romano cheese, grated
- 100g Parmesan cheese, grated
- 2 cloves garlic, minced
- Salt and black pepper to taste
- Fresh parsley for garnish

Directions:
1. Bring a large pot of salted water to boil and cook spaghetti according to package directions until al dente.
2. While pasta cooks, fry pancetta in a large skillet over medium heat until crispy, about 8-10 minutes.
3. In a bowl, whisk together eggs, both cheeses, and plenty of black pepper.
4. Reserve 1 cup of pasta cooking water, then drain the pasta.
5. Remove skillet from heat and add hot pasta to the pancetta, tossing to combine.
6. Quickly add egg mixture, tossing constantly. Add reserved pasta water a little at a time to create a creamy sauce.
7. Season with salt and more pepper. Serve immediately with extra cheese and parsley.'''
    },
    {
      'name': '🥗 Quick Greek Salad',
      'difficulty': 'Easy',
      'text': '''Quick Greek Salad

Serves: 4
Difficulty: Easy
Cuisine: Greek
Tags: Vegetarian, Healthy, Quick, Gluten-Free

Ingredients:
- 4 cups romaine lettuce, chopped
- 2 large tomatoes, diced
- 1 cucumber, sliced
- 1 red onion, thinly sliced
- 1 cup Kalamata olives
- 200g feta cheese, crumbled
- 1/4 cup extra virgin olive oil
- 2 tbsp red wine vinegar
- 1 tsp dried oregano
- Salt and pepper to taste

Instructions:
1. In a large bowl, combine lettuce, tomatoes, cucumber, onion, and olives.
2. In a small jar, shake together olive oil, vinegar, oregano, salt, and pepper.
3. Pour dressing over salad and toss gently to coat.
4. Top with crumbled feta cheese and serve immediately.

Chef's Note: For best flavor, let the salad sit for 5 minutes before serving to allow flavors to meld.'''
    },
    {
      'name': '🍰 Chocolate Chip Cookies',
      'difficulty': 'Easy',
      'text': '''Perfect Chocolate Chip Cookies

Makes: 24 cookies
Difficulty: Easy
Cuisine: American
Tags: Dessert, Baking

Ingredients:
- 2 1/4 cups all-purpose flour
- 1 tsp baking soda
- 1 tsp salt
- 1 cup butter, softened
- 3/4 cup granulated sugar
- 3/4 cup packed brown sugar
- 2 large eggs
- 2 tsp vanilla extract
- 2 cups chocolate chips

Steps:
1. Preheat oven to 375°F (190°C).
2. Mix flour, baking soda, and salt in a bowl and set aside.
3. In a large bowl, cream together butter and both sugars until light and fluffy, about 3 minutes.
4. Beat in eggs one at a time, then add vanilla extract.
5. Gradually stir in flour mixture until just combined.
6. Fold in chocolate chips.
7. Drop rounded tablespoons of dough onto ungreased cookie sheets, spacing 2 inches apart.
8. Bake for 9-11 minutes or until golden brown around the edges.
9. Cool on baking sheet for 2 minutes, then transfer to wire racks.'''
    },
    {
      'name': '🍜 Quick Stir-Fry Noodles',
      'difficulty': 'Easy',
      'text': '''Quick Vegetable Stir-Fry Noodles

Servings: 2-3
Prep Time: 10 minutes
Cook Time: 15 minutes
Cuisine: Asian
Tags: Quick, Vegetarian, One-Pot

Ingredients:
- 200g noodles (rice or wheat)
- 2 tbsp vegetable oil
- 1 bell pepper, sliced
- 1 carrot, julienned
- 1 cup broccoli florets
- 2 cloves garlic, minced
- 1 tbsp ginger, grated
- 3 tbsp soy sauce
- 1 tbsp sesame oil
- 1 tsp honey
- Sesame seeds for garnish
- Green onions, sliced

Instructions:
1. Cook noodles according to package instructions, drain and set aside.
2. Heat vegetable oil in a large wok or skillet over high heat.
3. Add bell pepper, carrot, and broccoli. Stir-fry for 5-6 minutes until tender-crisp.
4. Add garlic and ginger, cook for 30 seconds until fragrant.
5. Add cooked noodles to the wok.
6. Mix soy sauce, sesame oil, and honey in a small bowl, then pour over noodles.
7. Toss everything together for 2-3 minutes until well combined and heated through.
8. Garnish with sesame seeds and green onions. Serve hot.'''
    },
  ];

  static String getExample(int index) {
    if (index >= 0 && index < examples.length) {
      return examples[index]['text']!;
    }
    return examples[0]['text']!;
  }

  static String getExampleName(int index) {
    if (index >= 0 && index < examples.length) {
      return examples[index]['name']!;
    }
    return examples[0]['name']!;
  }

  static int get count => examples.length;
}
