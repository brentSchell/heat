/*

* NOTES:
* Ice Blocks should shake as they get close to melting
* Water should turn icyer? as they get close to freezing
* 
*
* GOAL: Light a match? Extinguish something? Both? Probably get to an exit? Cook something?
* 
* Option: Cook pasta: 
*    1. Fill pot with water 
*    2. Put noodles in pot (1 and 2 can vice versa)
*    3. Heat
*
* 2 Player could incorporate heat source and cold source
* 
* Player slides on ice?
* Thermometer block?
* Shows t reading, and a t to be set to, if its over it it opens.
* Can just be a sign (not solid), and it sets the gate open
*
* Player:
*  Walking candle
*  Kill yourself function: slowly puts extinguisher of head, resets level
*  Birth (start of level): strikes match on floor and lights himself
* Block Types:
* 
*
* Music: Same for each level, but dynamically changes each 4 bars based on if there is fire
* burning, water falling, in water? or whatever. There should be several "regular" phrases for when
* nothing is happening.
*
*
*/

// move around as a heat source
// constantly updating map for heat

// ice blocks -> turn to water, and back to ice. Maybe steam, then gone forever

/* @pjs preload="img/block.png,img/button.png,img/candle.png,img/door.png,img/door2.png,img/fire.png,img/ice.png,img/water1.png,img/water2.png,img/water3.png,img/water4.png,img/wood.png"; */

Tile[] grid;
int GRID_WIDTH = 20;
int GRID_HEIGHT = 20;
int PIXELS_PER_TILE = 32;
HeatSource src;
Collectable gem1,gem2;
boolean[] key_pressed;
int AIR = 0;
int ROCK = 1;
int WATER_SRC = 2;
int ICE = 3;
int STEAM = 4;
int WATER_STREAM = 5;
int WOOD = 6;
int WOOD_ON_FIRE = 7;
int THERM = 8;
int S = 10;
int X = 11;
int B = 12;
int G = 13; //gate
int O = 14; //open gate
int C = 15; // collectable

boolean levelWon, levelReset;
int current_level;
int game_tick = 0;
int transition_count = 0;
int transition_dir = 1;
int[][][] all_levels;



void setup() {
  // Init Window
  size(640,640, P2D);
  src = new HeatSource(GRID_WIDTH/2,GRID_HEIGHT/2,100.0);
  gem1 = new Collectable(GRID_WIDTH/2,GRID_HEIGHT/2);
  gem2 = new Collectable(GRID_WIDTH/2,GRID_HEIGHT/2);
  // Init Grid  
  grid = new Tile[GRID_WIDTH*GRID_HEIGHT];
  // SEtore all levels
  all_levels = new int[50][][];

  for (int i=0; i<=29; i++) {
    all_levels[i] = readLevel(i);  
  }

    
  levelWon = false;
  levelReset = false;
  
  current_level = 0;
  loadLevel(current_level);
  
  // Init Player
  
  // Init input
  key_pressed = new boolean[6];
  
}

void draw() {
  tick();
  render();
  
}

void keyPressed() {
  pressed(key);
  pressed(keyCode);
}
void pressed(int k) {
  switch(k) {
    case UP: 
      key_pressed[0] = true;
      break;
    case DOWN: 
      key_pressed[1] = true;
      break;
    case LEFT: 
      key_pressed[2] = true;
      break;
    case RIGHT: 
      key_pressed[3] = true;
      break;
    case ' ': 
      if (!key_pressed[4]) src.jump();
      key_pressed[4] = true;
      break;
    case 'z':
    case 'Z':
      key_pressed[5] = true;
      break;
  }  
}

void keyReleased() {
  released(key);
  released(keyCode);
}
void released(int k) {
  switch(k) {
    case UP: 
      key_pressed[0] = false;
      break;
    case DOWN: 
      key_pressed[1] = false;
      break;
    case LEFT: 
      key_pressed[2] = false;
      break;
    case RIGHT: 
      key_pressed[3] = false;
      break;
    case ' ': 
      key_pressed[4] = false;
      break;
    case 'z': 
      key_pressed[5] = false;
      break;
  }   
}
//----------------------------------------------
// Update stuff
//----------------------------------------------

void tick() {
  handleInput(); 
  
  heatUpdate();  // update temperatures
  if (game_tick % 40 == 0) {
    blockUpdate(true,false); 
  }
  src.tick(); // update player motion
  gem1.tick(); // update gem position
  gem2.tick(); // update gem position
  
  if (levelWon) { // Transition to next level
    transition_count += transition_dir;
    
    if (transition_count > GRID_WIDTH) {
      transition_dir = -1;
      current_level++;
      loadLevel(current_level);
    }   
    if (transition_count == 0) {
      levelWon = false; // end transition animation

    }
  } else {
    transition_dir = 1;
    transition_count = 0;  
  }
  
  if (levelReset) { // Reset Level
    loadLevel(current_level);
    levelReset = false; 
  }
  game_tick++;
}

