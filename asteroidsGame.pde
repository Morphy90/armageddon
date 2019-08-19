//Miguel Mojica
//CS 3310
//Last Modified: August 6, 2019
import processing.sound.*;
SoundFile intro;
SoundFile explosion;
SoundFile bullet;
SoundFile victory;
Ship ship;

boolean upPressed = false;
boolean downPressed = false;
boolean rightPressed = false;
boolean leftPressed = false;
boolean displayCredits = false;
boolean newGame;

float shipSpeed = 2;
float bulletSpeed = 10;

int numSmallAsteroids, smallRadius = 15;
int numMediumAsteroids, mediumRadius = 30;
int numLargeAsteroids, largeRadius = 70;
int texty = 600;
int score = 0, highScore; 
int begin, duration, time;
int numBullets;

PImage asteroidPicMedium, asteroidPicSmall, asteroidPicLarge;
PImage rocket;
PImage space, earth;
PImage introPic;
int DIM, W, H, x, y;

ArrayList<Bullet> bullets;
ArrayList<Asteroid> smallAsteroids;
ArrayList<Asteroid> medAsteroids;
ArrayList<Asteroid> largeAsteroids;

PFont font, fontScore, ammo;

//game state variables
int gameState;
public final int INTRO = 1;
public final int PLAY = 2;
public final int PAUSE = 3;
public final int GAMEOVER = 4;
public final int YOUWIN = 5;
String[] highScores; 

void setup()
{
  introPic = loadImage("introScreen.jpg");
  image(introPic, 0, 0, 900, 600);
  size(900, 600);
  font = createFont("Cambria", 32);
  noCursor();
  frameRate(24);
  
  asteroidPicSmall = loadImage("asteroidS.png");
  asteroidPicMedium = loadImage("asteroidM.png");
  asteroidPicLarge = loadImage("asteroidL.png");
  rocket = loadImage("rocket.png");
  
  smallAsteroids = new ArrayList<Asteroid>(0);
  medAsteroids = new ArrayList<Asteroid>(0);
  largeAsteroids = new ArrayList<Asteroid>(0);
  
  gameState = INTRO;
  intro = new SoundFile(this, "introMusic.mp3");
  intro.loop(.8);
  explosion = new SoundFile(this, "explosion.mp3");
  bullet = new SoundFile(this, "bullet.mp3");
  victory = new SoundFile(this, "victory.mp3");
  highScores = (loadStrings("data/scores.txt"));
  earth = loadImage("earth.png");
  DIM = 16;
  W = earth.width/DIM;
  H = earth.height/DIM;
}

