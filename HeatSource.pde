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
    
    sheet = loadImage("candle.png");
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
    println(dir);
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
      println(kill_count);
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