void handleInput() {
  // Move src
  float delta = 0.11;
  float dx = 0.0;
  float dy = 0.0;
  //if (key_pressed[0]) { // up
  //  println("down");
  //  dy -= delta;
 // }
  if (key_pressed[1]) { // down
    dy = 0.1;
  }
  if (key_pressed[2]) { // left
    dx -= delta;
  }
  if (key_pressed[3]) { // right
    dx += delta;
  }
  src.killing = key_pressed[5];

 
  src.vx += dx;
  src.vy += dy;
  
  float max_speed = 0.2;
  if (src.vx > max_speed) {
    src.vx  = max_speed;
  } else if (src.vx < -1*max_speed) {
    src.vx = -1*max_speed;  
  }
  
  if (src.vy > max_speed) {
    src.vy = max_speed;  
  }


 // println(src.vx + "," + src.vy);
  
}

void loadLevel(int level) {
  int gems_done = 0;
  for (int i=0; i<grid.length; i++) {
	  //println(i);
	  int y = (int)(i/GRID_WIDTH);
	  int x = (int)(i%GRID_WIDTH);
	  //println(x);
	  //println(y);
      if (all_levels[level][y][x] == S) { // Start marker
        src = new HeatSource(x + 0.5,y,100.0);
        grid[i] = new Tile(1.0,AIR);
      } else if (all_levels[level][y][x] == C) { // Collectable position
        if (gems_done == 0) {
          gem1 = new Collectable(x,y);
          gems_done++;
        } else if (gems_done == 1) {
          gem2 = new Collectable(x,y);          
        }
        grid[i] = new Tile(1.0,AIR);
      } else {
        grid[i] = new Tile(1.0,all_levels[level][y][x]);
      }
  }  
}

void blockUpdate(boolean doWater, boolean doFire) {
  int[] new_grid;
  float[] new_temp;
  new_grid = new int[GRID_HEIGHT*GRID_WIDTH];
  new_temp = new float[GRID_HEIGHT*GRID_WIDTH];
  
  boolean gates_unlocked = false;
  for (int y=0; y<GRID_HEIGHT;y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      new_grid[y*GRID_WIDTH+x] = -1;
      new_temp[y*GRID_WIDTH+x] = grid[y*GRID_WIDTH+x].t;
      
      if (y == 0 || y == GRID_HEIGHT-1 || x == 0 || x == GRID_WIDTH-1) {
        continue; // skip boundaries here, after resetting id 
      }
      
      if (doWater) {
        // -----
        // MELTING
        // -----
        // flow down from source
        if (grid[y*GRID_WIDTH+x].id == WATER_SRC && !grid[(y+1)*GRID_WIDTH+x].solid) {
          new_grid[(y+1)*GRID_WIDTH+x] = WATER_STREAM; 
        }
        // flow down from stream
        if (grid[y*GRID_WIDTH+x].id == AIR && (grid[(y-1)*GRID_WIDTH+x].id == WATER_STREAM || grid[(y-1)*GRID_WIDTH+x].id == WATER_SRC) ) {
          new_grid[(y)*GRID_WIDTH+x] = WATER_STREAM; 
        }
        // -----
        // FREEZING
        // -----  
        if (grid[y*GRID_WIDTH+x].id == WATER_STREAM && grid[(y-1)*GRID_WIDTH+x].id == ICE) {
          new_grid[y*GRID_WIDTH+x] = AIR; 
        }
        if (grid[y*GRID_WIDTH+x].id == WATER_STREAM && grid[(y-1)*GRID_WIDTH+x].id == AIR) {
          new_grid[y*GRID_WIDTH+x] = AIR; 
        }
        // -----
        // EXTINGUISHING
        // -----
        if (grid[y*GRID_WIDTH+x].id == WOOD_ON_FIRE && (grid[(y-1)*GRID_WIDTH+x].id == WATER_SRC || grid[(y-1)*GRID_WIDTH+x].id == WATER_STREAM) ) {            
          //println("extinguished");
          new_grid[y*GRID_WIDTH+x] = WOOD; 
          new_temp[y*GRID_WIDTH+x] = 10; 
          grid[y*GRID_WIDTH+x].age = 0;
        }
      }
      
      if (doFire) {
        // -----
        // SPREADING FIRE
        // -----  
        if (grid[y*GRID_WIDTH+x].id == WOOD) {
          if (grid[(y-1)*GRID_WIDTH+x].id == WOOD_ON_FIRE || grid[(y+1)*GRID_WIDTH+x].id == WOOD_ON_FIRE || 
              grid[(y)*GRID_WIDTH+x-1].id == WOOD_ON_FIRE || grid[(y)*GRID_WIDTH+x+1].id == WOOD_ON_FIRE) {
            new_grid[y*GRID_WIDTH+x] = WOOD_ON_FIRE; 
          }
        }
      }
      
      

    }
  }  
  for (int i=0; i<grid.length; i++) {
       
    if (new_grid[i] != -1) {  
      grid[i].setTile(new_temp[i],new_grid[i]);
    }
  }
}

