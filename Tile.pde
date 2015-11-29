
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
      this.sprite = loadImage("block.png");    
    } else if (this.id == B) {
      this.sprite = loadImage("button.png");
    } else if (this.id == ICE) {
      this.sprite = loadImage("ice.png");
    } else if (this.id == WOOD) {
      this.sprite = loadImage("wood.png");      
    } else if (this.id == WOOD_ON_FIRE) {
      this.sprite = loadImage("wood.png");      
      this.sprite2 = loadImage("fire.png");            
    } else if (this.id == WATER_SRC || this.id == WATER_STREAM) {
      this.sprite = loadImage("water1.png");
      this.sprite2 = loadImage("water2.png");
      this.sprite3 = loadImage("water3.png");
      this.sprite4 = loadImage("water4.png");
    } else if (this.id == G) {
      this.sprite = loadImage("gate1.png");
      this.sprite2 = loadImage("gate2.png");
    } else if (this.id == X) {
      this.sprite = loadImage("door.png");
      this.sprite2 = loadImage("door2.png");
    } else {
      this.sprite = loadImage("block.png");
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
