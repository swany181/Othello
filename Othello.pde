final int SIZE = 50;
final int STONE_SIZE = (int)(SIZE*0.7);
final int NONE = 0;
final int BLACK = 1;
final int WHITE = -1;

final int INITIATE = -100;
final int FINISH = 100;

int[][] field;
int[][] pre_field;
final int [][] VALUE = {
  {
    30, -12, 0, -1, -1, 0, -12, 30
  }
  , 
  {
    -12, -15, -3, -3, -3, -3, -15, -12
  }
  , 
  {
    0, -3, 0, -1, -1, 0, -3, 0
  }
  , 
  {
    -1, -3, -1, -1, -1, -1, -3, -1
  }
  , 
  {
    -1, -3, -1, -1, -1, -1, -3, -1
  }
  , 
  {
    0, -3, 0, -1, -1, 0, -3, 0
  }
  , 
  {
    -12, -15, -3, -3, -3, -3, -15, -12
  }
  , 
  {
    30, -12, 0, -1, -1, 0, -12, 30
  }
};

boolean black_turn = true;

boolean []a;
boolean []b;

int pass, pass_twice;
boolean flag = true;

boolean roop = true;
boolean check = false;

PFont font;

Table results;
String row; 
String column;

boolean count_flag = true;

int my_stone;

void setup() {
  size(400, 400);
  font = createFont("ヒラギノ角ゴ", 50);
  field = new int[8][8];
  pre_field = new int[8][8];
  a = new boolean[8];
  b = new boolean[8];

  results = new Table();
  results.addColumn("put");
  results.addColumn("black"); 
  results.addColumn("white"); 

  textFont(font);

  my_stone = BLACK;

  for (int i=0; i<8; ++i) {
    for (int j=0; j<8; ++j) {
      if ((i==3||i==4)&&(j==3||j==4)) {
        if ((i+j)%2==0) {
          field[i][j] = BLACK; 
          pre_field[i][j] = BLACK;
        } else {
          field[i][j] = WHITE;
          pre_field[i][j] = WHITE;
        }
      } else {
        field[i][j] = NONE;
        pre_field[i][j] = NONE;
      }
    }
    a[i] = false;
    b[i] = false;
  }
}

void draw() {

  background(0, 128, 0);

  // lines
  stroke(0);
  for (int i=1; i<8; ++i) {
    line(i*SIZE, 0, i*SIZE, height);
    line(0, i*SIZE, width, i*SIZE);
  }

  // draw stones
  noStroke();
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      if (field[i][j]==BLACK) {
        fill(0);  //color black
        ellipse((i*2+1)*SIZE/2, (j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      } else if (field[i][j]==WHITE) {
        fill(255); // color white
        ellipse((i*2+1)*SIZE/2, (j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      }

      if (flag) {
        if (!(sub_checked(i, j)&&field[i][j]==NONE)) {
          pass++;
        }
      }
    }
  }

  flag = false;

  if (pass==64&&pass_twice<2) {
    println("パス");
    fill(random(255), random(255), random(255));
    text("パス", width/2-55, height/2+50);
    delay(1000);
    black_turn = !black_turn;
    flag = true;
    pass = 0;
    pass_twice++;
  }
  if (count!=FINISH) {
    fill(0, 255, 255, 70);
    textSize(30);
    text("スペースキー: UNDO", width/2-150, height/2-50);
    ellipse(width/2-30, height/2, STONE_SIZE+20, STONE_SIZE+20);
    ellipse(width/2+30, height/2, STONE_SIZE+20, STONE_SIZE+20);
    fill(0, 70);
    textSize(50);
    text("黒", width/2-55, height/2+20);
    fill(255, 50);
    text("白", width/2+5, height/2+20);
    textSize(30);
    text("⬆", width/2-15, height/2+50);
    text("石色選択", width/2-60, height/2+80);
  }
  textSize(50);

  if (black_turn) {
    fill(0);  //color black
  } else {
    fill(255); // color white
  }
  ellipse(mouseX, mouseY, STONE_SIZE, STONE_SIZE);

  if (my_stone==BLACK) {
    if (!black_turn&&count<64) {
      auto_play();
    }
  } else if (my_stone==WHITE) {
    if (black_turn&&count<64) {
      auto_play();
    }
  }

  fill(255, 0, 0);
  if (count==64 || pass_twice==2) {
    TableRow newrow = results.addRow(); 
    newrow.setString("put", "Results"); 
    newrow.setInt("black", numBLACK);
    newrow.setInt("white", numWHITE); 
    saveTable(results, "results.csv");
    pass_twice = FINISH;
    count = FINISH;
  } else if (count>=64 || pass_twice>=2) {
    count_stone();
    text(numBLACK+":"+numWHITE+"で", width/2-70, height/2);
    if (numBLACK>numWHITE)text("黒の勝ち", width/2-90, height/2+50);
    else if (numBLACK==numWHITE)text("引き分け", width/2-90, height/2+50);
    else text("白の勝ち", width/2-90, height/2+50);
    pass_twice = FINISH;
    count = FINISH;
  }
  println(64-pass+" "+count);
}

int count = 4;

void mousePressed() {
  int x = mouseX/SIZE;
  int y = mouseY/SIZE;

  if (field[x][y]==NONE) {
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        pre_field[i][j] = field[i][j];
      }
    }

    if (checked(x, y)) {
      field[x][y] = current_stone();
      count_flag = true;

      TableRow newrow = results.addRow();
      newrow.setString("put", "black:"+write(x, y)); 
      count_stone();
      newrow.setInt("black", numBLACK);
      newrow.setInt("white", numWHITE); 
      saveTable(results, "results.csv");
      black_turn = !black_turn;
      count++;
      pass_twice = 0;
      flag = true;
      pass = 0;
      for (int i=0; i<8; i++) {
        a[i] = false;
      }
    }
  }
  if (dist(mouseX, mouseY, width/2-30, height/2)<(STONE_SIZE+10)/2)my_stone = BLACK;
  else if (dist(mouseX, mouseY, width/2+30, height/2)<(STONE_SIZE+10)/2)my_stone = WHITE;
}