void heatUpdate() {
  //Tile[] new_grid = new Tile[grid.length];
  float[] new_temps = new float[grid.length];
  int[] new_ids = new int[grid.length];
  
  // Place heat source in grid
  int sx = (int)(src.x);
  int sy = (int)(src.y-1);
  
  boolean gates_unlocked = false;
  if (sy >= 0 && sy<GRID_HEIGHT && sx >=0 && sx<GRID_WIDTH) {
    grid[sy*GRID_WIDTH+sx].t += 5.0;
  }
 // println(grid[sy*GRID_WIDTH+sx].t ); 
 // grid[sy*GRID_WIDTH+sx].t *= 1.05;

  // Update block source temp is on
  if (grid[sy*GRID_WIDTH+sx].t > src.t) {
    grid[sy*GRID_WIDTH+sx].t = src.t;
  }
  float alpha = 10.0;
  for (int y=0; y<GRID_HEIGHT;y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      
      //Update temperature based on heat equation
      float new_temperature = 0;
      int l=1;
      int r=1;
      int u=1;
      int d=1;
      if (x == 0) {
        l=0;
      }
      if (x == GRID_WIDTH - 1) {
        r=0;
      }
      if (y == 0) {
        d=0;
      }
      if (y == GRID_HEIGHT - 1) {
        u=0;    
      }
      
      new_temperature = ( grid[(y-d)*GRID_WIDTH+x].t - 2*grid[y*GRID_WIDTH+x].t + grid[(y+u)*GRID_WIDTH+ x].t ) / (float)(GRID_WIDTH*GRID_HEIGHT);
      new_temperature += ( grid[y*GRID_WIDTH+x-l].t - 2*grid[y*GRID_WIDTH+x].t + grid[y*GRID_WIDTH+x+r].t ) / (float)(GRID_WIDTH*GRID_HEIGHT);
      new_temperature *= alpha;
      new_temperature += grid[y*GRID_WIDTH+x].t;
      
      // Update blocks based on temperature changes
      int id = grid[y*GRID_WIDTH+x].id;
      if (id == ICE) { // Ice block
        if (new_temperature >= 25.0) {
          id = WATER_SRC; // melt to water
          //println("MELTED " + x + "," + y); 
        }
      } else if (id == WATER_SRC) {  // Water block
        if (new_temperature <= 25.0) 
          id = ICE;
      } else if (id == WOOD) {
        if (new_temperature >= 45.0 && (grid[(y-1)*GRID_WIDTH+x].id != WATER_STREAM && grid[(y-1)*GRID_WIDTH+x].id != WATER_SRC) ) {
          id = WOOD_ON_FIRE;
        }
      } else if (id == WOOD_ON_FIRE) {
        grid[y*GRID_WIDTH+x].age++;
        if (grid[y*GRID_WIDTH+x].age > 60*10) {
          id = AIR;  
        } else {
          float t = grid[y*GRID_WIDTH+x].t;
          if (t < 90) {
            t += 0.2;  
          } else {
            // oscillate fire between 90 to 100
            t = 95 + sin(frameCount/60.0)*5;  
          }
          new_temperature = t; // reset temp
        }
      } else if (id == B && (grid[(y-1)*GRID_WIDTH+x].id != AIR || (sx == x && (sy+2) == y)) ) {
        // there is a block, or the player standing on the button
        gates_unlocked = true;  
        //println("unlocked");
      } else if (id == THERM) {
        if (new_temperature >  grid[y*GRID_WIDTH+x].goal_t) {
          // println("goal met");        
        } 
      }
      
      new_temps[y*GRID_WIDTH+x] = new_temperature;
      new_ids[y*GRID_WIDTH+x] = id;
    }
  }
  
  // Copy new grid to grid
  for (int y=0; y<GRID_HEIGHT;y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      // Edges take the temperature of their inner neightbours, so they don't act as a cold source
      if (y == 0) {
        grid[y*GRID_WIDTH+x].setTile(new_temps[(y+1)*GRID_WIDTH+x]*0.5,grid[(y)*GRID_WIDTH+x].id);
      } else if (y == GRID_HEIGHT - 1) {
        grid[y*GRID_WIDTH+x].setTile(new_temps[(y-1)*GRID_WIDTH+x]*0.5,grid[(y)*GRID_WIDTH+x].id);
      } else if (x == 0) {
        grid[y*GRID_WIDTH+x].setTile(new_temps[(y)*GRID_WIDTH+x+1]*0.5,grid[(y)*GRID_WIDTH+x].id);        
      } else if (x == GRID_WIDTH - 1) {
        grid[y*GRID_WIDTH+x].setTile(new_temps[(y)*GRID_WIDTH+x-1]*0.5,grid[(y)*GRID_WIDTH+x].id);        
      } else {
        
        // updates button/gates
        if (gates_unlocked && grid[y*GRID_WIDTH+x].id == G) { // open gates if a button was pushed
          new_ids[y*GRID_WIDTH+x] = O;
        } else if (!gates_unlocked && grid[y*GRID_WIDTH+x].id == O) {
          new_ids[y*GRID_WIDTH+x] = G;
        }
        
        // all inner tiles heat update
        grid[y*GRID_WIDTH+x].setTile(new_temps[(y)*GRID_WIDTH+x],new_ids[(y)*GRID_WIDTH+x]);        
      }
    }
  }
}