void draw()
{
  switch(gameState)
  {
    case INTRO:
      drawScreen("Armageddon", "Press s to start");
      newGame = true;
      break;
    case PAUSE:
      drawScreen("PAUSED", "Press p to resume");
      break;
    case GAMEOVER:
      drawScreen("GAME OVER", "High Score: " + highScore + "\nPress s to try again");
      newGame = true;
      saveStrings("data/scores.txt", highScores);
      break;
    case YOUWIN:
      drawScreen("You Win \n" + "Score: " + score, "Press s to play again");
      newGame = true;
      break;
    case PLAY:
      intro.stop();
      fontScore = loadFont("AgencyFB-Reg-20.vlw");
      textFont(fontScore, 32);
      space = loadImage("space.png");
      image(space, 0, 0, width, height);                      //Background
      fill(255, 255, 255);
      if (displayCredits)
      {
       //textAlign(CENTER);
       textSize(32);
       fill(255, 200, 40, 150);
       text("Credits \n" +
            "Gameplay: Armageddon \n" +
            "Created by: Miguel Mojica \n"+
            "Intro music: 'Remember the name' by Fort Minor\n" +
            "Sound Effects provided by: www.zapsplat.com \n"+
            "Thank you for playing!", 900/2, texty);
       texty -= 2; 
      }
      x = frameCount%DIM*W;
      y = frameCount/DIM%DIM*H;
      PImage sprite = earth.get(x, y, W, H);
      image(sprite, width/2, H);
      
      ship.update();
      ship.render();
      
      //You lose
      if ((ship.checkCollision(smallAsteroids)) || (ship.checkCollision(medAsteroids)) || (ship.checkCollision(largeAsteroids)) || (time == 0))
      {
        if (score > highScore)
        {
          highScore = score;
          highScores = append(highScores, str(highScore));
        }
        explosion.play();
        gameState = GAMEOVER;
        saveStrings("data/scores.txt", highScores);
      }
      
      //Level cleared
      if ((smallAsteroids.size() <= 0) && (medAsteroids.size() <= 0 && (largeAsteroids.size() <= 0)))
      {
        victory.play();
        newGame = false;
        numSmallAsteroids += 2;
        numMediumAsteroids += 4;
        numLargeAsteroids += 1;
        numBullets += 20;
        initializeGame();
        gameState = PLAY;
      }
      else
      {
        for (int i = 0; i < bullets.size(); i++)
        {
          bullets.get(i).update();
          bullets.get(i).render();
          
          if (bullets.get(i).checkCollision(smallAsteroids))
          {
            explosion.play();
            if (bullets.get(i).releasePoints)
            {
              score = score + 20;
              numBullets += 3;
            }
            bullets.remove(i);
            i--;
          }
          else if (bullets.get(i).checkCollision(medAsteroids))
          {
            explosion.play();
            if (bullets.get(i).releasePoints)
            {
              score = score + 10;
              numBullets += 1;
            }
            bullets.remove(i);
            i--;
          }
          else if (bullets.get(i).checkCollision(largeAsteroids))
          {
            explosion.play();
            if (bullets.get(i).releasePoints)
            {
              score = score + 50;
              numBullets += 10;
            }
            bullets.remove(i);
            i--;
          }
        }
        
        
        for (int i = 0; i < smallAsteroids.size(); i++)
        {
          smallAsteroids.get(i).update();
          smallAsteroids.get(i).render();
        }
        for (int i = 0; i < medAsteroids.size(); i++)
        {
          medAsteroids.get(i).update();
          medAsteroids.get(i).render();
          if (medAsteroids.get(i).isDestroyed)
          {
            score = score + 10;
          }
        }
        for (int i = 0; i < largeAsteroids.size(); i++)
        {
          largeAsteroids.get(i).update();
          largeAsteroids.get(i).render();
          if (largeAsteroids.get(i).isDestroyed)
          {
            score = score + 50;
          }
        }
        
        float theta = heading2D(ship.rotation)+PI/2;
        
        if (leftPressed)
        {
          rotate2D(ship.rotation, -radians(5));
        }
        if (rightPressed)
        {
          rotate2D(ship.rotation, radians(5));
        }
        if (upPressed)
        {
          ship.acceleration = new PVector(0, shipSpeed);
          rotate2D(ship.acceleration, theta);
        }
      }
      fill(255, 255, 255);
      text("Score: " + score, 900/15, 15, 50);              //Display score
      if (time > 0)
      {
        time = duration - (millis() - begin)/1000;            //Display time remaining
        text("Time: " + time, 900/15, 50, 50);
      }
      if (numBullets == 0)
      {
        fill(255, 0, 0);
        text("Bullets: " + numBullets, 900 - 69, 15, 1000);  
      }
      else
      {
        text("Bullets: " + numBullets, 900 - 69, 15, 50);    //Display ammo
      }
      break;
  }
}

void init_timer()
{
  begin = millis();
  duration = 60;
  time = 60;
}
          
