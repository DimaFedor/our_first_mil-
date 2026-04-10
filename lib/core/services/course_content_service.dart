import '../../features/lessons/models/lesson_model.dart';

class CourseContentService {
  static const List<String> supportedCourseIds = <String>[
    'python',
    'javascript',
    'htmlcss',
    'react',
    'sql',
    'python-intermediate',
    'htmlcss-intermediate',
    'javascript-intermediate',
    'sql-intermediate',
    'react-intermediate',
  ];

  static List<Lesson> getLessonsForCourse(String courseId) {
    switch (courseId) {
      case 'python':
        return getPythonLessons();
      case 'javascript':
        return getJavaScriptLessons();
      case 'htmlcss':
        return getHTMLCSSLessons();
      case 'react':
        return getReactLessons();
      case 'sql':
        return getSQLLessons();
      case 'python-intermediate':
        return getPythonIntermediateLessons();
      case 'htmlcss-intermediate':
        return getHTMLCSSIntermediateLessons();
      case 'javascript-intermediate':
        return getJavaScriptIntermediateLessons();
      case 'sql-intermediate':
        return getSQLIntermediateLessons();
      case 'react-intermediate':
        return getReactIntermediateLessons();
      default:
        return const <Lesson>[];
    }
  }

  static List<Lesson> getPythonLessons() {
    return [
      // Lesson 1: Introduction to Python
      Lesson(
        id: 'python_lesson_1',
        courseId: 'python',
        moduleId: 'basics',
        title: 'Welcome to Python',
        description: 'Your first steps into the world of Python programming',
        theorySlides: [
          TheorySlide(
            title: 'What is Python? 🐍',
            content:
                'Python is one of the world\'s most popular programming languages. It\'s used by companies like Google, Netflix, and Instagram to build amazing software.\n\nPython is known for being:\n• Easy to read and write\n• Powerful yet simple\n• Perfect for beginners\n• Used everywhere: web development, data science, AI, and more!',
            order: 0,
          ),
          TheorySlide(
            title: 'Why Choose Python?',
            content:
                'Python was designed to be simple and readable. Unlike other programming languages that use lots of symbols and brackets, Python uses plain English words.\n\nPython powers:\n🌐 Websites (Instagram, Pinterest)\n🤖 AI and Machine Learning (Tesla, Spotify)\n📊 Data Analysis (Netflix recommendations)\n🎮 Games (Civilization IV)',
            order: 1,
          ),
          TheorySlide(
            title: 'Your First Python Program',
            content:
                'Every programmer starts with "Hello, World!" - a simple program that displays text on the screen.',
            codeSnippet: 'print("Hello, World!")',
            codeLanguage: 'python',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'What makes Python special compared to other programming languages?',
              options: [
                'It\'s easy to read and write',
                'It only works on Windows',
                'It\'s the fastest language',
                'It can only build games',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Python\'s main strength is its readability and simplicity, making it perfect for beginners while still being powerful enough for experts.',
            ),
            QuizQuestion(
              question: 'Which command displays text in Python?',
              options: ['show()', 'display()', 'print()', 'write()'],
              correctAnswerIndex: 2,
              explanation:
                  'The print() function is used to display text output in Python.',
            ),
            QuizQuestion(
              question: 'What punctuation must surround text in print()?',
              options: [
                'Square brackets []',
                'Curly braces {}',
                'Quotes "" or \'\'',
                'Parentheses ()',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Text (strings) in Python must be wrapped in quotes - either single \'\' or double "".',
            ),
            QuizQuestion(
              question: 'Which company uses Python?',
              options: ['Google', 'Netflix', 'Instagram', 'All of the above'],
              correctAnswerIndex: 3,
              explanation:
                  'Python is used by many major companies including Google, Netflix, Instagram, Spotify, and more!',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Say Hello!',
          description:
              'Write a program that displays "Hello, Python!" to the screen.',
          starterCode: '# Write your code below\n',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: 'Hello, Python!')],
          hint:
              'Use the print() function to display text. Remember to put your text in quotes!',
          solution: 'print("Hello, Python!")',
        ),
        xpReward: 15,
        order: 0,
      ),

      // Lesson 2: Variables and Data
      Lesson(
        id: 'python_lesson_2',
        courseId: 'python',
        moduleId: 'basics',
        title: 'Variables - Storing Information',
        description: 'Learn how to store and use data in your programs',
        theorySlides: [
          TheorySlide(
            title: 'What are Variables? 📦',
            content:
                'Think of variables like labeled boxes that store information. You can put different types of data in these boxes and use them later.\n\nFor example:\n• A box labeled "name" might contain "Alice"\n• A box labeled "age" might contain 25\n• A box labeled "is_student" might contain True',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Variables',
            content:
                'In Python, creating a variable is super simple! You just write the name, an equals sign, and the value.',
            codeSnippet:
                'name = "Alex"\nage = 20\nheight = 5.8\nis_student = True',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Types of Data',
            content:
                'Python automatically understands different types of data:\n\n• Text (String): "Hello", "Python", "123 Main St"\n• Numbers (Integer): 5, 42, -10, 0\n• Decimal Numbers (Float): 3.14, 2.5, -1.2\n• True/False (Boolean): True, False',
            codeSnippet:
                'message = "Welcome!"  # Text\nscore = 100          # Whole number\nprice = 19.99        # Decimal\nis_open = True       # True/False',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Using Variables',
            content:
                'Once you create a variable, you can use it anywhere in your program by writing its name.',
            codeSnippet:
                'player_name = "Maya"\npoints = 150\n\nprint("Player:", player_name)\nprint("Points:", points)\nprint("Great job", player_name, "!")',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'How do you create a variable called "score" with the value 100?',
              options: [
                'create score = 100',
                'score = 100',
                'var score = 100',
                'score := 100',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'In Python, you create variables using the assignment operator (=). Just write: score = 100',
            ),
            QuizQuestion(
              question: 'What type of data is "Hello World"?',
              options: ['Integer', 'Float', 'String', 'Boolean'],
              correctAnswerIndex: 2,
              explanation:
                  'Text in quotes is called a String. "Hello World" is a string because it contains text characters.',
            ),
            QuizQuestion(
              question: 'Which of these is a valid variable name?',
              options: ['2name', 'my-age', 'player_score', 'print'],
              correctAnswerIndex: 2,
              explanation:
                  'Variable names can contain letters, numbers, and underscores, but cannot start with a number or contain hyphens.',
            ),
            QuizQuestion(
              question: 'What is the value of x after: x = 5; x = 10?',
              options: ['5', '10', '15', 'Error'],
              correctAnswerIndex: 1,
              explanation:
                  'Variables can be reassigned. The second assignment (x = 10) replaces the first value.',
            ),
            QuizQuestion(
              question: 'What type is the value True?',
              options: ['String', 'Integer', 'Boolean', 'Float'],
              correctAnswerIndex: 2,
              explanation:
                  'True and False are Boolean values - they represent yes/no or on/off states.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Personal Info Card',
          description:
              'Create two variables:\n• name = "Alex"\n• age = 25\n\nThen print each on separate lines:\nName: Alex\nAge: 25',
          starterCode:
              '# Step 1: Create variables\nname = # add "Alex" here\nage = # add 25 here\n\n# Step 2: Print them\nprint("Name:", name)\nprint("Age:", age)',
          language: 'python',
          testCases: [
            TestCase(input: '', expectedOutput: 'Name: Alex\nAge: 25'),
          ],
          hint:
              'Replace the comments with values: name = "Alex" (with quotes for text) and age = 25 (no quotes for numbers).',
          solution:
              'name = "Alex"\nage = 25\n\nprint("Name:", name)\nprint("Age:", age)',
        ),
        xpReward: 20,
        order: 1,
      ),

      // Lesson 3: Working with Numbers
      Lesson(
        id: 'python_lesson_3',
        courseId: 'python',
        moduleId: 'basics',
        title: 'Math in Python',
        description: 'Learn to do calculations and work with numbers',
        theorySlides: [
          TheorySlide(
            title: 'Python is a Great Calculator! 🔢',
            content:
                'Python can perform all basic math operations and much more. You can use it like a powerful calculator!',
            codeSnippet:
                'print(5 + 3)    # Addition: 8\nprint(10 - 4)   # Subtraction: 6\nprint(6 * 7)    # Multiplication: 42\nprint(15 / 3)   # Division: 5.0',
            codeLanguage: 'python',
            order: 0,
          ),
          TheorySlide(
            title: 'Math with Variables',
            content:
                'You can use variables in math operations, making your calculations dynamic and reusable.',
            codeSnippet:
                'price = 25\nquantity = 3\ntotal = price * quantity\n\nprint("Total cost:", total)  # Total cost: 75',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Special Math Operations',
            content:
                'Python has some special math operators that are really useful:',
            codeSnippet:
                'print(10 ** 2)   # Power: 10 squared = 100\nprint(17 // 5)   # Floor division: 3\nprint(17 % 5)    # Modulo (remainder): 2',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Updating Variables',
            content:
                'You can change a variable\'s value by assigning it a new value. You can even use the variable\'s current value to calculate the new one!',
            codeSnippet:
                'score = 100\nprint("Current score:", score)\n\nscore = score + 50  # Add 50 points\nprint("New score:", score)\n\n# Shortcut: score += 50 does the same thing',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does 10 ** 3 equal in Python?',
              options: ['30', '103', '1000', '13'],
              correctAnswerIndex: 2,
              explanation:
                  '** is the power operator. 10 ** 3 means 10 to the power of 3, which is 10 × 10 × 10 = 1000.',
            ),
            QuizQuestion(
              question: 'If x = 5, what will x += 3 make x equal to?',
              options: ['5', '8', '3', '53'],
              correctAnswerIndex: 1,
              explanation:
                  'x += 3 is shorthand for x = x + 3. So if x starts at 5, it becomes 5 + 3 = 8.',
            ),
            QuizQuestion(
              question: 'What does the % operator do?',
              options: [
                'Calculates percentage',
                'Finds the remainder after division',
                'Multiplies by 100',
                'Converts to decimal',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The % operator (modulo) returns the remainder after division. For example, 17 % 5 = 2.',
            ),
            QuizQuestion(
              question: 'What is 15 // 4 in Python?',
              options: ['3.75', '3', '4', '3.7'],
              correctAnswerIndex: 1,
              explanation:
                  '// is floor division - it divides and rounds down to the nearest whole number. 15 / 4 = 3.75, but 15 // 4 = 3.',
            ),
            QuizQuestion(
              question:
                  'Which operator has the highest priority (executes first)?',
              options: [
                '+ (addition)',
                '* (multiplication)',
                '** (power)',
                '- (subtraction)',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Python follows math order of operations: ** (power) is calculated first, then * and /, then + and -.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Calculate Circle Area',
          description:
              'Given a radius, calculate the area of a circle using the formula: area = 3.14 * radius * radius',
          starterCode:
              '# Given radius\nradius = 5\n\n# Calculate area (use 3.14 for pi)\narea = \n\nprint("Area:", area)',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: 'Area: 78.5')],
          hint:
              'Use the formula: area = 3.14 * radius * radius. Remember that radius * radius is the same as radius ** 2.',
          solution:
              'radius = 5\narea = 3.14 * radius * radius\nprint("Area:", area)',
        ),
        xpReward: 20,
        order: 2,
      ),

      // Lesson 4: Text and Strings
      Lesson(
        id: 'python_lesson_4',
        courseId: 'python',
        moduleId: 'basics',
        title: 'Working with Text',
        description: 'Master text manipulation and string operations',
        theorySlides: [
          TheorySlide(
            title: 'Strings are Powerful! 📝',
            content:
                'In programming, text is called a "string" because it\'s like a string of characters tied together. Python has many tools to work with text.',
            codeSnippet:
                'message = "Hello, World!"\nname = "Python"\nsentence = "Learning " + name + " is fun!"',
            codeLanguage: 'python',
            order: 0,
          ),
          TheorySlide(
            title: 'Combining Text (Concatenation)',
            content:
                'You can join strings together using the + operator, just like adding numbers!',
            codeSnippet:
                'first_name = "John"\nlast_name = "Doe"\nfull_name = first_name + " " + last_name\n\nprint(full_name)  # John Doe',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Useful String Methods',
            content:
                'Strings come with built-in "methods" - special functions that can transform them:',
            codeSnippet:
                'text = "Hello World"\n\nprint(text.upper())     # HELLO WORLD\nprint(text.lower())     # hello world\nprint(text.title())     # Hello World\nprint(len(text))        # 11 (length)',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'F-strings: The Modern Way',
            content:
                'F-strings are the most elegant way to combine text and variables in Python:',
            codeSnippet:
                'name = "Alice"\nage = 30\nscore = 95.5\n\n# Old way:\nmessage1 = "Hi " + name + ", you are " + str(age)\n\n# F-string way (modern):\nmessage2 = f"Hi {name}, you are {age} years old!"\nmessage3 = f"Your score is {score}%"',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'How do you combine "Hello" and "World" with a space between?',
              options: [
                '"Hello" + "World"',
                '"Hello" + " " + "World"',
                '"Hello" & " " & "World"',
                '"Hello" * "World"',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'To combine strings with a space, use: "Hello" + " " + "World" which gives "Hello World".',
            ),
            QuizQuestion(
              question: 'What does "python".upper() return?',
              options: ['"PYTHON"', '"Python"', '"python"', 'Error'],
              correctAnswerIndex: 0,
              explanation:
                  'The .upper() method converts all letters to uppercase, so "python" becomes "PYTHON".',
            ),
            QuizQuestion(
              question: 'Which is an f-string?',
              options: [
                '"Hello " + name',
                'f"Hello {name}"',
                '"Hello {name}"',
                '"Hello %s" % name',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'F-strings start with f and use {variable_name} syntax: f"Hello {name}"',
            ),
            QuizQuestion(
              question: 'What does len("Python") return?',
              options: ['5', '6', '7', 'Error'],
              correctAnswerIndex: 1,
              explanation:
                  'len() returns the number of characters in a string. "Python" has 6 characters.',
            ),
            QuizQuestion(
              question: 'How do you get the first character of text = "Hello"?',
              options: ['text.first()', 'text[0]', 'text[1]', 'text.get(0)'],
              correctAnswerIndex: 1,
              explanation:
                  'Use square brackets with index. In Python, indexing starts at 0, so text[0] is the first character.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Build a Username',
          description:
              'Create a username by combining first name, last name initial, and birth year.',
          starterCode:
              'first_name = "john"\nlast_name = "doe"\nbirth_year = 1995\n\n# Create username: firstname + first letter of lastname + year\n# Example: john + d + 1995 = "johnd1995"\nusername = \n\nprint(username)',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: 'johnd1995')],
          hint:
              'Use string concatenation (+) or an f-string. To get the first letter of last_name, use last_name[0]. Convert birth_year to string with str().',
          solution:
              'first_name = "john"\nlast_name = "doe"\nbirth_year = 1995\n\nusername = first_name + last_name[0] + str(birth_year)\nprint(username)',
        ),
        xpReward: 25,
        order: 3,
      ),

      // Lesson 5: Making Decisions with If
      Lesson(
        id: 'python_lesson_5',
        courseId: 'python',
        moduleId: 'control_flow',
        title: 'Making Decisions',
        description: 'Learn how programs make choices using if statements',
        theorySlides: [
          TheorySlide(
            title: 'Programs That Think! 🤔',
            content:
                'Real programs need to make decisions based on different situations. The "if" statement lets your program choose what to do.\n\nThink of it like:\n"IF it\'s raining, bring an umbrella"\n"IF the score is high, show congratulations"',
            order: 0,
          ),
          TheorySlide(
            title: 'Basic If Statement',
            content:
                'The if statement checks if something is true, then runs code only if it is:',
            codeSnippet:
                'age = 18\n\nif age >= 18:\n    print("You can vote!")\n    print("Welcome to adulthood!")\n\nprint("This always runs")',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'If-Else: Two Choices',
            content: 'Use else to handle the case when the condition is false:',
            codeSnippet:
                'temperature = 25\n\nif temperature > 30:\n    print("It\'s hot! Stay hydrated.")\nelse:\n    print("Nice weather today!")\n    print("Perfect for a walk.")',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Multiple Conditions',
            content: 'Use elif (else if) to check multiple conditions:',
            codeSnippet:
                'score = 85\n\nif score >= 90:\n    grade = "A"\nelif score >= 80:\n    grade = "B"\nelif score >= 70:\n    grade = "C"\nelse:\n    grade = "Need more practice"\n\nprint(f"Your grade: {grade}")',
            codeLanguage: 'python',
            order: 3,
          ),
          TheorySlide(
            title: 'Comparison Operators',
            content: 'These operators help you compare values:',
            codeSnippet:
                '# Comparison operators\nprint(5 == 5)    # Equal to: True\nprint(5 != 3)    # Not equal: True\nprint(7 > 5)     # Greater than: True\nprint(4 < 8)     # Less than: True\nprint(5 >= 5)    # Greater or equal: True\nprint(3 <= 10)   # Less or equal: True',
            codeLanguage: 'python',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'What happens if the condition in an if statement is false?',
              options: [
                'The program crashes',
                'The code inside the if block is skipped',
                'The code runs anyway',
                'Python shows an error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'When an if condition is false, Python skips all the code inside that if block.',
            ),
            QuizQuestion(
              question: 'What does the == operator do?',
              options: [
                'Assigns a value',
                'Checks if two values are equal',
                'Adds two numbers',
                'Prints a value',
              ],
              correctAnswerIndex: 1,
              explanation:
                  '== checks if two values are equal and returns True or False. Don\'t confuse it with = which assigns values.',
            ),
            QuizQuestion(
              question: 'Which keyword is used for "otherwise" in Python?',
              options: ['otherwise', 'else', 'then', 'endif'],
              correctAnswerIndex: 1,
              explanation:
                  'The "else" keyword handles the case when the if condition is false.',
            ),
            QuizQuestion(
              question:
                  'What happens if no condition is True and there is no else?',
              options: [
                'Error',
                'Nothing happens',
                'Program crashes',
                'Prints None',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'If no condition matches and there is no else block, Python simply skips the entire if statement.',
            ),
            QuizQuestion(
              question: 'Which operator means "not equal"?',
              options: ['<>', '!=', '=/=', '<!='],
              correctAnswerIndex: 1,
              explanation:
                  '!= checks if two values are NOT equal. Example: 5 != 3 returns True.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Age Category Checker',
          description:
              'Write a program that categorizes people by age: Child (0-12), Teen (13-19), Adult (20-64), Senior (65+)',
          starterCode:
              'age = 16\n\n# Write if-elif-else statements to categorize the age\n# Print the appropriate category\n',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: 'Teen')],
          hint:
              'Use if-elif-else with age ranges. Check from youngest to oldest or use appropriate comparison operators.',
          solution:
              'age = 16\n\nif age <= 12:\n    print("Child")\nelif age <= 19:\n    print("Teen")\nelif age <= 64:\n    print("Adult")\nelse:\n    print("Senior")',
        ),
        xpReward: 30,
        order: 4,
      ),

      // Lesson 6: Lists
      Lesson(
        id: 'python_lesson_6',
        courseId: 'python',
        moduleId: 'data-structures',
        title: 'Working with Lists',
        description: 'Learn to store multiple items in ordered collections',
        theorySlides: [
          TheorySlide(
            title: 'What are Lists? 📝',
            content:
                'Lists let you store multiple items in a single variable. They are ordered, changeable, and allow duplicate values.\n\nReal-world examples:\n• Shopping list\n• Playlist of songs\n• List of high scores\n• Todo items',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Lists',
            content:
                'Lists are created using square brackets [], with items separated by commas.',
            codeSnippet:
                'fruits = ["apple", "banana", "cherry"]\nnumbers = [1, 2, 3, 4, 5]\nmixed = [1, "hello", True, 3.14]\n\nprint(fruits)',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Accessing List Items',
            content:
                'Access items by their index number. Python uses zero-based indexing (first item is 0).',
            codeSnippet:
                'fruits = ["apple", "banana", "cherry"]\n\nprint(fruits[0])   # apple\nprint(fruits[1])   # banana\nprint(fruits[-1])  # cherry (last item)',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'List Methods',
            content: 'Python provides many built-in methods to modify lists.',
            codeSnippet:
                'fruits = ["apple", "banana"]\n\n# Add item\nfruits.append("cherry")\n\n# Remove item\nfruits.remove("banana")\n\n# Sort list\nfruits.sort()\n\nprint(fruits)',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which index accesses the first element?',
              options: ['0', '1', '-1', 'first'],
              correctAnswerIndex: 0,
              explanation:
                  'Python uses zero-based indexing: index 0 is the first element.',
            ),
            QuizQuestion(
              question: 'Which method adds an item to the end?',
              options: ['add()', 'append()', 'push()', 'insert()'],
              correctAnswerIndex: 1,
              explanation: 'append() adds a single item to the end of a list.',
            ),
            QuizQuestion(
              question:
                  'What does fruits[-1] return if fruits = ["a", "b", "c"]?',
              options: ['"a"', '"b"', '"c"', 'Error'],
              correctAnswerIndex: 2,
              explanation:
                  'Negative indexing starts from the end. -1 is the last item, -2 is second to last, etc.',
            ),
            QuizQuestion(
              question: 'How do you change the second item in a list?',
              options: [
                'list[2] = value',
                'list[1] = value',
                'list.set(1, value)',
                'list.change(2, value)',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The second item has index 1 (since indexing starts at 0). Use list[1] = value to change it.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Shopping List',
          description:
              'Create a list with these 3 items: "milk", "bread", "eggs"\nThen add "butter" to the list.\nFinally, print the total count (should be 4).',
          starterCode:
              '# Step 1: Create the list\nshopping = ["milk", "bread", "eggs"]\n\n# Step 2: Add "butter" using append()\n\n\n# Step 3: Print the count using len()\n',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: '4')],
          hint:
              'Use shopping.append("butter") to add an item, then print(len(shopping)) to print the count.',
          solution:
              'shopping = ["milk", "bread", "eggs"]\nshopping.append("butter")\nprint(len(shopping))',
        ),
        xpReward: 30,
        order: 5,
      ),

      // Lesson 7: Loops
      Lesson(
        id: 'python_lesson_7',
        courseId: 'python',
        moduleId: 'control-flow',
        title: 'Loops and Iteration',
        description: 'Repeat actions efficiently with for and while loops',
        theorySlides: [
          TheorySlide(
            title: 'The for Loop 🔄',
            content:
                'Loops let you repeat code multiple times. The for loop iterates over sequences.',
            codeSnippet:
                'fruits = ["apple", "banana", "cherry"]\n\nfor fruit in fruits:\n    print(fruit)\n\n# Loop through range\nfor i in range(5):\n    print(i)  # 0, 1, 2, 3, 4',
            codeLanguage: 'python',
            order: 0,
          ),
          TheorySlide(
            title: 'The range() Function',
            content: 'range() generates sequences of numbers for loops.',
            codeSnippet:
                '# range(stop)\nfor i in range(3):\n    print(i)  # 0, 1, 2\n\n# range(start, stop, step)\nfor i in range(0, 10, 2):\n    print(i)  # 0, 2, 4, 6, 8',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'The while Loop',
            content: 'while loops continue as long as a condition is True.',
            codeSnippet:
                'count = 0\nwhile count < 5:\n    print(count)\n    count += 1  # Important!',
            codeLanguage: 'python',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does range(3) generate?',
              options: ['0, 1, 2', '1, 2, 3', '0, 1, 2, 3', '1, 2'],
              correctAnswerIndex: 0,
              explanation:
                  'range(3) generates 0, 1, 2 (up to but not including 3).',
            ),
            QuizQuestion(
              question: 'Which keyword exits a loop?',
              options: ['exit', 'break', 'stop', 'return'],
              correctAnswerIndex: 1,
              explanation: 'break immediately exits the current loop.',
            ),
            QuizQuestion(
              question: 'What does range(2, 8, 2) generate?',
              options: ['2, 4, 6', '2, 4, 6, 8', '2, 3, 4, 5, 6, 7', '4, 6'],
              correctAnswerIndex: 0,
              explanation:
                  'range(2, 8, 2) starts at 2, ends before 8, step 2 → gives 2, 4, 6.',
            ),
            QuizQuestion(
              question: 'Which keyword skips to the next iteration?',
              options: ['next', 'continue', 'skip', 'pass'],
              correctAnswerIndex: 1,
              explanation:
                  'continue skips the rest of the current iteration and moves to the next one.',
            ),
            QuizQuestion(
              question: 'What is wrong with: while True: print("Hi")?',
              options: [
                'Syntax error',
                'Infinite loop (runs forever)',
                'Prints nothing',
                'Prints once',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Since the condition is always True, this loop never stops - it is an infinite loop!',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Print Even Numbers',
          description: 'Print all even numbers from 0 to 10.',
          starterCode: '# Print even numbers 0-10\n',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: '0\n2\n4\n6\n8\n10')],
          hint: 'Use range(0, 11, 2).',
          solution: 'for i in range(0, 11, 2):\n    print(i)',
        ),
        xpReward: 35,
        order: 6,
      ),

      // Lesson 8: Dictionaries
      Lesson(
        id: 'python_lesson_8',
        courseId: 'python',
        moduleId: 'data-structures',
        title: 'Dictionaries',
        description: 'Store data in key-value pairs',
        theorySlides: [
          TheorySlide(
            title: 'What are Dictionaries? 🗂️',
            content:
                'Dictionaries store data as key-value pairs. Each key is unique and maps to a value.\n\nLike a real dictionary:\nWord (key) → Definition (value)\n\nIn programming:\n"name" → "Alice"\n"age" → 25',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Dictionaries',
            content: 'Use curly braces {} with key:value pairs.',
            codeSnippet:
                'person = {\n    "name": "Alice",\n    "age": 25,\n    "city": "NYC"\n}\n\nprint(person["name"])',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Dictionary Methods',
            content: 'Useful methods for working with dictionaries.',
            codeSnippet:
                'person = {"name": "Alice", "age": 25}\n\n# Get all keys\nprint(person.keys())\n\n# Get all values\nprint(person.values())\n\n# Check if key exists\nif "name" in person:\n    print("Found!")',
            codeLanguage: 'python',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'How do you access a dictionary value?',
              options: ['dict.key', 'dict["key"]', 'dict(key)', 'dict->key'],
              correctAnswerIndex: 1,
              explanation: 'Use bracket notation: dict["key"].',
            ),
            QuizQuestion(
              question: 'Which method returns all keys?',
              options: ['get_keys()', 'keys()', 'all_keys()', 'getKeys()'],
              correctAnswerIndex: 1,
              explanation: 'The keys() method returns all dictionary keys.',
            ),
            QuizQuestion(
              question: 'What happens if you access a key that does not exist?',
              options: [
                'Returns None',
                'Returns ""',
                'KeyError',
                'Creates the key',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Accessing a non-existent key raises a KeyError. Use .get("key") to safely return None instead.',
            ),
            QuizQuestion(
              question: 'Can dictionary keys be lists?',
              options: ['Yes', 'No', 'Only empty lists', 'Only small lists'],
              correctAnswerIndex: 1,
              explanation:
                  'Dictionary keys must be immutable (unchangeable). Lists can change, so they cannot be keys.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Student Record',
          description:
              'Create a dictionary with name, age, grade. Print the name.',
          starterCode: '# Create student dict\nstudent = {}\n',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: 'Alice')],
          hint: 'Use {"key": "value"} syntax.',
          solution:
              'student = {"name": "Alice", "age": 20, "grade": "A"}\nprint(student["name"])',
        ),
        xpReward: 35,
        order: 7,
      ),

      // Lesson 9: Functions
      Lesson(
        id: 'python_lesson_9',
        courseId: 'python',
        moduleId: 'functions',
        title: 'Creating Functions',
        description: 'Write reusable code blocks',
        theorySlides: [
          TheorySlide(
            title: 'What are Functions? ⚙️',
            content:
                'Functions are reusable blocks of code that perform specific tasks.\n\nBenefits:\n• Avoid code repetition\n• Organize complex programs\n• Make code easier to test\n• Enable code sharing',
            order: 0,
          ),
          TheorySlide(
            title: 'Defining Functions',
            content: 'Use the def keyword to create functions.',
            codeSnippet:
                'def greet():\n    print("Hello!")\n\n# Call the function\ngreet()\ngreet()  # Can call multiple times',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Function Parameters',
            content: 'Functions can accept input values (parameters).',
            codeSnippet:
                'def greet(name):\n    print(f"Hello, {name}!")\n\ngreet("Alice")\ngreet("Bob")',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Return Values',
            content: 'Functions can return values using return.',
            codeSnippet:
                'def add(a, b):\n    return a + b\n\nresult = add(5, 3)\nprint(result)  # 8',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What keyword defines a function?',
              options: ['function', 'def', 'func', 'define'],
              correctAnswerIndex: 1,
              explanation: 'The def keyword defines functions in Python.',
            ),
            QuizQuestion(
              question: 'What does a function return by default?',
              options: ['0', 'None', 'Empty string', 'Error'],
              correctAnswerIndex: 1,
              explanation: 'Functions without return statements return None.',
            ),
            QuizQuestion(
              question:
                  'What is wrong with: def greet(name): return f"Hi {name}" print("Done")?',
              options: [
                'Nothing',
                'Code after return never executes',
                'Syntax error',
                'Function is too long',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'return exits the function immediately. Code after return is unreachable.',
            ),
            QuizQuestion(
              question: 'What are parameters?',
              options: [
                'Return values',
                'Input values the function receives',
                'Errors',
                'Function names',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Parameters are variables that receive values when the function is called.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Calculator Function',
          description:
              'Create a multiply function that returns the product of two numbers.',
          starterCode:
              'def multiply(a, b):\n    # Your code\n    pass\n\nprint(multiply(6, 7))',
          language: 'python',
          testCases: [TestCase(input: '', expectedOutput: '42')],
          hint: 'Use * and return.',
          solution:
              'def multiply(a, b):\n    return a * b\n\nprint(multiply(6, 7))',
        ),
        xpReward: 40,
        order: 8,
      ),

      // Lesson 10: Exception Handling
      Lesson(
        id: 'python_lesson_10',
        courseId: 'python',
        moduleId: 'advanced',
        title: 'Handling Errors',
        description: 'Deal with errors gracefully in your code',
        theorySlides: [
          TheorySlide(
            title: 'What are Exceptions? ⚠️',
            content:
                'Exceptions are errors that occur during program execution.\n\nCommon exceptions:\n• ZeroDivisionError (divide by 0)\n• ValueError (wrong value type)\n• TypeError (wrong data type)\n• FileNotFoundError (missing file)',
            order: 0,
          ),
          TheorySlide(
            title: 'Try and Except',
            content: 'Handle errors with try/except blocks to prevent crashes.',
            codeSnippet:
                'try:\n    result = 10 / 0\nexcept ZeroDivisionError:\n    print("Cannot divide by zero!")',
            codeLanguage: 'python',
            order: 1,
          ),
          TheorySlide(
            title: 'Multiple Exceptions',
            content: 'Handle different error types separately.',
            codeSnippet:
                'try:\n    num = int(input("Enter number: "))\n    result = 10 / num\nexcept ValueError:\n    print("Invalid number!")\nexcept ZeroDivisionError:\n    print("Cannot divide by zero!")',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Finally Block',
            content:
                'Code in finally always runs, whether an error occurred or not.',
            codeSnippet:
                'try:\n    file = open("data.txt")\n    # Do something\nexcept FileNotFoundError:\n    print("File not found!")\nfinally:\n    print("Cleanup complete")',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which block handles exceptions?',
              options: ['catch', 'except', 'error', 'handle'],
              correctAnswerIndex: 1,
              explanation: 'The except block catches and handles exceptions.',
            ),
            QuizQuestion(
              question: 'When does the finally block execute?',
              options: ['Only on error', 'Only on success', 'Always', 'Never'],
              correctAnswerIndex: 2,
              explanation: 'finally always executes, regardless of errors.',
            ),
            QuizQuestion(
              question: 'What exception occurs when dividing by zero?',
              options: [
                'ValueError',
                'TypeError',
                'ZeroDivisionError',
                'MathError',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'ZeroDivisionError is raised when you try to divide a number by zero.',
            ),
            QuizQuestion(
              question: 'How do you catch any exception?',
              options: [
                'except All:',
                'except *:',
                'except Exception:',
                'except Error:',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'except Exception: catches most exceptions. You can also use except: alone to catch all.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Safe Division',
          description:
              'Create a safe division that catches ZeroDivisionError and prints "Cannot divide by zero!"',
          starterCode:
              '# Safe division\ntry:\n    result = 10 / 0\n    # Your code here\n',
          language: 'python',
          testCases: [
            TestCase(input: '', expectedOutput: 'Cannot divide by zero!'),
          ],
          hint: 'Use except ZeroDivisionError.',
          solution:
              'try:\n    result = 10 / 0\nexcept ZeroDivisionError:\n    print("Cannot divide by zero!")',
        ),
        xpReward: 45,
        order: 9,
      ),
    ];
  }

  static List<Lesson> getJavaScriptLessons() {
    return [
      // Lesson 1: Introduction to JavaScript
      Lesson(
        id: 'js_lesson_1',
        courseId: 'javascript',
        moduleId: 'basics',
        title: 'Welcome to JavaScript',
        description: 'Your first steps into the world of web programming',
        theorySlides: [
          TheorySlide(
            title: 'What is JavaScript? 🌐',
            content:
                'JavaScript is the programming language of the web! It makes websites interactive and dynamic.\n\nEvery website you visit uses JavaScript:\n• Animations and effects\n• Form validation\n• Interactive maps\n• Games and apps\n\nIt\'s one of the most popular languages in the world!',
            order: 0,
          ),
          TheorySlide(
            title: 'JavaScript Everywhere',
            content:
                'JavaScript started as a browser language, but now it runs everywhere!\n\n🌐 Frontend: React, Vue, Angular\n⚙️ Backend: Node.js, Express\n📱 Mobile: React Native\n🖥️ Desktop: Electron\n🎮 Games: Phaser, Three.js',
            order: 1,
          ),
          TheorySlide(
            title: 'Your First JavaScript',
            content:
                'Let\'s write your first JavaScript code! We use console.log() to display messages.',
            codeSnippet: 'console.log("Hello, World!");',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is JavaScript primarily used for?',
              options: [
                'Making websites interactive',
                'Designing graphics',
                'Writing documents',
                'Managing databases only',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'JavaScript is the language of the web, making websites dynamic and interactive!',
            ),
            QuizQuestion(
              question: 'Which function displays output in JavaScript?',
              options: ['print()', 'echo()', 'console.log()', 'display()'],
              correctAnswerIndex: 2,
              explanation:
                  'console.log() is the standard way to output messages in JavaScript.',
            ),
            QuizQuestion(
              question: 'Where can JavaScript code run?',
              options: [
                'Only in web browsers',
                'Only on servers',
                'Both browsers and servers',
                'Only on mobile devices',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'JavaScript runs everywhere - in browsers (frontend), on servers with Node.js, and even in mobile/desktop apps!',
            ),
            QuizQuestion(
              question: 'Which company originally created JavaScript?',
              options: ['Microsoft', 'Google', 'Netscape', 'Apple'],
              correctAnswerIndex: 2,
              explanation:
                  'JavaScript was created by Brendan Eich at Netscape in 1995 in just 10 days!',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Say Hello!',
          description:
              'Write code that displays "Hello, JavaScript!" using console.log()',
          starterCode: '// Write your code below\n',
          language: 'javascript',
          testCases: [
            TestCase(input: '', expectedOutput: 'Hello, JavaScript!'),
          ],
          hint: 'Use console.log() with your message in quotes!',
          solution: 'console.log("Hello, JavaScript!");',
        ),
        xpReward: 15,
        order: 0,
      ),

      // Lesson 2: Variables in JavaScript
      Lesson(
        id: 'js_lesson_2',
        courseId: 'javascript',
        moduleId: 'basics',
        title: 'Variables - Storing Data',
        description: 'Learn how to store and use information in JavaScript',
        theorySlides: [
          TheorySlide(
            title: 'What are Variables? 📦',
            content:
                'Variables are containers for storing data. Think of them as labeled boxes where you can put information.\n\nIn JavaScript, we have three ways to create variables:\n• let - for values that change\n• const - for values that stay the same\n• var - the old way (avoid using)',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Variables',
            content: 'Here\'s how to create and use variables:',
            codeSnippet:
                'let name = "Alex";\nlet age = 25;\nconst PI = 3.14159;\n\nconsole.log(name);  // Alex\nconsole.log(age);   // 25',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Data Types',
            content:
                'JavaScript has several data types:\n\n📝 String: "Hello" (text in quotes)\n🔢 Number: 42, 3.14 (numbers)\n✅ Boolean: true, false\n📋 Array: [1, 2, 3] (lists)\n📦 Object: {name: "Alex"} (complex data)',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'Which keyword creates a variable that cannot be changed?',
              options: ['let', 'var', 'const', 'static'],
              correctAnswerIndex: 2,
              explanation:
                  'const creates constants - values that cannot be reassigned.',
            ),
            QuizQuestion(
              question: 'What type is the value "Hello"?',
              options: ['Number', 'String', 'Boolean', 'Array'],
              correctAnswerIndex: 1,
              explanation: 'Text in quotes is called a String in JavaScript.',
            ),
            QuizQuestion(
              question:
                  'What happens if you use a variable before declaring it with let?',
              options: [
                'It works fine',
                'You get undefined',
                'ReferenceError is thrown',
                'It becomes a global variable',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'With let, variables are not hoisted like var. Accessing them before declaration causes a ReferenceError (temporal dead zone).',
            ),
            QuizQuestion(
              question: 'Which statement about const is true?',
              options: [
                'The value can never be modified',
                'The reference cannot be changed',
                'It only works with numbers',
                'It creates immutable objects',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'const prevents reassignment of the variable, but if it\'s an object or array, the contents can still be modified!',
            ),
            QuizQuestion(
              question: 'What is the result of: typeof null?',
              options: ['"null"', '"undefined"', '"object"', '"number"'],
              correctAnswerIndex: 2,
              explanation:
                  'This is a famous JavaScript quirk! typeof null returns "object" - a bug that can\'t be fixed due to backward compatibility.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Greeting',
          description:
              'Create a variable called "greeting" with the value "Hello!" and display it.',
          starterCode: '// Create your variable and display it\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Hello!')],
          hint: 'Use let greeting = "Hello!"; then console.log(greeting);',
          solution: 'let greeting = "Hello!";\nconsole.log(greeting);',
        ),
        xpReward: 20,
        order: 1,
      ),

      // Lesson 3: Operators
      Lesson(
        id: 'js_lesson_3',
        courseId: 'javascript',
        moduleId: 'basics',
        title: 'Operators - Math & Logic',
        description: 'Learn to perform calculations and comparisons',
        theorySlides: [
          TheorySlide(
            title: 'Math Operators ➕',
            content:
                'JavaScript can do math! Here are the basic operators:\n\n+ Addition\n- Subtraction\n* Multiplication\n/ Division\n% Modulus (remainder)\n** Exponentiation (power)',
            order: 0,
          ),
          TheorySlide(
            title: 'Math Examples',
            content: 'Let\'s see operators in action:',
            codeSnippet:
                'let sum = 10 + 5;      // 15\nlet diff = 10 - 3;     // 7\nlet product = 4 * 3;   // 12\nlet quotient = 15 / 3; // 5\nlet remainder = 17 % 5; // 2\nlet power = 2 ** 3;    // 8',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Comparison Operators',
            content:
                'Compare values to get true or false:\n\n== Equal value\n=== Equal value AND type\n!= Not equal\n> Greater than\n< Less than\n>= Greater or equal\n<= Less or equal',
            codeSnippet:
                'console.log(5 > 3);   // true\nconsole.log(10 === 10); // true\nconsole.log(5 !== 3);  // true',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is 17 % 5?',
              options: ['3', '2', '12', '3.4'],
              correctAnswerIndex: 1,
              explanation:
                  'The modulus operator returns the remainder. 17 ÷ 5 = 3 remainder 2.',
            ),
            QuizQuestion(
              question: 'What does === check?',
              options: ['Value only', 'Type only', 'Value and type', 'Nothing'],
              correctAnswerIndex: 2,
              explanation:
                  '=== checks both value AND type. "5" === 5 is false!',
            ),
            QuizQuestion(
              question: 'What is the result of: 5 + "5"?',
              options: ['10', '"55"', 'Error', '"10"'],
              correctAnswerIndex: 1,
              explanation:
                  'JavaScript coerces the number to a string and concatenates them, resulting in "55". This is type coercion in action!',
            ),
            QuizQuestion(
              question:
                  'Which operator would you use to check if two values are NOT equal in type AND value?',
              options: ['!=', '!==', '<>', '=/='],
              correctAnswerIndex: 1,
              explanation:
                  '!== is the strict inequality operator. It returns true if values differ in value OR type.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Calculate the Sum',
          description:
              'Create two variables a=15 and b=25, add them, and display the result.',
          starterCode: '// Create variables a and b, then display their sum\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: '40')],
          hint: 'Create a and b, then use console.log(a + b)',
          solution: 'let a = 15;\nlet b = 25;\nconsole.log(a + b);',
        ),
        xpReward: 20,
        order: 2,
      ),

      // Lesson 4: Strings
      Lesson(
        id: 'js_lesson_4',
        courseId: 'javascript',
        moduleId: 'basics',
        title: 'Working with Strings',
        description: 'Master text manipulation in JavaScript',
        theorySlides: [
          TheorySlide(
            title: 'Strings - Text Data 📝',
            content:
                'Strings are text values. You can create them with:\n\n• Single quotes: \'Hello\'\n• Double quotes: "Hello"\n• Backticks: `Hello` (template literals)\n\nBackticks are special - they allow embedding variables!',
            order: 0,
          ),
          TheorySlide(
            title: 'Template Literals',
            content: 'Template literals let you embed expressions:',
            codeSnippet:
                'let name = "Alex";\nlet age = 25;\n\n// Template literal with \${}\nlet message = `Hi, I\'m \${name} and I\'m \${age} years old!`;\n\nconsole.log(message);\n// Hi, I\'m Alex and I\'m 25 years old!',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'String Methods',
            content:
                'Strings have useful methods:\n\n.length - get length\n.toUpperCase() - UPPERCASE\n.toLowerCase() - lowercase\n.includes() - check if contains\n.slice() - extract part',
            codeSnippet:
                'let text = "JavaScript";\nconsole.log(text.length);      // 10\nconsole.log(text.toUpperCase()); // JAVASCRIPT\nconsole.log(text.includes("Script")); // true',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which quotes allow embedding variables?',
              options: [
                'Single quotes \'\'',
                'Double quotes ""',
                'Backticks ``',
                'All of them',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Only backticks (template literals) allow \${variable} syntax.',
            ),
            QuizQuestion(
              question: 'What does "hello".toUpperCase() return?',
              options: ['hello', 'HELLO', 'Hello', 'hELLO'],
              correctAnswerIndex: 1,
              explanation: 'toUpperCase() converts all letters to uppercase.',
            ),
            QuizQuestion(
              question: 'What is the output of: `The answer is ${5 + 3}`?',
              options: [
                'The answer is 5 + 3',
                'The answer is ${5 + 3}',
                'The answer is 8',
                'The answer is 53',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Template literals (backticks) evaluate expressions inside \${}. So 5 + 3 becomes 8.',
            ),
            QuizQuestion(
              question: 'How do you get the length of a string "hello"?',
              options: [
                '"hello".length()',
                '"hello".size',
                '"hello".length',
                'length("hello")',
              ],
              correctAnswerIndex: 2,
              explanation:
                  '.length is a property (not a method), so no parentheses are needed. "hello".length returns 5.',
            ),
            QuizQuestion(
              question: 'What does "JavaScript".slice(0, 4) return?',
              options: ['"Java"', '"JavaScript"', '"Script"', '"Jav"'],
              correctAnswerIndex: 0,
              explanation:
                  'slice(0, 4) extracts characters from index 0 to 3 (end index is exclusive), returning "Java".',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Introduce Yourself',
          description:
              'Create a variable name="Coder" and display "Hello, Coder!" using template literals.',
          starterCode: '// Use template literals to create a greeting\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Hello, Coder!')],
          hint: 'Use backticks: `Hello, \${name}!`',
          solution: 'let name = "Coder";\nconsole.log(`Hello, \${name}!`);',
        ),
        xpReward: 25,
        order: 3,
      ),

      // Lesson 5: Conditionals
      Lesson(
        id: 'js_lesson_5',
        courseId: 'javascript',
        moduleId: 'basics',
        title: 'If Statements - Making Decisions',
        description: 'Learn to write code that makes choices',
        theorySlides: [
          TheorySlide(
            title: 'Conditional Logic 🤔',
            content:
                'Programs need to make decisions! If statements let your code choose different paths based on conditions.\n\nThink of it like: "IF it\'s raining, THEN take umbrella, ELSE wear sunglasses"',
            order: 0,
          ),
          TheorySlide(
            title: 'If Statement Syntax',
            content: 'Here\'s how to write if statements:',
            codeSnippet:
                'let age = 18;\n\nif (age >= 18) {\n  console.log("You can vote!");\n} else {\n  console.log("Too young to vote");\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Multiple Conditions',
            content: 'Use else if for multiple conditions:',
            codeSnippet:
                'let score = 85;\n\nif (score >= 90) {\n  console.log("A - Excellent!");\n} else if (score >= 80) {\n  console.log("B - Good job!");\n} else if (score >= 70) {\n  console.log("C - Keep trying");\n} else {\n  console.log("Need improvement");\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does the else block do?',
              options: [
                'Runs if condition is true',
                'Runs if condition is false',
                'Always runs',
                'Never runs',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The else block executes when the if condition is false.',
            ),
            QuizQuestion(
              question: 'If x = 5, what does (x > 3) evaluate to?',
              options: ['true', 'false', '5', '3'],
              correctAnswerIndex: 0,
              explanation: '5 is greater than 3, so the condition is true.',
            ),
            QuizQuestion(
              question: 'What is the purpose of the else if statement?',
              options: [
                'To run code when all conditions are false',
                'To check multiple conditions sequentially',
                'To repeat code multiple times',
                'To define a function',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'else if allows you to test multiple conditions in order. The first true condition executes, then the rest are skipped.',
            ),
            QuizQuestion(
              question: 'What is the result of: true && false?',
              options: ['true', 'false', '1', '0'],
              correctAnswerIndex: 1,
              explanation:
                  'The && (AND) operator returns true only if BOTH operands are true. Here, false makes the whole expression false.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Age Checker',
          description:
              'Create a variable age=20. If age >= 18, display "Adult", else display "Minor".',
          starterCode: '// Check if someone is an adult\nlet age = 20;\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Adult')],
          hint: 'Use if (age >= 18) { console.log("Adult"); }',
          solution:
              'let age = 20;\nif (age >= 18) {\n  console.log("Adult");\n} else {\n  console.log("Minor");\n}',
        ),
        xpReward: 30,
        order: 4,
      ),

      // Lesson 6: Arrays
      Lesson(
        id: 'js_lesson_6',
        courseId: 'javascript',
        moduleId: 'data-structures',
        title: 'Working with Arrays',
        description: 'Master JavaScript arrays and their methods',
        theorySlides: [
          TheorySlide(
            title: 'What are Arrays? 📚',
            content:
                'Arrays store multiple values in a single variable. They are ordered and can hold any data type.\n\nCommon uses:\n• User lists\n• Shopping carts\n• Playlists\n• Game scores',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Arrays',
            content: 'Arrays use square brackets with comma-separated values.',
            codeSnippet:
                'const fruits = ["apple", "banana", "orange"];\nconst numbers = [1, 2, 3, 4, 5];\nconst mixed = [1, "hello", true, null];\n\nconsole.log(fruits[0]);  // apple',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Array Methods',
            content: 'JavaScript provides powerful array methods.',
            codeSnippet:
                'const arr = [1, 2, 3];\n\n// Add elements\narr.push(4);       // [1,2,3,4]\narr.unshift(0);    // [0,1,2,3,4]\n\n// Remove elements\narr.pop();         // Remove last\narr.shift();       // Remove first\n\nconsole.log(arr);',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Useful Array Methods',
            content: 'More methods for common tasks.',
            codeSnippet:
                'const numbers = [1, 2, 3, 4, 5];\n\nconsole.log(numbers.length);     // 5\nconsole.log(numbers.includes(3)); // true\nconsole.log(numbers.indexOf(4));  // 3\n\nconst doubled = numbers.map(n => n * 2);\nconsole.log(doubled);  // [2,4,6,8,10]',
            codeLanguage: 'javascript',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which method adds an element to the end?',
              options: ['add()', 'push()', 'append()', 'insert()'],
              correctAnswerIndex: 1,
              explanation: 'push() adds elements to the end of an array.',
            ),
            QuizQuestion(
              question: 'How do you access the first element?',
              options: ['arr[0]', 'arr[1]', 'arr.first', 'arr.first()'],
              correctAnswerIndex: 0,
              explanation:
                  'Arrays are zero-indexed, so arr[0] is the first element.',
            ),
            QuizQuestion(
              question: 'What does the spread operator (...) do with arrays?',
              options: [
                'Deletes all elements',
                'Copies or expands array elements',
                'Sorts the array',
                'Reverses the array',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The spread operator (...) expands array elements. Example: [...arr1, ...arr2] combines two arrays.',
            ),
            QuizQuestion(
              question: 'What is array destructuring?',
              options: [
                'Deleting array elements',
                'Extracting values into variables',
                'Combining multiple arrays',
                'Sorting an array',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Destructuring unpacks array values: const [a, b] = [1, 2] assigns a=1, b=2. It\'s a clean way to extract values!',
            ),
            QuizQuestion(
              question: 'What does [1,2,3].filter(n => n > 1) return?',
              options: ['[1]', '[2, 3]', '[1, 2, 3]', 'true'],
              correctAnswerIndex: 1,
              explanation:
                  'filter() creates a new array with elements that pass the test. Only 2 and 3 are greater than 1.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Manage a Task List',
          description:
              'Create an array with 3 tasks, add a 4th task, and log the array length.',
          starterCode: '// Create your task array\nconst tasks = [];\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: '4')],
          hint: 'Use push() and .length property.',
          solution:
              'const tasks = ["Task 1", "Task 2", "Task 3"];\ntasks.push("Task 4");\nconsole.log(tasks.length);',
        ),
        xpReward: 30,
        order: 5,
      ),

      // Lesson 7: Loops
      Lesson(
        id: 'js_lesson_7',
        courseId: 'javascript',
        moduleId: 'control-flow',
        title: 'Loops in JavaScript',
        description: 'Iterate efficiently with for, while, and forEach',
        theorySlides: [
          TheorySlide(
            title: 'The for Loop 🔄',
            content:
                'The classic for loop with three parts: initialization, condition, and increment.',
            codeSnippet:
                'for (let i = 0; i < 5; i++) {\n  console.log(i);\n}\n// Prints: 0, 1, 2, 3, 4\n\nfor (let i = 0; i < 10; i += 2) {\n  console.log(i);\n}\n// Prints: 0, 2, 4, 6, 8',
            codeLanguage: 'javascript',
            order: 0,
          ),
          TheorySlide(
            title: 'The while Loop',
            content: 'Loops continue while a condition is true.',
            codeSnippet:
                'let count = 0;\nwhile (count < 5) {\n  console.log(count);\n  count++;\n}\n\n// Be careful with infinite loops!\nlet ready = false;\nwhile (!ready) {\n  // Must set ready = true eventually\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'forEach for Arrays',
            content: 'The modern way to loop through arrays.',
            codeSnippet:
                'const fruits = ["apple", "banana", "orange"];\n\nfruits.forEach(fruit => {\n  console.log(fruit);\n});\n\n// With index\nfruits.forEach((fruit, index) => {\n  console.log(index + ": " + fruit);\n});',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does i++ do in a for loop?',
              options: ['Decreases i', 'Increments i', 'Resets i', 'Doubles i'],
              correctAnswerIndex: 1,
              explanation: 'i++ increments i by 1 each iteration.',
            ),
            QuizQuestion(
              question: 'Which is best for looping through arrays?',
              options: ['for', 'while', 'forEach', 'All are equal'],
              correctAnswerIndex: 2,
              explanation:
                  'forEach is the most readable and modern way to iterate arrays.',
            ),
            QuizQuestion(
              question:
                  'What is the key difference between for...of and for...in?',
              options: [
                'No difference',
                'for...of iterates values, for...in iterates keys',
                'for...in iterates values, for...of iterates keys',
                'Both iterate the same way',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'for...of loops through array VALUES, while for...in loops through object KEYS/indices. Use for...of for arrays!',
            ),
            QuizQuestion(
              question: 'How do you exit a loop early?',
              options: ['exit', 'break', 'stop', 'return'],
              correctAnswerIndex: 1,
              explanation:
                  'The break statement immediately exits the current loop. Use continue to skip to the next iteration.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Sum Numbers',
          description:
              'Use a for loop to calculate the sum of numbers from 1 to 10 and log it.',
          starterCode: '// Calculate sum of 1 to 10\nlet sum = 0;\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: '55')],
          hint: 'Loop from 1 to 10 and add each number to sum.',
          solution:
              'let sum = 0;\nfor (let i = 1; i <= 10; i++) {\n  sum += i;\n}\nconsole.log(sum);',
        ),
        xpReward: 35,
        order: 6,
      ),

      // Lesson 8: Objects
      Lesson(
        id: 'js_lesson_8',
        courseId: 'javascript',
        moduleId: 'data-structures',
        title: 'JavaScript Objects',
        description: 'Store structured data with objects',
        theorySlides: [
          TheorySlide(
            title: 'What are Objects? 🏷️',
            content:
                'Objects store data as key-value pairs (properties). They represent real-world entities.\n\nExamples:\n• User profiles\n• Product details\n• Game characters\n• Configuration settings',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Objects',
            content: 'Objects use curly braces with property: value pairs.',
            codeSnippet:
                'const person = {\n  name: "Alice",\n  age: 25,\n  city: "NYC",\n  isStudent: true\n};\n\nconsole.log(person.name);  // Alice\nconsole.log(person["age"]); // 25',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Object Methods',
            content: 'Objects can contain functions (methods).',
            codeSnippet:
                'const user = {\n  name: "Bob",\n  age: 30,\n  greet: function() {\n    console.log("Hi, I am " + this.name);\n  },\n  haveBirthday() {\n    this.age++;\n  }\n};\n\nuser.greet();  // Hi, I am Bob',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Object Manipulation',
            content: 'Add, update, or delete properties dynamically.',
            codeSnippet:
                'const car = {\n  brand: "Toyota",\n  year: 2020\n};\n\n// Add property\ncar.color = "red";\n\n// Update property\ncar.year = 2021;\n\n// Delete property\ndelete car.color;\n\nconsole.log(car);',
            codeLanguage: 'javascript',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'How do you access object properties?',
              options: [
                'obj.property or obj["property"]',
                'obj->property',
                'obj(property)',
                'obj::property',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Use dot notation or bracket notation to access properties.',
            ),
            QuizQuestion(
              question: 'What is "this" in an object method?',
              options: [
                'The global object',
                'Undefined',
                'The object itself',
                'The window',
              ],
              correctAnswerIndex: 2,
              explanation: '"this" refers to the object the method belongs to.',
            ),
            QuizQuestion(
              question: 'What is object destructuring?',
              options: [
                'Deleting object properties',
                'Extracting properties into variables',
                'Merging two objects',
                'Copying an object',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Destructuring extracts properties: const {name, age} = person assigns person.name to name and person.age to age.',
            ),
            QuizQuestion(
              question: 'What does Object.keys(obj) return?',
              options: [
                'An array of values',
                'An array of property names',
                'The number of properties',
                'A string of all keys',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Object.keys() returns an array of an object\'s property names (keys). Object.values() returns the values.',
            ),
            QuizQuestion(
              question: 'How do you create a shallow copy of an object?',
              options: [
                'obj.copy()',
                '{...obj}',
                'obj.clone()',
                'Object.copy(obj)',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The spread operator {...obj} creates a shallow copy. Alternatively, use Object.assign({}, obj).',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Product',
          description:
              'Create an object "product" with name, price, and inStock properties. Log the name.',
          starterCode: '// Create product object\nconst product = {};\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Laptop')],
          hint: 'Use {key: value} syntax.',
          solution:
              'const product = {\n  name: "Laptop",\n  price: 999,\n  inStock: true\n};\nconsole.log(product.name);',
        ),
        xpReward: 35,
        order: 7,
      ),

      // Lesson 9: Functions
      Lesson(
        id: 'js_lesson_9',
        courseId: 'javascript',
        moduleId: 'functions',
        title: 'Functions in JavaScript',
        description: 'Master function declarations, expressions, and arrows',
        theorySlides: [
          TheorySlide(
            title: 'Function Basics 📦',
            content:
                'Functions are reusable blocks of code. JavaScript has multiple ways to define them.',
            codeSnippet:
                '// Function declaration\nfunction greet(name) {\n  return "Hello, " + name + "!";\n}\n\nconsole.log(greet("Alice"));\n// Hello, Alice!',
            codeLanguage: 'javascript',
            order: 0,
          ),
          TheorySlide(
            title: 'Arrow Functions',
            content: 'Modern, concise syntax for functions.',
            codeSnippet:
                '// Traditional\nconst add = function(a, b) {\n  return a + b;\n};\n\n// Arrow function\nconst add = (a, b) => a + b;\n\n// Multiple lines\nconst greet = name => {\n  const message = "Hello, " + name;\n  return message;\n};',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Default Parameters',
            content: 'Provide default values for parameters.',
            codeSnippet:
                'const greet = (name = "Guest") => {\n  console.log("Welcome, " + name + "!");\n};\n\ngreet();          // Welcome, Guest!\ngreet("Alice");   // Welcome, Alice!',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Higher-Order Functions',
            content: 'Functions that take or return other functions.',
            codeSnippet:
                'const numbers = [1, 2, 3, 4, 5];\n\n// map: transform each element\nconst doubled = numbers.map(n => n * 2);\n\n// filter: keep elements that match\nconst evens = numbers.filter(n => n % 2 === 0);\n\nconsole.log(doubled);  // [2,4,6,8,10]\nconsole.log(evens);    // [2,4]',
            codeLanguage: 'javascript',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is the syntax for arrow functions?',
              options: [
                'function => {}',
                '() => {}',
                'arrow function()',
                '=> function()',
              ],
              correctAnswerIndex: 1,
              explanation: 'Arrow functions use () => {} syntax.',
            ),
            QuizQuestion(
              question: 'What does the map() method do?',
              options: [
                'Filters an array',
                'Transforms each element',
                'Sorts an array',
                'Reverses an array',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'map() creates a new array by transforming each element.',
            ),
            QuizQuestion(
              question: 'What is a closure in JavaScript?',
              options: [
                'A way to close a function',
                'A function with access to its outer scope',
                'A closed loop',
                'An error type',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A closure is when a function "remembers" variables from its outer scope, even after that scope has finished executing!',
            ),
            QuizQuestion(
              question:
                  'What is the difference between function declarations and arrow functions regarding "this"?',
              options: [
                'No difference',
                'Arrow functions don\'t have their own "this"',
                'Arrow functions create a new "this"',
                'Function declarations can\'t use "this"',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Arrow functions inherit "this" from their surrounding scope (lexical this). Regular functions create their own "this" context.',
            ),
            QuizQuestion(
              question: 'What does the reduce() method do?',
              options: [
                'Removes elements from an array',
                'Reduces array to a single value',
                'Filters array elements',
                'Makes array smaller',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'reduce() executes a reducer function on each element, resulting in a single output value. Example: sum all numbers.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Square Numbers',
          description:
              'Create an arrow function that takes a number and returns its square. Test with 8.',
          starterCode:
              '// Create square function\nconst square = \n\nconsole.log(square(8));',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: '64')],
          hint: 'Use (n) => n * n syntax.',
          solution: 'const square = (n) => n * n;\nconsole.log(square(8));',
        ),
        xpReward: 40,
        order: 8,
      ),

      // Lesson 10: Async JavaScript
      Lesson(
        id: 'js_lesson_10',
        courseId: 'javascript',
        moduleId: 'advanced',
        title: 'Asynchronous JavaScript',
        description: 'Handle timing, promises, and async operations',
        theorySlides: [
          TheorySlide(
            title: 'What is Async? ⏱️',
            content:
                'Asynchronous code doesn\'t wait for operations to complete. It continues running and handles results later.\n\nCommon async operations:\n• Network requests\n• File reading\n• Database queries\n• Timers',
            order: 0,
          ),
          TheorySlide(
            title: 'Callbacks',
            content: 'The original way to handle async operations.',
            codeSnippet:
                'setTimeout(() => {\n  console.log("After 2 seconds");\n}, 2000);\n\nconsole.log("Immediately");\n\n// Output:\n// Immediately\n// After 2 seconds',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Promises',
            content:
                'Modern way to handle async operations. A promise represents a future value.',
            codeSnippet:
                'const promise = new Promise((resolve, reject) => {\n  setTimeout(() => {\n    resolve("Success!");\n  }, 1000);\n});\n\npromise.then(result => {\n  console.log(result);  // Success!\n});',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Async/Await',
            content:
                'The cleanest syntax for async code. Makes it read like synchronous code.',
            codeSnippet:
                'async function getData() {\n  try {\n    const result = await fetchData();\n    console.log(result);\n  } catch (error) {\n    console.error(error);\n  }\n}\n\ngetData();',
            codeLanguage: 'javascript',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does setTimeout() do?',
              options: [
                'Stops time',
                'Delays execution',
                'Measures time',
                'Loops forever',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'setTimeout() delays code execution by a specified time.',
            ),
            QuizQuestion(
              question: 'What keyword makes a function async?',
              options: ['async', 'await', 'promise', 'defer'],
              correctAnswerIndex: 0,
              explanation: 'The async keyword makes a function asynchronous.',
            ),
            QuizQuestion(
              question: 'What does await do?',
              options: [
                'Stops the entire program',
                'Pauses execution until promise resolves',
                'Creates a new promise',
                'Cancels a promise',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'await pauses async function execution until the promise resolves, making async code look synchronous. Only works inside async functions!',
            ),
            QuizQuestion(
              question: 'What are the three states of a Promise?',
              options: [
                'start, middle, end',
                'pending, fulfilled, rejected',
                'waiting, done, error',
                'new, active, complete',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A Promise can be pending (initial), fulfilled (successful), or rejected (failed). Use .then() for fulfilled and .catch() for rejected.',
            ),
            QuizQuestion(
              question: 'What is Promise.all() used for?',
              options: [
                'Running promises one at a time',
                'Running multiple promises in parallel',
                'Canceling all promises',
                'Creating new promises',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Promise.all() runs multiple promises concurrently and resolves when ALL complete (or rejects if ANY fails). Great for parallel operations!',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Delayed Message',
          description:
              'Use setTimeout to log "Hello from the future!" after 0 milliseconds.',
          starterCode: '// Use setTimeout\n',
          language: 'javascript',
          testCases: [
            TestCase(input: '', expectedOutput: 'Hello from the future!'),
          ],
          hint: 'setTimeout takes a callback and delay in ms.',
          solution:
              'setTimeout(() => {\n  console.log("Hello from the future!");\n}, 0);',
        ),
        xpReward: 45,
        order: 9,
      ),
    ];
  }

  static List<Lesson> getHTMLCSSLessons() {
    return [
      // Lesson 1: Introduction to HTML
      Lesson(
        id: 'html_lesson_1',
        courseId: 'html_css',
        moduleId: 'basics',
        title: 'Welcome to HTML',
        description: 'Learn the building blocks of every website',
        theorySlides: [
          TheorySlide(
            title: 'What is HTML? 🏗️',
            content:
                'HTML (HyperText Markup Language) is the skeleton of every website. It defines the structure and content of web pages.\n\nHTML uses "tags" to mark up content:\n• <p> for paragraphs\n• <h1> for headings\n• <img> for images\n• <a> for links',
            order: 0,
          ),
          TheorySlide(
            title: 'HTML Structure',
            content: 'Every HTML document has a basic structure:',
            codeSnippet:
                '<!DOCTYPE html>\n<html>\n  <head>\n    <title>My Page</title>\n  </head>\n  <body>\n    <h1>Hello World!</h1>\n    <p>Welcome to my website.</p>\n  </body>\n</html>',
            codeLanguage: 'html',
            order: 1,
          ),
          TheorySlide(
            title: 'Tags and Elements',
            content:
                'Most HTML tags come in pairs:\n\n<tagname>content</tagname>\n\n• Opening tag: <p>\n• Content: Hello\n• Closing tag: </p>\n\nSome tags are self-closing: <img />, <br />, <hr />',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does HTML stand for?',
              options: [
                'HyperText Markup Language',
                'High Tech Modern Language',
                'Home Tool Markup Language',
                'Hyperlink Text Making Language',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'HTML = HyperText Markup Language, the standard for web pages.',
            ),
            QuizQuestion(
              question: 'Which tag creates a paragraph?',
              options: ['<paragraph>', '<text>', '<p>', '<para>'],
              correctAnswerIndex: 2,
              explanation: '<p> is the paragraph tag in HTML.',
            ),
            QuizQuestion(
              question:
                  'What is the purpose of the <!DOCTYPE html> declaration?',
              options: [
                'It makes the page colorful',
                'It tells the browser this is an HTML5 document',
                'It creates a title',
                'It is optional and does nothing',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The <!DOCTYPE html> declaration tells the browser to render the page in HTML5 standards mode.',
            ),
            QuizQuestion(
              question: 'Which section contains metadata like the page title?',
              options: ['<body>', '<head>', '<meta>', '<title>'],
              correctAnswerIndex: 1,
              explanation:
                  'The <head> section contains metadata including the <title>, <meta> tags, and links to stylesheets.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Heading',
          description: 'Write an h1 heading that says "Hello, World!"',
          starterCode: '<!-- Write your HTML below -->\n',
          language: 'html',
          testCases: [TestCase(input: '', expectedOutput: 'Hello, World!')],
          hint: 'Use <h1>Your text here</h1>',
          solution: '<h1>Hello, World!</h1>',
        ),
        xpReward: 15,
        order: 0,
      ),

      // Lesson 2: Text Elements
      Lesson(
        id: 'html_lesson_2',
        courseId: 'html_css',
        moduleId: 'basics',
        title: 'Text Elements',
        description: 'Learn to format text with HTML',
        theorySlides: [
          TheorySlide(
            title: 'Headings 📰',
            content:
                'HTML has 6 heading levels, from h1 (largest) to h6 (smallest):\n\n<h1> - Main heading\n<h2> - Section heading\n<h3> - Subsection\n<h4>, <h5>, <h6> - Smaller headings\n\nUse headings to organize your content logically!',
            order: 0,
          ),
          TheorySlide(
            title: 'Text Formatting',
            content: 'Format your text with these tags:',
            codeSnippet:
                '<p>This is a paragraph.</p>\n<strong>Bold text</strong>\n<em>Italic text</em>\n<u>Underlined text</u>\n<mark>Highlighted text</mark>\n<del>Deleted text</del>',
            codeLanguage: 'html',
            order: 1,
          ),
          TheorySlide(
            title: 'Line Breaks & Dividers',
            content:
                'Control spacing with:\n\n<br> - Line break (new line)\n<hr> - Horizontal rule (divider line)\n\nThese are self-closing tags - no closing tag needed!',
            codeSnippet:
                '<p>First line<br>Second line</p>\n<hr>\n<p>After the line</p>',
            codeLanguage: 'html',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which is the largest heading?',
              options: ['<h6>', '<h1>', '<h3>', '<heading>'],
              correctAnswerIndex: 1,
              explanation: '<h1> is the largest heading, <h6> is the smallest.',
            ),
            QuizQuestion(
              question: 'How do you make text bold?',
              options: ['<bold>', '<b> or <strong>', '<fat>', '<heavy>'],
              correctAnswerIndex: 1,
              explanation:
                  '<strong> (semantic) or <b> (visual) make text bold.',
            ),
            QuizQuestion(
              question: 'What is the difference between <strong> and <b>?',
              options: [
                'No difference at all',
                '<strong> has semantic importance, <b> is just visual',
                '<strong> is bigger',
                '<b> is deprecated',
              ],
              correctAnswerIndex: 1,
              explanation:
                  '<strong> indicates semantic importance (for screen readers), while <b> is purely visual formatting.',
            ),
            QuizQuestion(
              question: 'Which tag creates a line break?',
              options: ['<break>', '<lb>', '<br>', '<newline>'],
              correctAnswerIndex: 2,
              explanation:
                  '<br> creates a line break without starting a new paragraph.',
            ),
            QuizQuestion(
              question: 'Why should you use semantic HTML elements?',
              options: [
                'They make pages load faster',
                'They improve accessibility and SEO',
                'They add automatic styling',
                'They are required by all browsers',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Semantic HTML improves accessibility for screen readers and helps search engines understand your content structure.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Format Some Text',
          description: 'Create a paragraph with the word "important" in bold.',
          starterCode: '<!-- Create a paragraph with bold text -->\n',
          language: 'html',
          testCases: [TestCase(input: '', expectedOutput: 'important')],
          hint: 'Use <p> for paragraph and <strong> for bold.',
          solution: '<p>This is <strong>important</strong> information.</p>',
        ),
        xpReward: 20,
        order: 1,
      ),

      // Lesson 3: Links and Images
      Lesson(
        id: 'html_lesson_3',
        courseId: 'html_css',
        moduleId: 'basics',
        title: 'Links and Images',
        description: 'Add links and images to your pages',
        theorySlides: [
          TheorySlide(
            title: 'Creating Links 🔗',
            content:
                'The <a> tag creates hyperlinks. The href attribute specifies the destination:',
            codeSnippet:
                '<a href="https://google.com">Visit Google</a>\n\n<!-- Open in new tab -->\n<a href="https://google.com" target="_blank">\n  Open in new tab\n</a>',
            codeLanguage: 'html',
            order: 0,
          ),
          TheorySlide(
            title: 'Adding Images 🖼️',
            content: 'The <img> tag displays images. It\'s self-closing!',
            codeSnippet:
                '<img src="photo.jpg" alt="A beautiful photo">\n\n<!-- With size -->\n<img src="logo.png" alt="Logo" width="200" height="100">',
            codeLanguage: 'html',
            order: 1,
          ),
          TheorySlide(
            title: 'Image as Link',
            content:
                'You can make an image clickable by wrapping it in a link:',
            codeSnippet:
                '<a href="https://example.com">\n  <img src="banner.jpg" alt="Click me!">\n</a>',
            codeLanguage: 'html',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What attribute specifies link destination?',
              options: ['src', 'href', 'link', 'url'],
              correctAnswerIndex: 1,
              explanation:
                  'href (hypertext reference) specifies where the link goes.',
            ),
            QuizQuestion(
              question: 'What does the alt attribute do?',
              options: [
                'Changes image size',
                'Provides alternative text for accessibility',
                'Makes image alternate colors',
                'Nothing important',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'alt provides text description for screen readers and when image fails to load.',
            ),
            QuizQuestion(
              question: 'How do you open a link in a new tab?',
              options: [
                'target="_blank"',
                'newtab="true"',
                'window="new"',
                'open="tab"',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'The target="_blank" attribute opens links in a new browser tab or window.',
            ),
            QuizQuestion(
              question: 'What is the correct format for an absolute URL?',
              options: [
                'page.html',
                '../folder/page.html',
                'https://example.com/page.html',
                '/page.html',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'An absolute URL includes the full protocol (https://) and domain name.',
            ),
            QuizQuestion(
              question: 'Why is the alt attribute important for images?',
              options: [
                'It makes images load faster',
                'It improves accessibility and SEO',
                'It changes image quality',
                'It is not important',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The alt attribute helps visually impaired users and search engines understand image content.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Link',
          description:
              'Create a link to https://flutter.dev with text "Flutter"',
          starterCode: '<!-- Create your link here -->\n',
          language: 'html',
          testCases: [TestCase(input: '', expectedOutput: 'Flutter')],
          hint: 'Use <a href="url">text</a>',
          solution: '<a href="https://flutter.dev">Flutter</a>',
        ),
        xpReward: 20,
        order: 2,
      ),

      // Lesson 4: Introduction to CSS
      Lesson(
        id: 'css_lesson_1',
        courseId: 'html_css',
        moduleId: 'styling',
        title: 'Welcome to CSS',
        description: 'Learn to style your web pages',
        theorySlides: [
          TheorySlide(
            title: 'What is CSS? 🎨',
            content:
                'CSS (Cascading Style Sheets) controls how HTML elements look.\n\nIf HTML is the skeleton, CSS is the skin, clothes, and makeup!\n\nWith CSS you control:\n• Colors\n• Fonts\n• Spacing\n• Layout\n• Animations',
            order: 0,
          ),
          TheorySlide(
            title: 'CSS Syntax',
            content: 'CSS rules have a selector and declarations:',
            codeSnippet:
                'selector {\n  property: value;\n  property: value;\n}\n\n/* Example */\nh1 {\n  color: blue;\n  font-size: 24px;\n}',
            codeLanguage: 'css',
            order: 1,
          ),
          TheorySlide(
            title: 'Adding CSS',
            content:
                'Three ways to add CSS:\n\n1. Inline: <p style="color: red;">\n2. Internal: <style> in <head>\n3. External: separate .css file (best!)',
            codeSnippet:
                '<!-- Internal CSS -->\n<head>\n  <style>\n    p { color: blue; }\n  </style>\n</head>',
            codeLanguage: 'html',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does CSS stand for?',
              options: [
                'Cascading Style Sheets',
                'Creative Style System',
                'Computer Style Sheets',
                'Colorful Style Sheets',
              ],
              correctAnswerIndex: 0,
              explanation: 'CSS = Cascading Style Sheets.',
            ),
            QuizQuestion(
              question: 'Which is the best way to add CSS?',
              options: ['Inline', 'Internal', 'External file', 'All are equal'],
              correctAnswerIndex: 2,
              explanation:
                  'External CSS files are best for maintainability and reusability.',
            ),
            QuizQuestion(
              question: 'What is CSS specificity?',
              options: [
                'How fast CSS loads',
                'The priority system for conflicting styles',
                'The size of CSS files',
                'How specific a color is',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'CSS specificity determines which style rules apply when multiple rules target the same element. Inline > ID > Class > Element.',
            ),
            QuizQuestion(
              question: 'Which CSS selector has the highest specificity?',
              options: [
                'Element selector (p)',
                'Class selector (.box)',
                'ID selector (#header)',
                'Inline style',
              ],
              correctAnswerIndex: 3,
              explanation:
                  'Inline styles have the highest specificity, followed by IDs, classes, and element selectors.',
            ),
            QuizQuestion(
              question: 'What does the "Cascading" in CSS mean?',
              options: [
                'Styles flow like a waterfall',
                'Multiple stylesheets can be combined',
                'Styles cascade from parent to child elements',
                'All of the above',
              ],
              correctAnswerIndex: 3,
              explanation:
                  'Cascading refers to how styles from multiple sources combine, inherit from parent to child, and override each other based on specificity.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Color a Heading',
          description: 'Write CSS to make h1 elements red.',
          starterCode: '/* Write your CSS rule */\n',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: 'red')],
          hint: 'Use h1 { color: red; }',
          solution: 'h1 {\n  color: red;\n}',
        ),
        xpReward: 25,
        order: 3,
      ),

      // Lesson 5: CSS Colors and Backgrounds
      Lesson(
        id: 'css_lesson_2',
        courseId: 'html_css',
        moduleId: 'styling',
        title: 'Colors and Backgrounds',
        description: 'Master colors in CSS',
        theorySlides: [
          TheorySlide(
            title: 'Color Values 🌈',
            content:
                'CSS supports many color formats:\n\n• Named: red, blue, green\n• Hex: #FF0000, #00FF00\n• RGB: rgb(255, 0, 0)\n• RGBA: rgba(255, 0, 0, 0.5)\n• HSL: hsl(0, 100%, 50%)',
            order: 0,
          ),
          TheorySlide(
            title: 'Text and Background Colors',
            content: 'Two main color properties:',
            codeSnippet:
                '.card {\n  color: #333;           /* text color */\n  background-color: #f0f0f0; /* bg color */\n}\n\n.button {\n  color: white;\n  background-color: #007bff;\n}',
            codeLanguage: 'css',
            order: 1,
          ),
          TheorySlide(
            title: 'Gradients',
            content: 'Create beautiful gradients:',
            codeSnippet:
                '.gradient-box {\n  background: linear-gradient(\n    to right,\n    #ff6b6b,\n    #4ecdc4\n  );\n}\n\n.radial {\n  background: radial-gradient(\n    circle,\n    white,\n    blue\n  );\n}',
            codeLanguage: 'css',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is #FF0000?',
              options: ['Green', 'Blue', 'Red', 'Yellow'],
              correctAnswerIndex: 2,
              explanation: '#FF0000 is red (full red, no green, no blue).',
            ),
            QuizQuestion(
              question: 'What does rgba(0,0,0,0.5) create?',
              options: [
                'Solid black',
                'Semi-transparent black',
                'White',
                'Transparent',
              ],
              correctAnswerIndex: 1,
              explanation: 'The 0.5 alpha value makes it 50% transparent.',
            ),
            QuizQuestion(
              question: 'What is the difference between RGB and HSL?',
              options: [
                'No difference',
                'RGB uses red/green/blue, HSL uses hue/saturation/lightness',
                'HSL is faster',
                'RGB is deprecated',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'RGB defines colors by mixing red, green, and blue values. HSL uses hue (color), saturation (intensity), and lightness, which is often more intuitive.',
            ),
            QuizQuestion(
              question:
                  'How do you create a linear gradient from top to bottom?',
              options: [
                'background: gradient(top, blue, red);',
                'background: linear-gradient(blue, red);',
                'gradient: linear(blue, red);',
                'background-gradient: top-bottom;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'linear-gradient() creates gradients. Without a direction, it defaults to top-to-bottom.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Style a Box',
          description:
              'Create CSS for .box with white text and blue background.',
          starterCode: '/* Style the box class */\n',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: 'blue')],
          hint: 'Use .box { color: white; background-color: blue; }',
          solution: '.box {\n  color: white;\n  background-color: blue;\n}',
        ),
        xpReward: 30,
        order: 4,
      ),

      // Lesson 6: CSS Box Model
      Lesson(
        id: 'html_lesson_6',
        courseId: 'html-css',
        moduleId: 'css-layout',
        title: 'CSS Box Model',
        description: 'Understand margins, padding, and borders',
        theorySlides: [
          TheorySlide(
            title: 'The Box Model 📦',
            content:
                'Every HTML element is a box! The box model consists of:\n\n• Content - The actual text/image\n• Padding - Space around content\n• Border - Line around padding\n• Margin - Space outside border',
            order: 0,
          ),
          TheorySlide(
            title: 'Padding',
            content:
                'Padding creates space inside the element, between content and border.',
            codeSnippet:
                '.box {\n  padding: 20px;              /* all sides */\n  padding: 10px 20px;         /* top/bottom, left/right */\n  padding: 10px 20px 15px 5px; /* top, right, bottom, left */\n  padding-top: 10px;          /* specific side */\n}',
            codeLanguage: 'css',
            order: 1,
          ),
          TheorySlide(
            title: 'Margin',
            content:
                'Margin creates space outside the element, separating it from other elements.',
            codeSnippet:
                '.box {\n  margin: 20px;              /* all sides */\n  margin: 10px auto;         /* center horizontally */\n  margin-bottom: 30px;       /* specific side */\n  margin: 0;                 /* remove default margins */\n}',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Border',
            content: 'Borders wrap around padding and content.',
            codeSnippet:
                '.box {\n  border: 2px solid black;      /* shorthand */\n  border-width: 2px;\n  border-style: solid;          /* solid, dashed, dotted */\n  border-color: #333;\n  border-radius: 10px;          /* rounded corners */\n}',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does padding affect?',
              options: [
                'Space outside element',
                'Space inside element',
                'Border width',
                'Font size',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Padding creates space inside the element, between content and border.',
            ),
            QuizQuestion(
              question:
                  'How do you center an element horizontally with margin?',
              options: [
                'margin: center;',
                'margin: 0 auto;',
                'margin: auto 0;',
                'margin: middle;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'margin: 0 auto; sets top/bottom to 0 and left/right to auto, centering the element.',
            ),
            QuizQuestion(
              question: 'What is the default box-sizing value?',
              options: [
                'box-sizing: border-box;',
                'box-sizing: content-box;',
                'box-sizing: padding-box;',
                'box-sizing: auto;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'By default, box-sizing is content-box, where width/height only apply to content. border-box includes padding and border in the dimensions.',
            ),
            QuizQuestion(
              question: 'What happens when you set box-sizing: border-box?',
              options: [
                'Removes all borders',
                'Padding and border are included in the element\'s width/height',
                'Makes the box bigger',
                'Changes the border style',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'border-box makes width/height include padding and border, making sizing more predictable.',
            ),
            QuizQuestion(
              question: 'What is margin collapse?',
              options: [
                'When margins get smaller',
                'When vertical margins between elements combine into one',
                'When margins disappear',
                'A CSS error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Margin collapse occurs when vertical margins of adjacent elements overlap, and the larger margin wins.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Style a Card',
          description:
              'Create a CSS class called "card" with 20px padding, 10px margin, and a 1px solid gray border.',
          starterCode: '/* Style your card */\n.card {\n  \n}',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: 'padding')],
          hint: 'Use padding, margin, and border properties.',
          solution:
              '.card {\n  padding: 20px;\n  margin: 10px;\n  border: 1px solid gray;\n}',
        ),
        xpReward: 30,
        order: 5,
      ),

      // Lesson 7: Flexbox
      Lesson(
        id: 'html_lesson_7',
        courseId: 'html-css',
        moduleId: 'css-layout',
        title: 'Flexbox Layout',
        description: 'Create flexible layouts with CSS Flexbox',
        theorySlides: [
          TheorySlide(
            title: 'What is Flexbox? 🎯',
            content:
                'Flexbox is a powerful layout system that makes it easy to:\n\n• Align items horizontally or vertically\n• Distribute space between items\n• Create responsive layouts\n• Center content perfectly',
            order: 0,
          ),
          TheorySlide(
            title: 'Flex Container',
            content:
                'Enable flexbox by setting display: flex on the parent container.',
            codeSnippet:
                '.container {\n  display: flex;\n  flex-direction: row;     /* row, column */\n  justify-content: center; /* horizontal align */\n  align-items: center;     /* vertical align */\n}',
            codeLanguage: 'css',
            order: 1,
          ),
          TheorySlide(
            title: 'justify-content',
            content:
                'Controls alignment along the main axis (horizontal by default).',
            codeSnippet:
                '.container {\n  display: flex;\n  justify-content: flex-start;    /* start */\n  justify-content: flex-end;      /* end */\n  justify-content: center;        /* center */\n  justify-content: space-between; /* spread */\n  justify-content: space-around;  /* equal space */\n}',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Flex Items',
            content: 'Control how individual items grow, shrink, or align.',
            codeSnippet:
                '.item {\n  flex: 1;           /* grow to fill space */\n  flex-grow: 1;      /* growth factor */\n  flex-shrink: 0;    /* dont shrink */\n  align-self: center; /* override container align */\n}',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'How do you enable Flexbox?',
              options: [
                'flex: true;',
                'display: flex;',
                'layout: flex;',
                'flexbox: on;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Set display: flex on the container element to enable Flexbox.',
            ),
            QuizQuestion(
              question:
                  'Which property centers items horizontally in a flex row?',
              options: [
                'align-items: center',
                'justify-content: center',
                'text-align: center',
                'vertical-align: middle',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'justify-content controls alignment along the main axis (horizontal in row direction).',
            ),
            QuizQuestion(
              question: 'What does flex-direction: column do?',
              options: [
                'Creates multiple columns',
                'Makes items stack vertically',
                'Centers items',
                'Makes items grow',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'flex-direction: column changes the main axis to vertical, making items stack from top to bottom.',
            ),
            QuizQuestion(
              question: 'What does flex: 1 do to a flex item?',
              options: [
                'Makes it 1 pixel wide',
                'Makes it grow to fill available space',
                'Makes it disappear',
                'Makes it the first item',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'flex: 1 makes the item grow to fill available space, with a flex-grow factor of 1.',
            ),
            QuizQuestion(
              question: 'When would you use flex-wrap: wrap?',
              options: [
                'To wrap text inside items',
                'To allow items to wrap to next line when container is too small',
                'To remove gaps between items',
                'To center items',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'flex-wrap: wrap allows flex items to wrap to multiple lines instead of shrinking or overflowing.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Center Everything',
          description:
              'Create a flex container that centers its children both horizontally and vertically.',
          starterCode: '.center-box {\n  display: flex;\n  \n}',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: 'justify-content')],
          hint: 'Use justify-content and align-items both set to center.',
          solution:
              '.center-box {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n}',
        ),
        xpReward: 35,
        order: 6,
      ),

      // Lesson 8: CSS Grid
      Lesson(
        id: 'html_lesson_8',
        courseId: 'html-css',
        moduleId: 'css-layout',
        title: 'CSS Grid Basics',
        description: 'Build two-dimensional layouts with CSS Grid',
        theorySlides: [
          TheorySlide(
            title: 'What is CSS Grid? 📐',
            content:
                'CSS Grid is perfect for 2D layouts with rows AND columns.\n\nUse cases:\n• Page layouts\n• Image galleries\n• Card grids\n• Dashboard layouts',
            order: 0,
          ),
          TheorySlide(
            title: 'Grid Container',
            content: 'Enable grid and define columns and rows.',
            codeSnippet:
                '.grid {\n  display: grid;\n  grid-template-columns: 1fr 1fr 1fr; /* 3 equal cols */\n  grid-template-rows: 100px 200px;    /* 2 rows */\n  gap: 20px;                          /* spacing */\n}',
            codeLanguage: 'css',
            order: 1,
          ),
          TheorySlide(
            title: 'Grid Units',
            content: 'Different ways to size grid tracks.',
            codeSnippet:
                '.grid {\n  /* Fixed pixels */\n  grid-template-columns: 200px 200px;\n  \n  /* Fractional units (proportional) */\n  grid-template-columns: 1fr 2fr;  /* 1:2 ratio */\n  \n  /* Repeat function */\n  grid-template-columns: repeat(3, 1fr);\n}',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Placing Items',
            content: 'Control where items appear in the grid.',
            codeSnippet:
                '.item {\n  grid-column: 1 / 3;  /* span cols 1-2 */\n  grid-row: 1 / 2;     /* row 1 only */\n  \n  /* Shorthand */\n  grid-area: 1 / 1 / 2 / 3;\n}',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does "1fr" mean in CSS Grid?',
              options: [
                '1 pixel',
                '1 percent',
                '1 fraction of available space',
                '1 row',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'fr is a fractional unit that divides available space proportionally.',
            ),
            QuizQuestion(
              question: 'How do you create 4 equal columns?',
              options: [
                'grid-columns: 4',
                'grid-template-columns: repeat(4, 1fr)',
                'columns: 4',
                'grid: 4-col',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'repeat(4, 1fr) creates 4 columns, each taking 1 fraction of space.',
            ),
            QuizQuestion(
              question: 'What is the purpose of the gap property in Grid?',
              options: [
                'Creates gaps in text',
                'Sets spacing between grid items',
                'Removes grid lines',
                'Makes items transparent',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The gap property (or grid-gap) sets spacing between rows and columns in a grid layout.',
            ),
            QuizQuestion(
              question: 'What does grid-column: 1 / 3 mean?',
              options: [
                'Create 1 to 3 columns',
                'Item spans from column line 1 to 3',
                'Item is in column 1 or 3',
                'Divide column by 3',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'grid-column: 1 / 3 makes the item span from grid line 1 to line 3, covering 2 columns.',
            ),
            QuizQuestion(
              question: 'When should you use Grid instead of Flexbox?',
              options: [
                'Grid is always better',
                'For complex 2D layouts with rows AND columns',
                'For simple one-dimensional layouts',
                'They are identical',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Use Grid for 2D layouts where you need control over both rows and columns. Use Flexbox for simpler 1D layouts.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Grid',
          description:
              'Create a grid with 3 equal columns and 20px gap between items.',
          starterCode: '.gallery {\n  display: grid;\n  \n}',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: 'repeat')],
          hint: 'Use grid-template-columns with repeat() and gap.',
          solution:
              '.gallery {\n  display: grid;\n  grid-template-columns: repeat(3, 1fr);\n  gap: 20px;\n}',
        ),
        xpReward: 35,
        order: 7,
      ),

      // Lesson 9: Responsive Design
      Lesson(
        id: 'html_lesson_9',
        courseId: 'html-css',
        moduleId: 'responsive',
        title: 'Responsive Design',
        description: 'Make your websites work on all screen sizes',
        theorySlides: [
          TheorySlide(
            title: 'Why Responsive? 📱',
            content:
                'Users browse on many devices:\n\n• Desktop computers (1920px+)\n• Laptops (1024-1920px)\n• Tablets (768-1024px)\n• Phones (320-768px)\n\nYour design must adapt to all of them!',
            order: 0,
          ),
          TheorySlide(
            title: 'Viewport Meta Tag',
            content: 'Essential for mobile browsers to render correctly.',
            codeSnippet:
                '<!-- In your HTML <head> -->\n<meta name="viewport" \n      content="width=device-width, initial-scale=1.0">',
            codeLanguage: 'html',
            order: 1,
          ),
          TheorySlide(
            title: 'Media Queries',
            content: 'Apply different styles based on screen size.',
            codeSnippet:
                '/* Default styles for mobile */\n.container {\n  width: 100%;\n}\n\n/* Styles for tablets and up */\n@media (min-width: 768px) {\n  .container {\n    width: 750px;\n  }\n}\n\n/* Styles for desktop */\n@media (min-width: 1200px) {\n  .container {\n    width: 1140px;\n  }\n}',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Mobile-First Approach',
            content:
                'Start with mobile styles, then add complexity for larger screens.',
            codeSnippet:
                '/* Mobile-first: single column */\n.grid {\n  display: flex;\n  flex-direction: column;\n}\n\n/* Tablet: 2 columns */\n@media (min-width: 768px) {\n  .grid {\n    flex-direction: row;\n    flex-wrap: wrap;\n  }\n  .item { width: 50%; }\n}',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does the viewport meta tag do?',
              options: [
                'Makes text bigger',
                'Controls page width on mobile',
                'Adds animations',
                'Changes colors',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The viewport meta tag tells mobile browsers how to render the page width.',
            ),
            QuizQuestion(
              question: 'What is the mobile-first approach?',
              options: [
                'Only support mobile',
                'Design mobile last',
                'Start with mobile, add for larger screens',
                'Ignore mobile',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Mobile-first means writing base styles for mobile, then using media queries to enhance for larger screens.',
            ),
            QuizQuestion(
              question: 'What does min-width in a media query mean?',
              options: [
                'Maximum screen size',
                'Applies styles when screen is AT LEAST this wide',
                'Minimum font size',
                'Minimum margin',
              ],
              correctAnswerIndex: 1,
              explanation:
                  '@media (min-width: 768px) means "apply these styles when the viewport is 768px or wider".',
            ),
            QuizQuestion(
              question: 'What are common responsive breakpoints?',
              options: [
                '100px, 200px, 300px',
                '480px (mobile), 768px (tablet), 1024px (desktop)',
                'Only 1920px',
                'Breakpoints are not needed',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Common breakpoints target mobile (~480px), tablet (~768px), and desktop (~1024px+) devices.',
            ),
            QuizQuestion(
              question:
                  'Why use relative units (%, em, rem) instead of pixels for responsive design?',
              options: [
                'They look cooler',
                'They adapt better to different screen sizes and user preferences',
                'They load faster',
                'Pixels are deprecated',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Relative units scale proportionally and respect user accessibility settings, making designs more flexible and accessible.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Write a Media Query',
          description:
              'Write a media query that changes .box width to 500px on screens 768px or wider.',
          starterCode:
              '.box {\n  width: 100%;\n}\n\n/* Add media query below */\n',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: '@media')],
          hint: 'Use @media (min-width: 768px) { ... }',
          solution:
              '.box {\n  width: 100%;\n}\n\n@media (min-width: 768px) {\n  .box {\n    width: 500px;\n  }\n}',
        ),
        xpReward: 40,
        order: 8,
      ),

      // Lesson 10: CSS Animations
      Lesson(
        id: 'html_lesson_10',
        courseId: 'html-css',
        moduleId: 'animations',
        title: 'CSS Transitions & Animations',
        description: 'Add motion and interactivity to your designs',
        theorySlides: [
          TheorySlide(
            title: 'CSS Transitions ✨',
            content:
                'Transitions smoothly animate changes between two states.\n\nUse for:\n• Hover effects\n• Focus states\n• Color changes\n• Size changes',
            order: 0,
          ),
          TheorySlide(
            title: 'Transition Properties',
            content: 'Control what animates and how.',
            codeSnippet:
                '.button {\n  background: blue;\n  transition: background 0.3s ease;\n}\n\n.button:hover {\n  background: darkblue;\n}\n\n/* Multiple properties */\n.card {\n  transition: transform 0.3s, box-shadow 0.3s;\n}\n\n.card:hover {\n  transform: translateY(-5px);\n  box-shadow: 0 10px 20px rgba(0,0,0,0.2);\n}',
            codeLanguage: 'css',
            order: 1,
          ),
          TheorySlide(
            title: 'CSS Animations',
            content: 'For more complex, multi-step animations, use @keyframes.',
            codeSnippet:
                '@keyframes pulse {\n  0% {\n    transform: scale(1);\n  }\n  50% {\n    transform: scale(1.1);\n  }\n  100% {\n    transform: scale(1);\n  }\n}\n\n.heart {\n  animation: pulse 1s infinite;\n}',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Animation Properties',
            content: 'Fine-tune your animations.',
            codeSnippet:
                '.element {\n  animation-name: slide-in;\n  animation-duration: 0.5s;\n  animation-timing-function: ease-out;\n  animation-delay: 0.2s;\n  animation-iteration-count: 1;\n  animation-fill-mode: forwards;\n  \n  /* Shorthand */\n  animation: slide-in 0.5s ease-out 0.2s forwards;\n}',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'What is the difference between transition and animation?',
              options: [
                'No difference',
                'Transition needs 2 states, animation uses keyframes',
                'Animation is faster',
                'Transition is for colors only',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Transitions animate between two states, while animations use @keyframes for complex multi-step sequences.',
            ),
            QuizQuestion(
              question: 'What does "infinite" do in animation-iteration-count?',
              options: [
                'Run once',
                'Run twice',
                'Loop forever',
                'Stop animation',
              ],
              correctAnswerIndex: 2,
              explanation: 'infinite makes the animation repeat indefinitely.',
            ),
            QuizQuestion(
              question: 'What is the purpose of animation-timing-function?',
              options: [
                'Sets animation duration',
                'Controls the speed curve of the animation',
                'Delays the animation',
                'Names the animation',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'animation-timing-function (ease, linear, ease-in, ease-out, etc.) controls how the animation progresses over time.',
            ),
            QuizQuestion(
              question: 'When should you use transitions vs animations?',
              options: [
                'They are the same',
                'Transitions for simple 2-state changes, animations for complex sequences',
                'Always use animations',
                'Transitions are deprecated',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Use transitions for simple state changes (hover effects). Use @keyframes animations for multi-step, complex motion.',
            ),
            QuizQuestion(
              question: 'What does animation-fill-mode: forwards do?',
              options: [
                'Plays animation forward',
                'Keeps the final animation state after completion',
                'Moves element forward',
                'Increases speed',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'forwards makes the element retain the styles from the last keyframe after the animation completes.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Add a Hover Effect',
          description:
              'Make a button that smoothly changes background color on hover over 0.3 seconds.',
          starterCode:
              '.button {\n  background: #3498db;\n  color: white;\n  padding: 10px 20px;\n  /* Add transition */\n}\n\n.button:hover {\n  background: #2980b9;\n}',
          language: 'css',
          testCases: [TestCase(input: '', expectedOutput: 'transition')],
          hint: 'Add transition: background 0.3s; to .button',
          solution:
              '.button {\n  background: #3498db;\n  color: white;\n  padding: 10px 20px;\n  transition: background 0.3s;\n}\n\n.button:hover {\n  background: #2980b9;\n}',
        ),
        xpReward: 45,
        order: 9,
      ),
    ];
  }

  static List<Lesson> getReactLessons() {
    return [
      // Lesson 1: Introduction to React
      Lesson(
        id: 'react_lesson_1',
        courseId: 'react',
        moduleId: 'basics',
        title: 'Introduction to React',
        description: 'Learn what React is, JSX basics, and components',
        theorySlides: [
          TheorySlide(
            title: 'What is React? ⚛️',
            content:
                'React is a JavaScript library for building user interfaces. Created by Facebook, it lets you build complex UIs from small, reusable pieces called components.\n\nWhy React?\n• Component-based architecture\n• Virtual DOM for fast updates\n• Large ecosystem and community\n• Used by Facebook, Netflix, Instagram',
            order: 0,
          ),
          TheorySlide(
            title: 'JSX - JavaScript XML',
            content: 'JSX lets you write HTML-like code in JavaScript:',
            codeSnippet:
                'function Welcome() {\n  const name = "Sarah";\n  return (\n    <div>\n      <h1>Hello, {name}!</h1>\n      <p>Welcome to React</p>\n    </div>\n  );\n}\n\n// You can embed JavaScript expressions in curly braces {}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Your First Component',
            content:
                'Components are reusable pieces of UI. Start with a simple function:',
            codeSnippet:
                'function Button() {\n  return <button>Click me!</button>;\n}\n\n// Use it in your app\nfunction App() {\n  return (\n    <div>\n      <h1>My App</h1>\n      <Button />\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is React?',
              options: [
                'A programming language',
                'A JavaScript library for building UIs',
                'A database',
                'A CSS framework',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'React is a JavaScript library specifically designed for building user interfaces, not a full framework or language.',
            ),
            QuizQuestion(
              question: 'What does JSX stand for?',
              options: [
                'Java Syntax Extension',
                'JavaScript XML',
                'JSON Syntax',
                'Just Simple X',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'JSX stands for JavaScript XML. It allows you to write HTML-like syntax in JavaScript.',
            ),
            QuizQuestion(
              question: 'How do you embed JavaScript expressions in JSX?',
              options: [
                'Use square brackets []',
                'Use curly braces {}',
                'Use parentheses ()',
                r'Use dollar signs $$',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'In JSX, curly braces {} are used to embed JavaScript expressions, like {name} or {2 + 2}.',
            ),
            QuizQuestion(
              question: 'What is a React component?',
              options: [
                'A CSS file',
                'A reusable piece of UI',
                'A database table',
                'A web server',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A React component is a reusable piece of UI that can be combined with other components to build complex interfaces.',
            ),
            QuizQuestion(
              question: 'Which company created React?',
              options: ['Google', 'Microsoft', 'Facebook', 'Apple'],
              correctAnswerIndex: 2,
              explanation:
                  'React was created by Facebook (now Meta) and is used in many of their products.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Greeting Component',
          description:
              'Create a function component that returns an h1 element with the text "Hello, React!"',
          starterCode: 'function Greeting() {\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Hello, React!')],
          hint: 'Return JSX with an <h1> tag containing the greeting text.',
          solution:
              'function Greeting() {\n  return <h1>Hello, React!</h1>;\n}',
        ),
        xpReward: 15,
        order: 0,
      ),

      // Lesson 2: Components & Props
      Lesson(
        id: 'react_lesson_2',
        courseId: 'react',
        moduleId: 'basics',
        title: 'Components & Props',
        description: 'Master functional components, props, and composition',
        theorySlides: [
          TheorySlide(
            title: 'Understanding Props 📦',
            content:
                'Props (properties) let you pass data to components, making them reusable:\n\n• Props are read-only\n• Passed like HTML attributes\n• Accessed in function parameters\n• Can pass strings, numbers, objects, functions',
            order: 0,
          ),
          TheorySlide(
            title: 'Using Props',
            content: 'Pass data to components with props:',
            codeSnippet:
                'function Welcome(props) {\n  return <h1>Hello, {props.name}!</h1>;\n}\n\n// Destructure props for cleaner code\nfunction Welcome({ name, age }) {\n  return (\n    <div>\n      <h1>Hello, {name}!</h1>\n      <p>You are {age} years old</p>\n    </div>\n  );\n}\n\n// Usage\n<Welcome name="John" age={25} />',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Component Composition',
            content: 'Build complex UIs by combining components:',
            codeSnippet:
                'function Avatar({ src, name }) {\n  return <img src={src} alt={name} />;\n}\n\nfunction UserCard({ user }) {\n  return (\n    <div className="card">\n      <Avatar src={user.avatar} name={user.name} />\n      <h2>{user.name}</h2>\n      <p>{user.email}</p>\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What are props in React?',
              options: [
                'Properties passed to components',
                'CSS styling rules',
                'Database connections',
                'Error messages',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Props are properties passed from parent to child components to share data.',
            ),
            QuizQuestion(
              question: 'Can you modify props inside a component?',
              options: [
                'Yes, anytime',
                'No, props are read-only',
                'Only with special permission',
                'Only in class components',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Props are read-only. Components must never modify their own props - they should act like pure functions.',
            ),
            QuizQuestion(
              question: 'How do you pass a number as a prop?',
              options: [
                '<Component age="25" />',
                '<Component age={25} />',
                '<Component age=25 />',
                '<Component [age]=25 />',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Non-string values must be passed in curly braces: {25} for numbers, {true} for booleans, etc.',
            ),
            QuizQuestion(
              question: 'What is component composition?',
              options: [
                'Writing CSS for components',
                'Building complex UIs by combining simple components',
                'Compiling React code',
                'Testing components',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Component composition is the practice of building complex UIs by combining simpler, reusable components.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a User Card',
          description:
              'Create a UserCard component that accepts name and email props and displays them in a div.',
          starterCode:
              'function UserCard({ name, email }) {\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [
            TestCase(
              input: 'name="Alice",email="alice@example.com"',
              expectedOutput: 'Alice',
            ),
          ],
          hint: 'Return a div with the name and email displayed.',
          solution:
              'function UserCard({ name, email }) {\n  return (\n    <div>\n      <h2>{name}</h2>\n      <p>{email}</p>\n    </div>\n  );\n}',
        ),
        xpReward: 18,
        order: 1,
      ),

      // Lesson 3: State Management
      Lesson(
        id: 'react_lesson_3',
        courseId: 'react',
        moduleId: 'basics',
        title: 'State Management',
        description:
            'Learn useState hook, state updates, and controlled components',
        theorySlides: [
          TheorySlide(
            title: 'Understanding State 🔄',
            content:
                'State is data that changes over time. Unlike props, state is managed within the component.\n\nWhen state changes:\n• React re-renders the component\n• UI updates automatically\n• User interactions can modify state\n\nUse the useState hook to add state!',
            order: 0,
          ),
          TheorySlide(
            title: 'The useState Hook',
            content: 'useState returns current state and an updater function:',
            codeSnippet:
                'import { useState } from "react";\n\nfunction Counter() {\n  const [count, setCount] = useState(0);\n\n  return (\n    <div>\n      <p>Count: {count}</p>\n      <button onClick={() => setCount(count + 1)}>\n        Increment\n      </button>\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Controlled Components',
            content: 'Control form inputs with state:',
            codeSnippet:
                'function NameForm() {\n  const [name, setName] = useState("");\n\n  return (\n    <div>\n      <input\n        type="text"\n        value={name}\n        onChange={(e) => setName(e.target.value)}\n      />\n      <p>Hello, {name}!</p>\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is state in React?',
              options: [
                'CSS styles',
                'Data that can change over time',
                'HTML structure',
                'External API data',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'State is data managed within a component that can change over time, triggering re-renders when updated.',
            ),
            QuizQuestion(
              question: 'What does useState return?',
              options: [
                'Just the state value',
                'An array with [state, setState]',
                'An object with state properties',
                'A promise',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'useState returns an array with two elements: the current state value and a function to update it.',
            ),
            QuizQuestion(
              question: 'How do you update state?',
              options: [
                'Directly modify the state variable',
                'Use the setState function from useState',
                'Change props',
                'Reload the page',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Always use the setState function returned by useState. Never modify state directly.',
            ),
            QuizQuestion(
              question: 'What is a controlled component?',
              options: [
                'A component with many features',
                'An input whose value is controlled by React state',
                'A component that can\'t change',
                'A CSS-styled component',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A controlled component is a form input whose value is controlled by React state via value and onChange props.',
            ),
            QuizQuestion(
              question: 'What happens when state updates?',
              options: [
                'Nothing',
                'The component re-renders',
                'The page refreshes',
                'All components restart',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'When state updates, React re-renders the component to reflect the new state in the UI.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Toggle Button',
          description:
              'Create a component with a button that toggles between "ON" and "OFF" using useState.',
          starterCode:
              'import { useState } from "react";\n\nfunction Toggle() {\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'ON')],
          hint:
              'Use useState with a boolean value and toggle it on button click.',
          solution:
              'import { useState } from "react";\n\nfunction Toggle() {\n  const [isOn, setIsOn] = useState(false);\n  return (\n    <button onClick={() => setIsOn(!isOn)}>\n      {isOn ? "ON" : "OFF"}\n    </button>\n  );\n}',
        ),
        xpReward: 20,
        order: 2,
      ),

      // Lesson 4: Handling Events
      Lesson(
        id: 'react_lesson_4',
        courseId: 'react',
        moduleId: 'intermediate',
        title: 'Handling Events',
        description: 'Master onClick, onChange, and form handling',
        theorySlides: [
          TheorySlide(
            title: 'React Events 🖱️',
            content:
                'React handles events similar to HTML, but with camelCase naming:\n\n• onClick (not onclick)\n• onChange (not onchange)\n• onSubmit (not onsubmit)\n\nEvent handlers are functions, not strings!\n<button onClick={handleClick}> ✅\n<button onClick="handleClick()"> ❌',
            order: 0,
          ),
          TheorySlide(
            title: 'Event Handlers',
            content: 'Handle user interactions with event functions:',
            codeSnippet:
                'function Button() {\n  const handleClick = () => {\n    alert("Button clicked!");\n  };\n\n  // Pass parameters using arrow function\n  const handleClickWithParam = (name) => {\n    alert(`Hello, \${name}!`);\n  };\n\n  return (\n    <div>\n      <button onClick={handleClick}>Click me</button>\n      <button onClick={() => handleClickWithParam("Alice")}>\n        Greet Alice\n      </button>\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Form Handling',
            content: 'Handle form submissions in React:',
            codeSnippet:
                'function LoginForm() {\n  const [email, setEmail] = useState("");\n\n  const handleSubmit = (e) => {\n    e.preventDefault(); // Prevent page reload\n    console.log("Submitted:", email);\n  };\n\n  return (\n    <form onSubmit={handleSubmit}>\n      <input\n        type="email"\n        value={email}\n        onChange={(e) => setEmail(e.target.value)}\n      />\n      <button type="submit">Login</button>\n    </form>\n  );\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is the correct way to handle a click event?',
              options: [
                '<button onclick="handleClick">',
                '<button onClick={handleClick}>',
                '<button onClick="handleClick()">',
                '<button click={handleClick}>',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'React uses camelCase (onClick) and expects a function reference, not a string.',
            ),
            QuizQuestion(
              question: 'Why do we use e.preventDefault() in form handlers?',
              options: [
                'To make forms faster',
                'To prevent the default page reload',
                'To validate inputs',
                'To style the form',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'e.preventDefault() stops the default form submission behavior which would reload the page.',
            ),
            QuizQuestion(
              question: 'How do you pass parameters to an event handler?',
              options: [
                'onClick={handleClick(param)}',
                'onClick={() => handleClick(param)}',
                'onClick="handleClick(param)"',
                'onClick[handleClick(param)]',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Wrap the function call in an arrow function to pass parameters: onClick={() => handleClick(param)}',
            ),
            QuizQuestion(
              question: 'What does the event object "e" provide?',
              options: [
                'Only the event type',
                'Information about the event and target element',
                'CSS styles',
                'Component props',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The event object provides details about the event, including the target element, event type, and helpful methods.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Form with Submit Handler',
          description:
              'Create a form that captures a name input and logs it on submit. Use e.preventDefault().',
          starterCode:
              'import { useState } from "react";\n\nfunction NameForm() {\n  const [name, setName] = useState("");\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'form')],
          hint:
              'Create a form with onSubmit handler that prevents default and an input with onChange.',
          solution:
              'import { useState } from "react";\n\nfunction NameForm() {\n  const [name, setName] = useState("");\n  \n  const handleSubmit = (e) => {\n    e.preventDefault();\n    console.log(name);\n  };\n  \n  return (\n    <form onSubmit={handleSubmit}>\n      <input value={name} onChange={(e) => setName(e.target.value)} />\n      <button type="submit">Submit</button>\n    </form>\n  );\n}',
        ),
        xpReward: 22,
        order: 3,
      ),

      // Lesson 5: Lists & Keys
      Lesson(
        id: 'react_lesson_5',
        courseId: 'react',
        moduleId: 'intermediate',
        title: 'Lists & Keys',
        description: 'Render lists with .map() and understand unique keys',
        theorySlides: [
          TheorySlide(
            title: 'Rendering Lists 📋',
            content:
                'Use JavaScript\'s .map() to render lists of elements:\n\n• Transform array data into JSX\n• Each item needs a unique "key" prop\n• Keys help React identify which items changed\n• Keys should be stable and unique',
            order: 0,
          ),
          TheorySlide(
            title: 'Using .map() for Lists',
            content: 'Transform arrays into React elements:',
            codeSnippet:
                'function FruitList() {\n  const fruits = ["Apple", "Banana", "Orange"];\n\n  return (\n    <ul>\n      {fruits.map((fruit, index) => (\n        <li key={index}>{fruit}</li>\n      ))}\n    </ul>\n  );\n}\n\n// With objects\nfunction UserList({ users }) {\n  return (\n    <div>\n      {users.map(user => (\n        <div key={user.id}>\n          <h3>{user.name}</h3>\n          <p>{user.email}</p>\n        </div>\n      ))}\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Understanding Keys',
            content: 'Keys help React identify list items efficiently:',
            codeSnippet:
                '// ❌ Bad: Using index (can cause bugs)\nfruits.map((fruit, index) => <li key={index}>{fruit}</li>)\n\n// ✅ Good: Using unique ID\nusers.map(user => <div key={user.id}>{user.name}</div>)\n\n// ✅ Good: If no ID, use unique property\nproducts.map(product => (\n  <div key={product.sku}>{product.name}</div>\n))\n\n// Keys must be unique among siblings, not globally',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which method is used to render lists in React?',
              options: ['.forEach()', '.map()', '.filter()', '.reduce()'],
              correctAnswerIndex: 1,
              explanation:
                  '.map() transforms an array into a new array of JSX elements, making it perfect for rendering lists.',
            ),
            QuizQuestion(
              question: 'Why do list items need a key prop?',
              options: [
                'For styling',
                'To help React identify which items changed',
                'To make them clickable',
                'It\'s optional',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Keys help React identify which items have changed, been added, or removed, enabling efficient updates.',
            ),
            QuizQuestion(
              question: 'What makes a good key?',
              options: [
                'Any random number',
                'The array index',
                'A stable, unique identifier like an ID',
                'The item\'s value',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Good keys are stable and unique identifiers like database IDs, not array indices which can change.',
            ),
            QuizQuestion(
              question: 'When can you use index as a key?',
              options: [
                'Always',
                'Never',
                'Only if the list is static and won\'t reorder',
                'Only for small lists',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Index can be used as a last resort for static lists that won\'t reorder, but unique IDs are always better.',
            ),
            QuizQuestion(
              question: 'Do keys need to be globally unique?',
              options: [
                'Yes, across the entire app',
                'No, only unique among siblings',
                'Yes, across the component',
                'They don\'t need to be unique',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Keys only need to be unique among siblings (items in the same list), not globally across the app.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Render a List of Names',
          description:
              'Create a component that renders a ul with list items for each name in the array.',
          starterCode:
              'function NameList() {\n  const names = ["Alice", "Bob", "Charlie"];\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Alice')],
          hint:
              'Use .map() to transform the names array into <li> elements with keys.',
          solution:
              'function NameList() {\n  const names = ["Alice", "Bob", "Charlie"];\n  return (\n    <ul>\n      {names.map((name, index) => (\n        <li key={index}>{name}</li>\n      ))}\n    </ul>\n  );\n}',
        ),
        xpReward: 20,
        order: 4,
      ),

      // Lesson 6: Conditional Rendering
      Lesson(
        id: 'react_lesson_6',
        courseId: 'react',
        moduleId: 'intermediate',
        title: 'Conditional Rendering',
        description:
            'Learn ternary operators, && operator, and multiple conditions',
        theorySlides: [
          TheorySlide(
            title: 'Conditional Rendering 🔀',
            content:
                'Show different UI based on conditions:\n\n• Ternary operator: condition ? true : false\n• AND operator: condition && <Component />\n• If statements (outside JSX)\n• Early returns\n\nChoose the right approach for readability!',
            order: 0,
          ),
          TheorySlide(
            title: 'Ternary & AND Operators',
            content: 'Common patterns for conditional rendering:',
            codeSnippet:
                'function Greeting({ isLoggedIn, username }) {\n  // Ternary: show one thing or another\n  return (\n    <div>\n      {isLoggedIn ? (\n        <h1>Welcome back, {username}!</h1>\n      ) : (\n        <h1>Please log in</h1>\n      )}\n    </div>\n  );\n}\n\nfunction Notification({ hasMessages, count }) {\n  // AND: show something or nothing\n  return (\n    <div>\n      {hasMessages && <span>You have {count} messages</span>}\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Multiple Conditions',
            content:
                'Handle complex conditions with if statements or early returns:',
            codeSnippet:
                'function UserStatus({ user }) {\n  // Early return pattern\n  if (!user) {\n    return <p>No user found</p>;\n  }\n  \n  if (!user.isActive) {\n    return <p>Account inactive</p>;\n  }\n  \n  // Multiple conditions\n  let status;\n  if (user.isPremium) {\n    status = "Premium Member";\n  } else if (user.isVerified) {\n    status = "Verified User";\n  } else {\n    status = "Basic User";\n  }\n  \n  return <p>Status: {status}</p>;\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does the ternary operator look like?',
              options: [
                'if ? then : else',
                'condition ? true : false',
                'condition && value',
                'condition || value',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The ternary operator follows the pattern: condition ? valueIfTrue : valueIfFalse',
            ),
            QuizQuestion(
              question: 'When should you use the && operator?',
              options: [
                'To show one thing or another',
                'To show something or nothing',
                'To loop through arrays',
                'To update state',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Use && when you want to show something only if a condition is true, otherwise show nothing.',
            ),
            QuizQuestion(
              question: 'What is an early return?',
              options: [
                'Returning multiple values',
                'Returning before reaching the end of the function',
                'Returning arrays',
                'Returning promises',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Early returns exit the function before reaching the end, useful for handling edge cases first.',
            ),
            QuizQuestion(
              question: 'Can you use if statements inside JSX?',
              options: [
                'Yes, directly',
                'No, use ternary or && instead',
                'Only in class components',
                'Only with special syntax',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'If statements can\'t be used directly in JSX. Use ternary operators, &&, or define variables outside JSX.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Conditional Welcome Message',
          description:
              'Create a component that shows "Welcome!" if isLoggedIn is true, otherwise show "Please log in".',
          starterCode:
              'function WelcomeMessage({ isLoggedIn }) {\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [
            TestCase(input: 'isLoggedIn=true', expectedOutput: 'Welcome!'),
          ],
          hint:
              'Use a ternary operator: isLoggedIn ? "Welcome!" : "Please log in"',
          solution:
              'function WelcomeMessage({ isLoggedIn }) {\n  return (\n    <div>\n      {isLoggedIn ? <p>Welcome!</p> : <p>Please log in</p>}\n    </div>\n  );\n}',
        ),
        xpReward: 20,
        order: 5,
      ),

      // Lesson 7: useEffect Hook
      Lesson(
        id: 'react_lesson_7',
        courseId: 'react',
        moduleId: 'advanced',
        title: 'useEffect Hook',
        description: 'Master side effects, cleanup, and dependencies',
        theorySlides: [
          TheorySlide(
            title: 'Understanding Side Effects 🌊',
            content:
                'Side effects are operations that reach outside your component:\n\n• Fetching data from APIs\n• Setting up subscriptions\n• Manually changing the DOM\n• Setting timers\n\nuseEffect runs after render, keeping your component pure!',
            order: 0,
          ),
          TheorySlide(
            title: 'Using useEffect',
            content: 'useEffect takes a function and optional dependencies:',
            codeSnippet:
                'import { useState, useEffect } from "react";\n\nfunction Timer() {\n  const [seconds, setSeconds] = useState(0);\n\n  useEffect(() => {\n    // Runs after every render\n    const interval = setInterval(() => {\n      setSeconds(s => s + 1);\n    }, 1000);\n\n    // Cleanup function\n    return () => clearInterval(interval);\n  }, []); // Empty deps = run once\n\n  return <p>Seconds: {seconds}</p>;\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Dependency Array',
            content: 'Control when useEffect runs with the dependency array:',
            codeSnippet:
                '// Run on every render\nuseEffect(() => {\n  console.log("Every render");\n});\n\n// Run once on mount\nuseEffect(() => {\n  console.log("Component mounted");\n}, []);\n\n// Run when dependencies change\nuseEffect(() => {\n  console.log("Count changed:", count);\n}, [count]);\n\n// Multiple dependencies\nuseEffect(() => {\n  fetchUser(userId, filter);\n}, [userId, filter]);',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is a side effect in React?',
              options: [
                'A CSS animation',
                'An operation that affects something outside the component',
                'A rendering error',
                'A prop update',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Side effects are operations that interact with systems outside the component, like APIs, timers, or subscriptions.',
            ),
            QuizQuestion(
              question: 'When does useEffect run?',
              options: [
                'Before render',
                'During render',
                'After render',
                'Never automatically',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'useEffect runs after the render is committed to the screen, keeping the render phase pure.',
            ),
            QuizQuestion(
              question: 'What does an empty dependency array [] mean?',
              options: [
                'Run on every render',
                'Never run',
                'Run once when component mounts',
                'Run when any state changes',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'An empty dependency array means the effect runs once when the component mounts, like componentDidMount.',
            ),
            QuizQuestion(
              question: 'Why do we return a cleanup function?',
              options: [
                'To save memory',
                'To remove event listeners, clear timers, cancel subscriptions',
                'To update state',
                'It\'s optional and does nothing',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The cleanup function removes side effects when the component unmounts or before the effect runs again.',
            ),
            QuizQuestion(
              question: 'What happens if you forget dependencies?',
              options: [
                'Nothing',
                'Your effect might use stale values',
                'The app crashes',
                'Effects run faster',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Missing dependencies can cause your effect to use stale values. Always include values your effect depends on.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Fetch Data on Mount',
          description:
              'Create a component that logs "Data fetched" once when it mounts using useEffect.',
          starterCode:
              'import { useEffect } from "react";\n\nfunction DataFetcher() {\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'Data fetched')],
          hint:
              'Use useEffect with an empty dependency array to run once on mount.',
          solution:
              'import { useEffect } from "react";\n\nfunction DataFetcher() {\n  useEffect(() => {\n    console.log("Data fetched");\n  }, []);\n  \n  return <div>Check the console</div>;\n}',
        ),
        xpReward: 25,
        order: 6,
      ),

      // Lesson 8: Building a Project
      Lesson(
        id: 'react_lesson_8',
        courseId: 'react',
        moduleId: 'advanced',
        title: 'Building a Todo App',
        description: 'Combine all concepts into a functional todo application',
        theorySlides: [
          TheorySlide(
            title: 'Project Planning 🎯',
            content:
                'Let\'s build a todo app combining everything you\'ve learned:\n\n• State management (useState)\n• Form handling (events)\n• Lists and keys (.map)\n• Conditional rendering\n• Component composition\n\nThis is where it all comes together!',
            order: 0,
          ),
          TheorySlide(
            title: 'Todo App Structure',
            content: 'Break the app into components:',
            codeSnippet:
                'function TodoApp() {\n  const [todos, setTodos] = useState([]);\n  const [input, setInput] = useState("");\n\n  const addTodo = () => {\n    if (input.trim()) {\n      setTodos([...todos, { id: Date.now(), text: input, done: false }]);\n      setInput("");\n    }\n  };\n\n  const toggleTodo = (id) => {\n    setTodos(todos.map(todo => \n      todo.id === id ? { ...todo, done: !todo.done } : todo\n    ));\n  };\n\n  return (\n    <div>\n      <h1>My Todos</h1>\n      <input value={input} onChange={(e) => setInput(e.target.value)} />\n      <button onClick={addTodo}>Add</button>\n      {/* Todo list here */}\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Rendering Todo Items',
            content: 'Display the todo list with conditional styling:',
            codeSnippet:
                'function TodoApp() {\n  // ... previous code ...\n\n  return (\n    <div>\n      <h1>My Todos</h1>\n      <input value={input} onChange={(e) => setInput(e.target.value)} />\n      <button onClick={addTodo}>Add</button>\n      \n      <ul>\n        {todos.map(todo => (\n          <li\n            key={todo.id}\n            onClick={() => toggleTodo(todo.id)}\n            style={{ textDecoration: todo.done ? "line-through" : "none" }}\n          >\n            {todo.text}\n          </li>\n        ))}\n      </ul>\n    </div>\n  );\n}',
            codeLanguage: 'javascript',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Why should you break apps into multiple components?',
              options: [
                'To make files bigger',
                'For reusability and maintainability',
                'It\'s required by React',
                'To make it slower',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Breaking apps into components improves reusability, maintainability, and makes code easier to understand.',
            ),
            QuizQuestion(
              question: 'How do you add a new item to an array in state?',
              options: [
                'todos.push(newItem)',
                'setTodos([...todos, newItem])',
                'todos = [...todos, newItem]',
                'setTodos(todos.push(newItem))',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Use the spread operator to create a new array: setTodos([...todos, newItem]). Never mutate state directly.',
            ),
            QuizQuestion(
              question: 'What is Date.now() useful for?',
              options: [
                'Styling dates',
                'Generating unique IDs',
                'Formatting time',
                'Creating calendars',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Date.now() returns the current timestamp in milliseconds, making it useful for generating simple unique IDs.',
            ),
            QuizQuestion(
              question: 'How do you update a specific item in an array?',
              options: [
                'Change it directly',
                'Use .map() to create a new array',
                'Use .push()',
                'Delete and recreate the array',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Use .map() to iterate and conditionally update the specific item, creating a new array without mutating state.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Simple Todo App',
          description:
              'Build a basic todo app with add functionality. Display todos in a list.',
          starterCode:
              'import { useState } from "react";\n\nfunction TodoApp() {\n  const [todos, setTodos] = useState([]);\n  const [input, setInput] = useState("");\n  // Your code here\n}\n',
          language: 'javascript',
          testCases: [TestCase(input: '', expectedOutput: 'todo')],
          hint:
              'Create input, button, and list. Use state to manage todos array and input value.',
          solution:
              'import { useState } from "react";\n\nfunction TodoApp() {\n  const [todos, setTodos] = useState([]);\n  const [input, setInput] = useState("");\n  \n  const addTodo = () => {\n    if (input.trim()) {\n      setTodos([...todos, { id: Date.now(), text: input }]);\n      setInput("");\n    }\n  };\n  \n  return (\n    <div>\n      <input value={input} onChange={(e) => setInput(e.target.value)} />\n      <button onClick={addTodo}>Add</button>\n      <ul>\n        {todos.map(todo => <li key={todo.id}>{todo.text}</li>)}\n      </ul>\n    </div>\n  );\n}',
        ),
        xpReward: 25,
        order: 7,
      ),
    ];
  }

  static List<Lesson> getSQLLessons() {
    return [
      // Lesson 1: Introduction to SQL
      Lesson(
        id: 'sql_lesson_1',
        courseId: 'sql',
        moduleId: 'basics',
        title: 'Introduction to SQL',
        description: 'Discover the language that powers databases worldwide',
        theorySlides: [
          TheorySlide(
            title: 'What is SQL? 🗄️',
            content:
                'SQL (Structured Query Language) is the standard language for working with databases. It\'s used by millions of applications worldwide to store, retrieve, and manage data.\n\nSQL allows you to:\n• Store data in organized tables\n• Retrieve exactly the data you need\n• Update and delete information\n• Create complex reports and analysis',
            order: 0,
          ),
          TheorySlide(
            title: 'Understanding Databases',
            content:
                'A database is like a digital filing cabinet. It contains tables, which are like spreadsheets with rows and columns.\n\n📊 Table Example: "users"\n┌────┬──────────┬─────────────────┐\n│ id │ name     │ email           │\n├────┼──────────┼─────────────────┤\n│ 1  │ Alice    │ alice@email.com │\n│ 2  │ Bob      │ bob@email.com   │\n└────┴──────────┴─────────────────┘\n\nEach row is a record, each column is a field.',
            order: 1,
          ),
          TheorySlide(
            title: 'Your First SELECT Query',
            content:
                'The SELECT statement retrieves data from a database. It\'s the most common SQL command you\'ll use.',
            codeSnippet:
                '-- Get all data from the users table\nSELECT * FROM users;\n\n-- Get only names from the users table\nSELECT name FROM users;\n\n-- Get multiple columns\nSELECT name, email FROM users;',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does SQL stand for?',
              options: [
                'Simple Query Language',
                'Structured Query Language',
                'Standard Question Language',
                'Sequential Query Logic',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'SQL stands for Structured Query Language. It\'s the standard language for managing and querying relational databases.',
            ),
            QuizQuestion(
              question: 'What does the * symbol mean in SELECT * FROM users?',
              options: [
                'Select the first row only',
                'Select all columns',
                'Select random data',
                'Delete all data',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The asterisk (*) is a wildcard that means "all columns". SELECT * retrieves every column from the specified table.',
            ),
            QuizQuestion(
              question: 'In a database table, what is a row called?',
              options: ['A field', 'A column', 'A record', 'A query'],
              correctAnswerIndex: 2,
              explanation:
                  'Each row in a table is called a record. It represents a single entry with values for each column.',
            ),
            QuizQuestion(
              question:
                  'Which keyword is used to specify which table to query?',
              options: ['GET', 'FROM', 'TABLE', 'WHERE'],
              correctAnswerIndex: 1,
              explanation:
                  'The FROM keyword specifies which table to retrieve data from. Example: SELECT name FROM users.',
            ),
            QuizQuestion(
              question: 'What is the purpose of SQL?',
              options: [
                'Create websites',
                'Manage and query databases',
                'Design user interfaces',
                'Send emails',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'SQL is specifically designed to manage and query relational databases, allowing you to store, retrieve, update, and delete data.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Your First Query',
          description:
              'Write a SQL query to select ALL columns from the "products" table.',
          starterCode: '-- Select all columns from the products table\n',
          language: 'sql',
          testCases: [
            TestCase(input: '', expectedOutput: 'SELECT * FROM products;'),
          ],
          hint:
              'Use SELECT * to get all columns, and FROM to specify the table name.',
          solution: 'SELECT * FROM products;',
        ),
        xpReward: 15,
        order: 0,
      ),

      // Lesson 2: SELECT Basics
      Lesson(
        id: 'sql_lesson_2',
        courseId: 'sql',
        moduleId: 'basics',
        title: 'SELECT Basics',
        description: 'Master the fundamentals of querying data',
        theorySlides: [
          TheorySlide(
            title: 'Selecting Specific Columns 📋',
            content:
                'Instead of selecting everything with *, you can choose exactly which columns you need. This is more efficient and makes your queries clearer.',
            codeSnippet:
                '-- Select specific columns\nSELECT name, price FROM products;\n\n-- Select with a different order\nSELECT price, name, category FROM products;\n\n-- Columns can be listed in any order you want',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'Filtering with WHERE',
            content:
                'The WHERE clause filters results to show only rows that match a condition. It\'s like asking "show me only the items that..."',
            codeSnippet:
                '-- Find products with price greater than 50\nSELECT name, price FROM products\nWHERE price > 50;\n\n-- Find a specific user by name\nSELECT * FROM users\nWHERE name = \'Alice\';\n\n-- Find products in a specific category\nSELECT * FROM products\nWHERE category = \'Electronics\';',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Comparison Operators',
            content:
                'SQL supports various operators for comparing values:\n\n• = Equal to\n• != or <> Not equal to\n• > Greater than\n• < Less than\n• >= Greater than or equal\n• <= Less than or equal',
            codeSnippet:
                '-- Find products priced at exactly 29.99\nSELECT * FROM products WHERE price = 29.99;\n\n-- Find orders with quantity less than 10\nSELECT * FROM orders WHERE quantity < 10;\n\n-- Find users who are NOT admins\nSELECT * FROM users WHERE role != \'admin\';',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question:
                  'How do you select only the "name" and "email" columns from a "users" table?',
              options: [
                'SELECT * FROM users;',
                'SELECT name, email FROM users;',
                'GET name, email FROM users;',
                'SELECT (name email) FROM users;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'List the column names separated by commas after SELECT: SELECT name, email FROM users;',
            ),
            QuizQuestion(
              question: 'Which keyword is used to filter results?',
              options: ['FILTER', 'WHEN', 'WHERE', 'IF'],
              correctAnswerIndex: 2,
              explanation:
                  'The WHERE clause is used to filter records that match a specific condition.',
            ),
            QuizQuestion(
              question:
                  'How do you find products where price is greater than 100?',
              options: [
                'SELECT * FROM products WHERE price > 100;',
                'SELECT * FROM products IF price > 100;',
                'SELECT * FROM products WHEN price > 100;',
                'SELECT * FROM products WITH price > 100;',
              ],
              correctAnswerIndex: 0,
              explanation: 'Use WHERE with the > operator: WHERE price > 100',
            ),
            QuizQuestion(
              question: 'What operator means "not equal to" in SQL?',
              options: ['==', '!==', '!= or <>', '=/='],
              correctAnswerIndex: 2,
              explanation:
                  'In SQL, both != and <> mean "not equal to". Both are valid and widely used.',
            ),
            QuizQuestion(
              question: 'How should text values be written in SQL conditions?',
              options: [
                'In double quotes: "value"',
                'In single quotes: \'value\'',
                'In backticks: `value`',
                'Without any quotes: value',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'In SQL, text (string) values should be enclosed in single quotes, like \'Alice\' or \'Electronics\'.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Filter Products',
          description:
              'Write a query to select the name and price of all products where the price is less than or equal to 50.',
          starterCode: '-- Get name and price for affordable products\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT name, price FROM products WHERE price <= 50;',
            ),
          ],
          hint:
              'Use SELECT to choose columns, FROM for the table, and WHERE with <= for the condition.',
          solution: 'SELECT name, price FROM products WHERE price <= 50;',
        ),
        xpReward: 18,
        order: 1,
      ),

      // Lesson 3: Filtering Data
      Lesson(
        id: 'sql_lesson_3',
        courseId: 'sql',
        moduleId: 'basics',
        title: 'Filtering Data',
        description:
            'Learn advanced filtering with AND, OR, and pattern matching',
        theorySlides: [
          TheorySlide(
            title: 'Combining Conditions with AND & OR 🔍',
            content:
                'You can combine multiple conditions using AND (both must be true) or OR (at least one must be true).',
            codeSnippet:
                '-- AND: Both conditions must be true\nSELECT * FROM products\nWHERE category = \'Electronics\' AND price < 500;\n\n-- OR: At least one condition must be true\nSELECT * FROM products\nWHERE category = \'Books\' OR category = \'Music\';\n\n-- Combining AND and OR (use parentheses!)\nSELECT * FROM products\nWHERE (category = \'Electronics\' OR category = \'Gadgets\')\nAND price < 100;',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'IN, BETWEEN, and NOT',
            content:
                'SQL provides shortcuts for common filtering patterns:\n\n• IN: Match any value in a list\n• BETWEEN: Match a range of values\n• NOT: Negate a condition',
            codeSnippet:
                '-- IN: Instead of multiple OR conditions\nSELECT * FROM products\nWHERE category IN (\'Electronics\', \'Computers\', \'Phones\');\n\n-- BETWEEN: Range of values (inclusive)\nSELECT * FROM products\nWHERE price BETWEEN 10 AND 50;\n\n-- NOT: Exclude matches\nSELECT * FROM products\nWHERE category NOT IN (\'Clothing\', \'Food\');',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Pattern Matching with LIKE',
            content:
                'The LIKE operator lets you search for patterns in text using wildcards:\n\n• % matches any sequence of characters\n• _ matches exactly one character',
            codeSnippet:
                '-- Names starting with \'A\'\nSELECT * FROM users WHERE name LIKE \'A%\';\n\n-- Names ending with \'son\'\nSELECT * FROM users WHERE name LIKE \'%son\';\n\n-- Names containing \'ann\'\nSELECT * FROM users WHERE name LIKE \'%ann%\';\n\n-- Emails from gmail\nSELECT * FROM users WHERE email LIKE \'%@gmail.com\';\n\n-- Names with exactly 4 characters\nSELECT * FROM users WHERE name LIKE \'____\';',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does AND require for a row to be selected?',
              options: [
                'At least one condition must be true',
                'All conditions must be true',
                'No conditions need to be true',
                'Exactly one condition must be true',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'AND requires ALL conditions to be true. If any condition is false, the row is not selected.',
            ),
            QuizQuestion(
              question:
                  'Which is the correct way to match values 10, 20, or 30?',
              options: [
                'WHERE value = 10 OR 20 OR 30',
                'WHERE value IN (10, 20, 30)',
                'WHERE value BETWEEN 10 AND 30',
                'WHERE value = (10, 20, 30)',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'IN allows you to specify multiple values: WHERE value IN (10, 20, 30). Note that BETWEEN would include all numbers from 10 to 30, not just 10, 20, and 30.',
            ),
            QuizQuestion(
              question: 'What does the % wildcard match in LIKE?',
              options: [
                'Exactly one character',
                'Only numbers',
                'Any sequence of characters (including none)',
                'Only spaces',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'The % wildcard matches zero or more characters of any type. For example, \'A%\' matches \'A\', \'Alice\', and \'Amazing\'.',
            ),
            QuizQuestion(
              question: 'How do you find names that do NOT start with \'J\'?',
              options: [
                'WHERE name NOT LIKE \'J%\'',
                'WHERE name UNLIKE \'J%\'',
                'WHERE NOT name = \'J%\'',
                'WHERE name <> \'J%\'',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Use NOT LIKE to negate a pattern match: WHERE name NOT LIKE \'J%\'',
            ),
            QuizQuestion(
              question: 'What does BETWEEN 5 AND 10 include?',
              options: [
                'Only 5 and 10',
                '6, 7, 8, and 9 only',
                '5, 6, 7, 8, 9, and 10',
                'Everything except 5 and 10',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'BETWEEN is inclusive, meaning it includes both the start and end values. BETWEEN 5 AND 10 includes 5, 6, 7, 8, 9, and 10.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Complex Filter',
          description:
              'Write a query to find all users whose name starts with \'J\' AND whose email contains \'gmail\'.',
          starterCode: '-- Find users with specific name and email patterns\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT * FROM users WHERE name LIKE \'J%\' AND email LIKE \'%gmail%\';',
            ),
          ],
          hint:
              'Use LIKE with % wildcard for pattern matching. Combine conditions with AND.',
          solution:
              'SELECT * FROM users WHERE name LIKE \'J%\' AND email LIKE \'%gmail%\';',
        ),
        xpReward: 20,
        order: 2,
      ),

      // Lesson 4: Sorting & Limiting
      Lesson(
        id: 'sql_lesson_4',
        courseId: 'sql',
        moduleId: 'basics',
        title: 'Sorting & Limiting Results',
        description: 'Control the order and quantity of your results',
        theorySlides: [
          TheorySlide(
            title: 'Ordering Results with ORDER BY 📊',
            content:
                'The ORDER BY clause sorts your results. By default, it sorts in ascending order (A-Z, 0-9).',
            codeSnippet:
                '-- Sort by name alphabetically (A to Z)\nSELECT * FROM users ORDER BY name;\n\n-- Sort by price, lowest first (ascending)\nSELECT * FROM products ORDER BY price ASC;\n\n-- Sort by price, highest first (descending)\nSELECT * FROM products ORDER BY price DESC;\n\n-- Sort by multiple columns\nSELECT * FROM products\nORDER BY category ASC, price DESC;',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'Limiting Results with LIMIT',
            content:
                'LIMIT restricts how many rows are returned. This is essential for pagination and getting top/bottom results.',
            codeSnippet:
                '-- Get only the first 10 products\nSELECT * FROM products LIMIT 10;\n\n-- Get the 5 most expensive products\nSELECT * FROM products\nORDER BY price DESC\nLIMIT 5;\n\n-- Pagination: Skip first 20, get next 10\nSELECT * FROM products\nLIMIT 10 OFFSET 20;\n\n-- Alternative syntax: LIMIT offset, count\nSELECT * FROM products LIMIT 20, 10;',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Handling NULL Values',
            content:
                'NULL represents missing or unknown data. It requires special handling in SQL.',
            codeSnippet:
                '-- Find rows where email is NULL (missing)\nSELECT * FROM users WHERE email IS NULL;\n\n-- Find rows where email exists (is NOT NULL)\nSELECT * FROM users WHERE email IS NOT NULL;\n\n-- WRONG: This won\'t work!\nSELECT * FROM users WHERE email = NULL;\n\n-- NULLs sort last in ASC, first in DESC\n-- Use NULLS FIRST or NULLS LAST to control\nSELECT * FROM users\nORDER BY last_login DESC NULLS LAST;',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'How do you sort results from highest to lowest?',
              options: [
                'ORDER BY column ASC',
                'ORDER BY column DESC',
                'SORT BY column DOWN',
                'ORDER BY column REVERSE',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'DESC (descending) sorts from highest to lowest. ASC (ascending) sorts from lowest to highest.',
            ),
            QuizQuestion(
              question: 'What does LIMIT 5 do?',
              options: [
                'Skips the first 5 rows',
                'Returns only the first 5 rows',
                'Returns rows where a column equals 5',
                'Groups results into 5 categories',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'LIMIT 5 restricts the result set to only the first 5 rows returned by the query.',
            ),
            QuizQuestion(
              question: 'How do you check if a value is NULL?',
              options: [
                'WHERE column = NULL',
                'WHERE column == NULL',
                'WHERE column IS NULL',
                'WHERE column EQUALS NULL',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'NULL requires the IS operator, not =. Use WHERE column IS NULL or WHERE column IS NOT NULL.',
            ),
            QuizQuestion(
              question: 'What does OFFSET 10 do with LIMIT 5?',
              options: [
                'Returns 10 rows starting from row 5',
                'Returns 5 rows, skipping the first 10',
                'Returns rows 5 through 10',
                'Returns 15 rows total',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'OFFSET 10 skips the first 10 rows. Combined with LIMIT 5, you get rows 11-15.',
            ),
            QuizQuestion(
              question: 'How do you get the 3 cheapest products?',
              options: [
                'SELECT * FROM products ORDER BY price ASC LIMIT 3;',
                'SELECT * FROM products ORDER BY price DESC LIMIT 3;',
                'SELECT * FROM products LIMIT 3 ORDER BY price;',
                'SELECT TOP 3 * FROM products WHERE price = MIN;',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Sort by price in ascending order (lowest first) and limit to 3 results.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Top Products',
          description:
              'Write a query to get the 5 most expensive products. Show only the name and price columns, sorted by price from highest to lowest.',
          starterCode: '-- Get the top 5 expensive products\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT name, price FROM products ORDER BY price DESC LIMIT 5;',
            ),
          ],
          hint:
              'Use ORDER BY with DESC for highest first, then LIMIT to restrict results.',
          solution:
              'SELECT name, price FROM products ORDER BY price DESC LIMIT 5;',
        ),
        xpReward: 18,
        order: 3,
      ),

      // Lesson 5: Aggregate Functions
      Lesson(
        id: 'sql_lesson_5',
        courseId: 'sql',
        moduleId: 'intermediate',
        title: 'Aggregate Functions',
        description: 'Perform calculations on groups of data',
        theorySlides: [
          TheorySlide(
            title: 'What are Aggregate Functions? 📈',
            content:
                'Aggregate functions perform calculations on multiple rows and return a single value. They\'re essential for data analysis and reporting.\n\n• COUNT() - Number of rows\n• SUM() - Total of values\n• AVG() - Average of values\n• MIN() - Smallest value\n• MAX() - Largest value',
            order: 0,
          ),
          TheorySlide(
            title: 'COUNT, SUM, and AVG',
            content: 'These are the most commonly used aggregate functions:',
            codeSnippet:
                '-- Count total number of products\nSELECT COUNT(*) FROM products;\n\n-- Count products in a category\nSELECT COUNT(*) FROM products\nWHERE category = \'Electronics\';\n\n-- Sum of all order amounts\nSELECT SUM(amount) FROM orders;\n\n-- Average product price\nSELECT AVG(price) FROM products;\n\n-- Count non-NULL emails\nSELECT COUNT(email) FROM users;',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'MIN, MAX, and Column Aliases',
            content:
                'Find extreme values and give your results meaningful names:',
            codeSnippet:
                '-- Find the cheapest product price\nSELECT MIN(price) AS lowest_price FROM products;\n\n-- Find the most expensive product price  \nSELECT MAX(price) AS highest_price FROM products;\n\n-- Combine multiple aggregates\nSELECT \n  COUNT(*) AS total_products,\n  AVG(price) AS average_price,\n  MIN(price) AS min_price,\n  MAX(price) AS max_price\nFROM products;',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does COUNT(*) return?',
              options: [
                'The sum of all values',
                'The total number of rows',
                'The average of all values',
                'The number of columns',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'COUNT(*) counts all rows in the result set, including rows with NULL values.',
            ),
            QuizQuestion(
              question:
                  'What\'s the difference between COUNT(*) and COUNT(column)?',
              options: [
                'No difference',
                'COUNT(*) counts all rows, COUNT(column) only counts non-NULL values',
                'COUNT(*) is faster',
                'COUNT(column) counts all rows',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'COUNT(*) counts all rows, while COUNT(column) only counts rows where that specific column is not NULL.',
            ),
            QuizQuestion(
              question: 'How do you find the average order amount?',
              options: [
                'SELECT AVERAGE(amount) FROM orders;',
                'SELECT AVG(amount) FROM orders;',
                'SELECT MEAN(amount) FROM orders;',
                'SELECT SUM(amount)/COUNT(*) FROM orders;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'AVG() is the standard SQL function for calculating averages. While option D would work mathematically, AVG() is cleaner and handles NULLs correctly.',
            ),
            QuizQuestion(
              question: 'What does AS do in "SELECT COUNT(*) AS total"?',
              options: [
                'Filters the count',
                'Creates a column alias (name)',
                'Sorts the results',
                'Groups the data',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'AS creates an alias, giving the result column a custom name. "AS total" means the count will appear in a column named "total".',
            ),
            QuizQuestion(
              question: 'Which function finds the highest value?',
              options: ['TOP()', 'HIGHEST()', 'MAX()', 'GREATEST()'],
              correctAnswerIndex: 2,
              explanation:
                  'MAX() returns the maximum (highest) value in a column. It works with numbers, dates, and text.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Order Statistics',
          description:
              'Write a query that shows the total number of orders, the sum of all amounts, and the average amount from the "orders" table. Use aliases: total_orders, total_amount, avg_amount.',
          starterCode: '-- Calculate order statistics\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT COUNT(*) AS total_orders, SUM(amount) AS total_amount, AVG(amount) AS avg_amount FROM orders;',
            ),
          ],
          hint:
              'Use COUNT(*), SUM(), and AVG() with AS to create aliases for each result.',
          solution:
              'SELECT COUNT(*) AS total_orders, SUM(amount) AS total_amount, AVG(amount) AS avg_amount FROM orders;',
        ),
        xpReward: 20,
        order: 4,
      ),

      // Lesson 6: GROUP BY & HAVING
      Lesson(
        id: 'sql_lesson_6',
        courseId: 'sql',
        moduleId: 'intermediate',
        title: 'GROUP BY & HAVING',
        description: 'Group data and filter aggregated results',
        theorySlides: [
          TheorySlide(
            title: 'Grouping Data with GROUP BY 📊',
            content:
                'GROUP BY divides rows into groups based on column values, allowing you to apply aggregate functions to each group separately.',
            codeSnippet:
                '-- Count products per category\nSELECT category, COUNT(*) AS product_count\nFROM products\nGROUP BY category;\n\n-- Total sales per customer\nSELECT customer_id, SUM(amount) AS total_spent\nFROM orders\nGROUP BY customer_id;\n\n-- Average price by category\nSELECT category, AVG(price) AS avg_price\nFROM products\nGROUP BY category;',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'Filtering Groups with HAVING',
            content:
                'HAVING filters groups AFTER aggregation. Use it when you want to filter based on aggregate results (WHERE can\'t do this!).',
            codeSnippet:
                '-- Categories with more than 10 products\nSELECT category, COUNT(*) AS count\nFROM products\nGROUP BY category\nHAVING COUNT(*) > 10;\n\n-- Customers who spent over \$1000\nSELECT customer_id, SUM(amount) AS total\nFROM orders\nGROUP BY customer_id\nHAVING SUM(amount) > 1000;\n\n-- WHERE filters rows, HAVING filters groups\nSELECT category, AVG(price) AS avg_price\nFROM products\nWHERE price > 0        -- Filter rows first\nGROUP BY category\nHAVING AVG(price) > 50; -- Then filter groups',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Complete GROUP BY Example',
            content: 'Here\'s a real-world example combining everything:',
            codeSnippet:
                '-- Sales report by category and month\nSELECT \n  category,\n  COUNT(*) AS num_orders,\n  SUM(amount) AS total_sales,\n  AVG(amount) AS avg_order\nFROM orders\nWHERE status = \'completed\'\nGROUP BY category\nHAVING SUM(amount) >= 1000\nORDER BY total_sales DESC;\n\n-- Query execution order:\n-- 1. FROM (get table)\n-- 2. WHERE (filter rows)\n-- 3. GROUP BY (create groups)\n-- 4. HAVING (filter groups)\n-- 5. SELECT (choose columns)\n-- 6. ORDER BY (sort results)',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does GROUP BY do?',
              options: [
                'Sorts the results',
                'Divides rows into groups for aggregation',
                'Limits the number of results',
                'Joins two tables together',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'GROUP BY divides rows into groups based on one or more columns, so aggregate functions can be applied to each group separately.',
            ),
            QuizQuestion(
              question: 'What\'s the difference between WHERE and HAVING?',
              options: [
                'They are the same',
                'WHERE filters before grouping, HAVING filters after',
                'HAVING is faster',
                'WHERE only works with numbers',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'WHERE filters individual rows before they are grouped. HAVING filters groups after aggregation. Use HAVING when filtering on aggregate results like COUNT() or SUM().',
            ),
            QuizQuestion(
              question:
                  'Which query finds categories with average price over \$50?',
              options: [
                'SELECT category FROM products WHERE AVG(price) > 50 GROUP BY category;',
                'SELECT category FROM products GROUP BY category HAVING AVG(price) > 50;',
                'SELECT category FROM products GROUP BY category WHERE AVG(price) > 50;',
                'SELECT category, AVG(price) FROM products HAVING AVG(price) > 50;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'You must use HAVING (not WHERE) to filter on aggregate functions. HAVING comes after GROUP BY.',
            ),
            QuizQuestion(
              question: 'When using GROUP BY, what can appear in SELECT?',
              options: [
                'Any columns you want',
                'Only the grouped columns and aggregate functions',
                'Only aggregate functions',
                'Only the grouped columns',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'In a GROUP BY query, SELECT can only include columns that are in the GROUP BY clause, or columns wrapped in aggregate functions.',
            ),
            QuizQuestion(
              question: 'What order are SQL clauses executed?',
              options: [
                'SELECT → FROM → WHERE → GROUP BY',
                'FROM → SELECT → WHERE → GROUP BY',
                'FROM → WHERE → GROUP BY → HAVING → SELECT',
                'SELECT → WHERE → FROM → GROUP BY',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'SQL executes in this order: FROM (get data) → WHERE (filter rows) → GROUP BY (group) → HAVING (filter groups) → SELECT (columns) → ORDER BY (sort)',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Category Analysis',
          description:
              'Write a query to show each category and its product count from the "products" table. Only include categories that have more than 5 products. Order by count descending.',
          starterCode: '-- Show categories with more than 5 products\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT category, COUNT(*) AS product_count FROM products GROUP BY category HAVING COUNT(*) > 5 ORDER BY product_count DESC;',
            ),
          ],
          hint:
              'GROUP BY category, use HAVING to filter groups with COUNT(*) > 5, then ORDER BY.',
          solution:
              'SELECT category, COUNT(*) AS product_count FROM products GROUP BY category HAVING COUNT(*) > 5 ORDER BY product_count DESC;',
        ),
        xpReward: 22,
        order: 5,
      ),

      // Lesson 7: JOIN Basics
      Lesson(
        id: 'sql_lesson_7',
        courseId: 'sql',
        moduleId: 'intermediate',
        title: 'JOIN Basics',
        description: 'Combine data from multiple tables',
        theorySlides: [
          TheorySlide(
            title: 'Why Use JOINs? 🔗',
            content:
                'Real databases split data across multiple tables to avoid duplication. JOINs let you combine related data from different tables.\n\nExample Tables:\n• users: id, name, email\n• orders: id, user_id, amount, date\n\nThe user_id in orders links to id in users. This relationship lets us see which user made each order.',
            order: 0,
          ),
          TheorySlide(
            title: 'INNER JOIN',
            content:
                'INNER JOIN returns only rows that have matching values in both tables. It\'s the most common type of join.',
            codeSnippet:
                '-- Get orders with customer names\nSELECT orders.id, users.name, orders.amount\nFROM orders\nINNER JOIN users ON orders.user_id = users.id;\n\n-- Using table aliases for cleaner code\nSELECT o.id, u.name, o.amount\nFROM orders o\nINNER JOIN users u ON o.user_id = u.id;\n\n-- With additional filtering\nSELECT u.name, o.amount, o.order_date\nFROM orders o\nINNER JOIN users u ON o.user_id = u.id\nWHERE o.amount > 100;',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Understanding JOIN Syntax',
            content: 'The ON clause specifies how tables relate to each other:',
            codeSnippet:
                '-- Full syntax breakdown\nSELECT \n  products.name AS product_name,\n  categories.name AS category_name\nFROM products                    -- First table\nINNER JOIN categories            -- Second table\nON products.category_id = categories.id;  -- Link\n\n-- Join products with their orders\nSELECT p.name, o.quantity, o.order_date\nFROM products p\nINNER JOIN order_items o ON p.id = o.product_id;\n\n-- You can also just write JOIN (INNER is default)\nSELECT * FROM orders\nJOIN users ON orders.user_id = users.id;',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does an INNER JOIN return?',
              options: [
                'All rows from both tables',
                'Only rows that have matching values in both tables',
                'All rows from the left table',
                'All rows from the right table',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'INNER JOIN returns only the rows where there is a match in both tables based on the join condition.',
            ),
            QuizQuestion(
              question: 'What does the ON clause specify?',
              options: [
                'Which columns to display',
                'How the tables are related',
                'The order of results',
                'How many rows to return',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'The ON clause defines the relationship between tables by specifying which columns should match (e.g., orders.user_id = users.id).',
            ),
            QuizQuestion(
              question: 'What is a table alias?',
              options: [
                'A way to rename a table permanently',
                'A short name for a table in a query',
                'A backup of the table',
                'A type of join',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A table alias is a temporary short name (like "u" for "users") that makes queries easier to write and read.',
            ),
            QuizQuestion(
              question:
                  'If orders has 100 rows and users has 50, how many rows could INNER JOIN return maximum?',
              options: [
                'Exactly 100',
                'Exactly 50',
                'Up to 100 (if all orders have matching users)',
                '150',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'INNER JOIN returns only matching rows. If all 100 orders have valid user_ids that exist in users, you get 100 rows. Unmatched rows are excluded.',
            ),
            QuizQuestion(
              question: 'Is "JOIN" the same as "INNER JOIN"?',
              options: [
                'No, they are different',
                'Yes, JOIN defaults to INNER JOIN',
                'JOIN returns more rows',
                'INNER JOIN is faster',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'In SQL, JOIN without a prefix defaults to INNER JOIN. They produce the same results.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Join Orders with Users',
          description:
              'Write a query to show each order with the customer\'s name. Select the order id, user name, and amount. Use table aliases (o for orders, u for users).',
          starterCode: '-- Join orders with users to see customer names\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT o.id, u.name, o.amount FROM orders o INNER JOIN users u ON o.user_id = u.id;',
            ),
          ],
          hint:
              'Use FROM orders o, then INNER JOIN users u ON o.user_id = u.id',
          solution:
              'SELECT o.id, u.name, o.amount FROM orders o INNER JOIN users u ON o.user_id = u.id;',
        ),
        xpReward: 22,
        order: 6,
      ),

      // Lesson 8: Advanced JOINs
      Lesson(
        id: 'sql_lesson_8',
        courseId: 'sql',
        moduleId: 'intermediate',
        title: 'Advanced JOINs',
        description: 'Master LEFT JOIN, RIGHT JOIN, and multiple table joins',
        theorySlides: [
          TheorySlide(
            title: 'LEFT JOIN - Keep All Left Rows 👈',
            content:
                'LEFT JOIN returns all rows from the left table, plus matching rows from the right table. If there\'s no match, NULL values fill in for the right table columns.',
            codeSnippet:
                '-- All users, even those with no orders\nSELECT u.name, o.amount\nFROM users u\nLEFT JOIN orders o ON u.id = o.user_id;\n\n-- Result might include:\n-- Alice  | 99.99\n-- Bob    | 150.00\n-- Carol  | NULL    ← Carol has no orders\n\n-- Find users who have never ordered\nSELECT u.name, u.email\nFROM users u\nLEFT JOIN orders o ON u.id = o.user_id\nWHERE o.id IS NULL;',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'RIGHT JOIN & Visual Guide',
            content:
                'RIGHT JOIN is the opposite of LEFT - it keeps all rows from the right table.\n\n📊 JOIN Types Visual:\n\nINNER: Only matching rows (A ∩ B)\nLEFT:  All from left + matches (A + A∩B)\nRIGHT: All from right + matches (B + A∩B)',
            codeSnippet:
                '-- All products, even those never ordered\nSELECT p.name, o.quantity\nFROM order_items o\nRIGHT JOIN products p ON o.product_id = p.id;\n\n-- RIGHT JOIN is less common - you can usually\n-- rewrite it as LEFT JOIN by swapping tables:\nSELECT p.name, o.quantity\nFROM products p\nLEFT JOIN order_items o ON p.id = o.product_id;',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Joining Multiple Tables',
            content:
                'You can chain multiple JOINs to combine data from several related tables:',
            codeSnippet:
                '-- Orders with user names and product details\nSELECT \n  u.name AS customer,\n  p.name AS product,\n  oi.quantity,\n  o.order_date\nFROM orders o\nINNER JOIN users u ON o.user_id = u.id\nINNER JOIN order_items oi ON o.id = oi.order_id\nINNER JOIN products p ON oi.product_id = p.id\nWHERE o.order_date >= \'2024-01-01\';\n\n-- Mix JOIN types as needed\nSELECT u.name, COUNT(o.id) AS order_count\nFROM users u\nLEFT JOIN orders o ON u.id = o.user_id\nGROUP BY u.id, u.name;',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does LEFT JOIN return that INNER JOIN doesn\'t?',
              options: [
                'More columns',
                'Unmatched rows from the left table (with NULLs)',
                'Faster results',
                'Sorted results',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'LEFT JOIN includes all rows from the left table, even if there\'s no match in the right table. Unmatched right columns show as NULL.',
            ),
            QuizQuestion(
              question: 'How do you find users who have NO orders?',
              options: [
                'SELECT * FROM users WHERE orders = 0;',
                'SELECT * FROM users LEFT JOIN orders ON ... WHERE orders.id IS NULL;',
                'SELECT * FROM users INNER JOIN orders ON ... WHERE amount = 0;',
                'SELECT * FROM users WHERE NOT IN orders;',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Use LEFT JOIN and check for NULL in the right table\'s key column. If orders.id IS NULL, the user has no matching orders.',
            ),
            QuizQuestion(
              question:
                  'If users has 100 rows and orders has 50, what\'s the minimum LEFT JOIN result?',
              options: ['50 rows', '100 rows', '150 rows', '0 rows'],
              correctAnswerIndex: 1,
              explanation:
                  'LEFT JOIN always returns at least as many rows as the left table. All 100 users will appear, even those without orders.',
            ),
            QuizQuestion(
              question: 'Can you use multiple JOINs in one query?',
              options: [
                'No, only one JOIN allowed',
                'Yes, chain them one after another',
                'Only with subqueries',
                'Only with UNION',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'You can chain multiple JOINs to combine data from many tables. Each JOIN adds another table to the result.',
            ),
            QuizQuestion(
              question:
                  'RIGHT JOIN users ON orders.user_id = users.id is equivalent to:',
              options: [
                'LEFT JOIN orders ON users.id = orders.user_id',
                'INNER JOIN with the tables swapped',
                'LEFT JOIN users ON orders.user_id = users.id',
                'None of the above',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'RIGHT JOIN table_a is equivalent to LEFT JOIN with the tables swapped. Most developers prefer LEFT JOIN for consistency.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Find Inactive Users',
          description:
              'Write a query to find all users who have never placed an order. Use LEFT JOIN and check for NULL. Show only the user name and email.',
          starterCode: '-- Find users with no orders\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT u.name, u.email FROM users u LEFT JOIN orders o ON u.id = o.user_id WHERE o.id IS NULL;',
            ),
          ],
          hint:
              'LEFT JOIN keeps all users. Where there\'s no matching order, order columns will be NULL.',
          solution:
              'SELECT u.name, u.email FROM users u LEFT JOIN orders o ON u.id = o.user_id WHERE o.id IS NULL;',
        ),
        xpReward: 23,
        order: 7,
      ),

      // Lesson 9: INSERT, UPDATE, DELETE
      Lesson(
        id: 'sql_lesson_9',
        courseId: 'sql',
        moduleId: 'advanced',
        title: 'Modifying Data',
        description: 'Learn to insert, update, and delete data safely',
        theorySlides: [
          TheorySlide(
            title: 'Inserting Data with INSERT 📝',
            content:
                'The INSERT statement adds new rows to a table. You can insert single or multiple rows at once.',
            codeSnippet:
                '-- Insert a single row (specify columns)\nINSERT INTO users (name, email)\nVALUES (\'Alice\', \'alice@email.com\');\n\n-- Insert with all columns (order matters!)\nINSERT INTO products\nVALUES (1, \'Laptop\', 999.99, \'Electronics\');\n\n-- Insert multiple rows at once\nINSERT INTO users (name, email) VALUES\n  (\'Bob\', \'bob@email.com\'),\n  (\'Carol\', \'carol@email.com\'),\n  (\'Dave\', \'dave@email.com\');',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'Updating Data with UPDATE',
            content:
                'UPDATE modifies existing rows. ALWAYS use WHERE to specify which rows to update!',
            codeSnippet:
                '-- Update a specific user\'s email\nUPDATE users\nSET email = \'newemail@example.com\'\nWHERE id = 5;\n\n-- Update multiple columns\nUPDATE products\nSET price = 899.99, category = \'Sale\'\nWHERE id = 10;\n\n-- Update based on conditions\nUPDATE products\nSET price = price * 0.9  -- 10% discount\nWHERE category = \'Clearance\';\n\n-- ⚠️ DANGEROUS: Updates ALL rows!\nUPDATE users SET status = \'active\';',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Deleting Data with DELETE',
            content:
                'DELETE removes rows from a table. Be very careful - this is permanent!',
            codeSnippet:
                '-- Delete a specific row\nDELETE FROM users WHERE id = 5;\n\n-- Delete rows matching a condition\nDELETE FROM orders\nWHERE status = \'cancelled\'\nAND created_at < \'2023-01-01\';\n\n-- ⚠️ DANGEROUS: Deletes ALL rows!\nDELETE FROM users;\n\n-- Safety tip: Test with SELECT first!\nSELECT * FROM orders\nWHERE status = \'cancelled\';  -- Preview\n-- Then change SELECT to DELETE\n\n-- Use transactions for safety\nBEGIN TRANSACTION;\nDELETE FROM orders WHERE id = 100;\n-- Check results, then:\nCOMMIT;  -- Save changes\n-- Or: ROLLBACK;  -- Undo changes',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What\'s the correct syntax to insert a new user?',
              options: [
                'ADD INTO users VALUES (\'John\', \'john@email.com\');',
                'INSERT users (name, email) (\'John\', \'john@email.com\');',
                'INSERT INTO users (name, email) VALUES (\'John\', \'john@email.com\');',
                'CREATE ROW users (\'John\', \'john@email.com\');',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'The correct syntax is INSERT INTO table (columns) VALUES (values);',
            ),
            QuizQuestion(
              question:
                  'What happens if you run UPDATE users SET status = \'active\'; without WHERE?',
              options: [
                'It fails with an error',
                'It updates only the first row',
                'It updates ALL rows in the table',
                'Nothing happens',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Without a WHERE clause, UPDATE affects ALL rows in the table. This is a common and dangerous mistake!',
            ),
            QuizQuestion(
              question:
                  'How do you change a product\'s price from \$100 to \$90?',
              options: [
                'UPDATE products SET price = 90 WHERE price = 100;',
                'MODIFY products price = 90 WHERE price = 100;',
                'CHANGE products SET price 90 WHERE id = ?;',
                'UPDATE price = 90 FROM products;',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Use UPDATE table SET column = value WHERE condition; to modify specific rows.',
            ),
            QuizQuestion(
              question: 'What should you do before running a DELETE?',
              options: [
                'Run COMMIT first',
                'Test with SELECT using the same WHERE clause',
                'Nothing, just run it',
                'Create a new table',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Always preview what will be deleted by running a SELECT with the same WHERE clause first. This prevents accidental data loss.',
            ),
            QuizQuestion(
              question: 'What does ROLLBACK do in a transaction?',
              options: [
                'Saves all changes',
                'Undoes all changes since BEGIN TRANSACTION',
                'Deletes the table',
                'Locks the database',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'ROLLBACK undoes all changes made since the transaction began. COMMIT saves them. Transactions let you test changes safely.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Add a New Product',
          description:
              'Write an INSERT statement to add a new product with name "Wireless Mouse", price 29.99, and category "Electronics" to the products table.',
          starterCode: '-- Insert a new product\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'INSERT INTO products (name, price, category) VALUES (\'Wireless Mouse\', 29.99, \'Electronics\');',
            ),
          ],
          hint:
              'Use INSERT INTO table (columns) VALUES (values); - remember to quote text values.',
          solution:
              'INSERT INTO products (name, price, category) VALUES (\'Wireless Mouse\', 29.99, \'Electronics\');',
        ),
        xpReward: 23,
        order: 8,
      ),

      // Lesson 10: Creating Tables
      Lesson(
        id: 'sql_lesson_10',
        courseId: 'sql',
        moduleId: 'advanced',
        title: 'Creating Tables',
        description: 'Design and create your own database tables',
        theorySlides: [
          TheorySlide(
            title: 'CREATE TABLE Basics 🏗️',
            content:
                'CREATE TABLE defines a new table with columns and their data types. Each column needs a name and type.',
            codeSnippet:
                '-- Basic table creation\nCREATE TABLE users (\n  id INT,\n  name VARCHAR(100),\n  email VARCHAR(255),\n  age INT,\n  created_at TIMESTAMP\n);\n\n-- Common data types:\n-- INT: Whole numbers (1, 42, -10)\n-- DECIMAL(10,2): Decimal numbers (99.99)\n-- VARCHAR(n): Text up to n characters\n-- TEXT: Long text (no limit)\n-- BOOLEAN: true/false\n-- DATE: Dates (2024-01-15)\n-- TIMESTAMP: Date + time',
            codeLanguage: 'sql',
            order: 0,
          ),
          TheorySlide(
            title: 'Primary Keys & Auto Increment',
            content:
                'A PRIMARY KEY uniquely identifies each row. AUTO_INCREMENT generates unique IDs automatically.',
            codeSnippet:
                '-- Table with primary key and auto-increment\nCREATE TABLE products (\n  id INT PRIMARY KEY AUTO_INCREMENT,\n  name VARCHAR(255) NOT NULL,\n  price DECIMAL(10, 2) NOT NULL,\n  description TEXT,\n  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n);\n\n-- PostgreSQL uses SERIAL instead:\nCREATE TABLE products (\n  id SERIAL PRIMARY KEY,\n  name VARCHAR(255) NOT NULL,\n  price DECIMAL(10, 2) NOT NULL\n);',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Constraints & Foreign Keys',
            content:
                'Constraints enforce rules on your data to maintain integrity:',
            codeSnippet:
                '-- Table with various constraints\nCREATE TABLE orders (\n  id INT PRIMARY KEY AUTO_INCREMENT,\n  user_id INT NOT NULL,\n  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),\n  status VARCHAR(50) DEFAULT \'pending\',\n  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n  \n  -- Foreign key links to users table\n  FOREIGN KEY (user_id) REFERENCES users(id)\n);\n\n-- Constraints explained:\n-- NOT NULL: Column cannot be empty\n-- UNIQUE: All values must be different\n-- CHECK: Values must meet a condition\n-- DEFAULT: Value if none provided\n-- FOREIGN KEY: Must match a value in another table',
            codeLanguage: 'sql',
            order: 2,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does PRIMARY KEY ensure?',
              options: [
                'The column is always sorted',
                'Each row has a unique identifier',
                'The column can be NULL',
                'The table loads faster',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'PRIMARY KEY ensures each row has a unique, non-null identifier. It\'s essential for identifying and linking records.',
            ),
            QuizQuestion(
              question:
                  'Which data type is best for storing prices like \$99.99?',
              options: ['INT', 'VARCHAR(10)', 'DECIMAL(10, 2)', 'FLOAT'],
              correctAnswerIndex: 2,
              explanation:
                  'DECIMAL(10, 2) stores exact decimal numbers with 2 decimal places - perfect for money. FLOAT can have rounding errors.',
            ),
            QuizQuestion(
              question: 'What does NOT NULL mean?',
              options: [
                'The column can only store NULL',
                'The column must always have a value',
                'The column is a primary key',
                'The column stores zero',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'NOT NULL means the column cannot be empty - every row must have a value for that column.',
            ),
            QuizQuestion(
              question: 'What does a FOREIGN KEY do?',
              options: [
                'Creates a new table',
                'Links to a row in another table',
                'Makes the column unique',
                'Encrypts the data',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A FOREIGN KEY creates a relationship between tables by referencing the primary key of another table, ensuring referential integrity.',
            ),
            QuizQuestion(
              question: 'What does DEFAULT \'pending\' do?',
              options: [
                'Makes the column required',
                'Sets the value to \'pending\' if not provided',
                'Only allows the value \'pending\'',
                'Names the column \'pending\'',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'DEFAULT specifies a value to use when no value is provided during INSERT. In this case, the status would be \'pending\' by default.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Customers Table',
          description:
              'Create a "customers" table with: id (integer, primary key, auto increment), name (varchar 100, not null), email (varchar 255, unique), and created_at (timestamp with default current timestamp).',
          starterCode: '-- Create the customers table\n',
          language: 'sql',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'CREATE TABLE customers (\n  id INT PRIMARY KEY AUTO_INCREMENT,\n  name VARCHAR(100) NOT NULL,\n  email VARCHAR(255) UNIQUE,\n  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n);',
            ),
          ],
          hint:
              'Define each column with its type and constraints. Use commas between columns.',
          solution:
              'CREATE TABLE customers (\n  id INT PRIMARY KEY AUTO_INCREMENT,\n  name VARCHAR(100) NOT NULL,\n  email VARCHAR(255) UNIQUE,\n  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n);',
        ),
        xpReward: 25,
        order: 9,
      ),
    ];
  }

  // ========================
  // PYTHON INTERMEDIATE COURSE
  // ========================
  static List<Lesson> getPythonIntermediateLessons() {
    return [
      // Lesson 1: OOP Basics
      Lesson(
        id: 'python_int_lesson_1',
        courseId: 'python-intermediate',
        moduleId: 'oop',
        title: 'Classes and Objects',
        description: 'Master Object-Oriented Programming in Python',
        theorySlides: [
          TheorySlide(
            title: 'What is OOP? 🏗️',
            content:
                'Object-Oriented Programming organizes code into objects - bundles of data and functionality.\n\nKey concepts:\n• **Class**: A blueprint for creating objects\n• **Object**: An instance of a class\n• **Attributes**: Data stored in an object\n• **Methods**: Functions that belong to an object',
            order: 0,
          ),
          TheorySlide(
            title: 'Why Use OOP? 💡',
            content:
                'Benefits of OOP:\n\n✅ **Modularity** - Code is organized into self-contained units\n✅ **Reusability** - Create once, use many times\n✅ **Maintainability** - Easy to update and fix\n✅ **Real-world modeling** - Objects represent real things',
            order: 1,
          ),
          TheorySlide(
            title: 'Creating a Class',
            content: 'Use the class keyword to define a blueprint.',
            codeSnippet: '''class Dog:
    def __init__(self, name, breed):
        self.name = name
        self.breed = breed
    
    def bark(self):
        return f"{self.name} says Woof!"

my_dog = Dog("Buddy", "Golden Retriever")
print(my_dog.bark())''',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'The self Parameter 🔑',
            content:
                '**self** refers to the current instance of the class.\n\nIt allows you to:\n• Access attributes: self.name\n• Call methods: self.bark()\n• Distinguish instance from class variables',
            codeSnippet: '''class Person:
    def __init__(self, name):
        self.name = name  # Instance attribute
    
    def greet(self):
        return f"Hi, I am {self.name}"''',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is __init__ used for?',
              options: [
                'Initialize object attributes',
                'Delete object',
                'Print object',
                'Import modules',
              ],
              correctAnswerIndex: 0,
              explanation:
                  '__init__ is the constructor that sets up initial state when an object is created.',
            ),
            QuizQuestion(
              question: 'What does "self" refer to?',
              options: [
                'The class itself',
                'The current instance',
                'The parent class',
                'A global variable',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'self refers to the current instance of the class being created or used.',
            ),
            QuizQuestion(
              question: 'How do you create an object from class Dog?',
              options: ['Dog.new()', 'new Dog()', 'Dog()', 'create Dog'],
              correctAnswerIndex: 2,
              explanation:
                  'In Python, you create objects by calling the class name like a function: Dog()',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create a Car Class',
          description:
              'Create a Car class:\n1. In __init__, store brand in self.brand\n2. In describe(), return "Brand: X" where X is the brand\n\nExpected output: Brand: Toyota',
          language: 'python',
          starterCode: '''class Car:
    def __init__(self, brand):
        # Step 1: Store brand in self.brand
        self.brand = # your code
    
    def describe(self):
        # Step 2: Return "Brand: {brand}"
        return # your code

car = Car("Toyota")
print(car.describe())''',
          testCases: [TestCase(input: '', expectedOutput: 'Brand: Toyota')],
          hint:
              'Step 1: self.brand = brand\nStep 2: return f"Brand: {self.brand}"',
          solution: '''class Car:
    def __init__(self, brand):
        self.brand = brand
    
    def describe(self):
        return f"Brand: {self.brand}"

car = Car("Toyota")
print(car.describe())''',
        ),
        xpReward: 30,
        order: 0,
      ),

      // Lesson 2: Inheritance
      Lesson(
        id: 'python_int_lesson_2',
        courseId: 'python-intermediate',
        moduleId: 'oop',
        title: 'Inheritance',
        description: 'Learn how to reuse code with class inheritance',
        theorySlides: [
          TheorySlide(
            title: 'What is Inheritance? 🌳',
            content:
                'Inheritance allows a class to inherit attributes and methods from another class.\n\nTerminology:\n• **Parent/Base class**: The class being inherited from\n• **Child/Derived class**: The class that inherits\n• **Override**: Replace parent method in child',
            order: 0,
          ),
          TheorySlide(
            title: 'Why Inheritance? 🎯',
            content:
                'Benefits:\n\n✅ **DRY** - Don\'t Repeat Yourself\n✅ **Hierarchy** - Model real relationships\n✅ **Extend** - Add features without changing original\n✅ **Polymorphism** - Same interface, different behavior',
            order: 1,
          ),
          TheorySlide(
            title: 'Creating Child Classes',
            content: 'Pass the parent class in parentheses.',
            codeSnippet: '''class Animal:
    def __init__(self, name):
        self.name = name

class Cat(Animal):
    def speak(self):
        return f"{self.name} says Meow!"

cat = Cat("Whiskers")
print(cat.speak())''',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Using super() 🦸',
            content: 'super() calls the parent class methods.',
            codeSnippet: '''class Animal:
    def __init__(self, name):
        self.name = name

class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)  # Call parent __init__
        self.breed = breed

dog = Dog("Max", "Labrador")
print(dog.name, dog.breed)''',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does super() do?',
              options: [
                'Creates new object',
                'Calls parent class methods',
                'Deletes class',
                'Makes code faster',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'super() allows calling methods from the parent class.',
            ),
            QuizQuestion(
              question: 'How do you create a child class?',
              options: [
                'class Child extends Parent',
                'class Child(Parent)',
                'class Child: Parent',
                'Child = Parent.extend()',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'In Python, put the parent class name in parentheses: class Child(Parent)',
            ),
            QuizQuestion(
              question: 'What is method overriding?',
              options: [
                'Deleting a method',
                'Redefining parent method in child',
                'Calling a method twice',
                'Making method private',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Override means defining a method in child class with same name as parent to replace behavior.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create Student Class',
          description:
              'Create Student class inheriting from Person with grade attribute.',
          language: 'python',
          starterCode: '''class Person:
    def __init__(self, name):
        self.name = name

class Student(Person):
    def __init__(self, name, grade):
        # Use super() and add grade
        pass
    
    def info(self):
        # Return "Name: X, Grade: Y"
        pass

s = Student("Alex", 10)
print(s.info())''',
          testCases: [
            TestCase(input: '', expectedOutput: 'Name: Alex, Grade: 10'),
          ],
          hint: 'Use super().__init__(name) then self.grade = grade',
          solution: '''class Person:
    def __init__(self, name):
        self.name = name

class Student(Person):
    def __init__(self, name, grade):
        super().__init__(name)
        self.grade = grade
    
    def info(self):
        return f"Name: {self.name}, Grade: {self.grade}"

s = Student("Alex", 10)
print(s.info())''',
        ),
        xpReward: 30,
        order: 1,
      ),

      // Lesson 3: List Comprehensions
      Lesson(
        id: 'python_int_lesson_3',
        courseId: 'python-intermediate',
        moduleId: 'advanced',
        title: 'List Comprehensions',
        description: 'Write elegant, Pythonic code',
        theorySlides: [
          TheorySlide(
            title: 'List Comprehensions ✨',
            content:
                'List comprehensions provide a concise way to create lists.\n\nSyntax: [expression for item in iterable]\nWith filter: [expression for item in iterable if condition]',
            order: 0,
          ),
          TheorySlide(
            title: 'Why List Comprehensions? 🚀',
            content:
                'Benefits:\n\n✅ **Readable** - Clear intent in one line\n✅ **Fast** - More efficient than loops\n✅ **Pythonic** - The "Python way"\n✅ **Flexible** - Filter and transform together',
            order: 1,
          ),
          TheorySlide(
            title: 'Basic Examples',
            content: 'Transform and filter data in one line.',
            codeSnippet: '''# Squares of 1-5
squares = [x**2 for x in range(1, 6)]
print(squares)  # [1, 4, 9, 16, 25]

# Even numbers only
evens = [x for x in range(10) if x % 2 == 0]
print(evens)  # [0, 2, 4, 6, 8]''',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Nested Comprehensions 🔄',
            content: 'Create 2D structures or flatten lists.',
            codeSnippet: '''# Flatten a 2D list
matrix = [[1, 2], [3, 4], [5, 6]]
flat = [num for row in matrix for num in row]
print(flat)  # [1, 2, 3, 4, 5, 6]

# Create multiplication table
table = [[i*j for j in range(1,4)] for i in range(1,4)]
# [[1,2,3], [2,4,6], [3,6,9]]''',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is [x*2 for x in [1,2,3]]?',
              options: ['[1,2,3]', '[2,4,6]', '[1,4,9]', 'Error'],
              correctAnswerIndex: 1,
              explanation: 'Each element is multiplied by 2.',
            ),
            QuizQuestion(
              question: 'What does [x for x in range(5) if x > 2] return?',
              options: ['[0,1,2]', '[3,4]', '[2,3,4]', '[0,1,2,3,4]'],
              correctAnswerIndex: 1,
              explanation:
                  'Only values greater than 2 pass the filter: 3 and 4.',
            ),
            QuizQuestion(
              question:
                  'Which is equivalent to: result = []; for x in items: result.append(x*2)?',
              options: [
                '[x*2 in items]',
                '[x*2 for x in items]',
                '[for x in items: x*2]',
                'items.map(x*2)',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'List comprehension syntax: [expression for item in iterable]',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Squares of Evens',
          description: 'Create list of squares of even numbers from 1 to 10.',
          language: 'python',
          starterCode: '''# Create squares of even numbers 1-10
# Expected: [4, 16, 36, 64, 100]
squares = # Your code
print(squares)''',
          testCases: [
            TestCase(input: '', expectedOutput: '[4, 16, 36, 64, 100]'),
          ],
          hint: 'Use if x % 2 == 0 and x**2',
          solution: '''squares = [x**2 for x in range(1, 11) if x % 2 == 0]
print(squares)''',
        ),
        xpReward: 25,
        order: 2,
      ),

      // Lesson 4: Lambda Functions
      Lesson(
        id: 'python_int_lesson_4',
        courseId: 'python-intermediate',
        moduleId: 'advanced',
        title: 'Lambda Functions',
        description: 'Create anonymous functions',
        theorySlides: [
          TheorySlide(
            title: 'Lambda Functions ⚡',
            content:
                'Lambda functions are small anonymous functions.\n\nSyntax: lambda args: expression\n\nPerfect for short, one-time functions.',
            order: 0,
          ),
          TheorySlide(
            title: 'Lambda vs Regular Functions 🆚',
            content:
                'Comparison:\n\n**Regular function:**\ndef add(a, b):\n    return a + b\n\n**Lambda function:**\nadd = lambda a, b: a + b\n\nUse lambda for simple, single-use operations.',
            order: 1,
          ),
          TheorySlide(
            title: 'Lambda with sorted()',
            content: 'Sort with custom keys.',
            codeSnippet:
                '''students = [("Alice", 85), ("Bob", 92), ("Charlie", 78)]

# Sort by grade (second element)
sorted_students = sorted(students, key=lambda s: s[1])
print(sorted_students)''',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Lambda with map() & filter() 🔧',
            content: 'Use lambda with functional programming tools.',
            codeSnippet: '''numbers = [1, 2, 3, 4, 5]

# Double each number
doubled = list(map(lambda x: x*2, numbers))
# [2, 4, 6, 8, 10]

# Keep only evens
evens = list(filter(lambda x: x%2==0, numbers))
# [2, 4]''',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Correct lambda to add two numbers?',
              options: [
                'lambda: a+b',
                'lambda a,b: a+b',
                'def lambda(a,b)',
                'a,b => a+b',
              ],
              correctAnswerIndex: 1,
              explanation: 'Syntax: lambda parameters: expression',
            ),
            QuizQuestion(
              question: 'What can lambda functions contain?',
              options: [
                'Multiple statements',
                'A single expression',
                'Loops and if/else blocks',
                'Class definitions',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Lambda functions can only contain a single expression, not multiple statements.',
            ),
            QuizQuestion(
              question: 'What does map(lambda x: x**2, [1,2,3]) return?',
              options: ['[1,2,3]', '[1,4,9]', '6', 'Error'],
              correctAnswerIndex: 1,
              explanation:
                  'map() applies the lambda to each element: 1²=1, 2²=4, 3²=9',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Sort by Length',
          description: 'Sort words by length using lambda.',
          language: 'python',
          starterCode: '''words = ["python", "is", "awesome"]
# Sort by length
result = sorted(words, key=# your lambda)
print(result)''',
          testCases: [
            TestCase(input: '', expectedOutput: "['is', 'python', 'awesome']"),
          ],
          hint: 'Use lambda w: len(w)',
          solution: '''words = ["python", "is", "awesome"]
result = sorted(words, key=lambda w: len(w))
print(result)''',
        ),
        xpReward: 25,
        order: 3,
      ),

      // Lesson 5: Exception Handling
      Lesson(
        id: 'python_int_lesson_5',
        courseId: 'python-intermediate',
        moduleId: 'errors',
        title: 'Exception Handling',
        description: 'Handle errors gracefully',
        theorySlides: [
          TheorySlide(
            title: 'Try/Except 🛡️',
            content:
                'Handle errors without crashing your program.\n\nCommon exceptions:\n• ValueError - wrong value type\n• TypeError - wrong operation on type\n• ZeroDivisionError - divide by zero\n• FileNotFoundError - missing file',
            order: 0,
          ),
          TheorySlide(
            title: 'Why Handle Exceptions? 💡',
            content:
                'Benefits:\n\n✅ **Graceful failure** - App doesn\'t crash\n✅ **User-friendly** - Show helpful error messages\n✅ **Recovery** - Try alternative approaches\n✅ **Logging** - Track errors for debugging',
            order: 1,
          ),
          TheorySlide(
            title: 'Basic Syntax',
            content: 'Wrap risky code in try/except.',
            codeSnippet: '''try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")
finally:
    print("This always runs")''',
            codeLanguage: 'python',
            order: 2,
          ),
          TheorySlide(
            title: 'Multiple Exceptions 🎯',
            content: 'Handle different errors differently.',
            codeSnippet: '''try:
    value = int(input("Enter number: "))
    result = 100 / value
except ValueError:
    print("Not a valid number!")
except ZeroDivisionError:
    print("Cannot divide by zero!")
except Exception as e:
    print(f"Unknown error: {e}")''',
            codeLanguage: 'python',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which block always runs?',
              options: ['try', 'except', 'finally', 'raise'],
              correctAnswerIndex: 2,
              explanation: 'finally always executes, regardless of exceptions.',
            ),
            QuizQuestion(
              question: 'How do you catch ANY exception?',
              options: ['except:', 'except All:', 'except *:', 'catch:'],
              correctAnswerIndex: 0,
              explanation:
                  'A bare "except:" catches all exceptions (though "except Exception:" is preferred).',
            ),
            QuizQuestion(
              question: 'What does "raise" do?',
              options: [
                'Catch exception',
                'Create/throw exception',
                'Print error',
                'Exit program',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'raise creates and throws an exception that can be caught by try/except.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Safe Division',
          description: 'Create safe_divide that returns "Error" on failure.',
          language: 'python',
          starterCode: '''def safe_divide(a, b):
    # Return result or "Error"
    pass

print(safe_divide(10, 2))
print(safe_divide(10, 0))''',
          testCases: [TestCase(input: '', expectedOutput: '5.0\nError')],
          hint: 'Use try/except ZeroDivisionError',
          solution: '''def safe_divide(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return "Error"

print(safe_divide(10, 2))
print(safe_divide(10, 0))''',
        ),
        xpReward: 25,
        order: 4,
      ),
    ];
  }

  // ========================
  // HTML/CSS INTERMEDIATE COURSE
  // ========================
  static List<Lesson> getHTMLCSSIntermediateLessons() {
    return [
      // Lesson 1: Flexbox
      Lesson(
        id: 'htmlcss_int_lesson_1',
        courseId: 'htmlcss-intermediate',
        moduleId: 'layout',
        title: 'Flexbox Layout',
        description: 'Master flexible box layout',
        theorySlides: [
          TheorySlide(
            title: 'What is Flexbox? 📦',
            content:
                'Flexbox is a one-dimensional layout method for rows or columns.\n\nKey properties:\n• display: flex\n• justify-content (main axis)\n• align-items (cross axis)\n• flex-direction',
            order: 0,
          ),
          TheorySlide(
            title: 'Flexbox Axes 🎯',
            content:
                'Two axes in flexbox:\n\n**Main Axis** - Direction items flow (row/column)\n• justify-content controls this\n\n**Cross Axis** - Perpendicular to main\n• align-items controls this',
            order: 1,
          ),
          TheorySlide(
            title: 'Centering with Flexbox',
            content: 'Center items easily.',
            codeSnippet: '''.container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}''',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Flex Item Properties 🔧',
            content: 'Control individual items:',
            codeSnippet: '''.item {
  flex-grow: 1;    /* Can grow */
  flex-shrink: 0;  /* Won't shrink */
  flex-basis: 200px; /* Starting size */
  
  /* Shorthand: flex: grow shrink basis */
  flex: 1 0 200px;
}''',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which property centers on main axis?',
              options: [
                'align-items',
                'justify-content',
                'flex-direction',
                'flex-wrap',
              ],
              correctAnswerIndex: 1,
              explanation: 'justify-content controls main axis alignment.',
            ),
            QuizQuestion(
              question: 'What does flex-direction: column do?',
              options: [
                'Items side by side',
                'Items stacked vertically',
                'Makes columns equal',
                'Hides items',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'column changes the main axis to vertical, stacking items top to bottom.',
            ),
            QuizQuestion(
              question: 'What does flex: 1 mean?',
              options: [
                'Fixed width of 1px',
                'Item takes equal share of space',
                'Only 1 item visible',
                'Error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'flex: 1 means flex-grow: 1, allowing the item to grow and fill available space.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Center a Box',
          description: 'Center a div using flexbox.',
          language: 'css',
          starterCode: '''.container {
  height: 200px;
  /* Add flexbox centering */
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'display: flex; justify-content: center; align-items: center;',
            ),
          ],
          hint: 'Use display: flex with justify-content and align-items center',
          solution: '''.container {
  height: 200px;
  display: flex;
  justify-content: center;
  align-items: center;
}''',
        ),
        xpReward: 30,
        order: 0,
      ),

      // Lesson 2: CSS Grid
      Lesson(
        id: 'htmlcss_int_lesson_2',
        courseId: 'htmlcss-intermediate',
        moduleId: 'layout',
        title: 'CSS Grid',
        description: 'Create two-dimensional layouts',
        theorySlides: [
          TheorySlide(
            title: 'CSS Grid 🔲',
            content:
                'CSS Grid creates layouts with rows AND columns.\n\nKey properties:\n• grid-template-columns\n• grid-template-rows\n• gap\n• fr unit (fraction)',
            order: 0,
          ),
          TheorySlide(
            title: 'Grid vs Flexbox 🆚',
            content:
                'When to use which:\n\n**Grid:** 2D layouts (rows AND columns)\n• Page layouts\n• Card grids\n• Complex structures\n\n**Flexbox:** 1D layouts (row OR column)\n• Navigation bars\n• Centering\n• Single row/column',
            order: 1,
          ),
          TheorySlide(
            title: 'Responsive Grid',
            content: 'Create responsive grids.',
            codeSnippet: '''.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}''',
            codeLanguage: 'css',
            order: 2,
          ),
          TheorySlide(
            title: 'Grid Areas 🗺️',
            content: 'Name areas for visual layouts.',
            codeSnippet: '''.layout {
  display: grid;
  grid-template-areas:
    "header header"
    "sidebar main"
    "footer footer";
  grid-template-columns: 200px 1fr;
}

.header { grid-area: header; }
.sidebar { grid-area: sidebar; }''',
            codeLanguage: 'css',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does 1fr mean?',
              options: ['1 pixel', '1 fraction of space', '1 frame', '1 row'],
              correctAnswerIndex: 1,
              explanation: 'fr is a fraction unit for available space.',
            ),
            QuizQuestion(
              question: 'What does auto-fit do in repeat()?',
              options: [
                'Fixed columns',
                'Fills row with as many columns as fit',
                'Single column',
                'Error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'auto-fit creates as many columns as can fit in the available space.',
            ),
            QuizQuestion(
              question: 'Which creates a 2x2 grid?',
              options: [
                'grid: 2x2',
                'grid-template: 2 2',
                'grid-template-columns: 1fr 1fr; grid-template-rows: 1fr 1fr',
                'columns: 2; rows: 2',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Define both columns and rows with grid-template-columns and grid-template-rows.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create 3-Column Grid',
          description: 'Create equal 3-column grid with gap.',
          language: 'css',
          starterCode: '''.grid {
  /* Create 3 equal columns with 16px gap */
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;',
            ),
          ],
          hint: 'Use repeat(3, 1fr) for 3 equal columns',
          solution: '''.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}''',
        ),
        xpReward: 30,
        order: 1,
      ),

      // Lesson 3: CSS Variables
      Lesson(
        id: 'htmlcss_int_lesson_3',
        courseId: 'htmlcss-intermediate',
        moduleId: 'modern',
        title: 'CSS Variables',
        description: 'Use custom properties for maintainable CSS',
        theorySlides: [
          TheorySlide(
            title: 'CSS Variables ✨',
            content:
                'Store and reuse values throughout your stylesheet.\n\nDefine with --name, use with var(--name)',
            order: 0,
          ),
          TheorySlide(
            title: 'Example',
            content: 'Define colors and spacing.',
            codeSnippet: ''':root {
  --primary: #0066ff;
  --spacing: 16px;
}

.button {
  background: var(--primary);
  padding: var(--spacing);
}''',
            codeLanguage: 'css',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'How to define a CSS variable?',
              options: [
                '\$var: value',
                '@var: value',
                '--var: value',
                'var = value',
              ],
              correctAnswerIndex: 2,
              explanation: 'CSS variables use double-dash prefix.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Define and Use Variable',
          description: 'Create --primary color and use it.',
          language: 'css',
          starterCode: ''':root {
  /* Define --primary as #0066ff */
}

.btn {
  /* Use --primary for background */
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput: '--primary: #0066ff; background: var(--primary);',
            ),
          ],
          hint: 'Define in :root, use with var()',
          solution: ''':root {
  --primary: #0066ff;
}

.btn {
  background: var(--primary);
}''',
        ),
        xpReward: 25,
        order: 2,
      ),

      // Lesson 4: CSS Animations
      Lesson(
        id: 'htmlcss_int_lesson_4',
        courseId: 'htmlcss-intermediate',
        moduleId: 'animations',
        title: 'CSS Animations',
        description: 'Create smooth animations',
        theorySlides: [
          TheorySlide(
            title: 'CSS Animations 🎬',
            content:
                'Two types:\n• **Transitions**: Between two states\n• **Keyframes**: Multi-step animations',
            order: 0,
          ),
          TheorySlide(
            title: 'Keyframes',
            content: 'Define animation steps.',
            codeSnippet: '''@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.element {
  animation: fadeIn 0.5s ease;
}''',
            codeLanguage: 'css',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does infinite do?',
              options: [
                'Runs faster',
                'Loops forever',
                'Increases size',
                'Pauses',
              ],
              correctAnswerIndex: 1,
              explanation: 'infinite makes the animation repeat forever.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Pulse Animation',
          description: 'Create a pulse animation that scales 1 to 1.1.',
          language: 'css',
          starterCode: '''@keyframes pulse {
  /* 0%: scale(1), 50%: scale(1.1), 100%: scale(1) */
}

.box {
  animation: pulse 1s infinite;
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  '0% { transform: scale(1); } 50% { transform: scale(1.1); } 100% { transform: scale(1); }',
            ),
          ],
          hint: 'Use transform: scale() at each keyframe',
          solution: '''@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

.box {
  animation: pulse 1s infinite;
}''',
        ),
        xpReward: 30,
        order: 3,
      ),

      // Lesson 5: Media Queries
      Lesson(
        id: 'htmlcss_int_lesson_5',
        courseId: 'htmlcss-intermediate',
        moduleId: 'responsive',
        title: 'Media Queries',
        description: 'Build responsive layouts',
        theorySlides: [
          TheorySlide(
            title: 'Responsive Design 📱',
            content:
                'Apply different styles based on screen size.\n\nBreakpoints:\n• Mobile: < 768px\n• Tablet: 768px - 1024px\n• Desktop: > 1024px',
            order: 0,
          ),
          TheorySlide(
            title: 'Mobile First',
            content: 'Start with mobile, add desktop styles.',
            codeSnippet: '''.container {
  padding: 16px;
}

@media (min-width: 768px) {
  .container {
    padding: 32px;
    max-width: 1200px;
  }
}''',
            codeLanguage: 'css',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is mobile-first?',
              options: [
                'Only support mobile',
                'Write mobile CSS first, add desktop',
                'Test mobile first',
                'Ignore desktop',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Mobile-first uses base styles for mobile, media queries for larger screens.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Responsive Grid',
          description:
              'Create grid that is 1 column on mobile, 2 on tablet (768px+).',
          language: 'css',
          starterCode: '''.grid {
  display: grid;
  grid-template-columns: 1fr;
}

/* Add media query for 768px+ */''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  '@media (min-width: 768px) { .grid { grid-template-columns: 1fr 1fr; } }',
            ),
          ],
          hint: 'Use @media (min-width: 768px)',
          solution: '''.grid {
  display: grid;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .grid {
    grid-template-columns: 1fr 1fr;
  }
}''',
        ),
        xpReward: 30,
        order: 4,
      ),
    ];
  }

  // ========================
  // JAVASCRIPT INTERMEDIATE COURSE
  // ========================
  static List<Lesson> getJavaScriptIntermediateLessons() {
    return [
      // Lesson 1: ES6+ Features
      Lesson(
        id: 'js_int_lesson_1',
        courseId: 'javascript-intermediate',
        moduleId: 'es6',
        title: 'ES6+ Features',
        description: 'Modern JavaScript syntax',
        theorySlides: [
          TheorySlide(
            title: 'ES6+ Modern Syntax 🚀',
            content:
                'Key ES6+ features:\n• Destructuring\n• Spread operator\n• Rest parameters\n• Default parameters\n• Template literals',
            order: 0,
          ),
          TheorySlide(
            title: 'Destructuring',
            content: 'Extract values from arrays and objects.',
            codeSnippet: '''// Array destructuring
const [first, second] = [1, 2, 3];

// Object destructuring
const { name, age } = { name: "Alex", age: 25 };

// With defaults
const { role = "user" } = {};
console.log(role); // "user"''',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Template Literals 📝',
            content:
                'Powerful string formatting:\n• Use backticks ` instead of quotes\n• Embed expressions with \${}\n• Multi-line strings built-in\n• Tagged templates for custom processing',
            codeSnippet: '''// String interpolation
const name = "Alex";
const greeting = `Hello, \${name}!`;

// Expressions in templates
const price = 19.99;
const qty = 3;
console.log(`Total: \$\${price * qty}`); // "Total: \$59.97"

// Multi-line strings
const html = `
  <div class="card">
    <h2>\${name}</h2>
    <p>Welcome!</p>
  </div>
`;''',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Default Parameters 🎯',
            content:
                'Set default values for function parameters:\n• Defaults used when argument is undefined\n• Can use expressions as defaults\n• Earlier params available in later defaults',
            codeSnippet: '''// Basic default parameters
function greet(name = "Guest", greeting = "Hello") {
  return `\${greeting}, \${name}!`;
}

greet();              // "Hello, Guest!"
greet("Alex");        // "Hello, Alex!"
greet("Alex", "Hi");  // "Hi, Alex!"

// Expression as default
function createUser(name, role = "user", id = Date.now()) {
  return { name, role, id };
}

// Using earlier param in later default
function fetchData(url, timeout = 5000, retries = timeout > 3000 ? 1 : 3) {
  console.log(`Fetching \${url}, timeout: \${timeout}, retries: \${retries}`);
}''',
            codeLanguage: 'javascript',
            order: 3,
          ),
          TheorySlide(
            title: 'Enhanced Object Literals ⚡',
            content:
                'Shorter syntax for objects:\n• Property shorthand\n• Method shorthand\n• Computed property names',
            codeSnippet: '''const name = "Alex";
const age = 25;

// Property shorthand
const user = { name, age }; // Same as { name: name, age: age }

// Method shorthand
const calculator = {
  add(a, b) { return a + b; },     // Instead of add: function(a,b)
  subtract(a, b) { return a - b; }
};

// Computed property names
const prop = "status";
const obj = {
  [prop]: "active",           // { status: "active" }
  [`\${prop}Code`]: 200       // { statusCode: 200 }
};''',
            codeLanguage: 'javascript',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does const [a, b] = [1, 2] do?',
              options: [
                'Creates array',
                'Destructures array',
                'Copies array',
                'Error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Array destructuring assigns array elements to variables.',
            ),
            QuizQuestion(
              question: 'Which syntax is correct for template literals?',
              options: [
                '`Hello \${name}`',
                '"Hello \${name}"',
                '\'Hello \${name}\'',
                '"Hello " + name',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Template literals use backticks ` and \${} for interpolation.',
            ),
            QuizQuestion(
              question:
                  'What happens when you call greet() with function greet(name = "World")?',
              options: [
                'Error - missing argument',
                'Returns undefined',
                'Uses "World" as name',
                'Returns null',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Default parameters are used when arguments are undefined or not provided.',
            ),
            QuizQuestion(
              question: 'What is { name, age } shorthand for?',
              options: [
                '{ name: "name", age: "age" }',
                '{ name: name, age: age }',
                '[name, age]',
                'Error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Property shorthand creates properties with variable names and values.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Destructure User',
          description:
              'Extract name and email from the user object using destructuring.\n\nInstead of:\nconst name = user.name;\nconst email = user.email;\n\nUse:\nconst { name, email } = user;',
          language: 'javascript',
          starterCode:
              '''const user = { name: "Alex", email: "alex@test.com", age: 25 };

// Use destructuring to extract name and email
const { name, email } = // complete this line

console.log(name, email);''',
          testCases: [
            TestCase(input: '', expectedOutput: 'Alex alex@test.com'),
          ],
          hint: 'Complete the line: const { name, email } = user;',
          solution:
              '''const user = { name: "Alex", email: "alex@test.com", age: 25 };

const { name, email } = user;

console.log(name, email);''',
        ),
        xpReward: 30,
        order: 0,
      ),

      // Lesson 2: Spread & Rest
      Lesson(
        id: 'js_int_lesson_2',
        courseId: 'javascript-intermediate',
        moduleId: 'es6',
        title: 'Spread & Rest',
        description: 'Master ... operator',
        theorySlides: [
          TheorySlide(
            title: 'Spread Operator ... 📤',
            content:
                'Spread expands elements:\n• Combine arrays\n• Clone objects\n• Pass arguments',
            order: 0,
          ),
          TheorySlide(
            title: 'Examples',
            content: 'Spread in action.',
            codeSnippet: '''// Combine arrays
const arr1 = [1, 2];
const arr2 = [3, 4];
const combined = [...arr1, ...arr2]; // [1,2,3,4]

// Clone & extend object
const user = { name: "Alex" };
const updated = { ...user, age: 25 };''',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Object Spread Deep Dive 🔄',
            content:
                'Object spread for immutable updates:\n• Clone objects without mutation\n• Override specific properties\n• Merge multiple objects\n• Order matters for overrides!',
            codeSnippet: '''// Shallow clone
const original = { a: 1, b: 2 };
const clone = { ...original };

// Override properties (last value wins)
const defaults = { theme: "light", lang: "en" };
const userPrefs = { theme: "dark" };
const settings = { ...defaults, ...userPrefs };
// { theme: "dark", lang: "en" }

// Add new properties
const product = { name: "Phone", price: 999 };
const withDiscount = { ...product, discount: 0.1, finalPrice: 899 };

// Nested objects (shallow copy warning!)
const user = { name: "Alex", address: { city: "NYC" } };
const copy = { ...user };
copy.address.city = "LA"; // Also changes original!''',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Rest Parameters in Functions 📥',
            content:
                'Collect remaining arguments:\n• Must be last parameter\n• Creates a real array (not arguments object)\n• Works with destructuring',
            codeSnippet: '''// Collect remaining args
function sum(first, ...rest) {
  console.log(first);  // 1
  console.log(rest);   // [2, 3, 4, 5]
  return rest.reduce((a, b) => a + b, first);
}
sum(1, 2, 3, 4, 5); // 15

// With destructuring
function processUser({ name, ...otherProps }) {
  console.log(name);        // "Alex"
  console.log(otherProps);  // { age: 25, role: "admin" }
}
processUser({ name: "Alex", age: 25, role: "admin" });

// Real array vs arguments object
function oldWay() {
  // arguments is array-like, not real array
  return Array.from(arguments).map(x => x * 2);
}
const newWay = (...nums) => nums.map(x => x * 2); // Cleaner!''',
            codeLanguage: 'javascript',
            order: 3,
          ),
          TheorySlide(
            title: 'Spread vs Rest Comparison 🎯',
            content:
                'Same syntax, different contexts:\n• Spread: Expands (unpacks)\n• Rest: Collects (packs)\n• Position determines behavior',
            codeSnippet: '''// SPREAD - expands elements
const nums = [1, 2, 3];
console.log(...nums);        // 1 2 3 (expanded)
console.log(Math.max(...nums)); // 3

// REST - collects elements
const [first, ...remaining] = [1, 2, 3, 4];
// first = 1, remaining = [2, 3, 4]

// Both in same function
function merge(target, ...sources) {
  // ...sources is REST (collecting args)
  return sources.reduce((acc, src) => ({
    ...acc,    // SPREAD (expanding object)
    ...src     // SPREAD (expanding object)
  }), target);
}

merge({}, { a: 1 }, { b: 2 }); // { a: 1, b: 2 }''',
            codeLanguage: 'javascript',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What is rest parameters?',
              options: [
                'Pause function',
                'Collect remaining args',
                'Return nothing',
                'Loop',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Rest (...args) collects remaining arguments into array.',
            ),
            QuizQuestion(
              question:
                  'What does { ...obj1, ...obj2 } produce if both have property "x"?',
              options: [
                'Error - duplicate key',
                'obj1.x wins',
                'obj2.x wins',
                'Both values in array',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'In object spread, later properties override earlier ones.',
            ),
            QuizQuestion(
              question:
                  'Where must rest parameter appear in function signature?',
              options: [
                'First position',
                'Any position',
                'Last position',
                'Middle position',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Rest parameter must be the last parameter in a function.',
            ),
            QuizQuestion(
              question: 'What does const [a, ...b] = [1, 2, 3] assign to b?',
              options: ['2', '[2, 3]', '3', 'undefined'],
              correctAnswerIndex: 1,
              explanation:
                  'Rest in destructuring collects remaining elements into an array.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Merge Arrays',
          description: 'Merge two arrays with spread operator.',
          language: 'javascript',
          starterCode: '''const nums1 = [1, 2, 3];
const nums2 = [4, 5, 6];

// Use spread to merge
const merged = ;

console.log(merged);''',
          testCases: [
            TestCase(input: '', expectedOutput: '[ 1, 2, 3, 4, 5, 6 ]'),
          ],
          hint: 'Use [...nums1, ...nums2]',
          solution: '''const nums1 = [1, 2, 3];
const nums2 = [4, 5, 6];

const merged = [...nums1, ...nums2];

console.log(merged);''',
        ),
        xpReward: 25,
        order: 1,
      ),

      // Lesson 3: Array Methods
      Lesson(
        id: 'js_int_lesson_3',
        courseId: 'javascript-intermediate',
        moduleId: 'functional',
        title: 'Array Methods',
        description: 'map, filter, reduce mastery',
        theorySlides: [
          TheorySlide(
            title: 'Functional Array Methods 🔧',
            content:
                'Transform arrays without mutation:\n• **map**: Transform each element\n• **filter**: Keep matching elements\n• **reduce**: Combine to single value\n• **find**: Get first match',
            order: 0,
          ),
          TheorySlide(
            title: 'Chaining Methods',
            content: 'Chain for powerful transformations.',
            codeSnippet: '''const numbers = [1, 2, 3, 4, 5];

const result = numbers
  .filter(n => n > 2)      // [3, 4, 5]
  .map(n => n * 2)         // [6, 8, 10]
  .reduce((a, b) => a + b); // 24

console.log(result);''',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'find() and findIndex() 🔍',
            content:
                'Search for single elements:\n• find(): Returns first matching element\n• findIndex(): Returns index of first match\n• Returns undefined/-1 if not found\n• Stops searching after first match',
            codeSnippet: '''const users = [
  { id: 1, name: "Alex", active: false },
  { id: 2, name: "Sam", active: true },
  { id: 3, name: "Jordan", active: true }
];

// Find first active user
const activeUser = users.find(user => user.active);
console.log(activeUser); // { id: 2, name: "Sam", active: true }

// Find index of user by id
const index = users.findIndex(user => user.id === 3);
console.log(index); // 2

// Not found cases
const admin = users.find(user => user.role === "admin");
console.log(admin); // undefined

const adminIndex = users.findIndex(user => user.role === "admin");
console.log(adminIndex); // -1''',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'some() and every() ✅',
            content:
                'Test array conditions:\n• some(): At least one matches (OR)\n• every(): All must match (AND)\n• Return boolean values\n• Short-circuit when result is determined',
            codeSnippet: '''const numbers = [1, 2, 3, 4, 5];

// some() - at least one passes test
const hasEven = numbers.some(n => n % 2 === 0);
console.log(hasEven); // true (2 and 4 are even)

const hasNegative = numbers.some(n => n < 0);
console.log(hasNegative); // false

// every() - all must pass test
const allPositive = numbers.every(n => n > 0);
console.log(allPositive); // true

const allEven = numbers.every(n => n % 2 === 0);
console.log(allEven); // false

// Practical example: form validation
const fields = [
  { name: "email", valid: true },
  { name: "password", valid: true },
  { name: "phone", valid: false }
];
const formValid = fields.every(field => field.valid);
console.log(formValid); // false''',
            codeLanguage: 'javascript',
            order: 3,
          ),
          TheorySlide(
            title: 'includes() and flat() 📋',
            content:
                'More useful array methods:\n• includes(): Check if element exists\n• flat(): Flatten nested arrays\n• flatMap(): Map then flatten',
            codeSnippet: '''// includes() - simple existence check
const fruits = ["apple", "banana", "orange"];
console.log(fruits.includes("banana")); // true
console.log(fruits.includes("grape"));  // false

// With fromIndex
console.log(fruits.includes("apple", 1)); // false (starts from index 1)

// flat() - flatten nested arrays
const nested = [1, [2, 3], [4, [5, 6]]];
console.log(nested.flat());    // [1, 2, 3, 4, [5, 6]]
console.log(nested.flat(2));   // [1, 2, 3, 4, 5, 6]
console.log(nested.flat(Infinity)); // Flatten all levels

// flatMap() - map + flat(1) combined
const sentences = ["Hello world", "How are you"];
const words = sentences.flatMap(s => s.split(" "));
console.log(words); // ["Hello", "world", "How", "are", "you"]''',
            codeLanguage: 'javascript',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does filter() return?',
              options: [
                'Modified array',
                'New array with matches',
                'Boolean',
                'Single value',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'filter() returns new array with elements passing the test.',
            ),
            QuizQuestion(
              question: 'What does find() return if no element matches?',
              options: ['Empty array', 'null', 'undefined', 'false'],
              correctAnswerIndex: 2,
              explanation:
                  'find() returns undefined when no element satisfies the condition.',
            ),
            QuizQuestion(
              question: 'What does [1,2,3].some(n => n > 2) return?',
              options: ['[3]', '3', 'true', 'false'],
              correctAnswerIndex: 2,
              explanation:
                  'some() returns true because at least one element (3) is greater than 2.',
            ),
            QuizQuestion(
              question: 'What does [1,2,3].every(n => n > 0) return?',
              options: ['[1,2,3]', '3', 'true', 'false'],
              correctAnswerIndex: 2,
              explanation:
                  'every() returns true because all elements are greater than 0.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Sum of Squares',
          description: 'Get sum of squares of even numbers.',
          language: 'javascript',
          starterCode: '''const nums = [1, 2, 3, 4, 5, 6];

// Filter evens, square them, sum
const result = nums

console.log(result);''',
          testCases: [TestCase(input: '', expectedOutput: '56')],
          hint: 'Chain filter, map, reduce',
          solution: '''const nums = [1, 2, 3, 4, 5, 6];

const result = nums
  .filter(n => n % 2 === 0)
  .map(n => n * n)
  .reduce((a, b) => a + b);

console.log(result);''',
        ),
        xpReward: 30,
        order: 2,
      ),

      // Lesson 4: Promises
      Lesson(
        id: 'js_int_lesson_4',
        courseId: 'javascript-intermediate',
        moduleId: 'async',
        title: 'Promises Deep Dive',
        description: 'Handle async operations',
        theorySlides: [
          TheorySlide(
            title: 'Promises ⏳',
            content:
                'A Promise represents future value.\n\nStates:\n• **pending**: Initial\n• **fulfilled**: Success\n• **rejected**: Error',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Promises',
            content: 'Create and chain promises.',
            codeSnippet: '''const fetchData = () => {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve({ name: "Data" });
    }, 1000);
  });
};

fetchData()
  .then(data => console.log(data))
  .catch(err => console.error(err));''',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Promise.all() - Parallel Execution 🚀',
            content:
                'Run multiple promises in parallel:\n• All must succeed for success\n• Fails fast on first rejection\n• Results in same order as input\n• Great for independent async tasks',
            codeSnippet: '''// Fetch multiple resources in parallel
const fetchUser = () => fetch("/api/user").then(r => r.json());
const fetchPosts = () => fetch("/api/posts").then(r => r.json());
const fetchComments = () => fetch("/api/comments").then(r => r.json());

// All requests run simultaneously
Promise.all([fetchUser(), fetchPosts(), fetchComments()])
  .then(([user, posts, comments]) => {
    console.log("User:", user);
    console.log("Posts:", posts);
    console.log("Comments:", comments);
  })
  .catch(error => {
    // If ANY request fails, catch is called
    console.error("One request failed:", error);
  });

// Practical example: batch processing
const ids = [1, 2, 3, 4, 5];
const fetchAllUsers = Promise.all(
  ids.map(id => fetch(`/api/users/\${id}`).then(r => r.json()))
);''',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Promise Error Handling 🛡️',
            content:
                'Proper error handling strategies:\n• .catch() for chain errors\n• reject() for explicit failures\n• Error propagation through chain\n• finally() for cleanup',
            codeSnippet: '''// Basic error handling
fetchData()
  .then(data => processData(data))
  .then(result => saveResult(result))
  .catch(error => {
    // Catches errors from ANY step above
    console.error("Error occurred:", error.message);
  })
  .finally(() => {
    // Always runs - success or failure
    console.log("Cleanup complete");
    hideLoadingSpinner();
  });

// Creating rejected promise
const validate = (data) => {
  return new Promise((resolve, reject) => {
    if (!data.email) {
      reject(new Error("Email is required"));
    } else {
      resolve(data);
    }
  });
};

// Recovering from errors
fetchData()
  .catch(err => {
    console.warn("Fetch failed, using cache");
    return getCachedData(); // Return fallback
  })
  .then(data => console.log(data)); // Continues with cached data''',
            codeLanguage: 'javascript',
            order: 3,
          ),
          TheorySlide(
            title: 'Promise.allSettled() & Promise.race() 🏁',
            content:
                'More Promise combinators:\n• allSettled(): Wait for all, never rejects\n• race(): First to settle wins\n• any(): First to fulfill wins',
            codeSnippet:
                '''// Promise.allSettled - get all results regardless of success/failure
const promises = [
  fetch("/api/users"),
  fetch("/api/invalid-endpoint"), // This might fail
  fetch("/api/posts")
];

Promise.allSettled(promises)
  .then(results => {
    results.forEach((result, i) => {
      if (result.status === "fulfilled") {
        console.log(`Promise \${i}: Success`, result.value);
      } else {
        console.log(`Promise \${i}: Failed`, result.reason);
      }
    });
  });

// Promise.race - first to complete wins
const timeout = new Promise((_, reject) => 
  setTimeout(() => reject(new Error("Timeout")), 5000)
);

Promise.race([fetchData(), timeout])
  .then(data => console.log("Got data:", data))
  .catch(err => console.error("Request timed out"));

// Promise.any - first successful wins (ignores rejections)
Promise.any([fetchFromServer1(), fetchFromServer2(), fetchFromServer3()])
  .then(data => console.log("First successful:", data));''',
            codeLanguage: 'javascript',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does .catch() handle?',
              options: [
                'Success',
                'Rejection/errors',
                'Pending state',
                'All states',
              ],
              correctAnswerIndex: 1,
              explanation: '.catch() handles rejected promises and errors.',
            ),
            QuizQuestion(
              question: 'What happens if one promise in Promise.all() rejects?',
              options: [
                'Other promises continue',
                'All results are returned',
                'Entire Promise.all rejects',
                'Only failed one is ignored',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Promise.all() fails fast - it rejects immediately when any promise rejects.',
            ),
            QuizQuestion(
              question: 'What does .finally() do?',
              options: [
                'Only runs on success',
                'Only runs on failure',
                'Runs after success or failure',
                'Cancels the promise',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'finally() always executes after the promise settles, regardless of outcome.',
            ),
            QuizQuestion(
              question:
                  'Which method waits for all promises and never rejects?',
              options: [
                'Promise.all()',
                'Promise.race()',
                'Promise.allSettled()',
                'Promise.any()',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Promise.allSettled() waits for all promises and returns their results, never rejects.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create Promise',
          description: 'Create promise that resolves with "Hello" after delay.',
          language: 'javascript',
          starterCode: '''const greet = () => {
  return new Promise((resolve, reject) => {
    // Resolve with "Hello"
  });
};

greet().then(msg => console.log(msg));''',
          testCases: [TestCase(input: '', expectedOutput: 'Hello')],
          hint: 'Use resolve("Hello")',
          solution: '''const greet = () => {
  return new Promise((resolve, reject) => {
    resolve("Hello");
  });
};

greet().then(msg => console.log(msg));''',
        ),
        xpReward: 30,
        order: 3,
      ),

      // Lesson 5: Async/Await
      Lesson(
        id: 'js_int_lesson_5',
        courseId: 'javascript-intermediate',
        moduleId: 'async',
        title: 'Async/Await',
        description: 'Clean async syntax',
        theorySlides: [
          TheorySlide(
            title: 'Async/Await ✨',
            content:
                'Write async code like sync:\n• **async**: Makes function return Promise\n• **await**: Pauses until Promise resolves\n• Use try/catch for errors',
            order: 0,
          ),
          TheorySlide(
            title: 'Example',
            content: 'Clean async code.',
            codeSnippet: '''async function fetchUser() {
  try {
    const response = await fetch("/api/user");
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Failed:", error);
  }
}''',
            codeLanguage: 'javascript',
            order: 1,
          ),
          TheorySlide(
            title: 'Try/Catch Error Handling 🛡️',
            content:
                'Proper error handling with async/await:\n• Wrap await calls in try/catch\n• Catch specific error types\n• Always handle errors gracefully\n• Can re-throw for higher-level handling',
            codeSnippet: '''async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/\${userId}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: \${response.status}`);
    }
    
    const data = await response.json();
    return data;
    
  } catch (error) {
    if (error.name === "TypeError") {
      console.error("Network error - check connection");
    } else if (error.message.includes("404")) {
      console.error("User not found");
    } else {
      console.error("Unexpected error:", error.message);
    }
    
    // Return fallback or re-throw
    return { error: true, message: error.message };
  } finally {
    // Cleanup - always runs
    console.log("Request completed");
  }
}''',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Parallel Await with Promise.all 🚀',
            content:
                'Run async operations in parallel:\n• Sequential await is slow\n• Promise.all() runs in parallel\n• Use when requests are independent\n• Significant performance improvement',
            codeSnippet: '''// ❌ SLOW - Sequential (waits for each)
async function getDataSlow() {
  const users = await fetchUsers();    // 1 second
  const posts = await fetchPosts();    // 1 second  
  const comments = await fetchComments(); // 1 second
  // Total: ~3 seconds
  return { users, posts, comments };
}

// ✅ FAST - Parallel (all at once)
async function getDataFast() {
  const [users, posts, comments] = await Promise.all([
    fetchUsers(),
    fetchPosts(),
    fetchComments()
  ]);
  // Total: ~1 second (longest request)
  return { users, posts, comments };
}

// Mix parallel and sequential when needed
async function processOrder(orderId) {
  // First, get order (need this before anything else)
  const order = await fetchOrder(orderId);
  
  // Then fetch user and items in parallel
  const [user, items] = await Promise.all([
    fetchUser(order.userId),
    fetchItems(order.itemIds)
  ]);
  
  return { order, user, items };
}''',
            codeLanguage: 'javascript',
            order: 3,
          ),
          TheorySlide(
            title: 'Advanced Async Patterns 🎯',
            content:
                'Common async patterns:\n• Async loops (for...of with await)\n• Retry logic\n• Timeout handling\n• Async IIFE',
            codeSnippet: '''// Async for...of loop (sequential)
async function processItems(items) {
  for (const item of items) {
    await processItem(item); // One at a time
  }
}

// Retry pattern
async function fetchWithRetry(url, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      return await fetch(url).then(r => r.json());
    } catch (error) {
      if (i === retries - 1) throw error;
      console.log(`Retry \${i + 1}/\${retries}...`);
      await delay(1000 * (i + 1)); // Exponential backoff
    }
  }
}

// Timeout wrapper
async function fetchWithTimeout(url, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, { signal: controller.signal });
    return await response.json();
  } finally {
    clearTimeout(timeoutId);
  }
}

// Async IIFE (Immediately Invoked Function Expression)
(async () => {
  const data = await fetchData();
  console.log(data);
})();''',
            codeLanguage: 'javascript',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Where can you use await?',
              options: [
                'Anywhere',
                'Inside async function',
                'Only in callbacks',
                'Only in classes',
              ],
              correctAnswerIndex: 1,
              explanation: 'await can only be used inside async functions.',
            ),
            QuizQuestion(
              question:
                  'What is the benefit of using try/catch with async/await?',
              options: [
                'Makes code faster',
                'Handles errors synchronously-looking way',
                'Prevents all errors',
                'Not needed with async/await',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'try/catch provides clean, synchronous-style error handling for async code.',
            ),
            QuizQuestion(
              question: 'How do you run multiple awaits in parallel?',
              options: [
                'Put them on same line',
                'Use Promise.all()',
                'Use async.parallel()',
                'Not possible',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Promise.all() runs multiple promises in parallel and awaits all results.',
            ),
            QuizQuestion(
              question: 'What does an async function always return?',
              options: [
                'undefined',
                'The return value directly',
                'A Promise',
                'An async object',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Async functions always return a Promise, even if you return a plain value.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Async Greeting',
          description: 'Create async function that returns greeting.',
          language: 'javascript',
          starterCode:
              '''const delay = (ms) => new Promise(r => setTimeout(r, ms));

async function greet(name) {
  // await delay, then return "Hello, {name}!"
}

greet("World").then(console.log);''',
          testCases: [TestCase(input: '', expectedOutput: 'Hello, World!')],
          hint: 'await delay(100) then return template literal',
          solution:
              '''const delay = (ms) => new Promise(r => setTimeout(r, ms));

async function greet(name) {
  await delay(100);
  return `Hello, \${name}!`;
}

greet("World").then(console.log);''',
        ),
        xpReward: 30,
        order: 4,
      ),
    ];
  }

  // ========================
  // SQL INTERMEDIATE COURSE
  // ========================
  static List<Lesson> getSQLIntermediateLessons() {
    return [
      // Lesson 1: JOINs
      Lesson(
        id: 'sql_int_lesson_1',
        courseId: 'sql-intermediate',
        moduleId: 'joins',
        title: 'SQL JOINs',
        description: 'Combine data from multiple tables',
        theorySlides: [
          TheorySlide(
            title: 'JOINs 🔗',
            content:
                'Combine rows from multiple tables:\n• **INNER JOIN**: Matching rows only\n• **LEFT JOIN**: All left + matching right\n• **RIGHT JOIN**: All right + matching left\n• **FULL JOIN**: All from both',
            order: 0,
          ),
          TheorySlide(
            title: 'INNER JOIN',
            content: 'Get matching records from both tables.',
            codeSnippet: '''SELECT users.name, orders.total
FROM users
INNER JOIN orders ON users.id = orders.user_id;

-- Only users WITH orders''',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'RIGHT & FULL JOIN 🔄',
            content:
                'More JOIN types:\n• **RIGHT JOIN**: All right table rows + matching left\n• **FULL OUTER JOIN**: All rows from both tables\n• NULL fills missing matches',
            codeSnippet: '''-- RIGHT JOIN: All orders, even without users
SELECT users.name, orders.total
FROM users
RIGHT JOIN orders ON users.id = orders.user_id;

-- FULL JOIN: All users AND all orders
SELECT users.name, orders.total
FROM users
FULL OUTER JOIN orders ON users.id = orders.user_id;''',
            codeLanguage: 'sql',
            order: 2,
          ),
          TheorySlide(
            title: 'Multiple JOINs 🔗🔗',
            content:
                'Chain multiple tables together:\n• Join as many tables as needed\n• Each JOIN adds more data\n• Order matters for readability',
            codeSnippet: '''SELECT 
  u.name,
  o.order_date,
  p.product_name,
  oi.quantity
FROM users u
INNER JOIN orders o ON u.id = o.user_id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id;''',
            codeLanguage: 'sql',
            order: 3,
          ),
          TheorySlide(
            title: 'Self JOIN 🪞',
            content:
                'Join a table to itself:\n• Useful for hierarchical data\n• Compare rows in same table\n• Must use table aliases',
            codeSnippet: '''-- Find employees and their managers
SELECT 
  e.name AS employee,
  m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;

-- Find pairs of users from same city
SELECT a.name, b.name, a.city
FROM users a
JOIN users b ON a.city = b.city AND a.id < b.id;''',
            codeLanguage: 'sql',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Which JOIN includes all left table rows?',
              options: ['INNER JOIN', 'LEFT JOIN', 'RIGHT JOIN', 'CROSS JOIN'],
              correctAnswerIndex: 1,
              explanation: 'LEFT JOIN keeps all rows from left table.',
            ),
            QuizQuestion(
              question: 'What does FULL OUTER JOIN return?',
              options: [
                'Only matching rows',
                'All rows from left table',
                'All rows from right table',
                'All rows from both tables',
              ],
              correctAnswerIndex: 3,
              explanation:
                  'FULL OUTER JOIN returns all rows from both tables, with NULL for non-matching rows.',
            ),
            QuizQuestion(
              question: 'When would you use a self JOIN?',
              options: [
                'To duplicate a table',
                'To find hierarchical relationships in same table',
                'To delete duplicates',
                'To create a backup',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Self JOINs are useful for hierarchical data like employees/managers or finding relationships within the same table.',
            ),
            QuizQuestion(
              question: 'How many tables can you JOIN in one query?',
              options: [
                'Only 2',
                'Maximum 5',
                'Maximum 10',
                'As many as needed',
              ],
              correctAnswerIndex: 3,
              explanation:
                  'You can chain as many JOINs as needed, though performance may decrease with many tables.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Join Users and Orders',
          description:
              'Write a query to get:\n• users.name\n• orders.total\n\nUse LEFT JOIN to include users even if they have no orders.\n\nStructure:\nSELECT ... FROM users LEFT JOIN orders ON ...',
          language: 'sql',
          starterCode: '''-- Select users.name and orders.total
-- Use LEFT JOIN to include all users
SELECT users.name, orders.total
FROM users
-- Add LEFT JOIN here
''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT users.name, orders.total FROM users LEFT JOIN orders ON users.id = orders.user_id;',
            ),
          ],
          hint: 'Add: LEFT JOIN orders ON users.id = orders.user_id',
          solution: '''SELECT users.name, orders.total
FROM users
LEFT JOIN orders ON users.id = orders.user_id;''',
        ),
        xpReward: 30,
        order: 0,
      ),

      // Lesson 2: Subqueries
      Lesson(
        id: 'sql_int_lesson_2',
        courseId: 'sql-intermediate',
        moduleId: 'advanced',
        title: 'Subqueries',
        description: 'Queries within queries',
        theorySlides: [
          TheorySlide(
            title: 'Subqueries 📦',
            content:
                'A query nested inside another query.\n\nUseful for:\n• Filtering with computed values\n• Creating temp result sets\n• Complex conditions',
            order: 0,
          ),
          TheorySlide(
            title: 'Example',
            content: 'Find above-average salaries.',
            codeSnippet: '''SELECT name, salary
FROM employees
WHERE salary > (
  SELECT AVG(salary) 
  FROM employees
);''',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'IN Subquery 📋',
            content:
                'Check if value exists in a list:\n• Returns TRUE if value matches any result\n• Alternative to multiple OR conditions\n• Can use NOT IN for exclusion',
            codeSnippet: '''-- Find users who made orders
SELECT name FROM users
WHERE id IN (
  SELECT DISTINCT user_id FROM orders
);

-- Find products NOT ordered
SELECT name FROM products
WHERE id NOT IN (
  SELECT product_id FROM order_items
);''',
            codeLanguage: 'sql',
            order: 2,
          ),
          TheorySlide(
            title: 'EXISTS Subquery ✅',
            content:
                'Check if subquery returns any rows:\n• Returns TRUE/FALSE\n• Often faster than IN\n• Use for existence checks',
            codeSnippet: '''-- Find users who have placed orders
SELECT name FROM users u
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.user_id = u.id
);

-- Find categories with no products
SELECT name FROM categories c
WHERE NOT EXISTS (
  SELECT 1 FROM products p
  WHERE p.category_id = c.id
);''',
            codeLanguage: 'sql',
            order: 3,
          ),
          TheorySlide(
            title: 'Correlated Subqueries 🔄',
            content:
                'Subquery references outer query:\n• Executes once per outer row\n• More powerful but slower\n• Uses outer table aliases',
            codeSnippet: '''-- Find employees earning more than dept average
SELECT name, salary, department_id
FROM employees e1
WHERE salary > (
  SELECT AVG(salary)
  FROM employees e2
  WHERE e2.department_id = e1.department_id
);

-- Find latest order per customer
SELECT * FROM orders o1
WHERE order_date = (
  SELECT MAX(order_date) FROM orders o2
  WHERE o2.customer_id = o1.customer_id
);''',
            codeLanguage: 'sql',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Where can subqueries appear?',
              options: [
                'Only in WHERE',
                'Only in SELECT',
                'WHERE, SELECT, FROM',
                'Only in FROM',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'Subqueries can be in SELECT, FROM, or WHERE clauses.',
            ),
            QuizQuestion(
              question: 'What does EXISTS return?',
              options: [
                'The matching rows',
                'A count of rows',
                'TRUE or FALSE',
                'NULL',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'EXISTS returns TRUE if the subquery returns any rows, FALSE otherwise.',
            ),
            QuizQuestion(
              question: 'What is a correlated subquery?',
              options: [
                'A subquery with GROUP BY',
                'A subquery that references the outer query',
                'A subquery with JOIN',
                'A subquery with ORDER BY',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'A correlated subquery references columns from the outer query and executes once per outer row.',
            ),
            QuizQuestion(
              question: 'When is EXISTS often better than IN?',
              options: [
                'For small datasets',
                'When checking if rows exist (not values)',
                'For string comparisons',
                'Never',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'EXISTS can be faster because it stops as soon as it finds a match, while IN evaluates all values.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Above Average Price',
          description: 'Find products priced above average.',
          language: 'sql',
          starterCode: '''-- Find products with price > average price
SELECT name, price
FROM products
WHERE price > 
''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT name, price FROM products WHERE price > (SELECT AVG(price) FROM products);',
            ),
          ],
          hint: 'Use (SELECT AVG(price) FROM products)',
          solution: '''SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);''',
        ),
        xpReward: 30,
        order: 1,
      ),

      // Lesson 3: GROUP BY & HAVING
      Lesson(
        id: 'sql_int_lesson_3',
        courseId: 'sql-intermediate',
        moduleId: 'aggregation',
        title: 'GROUP BY & HAVING',
        description: 'Aggregate and filter groups',
        theorySlides: [
          TheorySlide(
            title: 'Grouping Data 📊',
            content:
                'GROUP BY groups rows for aggregation.\n\nHAVING filters groups (like WHERE for aggregates).\n\nOrder: WHERE → GROUP BY → HAVING → ORDER BY',
            order: 0,
          ),
          TheorySlide(
            title: 'Example',
            content: 'Find categories with high sales.',
            codeSnippet: '''SELECT category, SUM(amount) as total
FROM sales
GROUP BY category
HAVING SUM(amount) > 1000
ORDER BY total DESC;''',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Multiple Column Grouping 📊📊',
            content:
                'Group by multiple columns:\n• Creates unique combinations\n• More granular aggregation\n• Order of columns matters',
            codeSnippet: '''-- Sales by category AND year
SELECT 
  category,
  YEAR(sale_date) as year,
  SUM(amount) as total,
  COUNT(*) as num_sales
FROM sales
GROUP BY category, YEAR(sale_date)
ORDER BY category, year;

-- Result: Electronics 2023 5000, Electronics 2024 7000...''',
            codeLanguage: 'sql',
            order: 2,
          ),
          TheorySlide(
            title: 'HAVING with Multiple Conditions 🎯',
            content:
                'Filter groups with complex conditions:\n• Use AND/OR in HAVING\n• Can combine multiple aggregates\n• Filter after grouping',
            codeSnippet: '''-- Categories with high sales AND many orders
SELECT 
  category,
  SUM(amount) as total,
  COUNT(*) as orders
FROM sales
GROUP BY category
HAVING SUM(amount) > 1000 
   AND COUNT(*) >= 10;

-- Customers with avg order > 100 but < 500
SELECT customer_id, AVG(total) as avg_order
FROM orders
GROUP BY customer_id
HAVING AVG(total) BETWEEN 100 AND 500;''',
            codeLanguage: 'sql',
            order: 3,
          ),
          TheorySlide(
            title: 'WHERE + GROUP BY + HAVING 🔗',
            content:
                'Combine all clauses effectively:\n• WHERE: Filter rows BEFORE grouping\n• GROUP BY: Create groups\n• HAVING: Filter groups AFTER aggregation',
            codeSnippet: '''-- 2024 sales by category, only categories > 5000
SELECT 
  category,
  SUM(amount) as total
FROM sales
WHERE sale_date >= '2024-01-01'   -- Filter rows first
GROUP BY category                  -- Then group
HAVING SUM(amount) > 5000          -- Filter groups
ORDER BY total DESC;

-- Active customers with many orders
SELECT customer_id, COUNT(*) as orders
FROM orders
WHERE status = 'completed'
GROUP BY customer_id
HAVING COUNT(*) > 5;''',
            codeLanguage: 'sql',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Difference between WHERE and HAVING?',
              options: [
                'Same thing',
                'WHERE filters rows, HAVING filters groups',
                'HAVING is faster',
                'WHERE is deprecated',
              ],
              correctAnswerIndex: 1,
              explanation: 'WHERE filters before grouping, HAVING after.',
            ),
            QuizQuestion(
              question: 'What happens when you GROUP BY multiple columns?',
              options: [
                'Error occurs',
                'Only first column is used',
                'Creates unique combinations of all columns',
                'Columns are merged',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'GROUP BY multiple columns creates a group for each unique combination of values.',
            ),
            QuizQuestion(
              question: 'Can you use WHERE and HAVING in the same query?',
              options: [
                'No, only one allowed',
                'Yes, WHERE runs first',
                'Yes, HAVING runs first',
                'Only with subqueries',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Yes! WHERE filters rows before grouping, HAVING filters groups after aggregation.',
            ),
            QuizQuestion(
              question: 'Which is correct execution order?',
              options: [
                'SELECT → FROM → WHERE',
                'FROM → WHERE → GROUP BY → HAVING',
                'GROUP BY → WHERE → HAVING',
                'HAVING → GROUP BY → WHERE',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'SQL executes: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'High Volume Customers',
          description: 'Find customers with more than 5 orders.',
          language: 'sql',
          starterCode: '''-- Find customers with > 5 orders
SELECT customer_id, COUNT(*) as order_count
FROM orders

''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 5;',
            ),
          ],
          hint: 'Use GROUP BY and HAVING COUNT(*) > 5',
          solution: '''SELECT customer_id, COUNT(*) as order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;''',
        ),
        xpReward: 30,
        order: 2,
      ),

      // Lesson 4: Window Functions
      Lesson(
        id: 'sql_int_lesson_4',
        courseId: 'sql-intermediate',
        moduleId: 'advanced',
        title: 'Window Functions',
        description: 'Advanced analytics',
        theorySlides: [
          TheorySlide(
            title: 'Window Functions 🪟',
            content:
                'Perform calculations across rows:\n• ROW_NUMBER(): Sequential number\n• RANK(): Rank with gaps\n• LAG/LEAD: Previous/next row\n• SUM() OVER: Running total',
            order: 0,
          ),
          TheorySlide(
            title: 'Example',
            content: 'Rank employees by salary.',
            codeSnippet: '''SELECT 
  name,
  salary,
  ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- Result: Alex 100k #1, Bob 80k #2...''',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'LAG & LEAD Functions ⏮️⏭️',
            content:
                'Access previous/next row values:\n• **LAG()**: Get value from previous row\n• **LEAD()**: Get value from next row\n• Great for comparisons and trends',
            codeSnippet: '''SELECT 
  sale_date,
  amount,
  LAG(amount) OVER (ORDER BY sale_date) as prev_amount,
  LEAD(amount) OVER (ORDER BY sale_date) as next_amount,
  amount - LAG(amount) OVER (ORDER BY sale_date) as change
FROM sales;

-- Result: Shows each sale with previous and next amounts''',
            codeLanguage: 'sql',
            order: 2,
          ),
          TheorySlide(
            title: 'Running Totals 📈',
            content:
                'Calculate cumulative sums:\n• SUM() OVER with ORDER BY\n• Running count, avg also possible\n• Resets with PARTITION BY',
            codeSnippet: '''SELECT 
  order_date,
  amount,
  SUM(amount) OVER (ORDER BY order_date) as running_total,
  COUNT(*) OVER (ORDER BY order_date) as order_num,
  AVG(amount) OVER (ORDER BY order_date) as running_avg
FROM orders;

-- Running total per customer
SELECT customer_id, order_date, amount,
  SUM(amount) OVER (
    PARTITION BY customer_id 
    ORDER BY order_date
  ) as customer_running_total
FROM orders;''',
            codeLanguage: 'sql',
            order: 3,
          ),
          TheorySlide(
            title: 'PARTITION BY Examples 📊',
            content:
                'Divide data into groups for calculations:\n• Like GROUP BY but keeps all rows\n• Each partition calculated separately\n• Combine with any window function',
            codeSnippet: '''-- Rank employees within each department
SELECT 
  name,
  department,
  salary,
  RANK() OVER (
    PARTITION BY department 
    ORDER BY salary DESC
  ) as dept_rank
FROM employees;

-- Percentage of department total
SELECT 
  name,
  department,
  salary,
  salary * 100.0 / SUM(salary) OVER (
    PARTITION BY department
  ) as pct_of_dept
FROM employees;''',
            codeLanguage: 'sql',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does PARTITION BY do?',
              options: [
                'Deletes partitions',
                'Groups for window function',
                'Creates new table',
                'Filters rows',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'PARTITION BY divides rows into groups for window calculations.',
            ),
            QuizQuestion(
              question: 'What does LAG() return?',
              options: [
                'Next row value',
                'Previous row value',
                'Current row value',
                'Random row value',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'LAG() returns the value from the previous row in the result set.',
            ),
            QuizQuestion(
              question: 'How do you calculate a running total?',
              options: [
                'GROUP BY with SUM',
                'SUM() OVER (ORDER BY date)',
                'RUNNING_TOTAL()',
                'CUMULATIVE_SUM()',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'SUM() OVER with ORDER BY calculates a running total that accumulates row by row.',
            ),
            QuizQuestion(
              question: 'Difference between ROW_NUMBER and RANK?',
              options: [
                'No difference',
                'RANK skips numbers for ties',
                'ROW_NUMBER skips numbers',
                'RANK starts at 0',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'RANK gives same number to ties and skips next numbers. ROW_NUMBER is always sequential.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Rank Products',
          description: 'Rank products by price with ROW_NUMBER.',
          language: 'sql',
          starterCode: '''-- Add rank by price (highest = 1)
SELECT 
  name,
  price,
  
FROM products;''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput: 'ROW_NUMBER() OVER (ORDER BY price DESC) as rank',
            ),
          ],
          hint: 'Use ROW_NUMBER() OVER (ORDER BY price DESC)',
          solution: '''SELECT 
  name,
  price,
  ROW_NUMBER() OVER (ORDER BY price DESC) as rank
FROM products;''',
        ),
        xpReward: 35,
        order: 3,
      ),

      // Lesson 5: Indexes & Performance
      Lesson(
        id: 'sql_int_lesson_5',
        courseId: 'sql-intermediate',
        moduleId: 'performance',
        title: 'Indexes & Performance',
        description: 'Optimize query speed',
        theorySlides: [
          TheorySlide(
            title: 'Database Indexes ⚡',
            content:
                'Indexes speed up queries:\n• Like book index - fast lookup\n• Create on frequently queried columns\n• Trade-off: Slower writes, more storage',
            order: 0,
          ),
          TheorySlide(
            title: 'Creating Indexes',
            content: 'Index common search columns.',
            codeSnippet: '''-- Single column index
CREATE INDEX idx_email ON users(email);

-- Composite index
CREATE INDEX idx_name_date 
ON orders(customer_name, order_date);

-- Check with EXPLAIN
EXPLAIN SELECT * FROM users WHERE email = 'test@test.com';''',
            codeLanguage: 'sql',
            order: 1,
          ),
          TheorySlide(
            title: 'Composite Indexes 🔗',
            content:
                'Index multiple columns together:\n• Column order matters!\n• Leftmost columns used first\n• Great for multi-column WHERE/ORDER BY',
            codeSnippet: '''-- Composite index on (last_name, first_name)
CREATE INDEX idx_name ON users(last_name, first_name);

-- Uses index (starts with last_name)
SELECT * FROM users WHERE last_name = 'Smith';

-- Uses index (both columns)
SELECT * FROM users 
WHERE last_name = 'Smith' AND first_name = 'John';

-- Does NOT use index (missing leftmost column)
SELECT * FROM users WHERE first_name = 'John';''',
            codeLanguage: 'sql',
            order: 2,
          ),
          TheorySlide(
            title: 'EXPLAIN Analyze 🔍',
            content:
                'Understand query execution:\n• Shows if index is used\n• Reveals full table scans\n• Helps optimize slow queries',
            codeSnippet: '''-- Basic EXPLAIN
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- Shows: type, possible_keys, key, rows scanned

-- EXPLAIN ANALYZE (actual execution)
EXPLAIN ANALYZE SELECT * FROM orders 
WHERE customer_id = 100 AND status = 'pending';

-- Look for:
-- ✅ "Using index" - Good!
-- ❌ "Full table scan" - Needs index
-- ❌ "filesort" - Consider index on ORDER BY''',
            codeLanguage: 'sql',
            order: 3,
          ),
          TheorySlide(
            title: 'Index Best Practices 📋',
            content:
                'When to use indexes:\n• Columns in WHERE, JOIN, ORDER BY\n• High cardinality columns (many unique values)\n• Foreign keys\n\nAvoid indexes on:\n• Frequently updated columns\n• Small tables\n• Low cardinality (few unique values)',
            codeSnippet: '''-- Good index candidates
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_customer_status ON orders(customer_id, status);
CREATE INDEX idx_product_category ON products(category_id);

-- Check existing indexes
SHOW INDEX FROM orders;

-- Remove unused index
DROP INDEX idx_old_unused ON orders;

-- Unique index (also enforces uniqueness)
CREATE UNIQUE INDEX idx_email ON users(email);''',
            codeLanguage: 'sql',
            order: 4,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'When NOT to use indexes?',
              options: [
                'On primary keys',
                'On frequently updated columns',
                'On WHERE columns',
                'On JOIN columns',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Frequent updates slow down with indexes due to maintenance.',
            ),
            QuizQuestion(
              question: 'In composite index (A, B, C), which queries use it?',
              options: [
                'Only WHERE A',
                'WHERE A, WHERE A+B, WHERE A+B+C',
                'Any combination of A, B, C',
                'Only WHERE A+B+C',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Composite indexes work left-to-right. Queries must include leftmost columns to use the index.',
            ),
            QuizQuestion(
              question: 'What does EXPLAIN help you find?',
              options: [
                'Syntax errors',
                'Missing tables',
                'Query execution plan and index usage',
                'User permissions',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'EXPLAIN shows how the database executes a query, including which indexes are used.',
            ),
            QuizQuestion(
              question: 'What is "cardinality" in index context?',
              options: [
                'Index size',
                'Number of unique values',
                'Query speed',
                'Table row count',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Cardinality is the number of unique values. High cardinality columns (many unique values) benefit most from indexes.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create Index',
          description: 'Create index on products category column.',
          language: 'sql',
          starterCode: '''-- Create index on category column
''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'CREATE INDEX idx_category ON products(category);',
            ),
          ],
          hint: 'Use CREATE INDEX idx_name ON table(column)',
          solution: '''CREATE INDEX idx_category ON products(category);''',
        ),
        xpReward: 30,
        order: 4,
      ),
    ];
  }

  // ========================
  // REACT INTERMEDIATE COURSE
  // ========================
  static List<Lesson> getReactIntermediateLessons() {
    return [
      // Lesson 1: Hooks Deep Dive
      Lesson(
        id: 'react_int_lesson_1',
        courseId: 'react-intermediate',
        moduleId: 'hooks',
        title: 'Hooks Deep Dive',
        description: 'Master React hooks',
        theorySlides: [
          TheorySlide(
            title: 'React Hooks 🪝',
            content:
                'Built-in hooks:\n• **useState**: Local state\n• **useEffect**: Side effects\n• **useContext**: Consume context\n• **useRef**: Mutable refs\n• **useMemo/useCallback**: Optimization',
            order: 0,
          ),
          TheorySlide(
            title: 'Rules of Hooks 📏',
            content:
                'Two rules you MUST follow:\n\n1️⃣ **Only call at top level** - Not inside loops, conditions, or nested functions\n\n2️⃣ **Only call from React functions** - Components or custom hooks',
            order: 1,
          ),
          TheorySlide(
            title: 'useEffect Cleanup',
            content: 'Clean up subscriptions and timers.',
            codeSnippet: '''useEffect(() => {
  const timer = setInterval(() => {
    console.log("tick");
  }, 1000);
  
  // Cleanup function
  return () => clearInterval(timer);
}, []);''',
            codeLanguage: 'javascript',
            order: 2,
          ),
          TheorySlide(
            title: 'Dependency Array ⚙️',
            content:
                'Controls when effect runs:\n\n• **[]** - Only on mount\n• **[dep]** - When dep changes\n• **No array** - Every render (careful!)\n\nAlways include all values used inside effect.',
            codeSnippet: '''// Runs when userId changes
useEffect(() => {
  fetchUser(userId);
}, [userId]);

// Runs on every render - usually wrong!
useEffect(() => {
  console.log("rendered");
});''',
            codeLanguage: 'javascript',
            order: 3,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'When does useEffect cleanup run?',
              options: [
                'On mount only',
                'Before every re-run and unmount',
                'Never',
                'On click',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Cleanup runs before re-running effect and on unmount.',
            ),
            QuizQuestion(
              question: 'What does an empty dependency array [] mean?',
              options: [
                'Run on every render',
                'Run only once on mount',
                'Never run',
                'Error',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Empty array means effect runs only once when component mounts.',
            ),
            QuizQuestion(
              question: 'Can you use hooks inside if statements?',
              options: [
                'Yes, always',
                'No, must be at top level',
                'Only useState',
                'Only useEffect',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Hooks must be called at the top level to ensure consistent order between renders.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Timer with Cleanup',
          description: 'Create useEffect with cleanup for interval.',
          language: 'javascript',
          starterCode: '''function Timer() {
  const [count, setCount] = useState(0);
  
  useEffect(() => {
    // Set interval and return cleanup
  }, []);
  
  return <div>{count}</div>;
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput: 'setInterval return () => clearInterval',
            ),
          ],
          hint: 'Return cleanup function with clearInterval',
          solution: '''function Timer() {
  const [count, setCount] = useState(0);
  
  useEffect(() => {
    const timer = setInterval(() => {
      setCount(c => c + 1);
    }, 1000);
    return () => clearInterval(timer);
  }, []);
  
  return <div>{count}</div>;
}''',
        ),
        xpReward: 30,
        order: 0,
      ),

      // Lesson 2: Custom Hooks
      Lesson(
        id: 'react_int_lesson_2',
        courseId: 'react-intermediate',
        moduleId: 'hooks',
        title: 'Custom Hooks',
        description: 'Create reusable logic',
        theorySlides: [
          TheorySlide(
            title: 'Custom Hooks 🔧',
            content:
                'Extract reusable logic:\n• Start with "use" prefix\n• Can use other hooks inside\n• Share stateful logic, not state',
            order: 0,
          ),
          TheorySlide(
            title: 'Example: useLocalStorage',
            content: 'Persist state to localStorage.',
            codeSnippet: '''function useLocalStorage(key, initial) {
  const [value, setValue] = useState(() => {
    const saved = localStorage.getItem(key);
    return saved ? JSON.parse(saved) : initial;
  });
  
  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);
  
  return [value, setValue];
}''',
            codeLanguage: 'javascript',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'Custom hook naming convention?',
              options: ['hook_name', 'useHookName', 'HookName', 'with_hook'],
              correctAnswerIndex: 1,
              explanation: 'Custom hooks must start with "use" prefix.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Create useToggle',
          description: 'Create a useToggle hook for boolean state.',
          language: 'javascript',
          starterCode: '''function useToggle(initial = false) {
  // Return [value, toggle function]
}

// Usage:
// const [isOn, toggle] = useToggle();''',
          testCases: [TestCase(input: '', expectedOutput: 'useState setX(!x)')],
          hint: 'Use useState and return setter that flips value',
          solution: '''function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = () => setValue(v => !v);
  return [value, toggle];
}''',
        ),
        xpReward: 30,
        order: 1,
      ),

      // Lesson 3: Context API
      Lesson(
        id: 'react_int_lesson_3',
        courseId: 'react-intermediate',
        moduleId: 'state',
        title: 'Context API',
        description: 'Global state without props drilling',
        theorySlides: [
          TheorySlide(
            title: 'React Context 🌐',
            content:
                'Share data without passing props:\n• createContext(): Create context\n• Provider: Provide value\n• useContext(): Consume value',
            order: 0,
          ),
          TheorySlide(
            title: 'Context Pattern',
            content: 'Complete context setup.',
            codeSnippet: '''const ThemeContext = createContext('light');

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

function Button() {
  const { theme } = useContext(ThemeContext);
  return <button className={theme}>Click</button>;
}''',
            codeLanguage: 'javascript',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What does useContext return?',
              options: [
                'Provider',
                'Consumer',
                'Current context value',
                'Context object',
              ],
              correctAnswerIndex: 2,
              explanation:
                  'useContext returns the current value from nearest Provider.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Use Theme Context',
          description: 'Create and use a simple theme context.',
          language: 'javascript',
          starterCode: '''const ThemeContext = createContext();

function App() {
  return (
    // Wrap with Provider value="dark"
    <Button />
  );
}

function Button() {
  // Use context to get theme
  return <button>{theme}</button>;
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput:
                  'ThemeContext.Provider value useContext(ThemeContext)',
            ),
          ],
          hint: 'Use Provider with value prop, useContext to consume',
          solution: '''const ThemeContext = createContext();

function App() {
  return (
    <ThemeContext.Provider value="dark">
      <Button />
    </ThemeContext.Provider>
  );
}

function Button() {
  const theme = useContext(ThemeContext);
  return <button>{theme}</button>;
}''',
        ),
        xpReward: 30,
        order: 2,
      ),

      // Lesson 4: Performance Optimization
      Lesson(
        id: 'react_int_lesson_4',
        courseId: 'react-intermediate',
        moduleId: 'performance',
        title: 'Performance Optimization',
        description: 'useMemo, useCallback, memo',
        theorySlides: [
          TheorySlide(
            title: 'React Performance ⚡',
            content:
                'Prevent unnecessary re-renders:\n• **React.memo**: Memoize components\n• **useMemo**: Memoize values\n• **useCallback**: Memoize functions',
            order: 0,
          ),
          TheorySlide(
            title: 'When to Optimize',
            content: 'Only optimize when needed!',
            codeSnippet: '''// Expensive calculation
const sorted = useMemo(() => {
  return items.sort((a, b) => a - b);
}, [items]);

// Stable callback for child
const handleClick = useCallback(() => {
  setCount(c => c + 1);
}, []);

// Memoized child
const Child = React.memo(({ onClick }) => {
  return <button onClick={onClick}>Click</button>;
});''',
            codeLanguage: 'javascript',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'When does useMemo recalculate?',
              options: [
                'Every render',
                'When dependencies change',
                'Never',
                'On click',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'useMemo only recalculates when dependencies change.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Memoize Expensive Calc',
          description: 'Use useMemo for expensive calculation.',
          language: 'javascript',
          starterCode: '''function List({ items }) {
  // Memoize the filtered result
  const filtered = items.filter(i => i > 10);
  
  return <ul>{filtered.map(i => <li>{i}</li>)}</ul>;
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput: 'useMemo(() => items.filter [items]',
            ),
          ],
          hint: 'Wrap filter in useMemo with [items] dependency',
          solution: '''function List({ items }) {
  const filtered = useMemo(() => {
    return items.filter(i => i > 10);
  }, [items]);
  
  return <ul>{filtered.map(i => <li>{i}</li>)}</ul>;
}''',
        ),
        xpReward: 30,
        order: 3,
      ),

      // Lesson 5: Error Boundaries
      Lesson(
        id: 'react_int_lesson_5',
        courseId: 'react-intermediate',
        moduleId: 'patterns',
        title: 'Error Boundaries',
        description: 'Handle component errors gracefully',
        theorySlides: [
          TheorySlide(
            title: 'Error Boundaries 🛡️',
            content:
                'Catch JavaScript errors in components:\n• Prevents whole app crash\n• Shows fallback UI\n• Class component only (for now)',
            order: 0,
          ),
          TheorySlide(
            title: 'Error Boundary Class',
            content: 'Create error boundary component.',
            codeSnippet: '''class ErrorBoundary extends React.Component {
  state = { hasError: false };
  
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }
  
  componentDidCatch(error, info) {
    console.error(error, info);
  }
  
  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return this.props.children;
  }
}''',
            codeLanguage: 'javascript',
            order: 1,
          ),
        ],
        quiz: Quiz(
          questions: [
            QuizQuestion(
              question: 'What errors do boundaries NOT catch?',
              options: [
                'Render errors',
                'Event handler errors',
                'Lifecycle errors',
                'Constructor errors',
              ],
              correctAnswerIndex: 1,
              explanation:
                  'Error boundaries dont catch event handler errors - use try/catch.',
            ),
          ],
        ),
        codingChallenge: CodingChallenge(
          title: 'Use Error Boundary',
          description: 'Wrap component with error boundary.',
          language: 'javascript',
          starterCode: '''function App() {
  return (
    // Wrap UserProfile with ErrorBoundary
    <UserProfile />
  );
}''',
          testCases: [
            TestCase(
              input: '',
              expectedOutput: '<ErrorBoundary><UserProfile /></ErrorBoundary>',
            ),
          ],
          hint: 'Wrap UserProfile in ErrorBoundary tags',
          solution: '''function App() {
  return (
    <ErrorBoundary>
      <UserProfile />
    </ErrorBoundary>
  );
}''',
        ),
        xpReward: 30,
        order: 4,
      ),
    ];
  }
}