//----------------------------------------------
// Render stuff
//----------------------------------------------
void render() {
  background(0);
  
  render_level();  
  gem1.render();
  gem2.render();
  src.render();
  
  if (transition_count > 0 ) {
    render_transition(transition_count);  
  }

}

void render_transition(int t) {
  fill(0,0,0);
  for (int y=0; y<GRID_HEIGHT; y++) {
    for (int x=0; x<GRID_WIDTH; x++) {
      int dd = (x-t + y-t);
      if (dd < 0) {
        rect(x*PIXELS_PER_TILE,y*PIXELS_PER_TILE,PIXELS_PER_TILE,PIXELS_PER_TILE);    
      }
    } 
  }
}

void render_level() {
  noStroke();
  // render tiles from bottom left to top right to get proper clipping
  // need to render air first, then all tiles
  for (int i=0; i<2; i++) {
    for (int y=GRID_HEIGHT-1; y>=0; y--) {
      for (int x=0; x<GRID_WIDTH; x++) {
        if (i==0) {
          grid[y*GRID_WIDTH+x].render(x*PIXELS_PER_TILE,y*PIXELS_PER_TILE,PIXELS_PER_TILE,true);          
                   //fill(255);
                   //text((int)grid[y*GRID_WIDTH+x].t + "",x*PIXELS_PER_TILE,y*PIXELS_PER_TILE + PIXELS_PER_TILE/2.0);

        } else if (i==1 && grid[y*GRID_WIDTH+x].id != AIR)  {
          grid[y*GRID_WIDTH+x].render(x*PIXELS_PER_TILE,y*PIXELS_PER_TILE,PIXELS_PER_TILE,false);
          //fill(255,255,255);
          //text((int)grid[y*GRID_WIDTH+x].t + "",x*PIXELS_PER_TILE,y*PIXELS_PER_TILE + PIXELS_PER_TILE/2.0);
         // text((int)grid[y*GRID_WIDTH+x].id + "",x*PIXELS_PER_TILE,y*PIXELS_PER_TILE + PIXELS_PER_TILE/2.0 + 5);

        }
      }  
    }
  }
  
}