boolean pre_check(int x, int y, int dx, int dy) {
  if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && field[x+dx][y+dy] != current_stone()) {
    return check(x, y, dx, dy);
  }
  return false;
}
boolean sub_pre_check(int x, int y, int dx, int dy) {
  if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && field[x+dx][y+dy] != current_stone()) {
    return sub_check(x, y, dx, dy);
  }
  return false;
}

boolean check(int x, int y, int dx, int dy) {
  if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && field[x+dx][y+dy]==current_stone())return true;
  else if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && field[x+dx][y+dy]==NONE)return false;
  else if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && check(x+dx, y+dy, dx, dy)) {
    field[x+dx][y+dy] = current_stone();
    return true;
  } else return false;
}
boolean sub_check(int x, int y, int dx, int dy) {
  if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && field[x+dx][y+dy]==current_stone())return true;
  else if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && field[x+dx][y+dy]==NONE)return false;
  else if (x+dx>=0 && x+dx<8 && y+dy>=0 && y+dy<8 && sub_check(x+dx, y+dy, dx, dy))return true;
  else return false;
}

int current_stone() {
  if (black_turn)return BLACK;
  else return WHITE;
}

int numBLACK, numWHITE;

void count_stone() {
  numBLACK = 0;
  numWHITE = 0;
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      if (field[i][j] == BLACK)numBLACK++;
      else if (field[i][j] == WHITE)numWHITE++;
    }
  }
  if (count==64)count=FINISH;
}

void auto_play() {
  int best = INITIATE;
  int auto_x = 0;
  int auto_y = 0;
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      if (field[i][j]==NONE) {
        if (sub_checked(i, j)) {
          if (best<VALUE[i][j]) {
            best = VALUE[i][j];
            auto_x = i;
            auto_y = j;
          }
        }
      }
    }
  }
  checked(auto_x, auto_y);
  field[auto_x][auto_y] = current_stone();

  count_stone();
  TableRow newrow = results.addRow();
  newrow.setString("put", "white:"+write(auto_x, auto_y)); 
  newrow.setInt("black", numBLACK);
  newrow.setInt("white", numWHITE); 
  saveTable(results, "results.csv");

  black_turn = !black_turn;
  count++;
  pass_twice = 0;
  flag = true;
  pass = 0;
  for (int i=0; i<8; i++) {
    a[i] = false;
  }
}

void keyPressed() {
  if (key==' ') {
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        field[i][j] = pre_field[i][j];
      }
    }
    if (count_flag&&count>4) {
      results.removeRow(count-5);
      results.removeRow(count-6);
      count -= 2;
      count_flag = false;
    }
  }
}
boolean checked(int x, int y) {
  a[0] = pre_check(x, y, -1, 0);
  a[1] = pre_check(x, y, 1, 0);
  a[2] = pre_check(x, y, 0, -1);
  a[3] = pre_check(x, y, 0, 1); 
  a[4] = pre_check(x, y, -1, -1);
  a[5] = pre_check(x, y, -1, 1);
  a[6] = pre_check(x, y, 1, -1);
  a[7] = pre_check(x, y, 1, 1);
  if (a[0]||a[1]||a[2]||a[3]||a[4]||a[5]||a[6]||a[7])return true;
  else return false;
}
boolean sub_checked(int x, int y) {
  a[0] = sub_pre_check(x, y, -1, 0);
  a[1] = sub_pre_check(x, y, 1, 0);
  a[2] = sub_pre_check(x, y, 0, -1);
  a[3] = sub_pre_check(x, y, 0, 1); 
  a[4] = sub_pre_check(x, y, -1, -1);
  a[5] = sub_pre_check(x, y, -1, 1);
  a[6] = sub_pre_check(x, y, 1, -1);
  a[7] = sub_pre_check(x, y, 1, 1);
  if (a[0]||a[1]||a[2]||a[3]||a[4]||a[5]||a[6]||a[7])return true;
  else return false;
}

String write(int x, int y) {
  if (x==0)row = "a"; 
  else if (x==1)row = "b";
  else if (x==2)row = "c";
  else if (x==3)row = "d";
  else if (x==4)row = "e";
  else if (x==5)row = "f";
  else if (x==6)row = "g";
  else row = "h";
  if (y==0)column = "1"; 
  else if (y==1)column = "2";
  else if (y==2)column = "3";
  else if (y==3)column = "4";
  else if (y==4)column = "5";
  else if (y==5)column = "6";
  else if (y==6)column = "7";
  else column = "8";
  return row+column;
}