//Initialize the game settings. Create ship, bullets, and asteroids
void initializeGame()
{
  ship = new Ship();
  bullets = new ArrayList<Bullet>();
  smallAsteroids = new ArrayList<Asteroid>();
  medAsteroids = new ArrayList<Asteroid>();
  largeAsteroids = new ArrayList<Asteroid>();
  if (newGame)
  {
    numSmallAsteroids = 2;
    numMediumAsteroids = 4;
    numLargeAsteroids = 1;
    score = 0;
    numBullets = 20;
    displayCredits = false;
    texty = 600;
    highScore = Integer.parseInt(highScores[highScores.length - 1]);
  }
  init_timer();
  
  for (int i = 0; i < numSmallAsteroids; i++)
  {
    PVector position = new PVector((int)(Math.random()*width), 50);
    smallAsteroids.add(new Asteroid(position, smallRadius, asteroidPicSmall, 1));
  }
  for (int i = 0; i < numMediumAsteroids; i++)
  {
    PVector position2 = new PVector((int)(Math.random()*width), 50);
    medAsteroids.add(new Asteroid(position2, mediumRadius, asteroidPicMedium, 2));
  }
  for (int i = 0; i < numLargeAsteroids; i++)
  {
    PVector position3 = new PVector((int)(Math.random()*width), 50);
    largeAsteroids.add(new Asteroid(position3, largeRadius, asteroidPicLarge, 3));
  }
}

void fireBullet()
{
  println("fire");  //this line is for debugging purpose
  
  PVector pos = new PVector(0, ship.r*2);
  rotate2D(pos, heading2D(ship.rotation)+PI/2);
  pos.add(ship.position);
  PVector vel = new PVector(0, bulletSpeed);
  rotate2D(vel, heading2D(ship.rotation)+PI/2);
  bullets.add(new Bullet(pos, vel));
}

void keyPressed()
{ 
  if(key== 's' && ( gameState==INTRO || gameState==GAMEOVER || gameState==YOUWIN)) 
  {
    initializeGame();  
    gameState=PLAY;    
  }
  if(key=='p' && gameState==PLAY)
  {
    gameState=PAUSE;
  }
  else if(key=='p' && gameState==PAUSE)
  {
    gameState=PLAY;
  }
  
  
  //when space key is pressed, fire a bullet
  if(key == ' ' && gameState == PLAY && numBullets > 0)
  {
     bullet.play();
     fireBullet();
     numBullets --;
  } 
  if(key==CODED && gameState == PLAY)
  {         
     if(keyCode==UP) 
       upPressed=true;
     else if(keyCode==DOWN)
       downPressed=true;
     else if(keyCode == LEFT)
       leftPressed = true;  
     else if(keyCode==RIGHT)
       rightPressed = true;        
  }  
  if (key == 'c' && gameState == PLAY)
  {
    displayCredits = true;
    if (texty < -300)
    {
      displayCredits = false;
      texty = 600;
    }
  }
}
       
void keyReleased()
{
  if(key==CODED)
  {
   if(keyCode==UP)
   {
     upPressed=false;
     ship.acceleration = new PVector(0,0);  
   } 
   else if(keyCode==DOWN)
   {
     downPressed=false;
     ship.acceleration = new PVector(0,0); 
   } 
   else if(keyCode==LEFT)
      leftPressed = false; 
   else if(keyCode==RIGHT)
      rightPressed = false;           
  } 
}


void drawScreen(String title, String instructions) 
{  
  // draw title
  fill(255,100,0);
  textSize(60);
  textAlign(CENTER, BOTTOM);
  text(title, width/2, height/2);
  
  // draw instructions
  fill(255,255,255);
  textSize(32);
  textAlign(CENTER, TOP);
  text(instructions, width/2, height/2);
}



float heading2D(PVector pvect)
{
   return (float)(Math.atan2(pvect.y, pvect.x));  
}


void rotate2D(PVector v, float theta) 
{
  float xTemp = v.x;
  v.x = v.x*cos(theta) - v.y*sin(theta);
  v.y = xTemp*sin(theta) + v.y*cos(theta);
}