color getColor(float temperature) {
  color c = color(0,0,0);
  float red = 0;
  float blue = 0;
  float green = 0;
  if (temperature < 20) {
    c = color(29,0,255);
  } else if (temperature < 30) {
    c = color(10,255,250);
  } else if (temperature < 50) {
    c = color(18,255,10);
  } else if (temperature < 60) {
    c = color(255,216,0);
  } else if (temperature < 80) {
    c = color(255,106,0);
  } else if (temperature < 90) {
    c = color(255,0,0);
  }
  float yellow = (temperature/100.0)*500.0;
  if (yellow < 15) yellow = 0;
  if (yellow > 255) yellow = 255;
  
  float alpha = 255 - (temperature/100.0)*500.0;
  if (alpha < 10) alpha = 10;
  if (alpha > 128) alpha = 128;
 // if (r < 15) r = 0;
  c = color(yellow,yellow/2.0,0, 255);
  /*
  if (temperature < 25.0 ) {
    // Blue to red
    blue = 255.0 - 255.0*temperature/25.0
    red = 128.0*temperature/25.0;
    green = 0.0;
  } else if (temperature < 50.0 ) {
    red = 128 + 127.0*temperature/50.0;
    green = 0.0;
    blue = 0.0;
  } else if (temperature < 75.0) {
    red = 255.0;
    green = 128.0*temperature/75.0;
    blue = 0.0;   
  } else {
    // Yellow to white
    red = 255.0;
    green = 128.0 + 128.0*temperature/100.0;
    blue = 128.0*temperature/100.0;
  }*/
  /*
  if      (temperature < 2.0 ) c = color(0,0,255);
  else if (temperature < 10.0) c = color(20,30,255);
  else if (temperature < 15.0) c = color(40,30,255);
  else if (temperature < 20.0) c = color(60,30,255);
  else if (temperature < 25.0) c = color(80,30,255);
  else if (temperature < 30.0) c = color(50,30,200); // MELTING
  else if (temperature < 35.0) c = color(60,30,150);
  else if (temperature < 40.0) c = color(70,30,100);
  else if (temperature < 45.0) c = color(80,30,50);
  else if (temperature < 50.0) c = color(90,30,10);
  else if (temperature < 55.0) c = color(150,30,10); // BURNING
  else if (temperature < 60.0) c = color(160,30,10);
  else if (temperature < 65.0) c = color(170,30,10);
  else if (temperature < 65.0) c = color(190,30,10);
  else if (temperature < 75.0) c = color(210,30,10);
  else if (temperature < 80.0) c = color(230,30,10);
  else if (temperature < 85.0) c = color(255,30,10);
  else if (temperature < 90.0) c = color(255,100,10);
  else if (temperature < 95.0) c = color(255,150,10);
  else if (temperature < 100.0) c = color(255,200,10);
  else c = color(255,255,255);
  */
  
  /*
  float red = 0;
  float blue = 255;
  float green = 30;
  if (temperature >= 10) {
      red = 128.0 * temperature / 100.0;
      red *= 2;
      
      blue = 255.0 - 255.0 * temperature / 100.0;
  }
  */
  return c;
}



int[][] readLevel(int level_number) {
  int[][] level = new int[20][20];
  boolean doneLevel = false;
  String lines[] = loadStrings("static/levels.txt");
  
  for (int jjj=0; jjj<lines.length && !doneLevel; jjj++) {
	//println("line: " + jjj);
	//println(lines[jjj]);
	String line = lines[jjj];
	
    if (line.contains("L" + level_number)) {
		for (int yy=0; yy<GRID_HEIGHT; yy++) {
			jjj++;
			line = lines[jjj];
			for (int xx=0; xx<GRID_WIDTH; xx++) {
				String s = line.substring(xx,xx+1);
				int id = 0;
				if (s == "S") {
					id = S;  
				} else if (s == "X") {
					id = X;  
				} else if (s == "G") {
					id = G;  
				} else if (s == "B") {
					id = B;
				} else if (s == "C") {
					id = C;  
				} else if (s == "T") {
					id = THERM;  
				} else if (s == " ") {
					id = 0;  
				} else if (s == "0") {
					id = 0;
				} else if (s == "1") {
					id = 1;
				} else if (s == "2") {
					id = 2;
				} else if (s == "3") {
					id = 3;
				} else if (s == "4") {
					id = 4;
				} else if (s == "5") {
					id = 5;
				} else if (s == "6") {
					id = 6;
				} else if (s == "7") {
					id = 7;
				} else if (s == "8") {
					id = 8;
				} else if (s == "9") {
					id = 9;
				}							
				level[yy][xx] = id;  
				if (yy < 10) {
				//println(xx + "," + yy + "=" + id );
				}
			}
			//println();
		}
		doneLevel = true;
	}
  }
  return level;
}
/*
  //println(lines.length);	
  int i = 0;
  String line = ""; 

  while (i<lines.length && !doneLevel) {
	line = lines[i];
	
    if (line.contains("L" + level_number)) {
      println("found level" + level_number);
      for (int y=0; y<GRID_HEIGHT; y++) {
		i++;
        line = lines[i];

        for (int x=0; x<GRID_WIDTH; x++) {
          char id = line.charAt(x);
          println(line + ": " + x + "," + y + "," + id);
		  println(id);
          if (id - '0' == 'S') {
            id = S;  
			println("Is S");
          } else if (id == 'X') {
            id = X;  
			println("Is X");
		  } else if (id == 'G') {
            id = G;  
			println("Is G");
          } else if (id == 'B') {
            id = B;
          } else if (id == 'C') {
            id = C;  
          } else if (id == 'T') {
            id = THERM;  
          } else if (id == ' ') {
            id = 0;  
          }else {
            id -= '0';  
          }  
          level[y][x] = id;  
        }
      }
      doneLevel = true;  
    }
    // read next line
	i++;
  }
  println(level[0][0]);
  println(level[0][1]);
  println(level[0][2]);
  println(level[0][3]);
  return level; 
}
*/
PImage flipImg(PImage i) {
  PImage flipped = new PImage(i.width,i.height,ARGB);
  for (int y=0; y<i.height; y++) {
    for (int x=0; x<i.width; x++) {
      flipped.set(x,y,i.get(i.width-1-x,y));
    } 
  }  
  return flipped;
}

