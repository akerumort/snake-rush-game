<h1 align="center">Snake Rush is more than just a classic snake game 🐍</h1>

This game is a modern interpretation of the classic snake game with different levels, animations, sound effects and a colorful user interface. The game is built using the Lua language and Solar2D framework, providing a robust platform for desktops and mobile devices too.

## ⚙️Features

### 💢 Game Levels:
*   **Level 1**: A classic snake that must collect food to grow. The more objects eaten - the more points. The snake dies if it “bites” itself.
*   **Level 2**: Introduces bombs as obstacles that the snake must avoid while collecting food. The bombs change position after a few seconds. It's not that simple!
*   **Level 3**: Moving obstacles (ghosts) and portals are added, which the snake can go in and out of another. Obstacles move chaotically and their movement cannot be predicted! It seems harder than you think....

### 🎮 Animations:
- Smooth background transitions and movements.
- Collision and explosion animations when the snake hits obstacles or bombs.

### 🔊 Sound Effects:
- Background music for the main menu and levels (the same for all levels 😥).
- Eating sound when the snake collects food.
- Explosion sound when the snake hits a bomb.
- Collision sound when the snake hits an obstacle (ghost).

### 🎨 User Interface:
- A main menu with animated backgrounds.
- Settings menu with volume controls for music and sound effects.
- Game over screen displaying the final score with options to restart or return to the main menu.

## 🛠️ Installation

### Prerequisites:
- Ensure you have [Solar2D](https://solar2d.com/) installed on your machine. Solar2D is a free and open-source game engine that uses Lua scripting language.

### PC Installation:
1. Clone this repository:
    ```sh
    git clone https://github.com/akerumort/snakeRushGame.git
    ```
2. Navigate to the project directory:
 
3. Open the project in the Solar2D Simulator:

4. Run the project using the Solar2D Simulator.

### Mobile Installation:
#### Android
1. Clone the repository as shown above.
2. Navigate to the project directory and open the project in Solar2D.
3. Build the project for Android:
    - Open Solar2D Simulator.
    - Select `File > Build > Android`.
    - Follow the prompts to configure your build settings.
4. Install the APK on your Android device.

#### iOS
1. Clone the repository as shown above.
2. Navigate to the project directory and open the project in Solar2D.
3. Build the project for iOS:
    - Open Solar2D Simulator.
    - Select `File > Build > iOS`.
    - Follow the prompts to configure your build settings.
4. Deploy the app to your iOS device using Xcode.

## 🕹 Controls

### PC:
- **Arrow Keys**: Control the direction of the snake.
- **Escape**: Pause the game.

### Mobile:
- **Swipe Gestures**: Control the direction of the snake.
- **Tap on Info Bar**: Pause the game.

## 💻 Used technologies:
- **Language**: Lua
- **Framework**: Solar2D
- **Image Editing**: Stylized text generators, AI for image generation
- **Audio Editing**: Free sound effects from various sites

## 🔗 File Structure:
- `main.lua`: The main entry point of the game.
- `level1.lua`, `level2.lua`, `level3.lua`: Level-specific logic and setup.
- `dataManager.lua`: Handles saving and loading of game data.
- `snake.lua`: Logic for snake movement and behavior.
- `settings.lua`: Logic for the settings menu.
- `menu.lua`: Main menu logic.
- `gameover.lua`: Game over screen logic.
- `pictures/`: Contains all game images.
- `music/`: Contains all game audio files.

## 🛡️ License:
This project is licensed under the MIT License. See the `LICENSE` file for more details.

## ✉️ Contact:
For any questions or inquiries, please contact `akerumort404@gmail.com`.

Enjoy playing Snake Rush! 💜
