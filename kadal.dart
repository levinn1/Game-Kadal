import 'dart:io';
import 'dart:math';

class Point {
  int x, y;
  Point(this.x, this.y);
}

class Game {
  late int width;
  late int height;
  List<Point> snake = [Point(5, 5)];
  List<Point> food = [];
  Random random = Random();
  int foodCount; // Track the number of food items

  Game(this.foodCount) {
    // Set width and height to the size of the terminal
    width = stdout.terminalColumns;
    height = stdout.terminalLines - 2; // Subtract 2 to prevent overlap with prompt

    // Generate the first food item
    food.add(generateFood());
  }

  Point generateFood() {
    int x, y;
    do {
      x = random.nextInt(width);
      y = random.nextInt(height);
    } while (snake.any((s) => s.x == x && s.y == y) ||
             food.any((f) => f.x == x && f.y == y)); // Avoid placing food on the snake
    return Point(x, y);
  }

  void draw() {
    List<List<String>> grid = List.generate(height, (_) => List.generate(width, (_) => ' '));

    // Draw snake with body and "legs" (horizontal lines)
    for (var s in snake) {
      drawLizard(grid, s.x, s.y);
    }

    // Draw food if it exists
    if (food.isNotEmpty) {
      for (var f in food) {
        grid[f.y][f.x] = 'O';
      }
    }

    // Clear the console and redraw
    print("\x1B[2J\x1B[0;0H");
    for (var row in grid) {
      print(row.join());
    }
  }

  // Function to draw a lizard shape (vertical body with two horizontal legs)
  void drawLizard(List<List<String>> grid, int x, int y) {
    List<Point> lizardShape = [
      Point(x, y),     // Center (body)
      Point(x, y - 2), // Upper body (head)
      Point(x, y + 2), // Lower body
      // Horizontal "legs" at upper body
      Point(x - 2, y - 1),
      Point(x - 1, y - 1),
      Point(x + 1, y - 1),
      Point(x + 2, y - 1),
      // Horizontal "legs" at lower body
      Point(x - 2, y + 1),
      Point(x - 1, y + 1),
      Point(x + 1, y + 1),
      Point(x + 2, y + 1),
    ];

    for (var p in lizardShape) {
      if (p.x >= 0 && p.x < width && p.y >= 0 && p.y < height) {
        grid[p.y][p.x] = '*'; // Draw the lizard using '*'
      }
    }
  }

  void update() {
    Point center = snake.first; 
    Point head = Point(center.x, center.y - 2); // Now upper body (head) is at (x, y-2)

    // Find the closest food
    Point? closestFood = food.reduce((a, b) =>
        (distance(head, a) < distance(head, b)) ? a : b);

    // Move snake towards closest food
    int dx = closestFood.x - head.x;
    int dy = closestFood.y - head.y;
    int moveX = dx.sign;
    int moveY = dy.sign;

    Point newHead = Point(center.x + moveX, center.y + moveY); // Move from center

    // If the snake's head reaches the food
    if (newHead.x == closestFood.x && newHead.y - 2 == closestFood.y) {
      snake.insert(0, newHead); // Grow the snake (add new head)
      food.remove(closestFood); // Remove the food

      // Generate new food if the food count is not exhausted
      if (foodCount > 0) {
        food.add(generateFood());
        foodCount--; // Decrement food count
      } else {
        print("All food eaten! Game over.");
        exit(0);
      }
    } else {
      snake.insert(0, newHead); // Move the snake
      snake.removeLast(); // Keep the snake size the same
    }
  }

  double distance(Point a, Point b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }

  void run() async {
    while (true) {
      draw();
      update();
      await Future.delayed(Duration(milliseconds: 50));
    }
  }
}

void main() {
  stdout.write("Enter the number of food items: ");
  int foodCount = int.parse(stdin.readLineSync()!);

  Game game = Game(foodCount);
  game.run();
}