//----------------------------------------------
// Heat source (player) object
//----------------------------------------------
class HeatSource {
  float x,y,t,rx,ry,vx,vy;
  float gravity = 0.3;
  int jump_count, kill_count, run_index, idle_index;
  boolean onGround, hitCeiling, killing, inWater, isStopped, dirX;
  PImage sheet;
  private PImage[] idle, run, kill;
  public HeatSource(float x,float y,float temp) {
    this.vx = 0;
    this.vy = 0;
    this.x = x;
    this.y = y;
    this.t = temp;  
    this.rx = 26.0/40.0;
    this.ry = 35.0/40.0;
    onGround = false;
    hitCeiling = true;
    jump_count = 0;
    kill_count = 0;
    killing = false;
    inWater = false;
    isStopped = true;
    run_index = 0;
    idle_index = 0;
    
    sheet = loadImage("img/candle.png");
    idle = new PImage[4];
    idle[0] = sheet.get(0*26,1*40,26,40);
    idle[1] = sheet.get(1*26,1*40,26,40);
    idle[2] = sheet.get(2*26,1*40,26,40);
    idle[3] = sheet.get(3*26,1*40,26,40);
    
    run = new PImage[4];
    run[0] = sheet.get(1*26,0*40,26,40);
    run[1] = sheet.get(2*26,0*40,26,40);
    run[2] = flipImg(run[0]);
    run[3] = flipImg(run[1]);
    
    kill = new PImage[8];
    /*kill[0] = sheet.get(0*40,0*40,40,40);
    kill[1] = sheet.get(1*40,0*40,40,40);
    kill[2] = sheet.get(2*40,0*40,40,40);
    kill[3] = sheet.get(3*40,0*40,40,40);
    kill[4] = sheet.get(4*40,0*40,40,40);
    kill[5] = sheet.get(5*40,0*40,40,40);
    kill[6] = sheet.get(6*40,0*40,40,40);
    kill[7] = sheet.get(7*40,0*40,40,40);
*/
  }
  
  public void setVel(float vx, float vy) {
    this.vx = vx;
    this.vy = vy;  
  }
  public void jump() {
    if (inWater)
      return;
    else if (jump_count < 2) {
    //if (onGround && jump_count == 0) {
    //  jump_count++;
     // this.vy = -0.3;  
    //} else if (!onGround && jump_count < 2) {
      jump_count++;
      this.vy = -0.3; 
    }
  }
  private void hitGround() {
    this.onGround = true;
    this.jump_count = 0;  
  }
  
  public boolean move() {
    float xa = this.vx;
    float ya = this.vy;
    
    if (xa != 0 || ya != 0) {
      boolean stopped = true;
      if (xa != 0 && moveX(xa)) {
        stopped = false;
        this.dirX = (xa > 0);
      }
      if (ya != 0 && moveY(ya)) {
        stopped = false;
        this.onGround = false;          
      }
      
      if (!stopped) {
        int stepped_on_id = grid[(int)ya*GRID_WIDTH+(int)xa].id;
      }
      return stopped;
    }
    return false;
  }
  
  public boolean moveX(float dx) {
    // return true if we moved
    float d = 0.01;
    float dir = 1;
    if (dx < 0) dir = -1;
    
    int ty = (int)this.y;
    int tyl = (int)(this.y-this.ry/2.0);
    int tyr = (int)(this.y+this.ry/2.0);
    float cx = d*dir;

    while (abs(cx) < abs(dx)) {
     int tx = (int)(this.x+cx+dir*this.rx/2.0);
     if (grid[ty*GRID_WIDTH+tx].solid) {// || grid[tyl*GRID_WIDTH+tx].solid) {
        cx -= d*dir;
        break;
     }
      cx += d*dir;  
    }

    this.x += cx;  
    return (cx != 0);  
  }
  
  public boolean moveY(float dy) {
    
    float d = 0.01;
    float dir = 1;
    if (dy < 0) dir = -1;
    
    int tx = (int)(this.x);
    int txr = (int)(this.x + this.rx/2);
    int txl = (int)(this.x - this.rx/2);
    float cy = d*dir;
    //println(dir);
    while (abs(cy) < abs(dy)) {
     int ty = (int)(this.y+cy+dir*this.ry/2.0);
    // if (grid[ty*GRID_WIDTH+txr].solid || grid[ty*GRID_WIDTH+txl].solid) {
     if (grid[ty*GRID_WIDTH+tx].solid) {   
        cy -= d*dir;
        
        // hit floor or ceiling 
        this.vy = 0;
        if (dy > 0) { // hit floor, not ceiling
          this.hitGround();
        } else {
          cy -= d*dir; // hacky fix for ceiling hit  
        }
        break;
     }
      cy += d*dir;  
    }
    this.y += cy;  
    return (cy != 0);  
  }
   
  public void tick() {
    
    int ix = (int)this.x;
    int iy = (int)this.y;
    
    if (gem1.collected && gem2.collected && grid[iy*GRID_WIDTH+ix].id == X) { // check win condition
      levelWon = true;
      return;  
    }
    
    // add gravity
    this.vy += 0.02;
    
    int by = (int)(this.y + this.ry/2); // check a bit below player, so they cant jump out of water

    if (grid[(int)y*GRID_WIDTH+ix].id == WATER_SRC || grid[(int)y*GRID_WIDTH+ix].id == WATER_STREAM ) {
      this.inWater = true;
      this.vy -= 0.02; // no gravity
      this.vy -= 0.01;
      if (this.vy < -0.1) 
        this.vy = -0.1;
    } 
    // set player still in water if just above it
    if (grid[by*GRID_WIDTH+ix].id == WATER_SRC || grid[by*GRID_WIDTH+ix].id == WATER_STREAM ) {
      this.inWater = true;
    } else {
      this.inWater = false;
    }
    
    // check suicide
    if (this.killing) {
      this.kill_count++;
      this.vx = 0; // reset horizontal movement
      //println(kill_count);
      if (this.kill_count >= 180) {
        levelReset = true;
        this.kill_count = 0; // reset suicide counter
      }    
    } else {
      this.kill_count = 0; // reset suicide counter
    }
    //println(inWater);

    // friction (possibly change friction values for inAir, onGround, onICe
    /*float friction = 0.01;
    if (this.vx < 0) friction *= 1;
    else if (this.vx > 0) friction *= -1;
    else friction = 0.0;
  
    this.vx += friction;
    if (abs(this.vx) < friction) this.vx = 0;
   // println(vx + "," + vy);*/
    this.isStopped = move();    
    this.vx = 0;
  }
  
  public void render() {
    
    color c = color(255,0,0,128);
    fill(c);
    noStroke();
    PImage i = idle[0];
    
    // SELECT SPRITE    
    if (this.kill_count > 0) { // suicide animation
      int img_index = (int) ( (float)(this.kill_count)*8.0/180.0 );
      if (img_index == 8) 
        img_index = 7;
      i = kill[img_index]; 
      i = idle[0]; // temp  
    }
    else if (this.isStopped) { // Idle
      if (frameCount % 32 == 0) {
        idle_index = (idle_index + 1) % 2;
      
        if (random(0,1) > 0.95) idle_index += 2; // blink
      }
      i = idle[idle_index]; // temp
    } else if (this.onGround) { // Running  
      // 0 to 10 are 1st run, 11 to 20 are 2nd run, etc..
      if (frameCount % 8 == 0) {
        run_index = (run_index + 1) % 2;
      }
      int index = run_index;
      if (!this.dirX) // get left-facing sprites
        index += 2;
      i = run[index];
    }
    // draw image
    image(i,(this.x-this.rx/2.0)*PIXELS_PER_TILE,(this.y + this.ry/2.0)*PIXELS_PER_TILE - 40,i.width,i.height);
    //fill (255,0,110);
    //ellipse(this.x*PIXELS_PER_TILE,this.y*PIXELS_PER_TILE,this.rx*PIXELS_PER_TILE,this.ry*PIXELS_PER_TILE);
  }
  
}





class Collectable extends HeatSource {
  public float dx,dy;
  public boolean collected;
  private float rot_offset;
  public Collectable(int x,int y) { 
    super((float)x + 0.5,(float)y+0.5,0); 
    this.dx = 0;
    this.dy = 0;
    this.rx = 0.5;
    this.ry = 0.5;
    collected = false;
    this.rot_offset = random(0.0,500.0);
  }
  public void tick() {
    if (!collected) {
      this.dx = 0.25*cos((frameCount+rot_offset)/50.0);  
      this.dy = 0.25*sin((frameCount+rot_offset)/50.0);  
      
      float mx = (float)this.x+this.dx;
      float my = (float)this.y+this.dy;
      if (src.x >= mx - this.rx && src.x <= mx+this.rx && src.y <= my+this.ry && src.y >= my-this.ry) {
        collected = true; 
      }   
    }
  }
  public void render() {
    if (!collected ) {
      color c = color(0,255,0);
      fill(c);
      noStroke();
      ellipse((this.x + this.dx)*PIXELS_PER_TILE,(this.y + this.dy)*PIXELS_PER_TILE,this.rx*PIXELS_PER_TILE,this.ry*PIXELS_PER_TILE);  
    }
  }
  
}


class Tile {
  public float t=0.0;
  public float goal_t = 50.0;
  public int id;
  public boolean solid = false;
  public int water_length = 0;
  public int age;
  PImage sprite, sprite2, sprite3, sprite4;
  public Tile(float t, int id) {
    setTile(t,id);
    age = 0;
  } 
  // same as constructor 
  public void setTile(float t, int id) {
    this.t = t;
    if (id != this.id) { // only change/load sprites when there is a change
      this.id = id;
      loadSprite();
      this.solid =  (id == ROCK || id == ICE || id == WOOD || id == WOOD_ON_FIRE || id == B || id == G);      
    }
  }
  
  
  private void loadSprite() {
    if (this.id == ROCK) {
      this.sprite = loadImage("img/block.png");    
    } else if (this.id == B) {
      this.sprite = loadImage("img/button.png");
    } else if (this.id == ICE) {
      this.sprite = loadImage("img/ice.png");
    } else if (this.id == WOOD) {
      this.sprite = loadImage("img/wood.png");      
    } else if (this.id == WOOD_ON_FIRE) {
      this.sprite = loadImage("img/wood.png");      
      this.sprite2 = loadImage("img/fire.png");            
    } else if (this.id == WATER_SRC || this.id == WATER_STREAM) {
      this.sprite = loadImage("img/water1.png");
      this.sprite2 = loadImage("img/water2.png");
      this.sprite3 = loadImage("img/water3.png");
      this.sprite4 = loadImage("img/water4.png");
    } else if (this.id == G) {
      this.sprite = loadImage("img/gate1.png");
      this.sprite2 = loadImage("img/gate2.png");
    } else if (this.id == X) {
      this.sprite = loadImage("img/door.png");
      this.sprite2 = loadImage("img/door2.png");
    } else {
      this.sprite = loadImage("img/block.png");
    } 
    
  }
  
  public void render(int px, int py, int w, boolean background) {
    int pwx = 0; // pixel wiggle x
    int pwy = 0;
    color c = color(0,0,0);
    if (background) {
      c = getColor(this.t);  
      fill(c);
      rect(px,py,w,w);
      return;
    } else {
    if (id == AIR)
      c = getColor(this.t);
    else if (id == ROCK)
      c = color(10,10,10);
    else if (id == ICE) {      
      if (this.t >= 20.0) { // shake if about to melt
          pwx = (int)random(-3,3);
          pwy = (int)random(-3,3);
      }
      else if (this.t >= 10.0) { // small shake
          pwx = (int)random(-2,2);
          pwy = (int)random(-2,2);
      }
    }
    else if (id == WATER_SRC || id == WATER_STREAM)
      c = color(100,100,255);
    else if (id == STEAM)
      c = color(255,255,255);
    else if (id == WOOD) {
      if (this.t >=  41.0) { // shake if about to burn
          pwx = (int)random(-2,2);
          pwy = (int)random(-2,2);
      }
      if (this.t >= 44.0) { // shake if about to burn
          pwx = (int)random(-3,3);
          pwy = (int)random(-3,3);
      }
    }
    
    if (id == ROCK || id == B || id == ICE || id == WOOD) {
      image(sprite,px+pwx,py+pwy-8,40,40);  
    } else if (id == WOOD_ON_FIRE) {
      image(sprite,px+pwx,py+pwy-8,40,40);  
      image(sprite2,px+pwx,py+pwy-8,40,40);   
    } else if (this.id == WATER_SRC || this.id == WATER_STREAM) {
      int spacing = frameCount % 80;
      if (spacing < 20) {
        image(sprite,px+pwx,py+pwy-8,40,40);  
      } else if (spacing < 40) {
        image(sprite2,px+pwx,py+pwy-8,40,40);  
      } else if (spacing < 60) {
        image(sprite3,px+pwx,py+pwy-8,40,40);  
      }  else {
        image(sprite4,px+pwx,py+pwy-8,40,40);  
      }   
    } else if (id == THERM) {
      c = color(255,255,255); 
    } else if (id == G) {
      if (!this.solid) image(sprite2,px+pwx,py+pwy-8,40,40);   
      else image(sprite,px+pwx,py+pwy-8,40,40);   
    } else if (id == O) {
       image(sprite2,px+pwx,py+pwy-8,40,40);
    } else if (id == X) {
      if (gem1.collected && gem2.collected) {
        image(sprite2,px+pwx,py+pwy-8,40,40);  
      } else {
        image(sprite,px+pwx,py+pwy-8,40,40);  
      }    
    }
    else {
      fill(c);
      rect(px,py,w,w);
    }
    if (id == THERM) {
      textAlign(CENTER);
      text((int)this.t + "",px+PIXELS_PER_TILE*0.5,py+PIXELS_PER_TILE*0.3);
      text((int)this.goal_t + "",px+PIXELS_PER_TILE*0.5,py+PIXELS_PER_TILE*0.7);
      
    }
  }
}
}
