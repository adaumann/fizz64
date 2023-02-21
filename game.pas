program game;



@startblock $7A00 "Variables"

var	
	//@define DEBUG 1
	@define OVERFLOW_CHECK 1
	@define USE_KERNAL 0
	
	// Charsets
	@define charsetLoc1 $3800
	@define charsetLoc2 $7800
	@define tilesetLoc1 $3000
	@define tilesetLoc2 $7000
	@define tilesetCol $6c00
	// Automatically export charsets 
	@export "charsets/charset.flf" "charsets/charset.bin" 60	
 	@export "charsets/tileset.flf" "charsets/tileset.bin" 256	
  	charset1: incbin("charsets/charset.bin", @charsetLoc1);
  	charset2: incbin("charsets/charset.bin", @charsetLoc2);
  	tileset1: incbin("charsets/tileset.bin", @tilesetLoc1);
	// Pointer that will point to character data location at $2000+$800=$2800
   	tileset2: incbin("charsets/tileset.bin", @tilesetLoc2);
	// Pointer that will point to character data location at $2000+$800=$2800
	tilesetColors :  incbin("charsets/tileset_color.bin", @tilesetCol);
	
	// Double Buffer
	currentBank: byte=0;
	time: byte=0;
	frameStatus: byte;
	screen: byte;
	debugx: byte;
	// Game	
	@define SCENES_SIZE 1
	@define DIMX 20
	@define DIMY 12
	@define DIMZ 4
	@define DIMTILES 240
	@define Z_BACK2 3
	@define Z_BACK1 2
	@define Z_MAIN 1
	@define Z_FRONT 0
	@define UNKNOWN $FF
	@define DOWN 0
	@define UP 1
	@define LEFT 2
	@define RIGHT 3
	@define SHIFT_DOWN 4
	@define SHIFT_UP 5
	@define SHIFT_LEFT 6
	@define SHIFT_RIGHT 7
	@define DOWN_LEFT 8
	@define DOWN_RIGHT 9
	@define UP_LEFT 10
	@define UP_RIGHT 11	
	@define STOP 12
	@define AREA_OUT $FF
	@define AREA_DOWN 0
	@define AREA_UP 1
	@define AREA_LEFT 2
	@define AREA_RIGHT 3
	@define AREA_CENTER 4
	
	collAreaUp: array[9] of byte = (8,7,6,5,4,3,2,1,0);
	collAreaLeft: array[9] of byte = (2,5,8,1,4,7,0,3,6);
	collAreaRight: array[9] of byte = (6,3,0,7,4,1,8,5,2);

	shiftAreaDownX: array[9] of byte = (-1, 0, 1 , -1, 0, 1, -1, 0, 1);
	shiftAreaUpX: array[9] of byte = (1, 0, -1, 1, 0, -1, 1, 0, -1);
	shiftAreaLeftX: array[9] of byte = (1, 1, 1, 0, 0, 0, -1, -1, -1);
	shiftAreaRightX: array[9] of byte = (-1, -1, -1,0, 0, 0, 1, 1, 1);

	shiftAreaDownY: array[9] of byte = (-1, -1, -1, 0, 0, 0, 1, 1, 1);
	shiftAreaUpY: array[9] of byte = ( 1, 1, 1 , 0, 0, 0, -1, -1, -1);
	shiftAreaLeftY: array[9] of byte = ( -1, 0, 1, -1, 0, 1, -1, 0, 1);
	shiftAreaRightY: array[9] of byte = ( 1, 0, -1,  1, 0, -1, 1, 0, -1);
	
	tempPointer: pointer of byte;
	
	@define ID_TEXTBOX 128
	@define ID_IMAGEBOX 129
	@define ID_MENU 130
	@define STATE_PLAY 0
	@define STATE_DO_NOTHING 1
	@define STATE_PAUSE_TAGS 2
	@define STATE_PAUSE_ALL 3
	
	@define DURATION_KILL 50
	
	@define SCRIPT_INIT 0
	@define SCRIPT_PLAY 1
	
	@define COMP_PHYSICS_0         %00000001
	@define COMP_COLLIDE_ABLE_0    %00000010
	@define COMP_SHIFT_PLATTFORM_0 %00000100	
	@define COMP_DESTROY_COLLIDE_0 %00001000
 	@define COMP_ERASE_ABLE_0      %00010000
 	
	@define LEV_BRICK $01
	@define LEV_STONE $0f
	
	gobject = class
		id: byte;
		isActive : boolean;
		components: array[4] of byte;
		
		// TransformTile
		transIsStatic: boolean;
		transX, transY, transZ, transPriority, transRot: byte;
	
		// Render
		rendToMove, rendDrawEnergy, rendInAnimCycle : boolean;
//		rendLastXpos, rendLastYpos, rendLastPathElem, rendMoveoffsetx, rendMoveoffsety, rendCenterX, rendCentery: byte;
		rendEnergyX, rendEnergyY, rendEnergyPercent, rendTilePos: byte;
		
		// Physics
		physGravity: byte;
		physRollLeftRight: boolean;

		// ShiftPlattform
		shiftDirection: byte;
		
		// DestroyCollide
		destColIgnoreTag: byte;
		destColDamageEnergy: byte;
		destColKey: byte;
		
		
	end;
	lev0: cstring = ("a aa a   a  a  a  aaaoooa aa  a  aa    aa oo  aaa  aa      aaa a               aa                  aa                  aa                  aa                  aa                  aa                  aa                  aa                  aa");
	objectList : Array[128] of gobject;
	countObjects: byte;
	deletedObjects: Array[128] of byte;
	countDeletedObjects: byte;
	dynObjectListBack2 : Array[128] of byte;
	dynObjectListBack1 : Array[128] of byte;	
	dynObjectListMain : Array[128] of byte;
	dynObjectListFront : Array[128] of byte;		
	countDynBack2, countDynBack1,countDynMain,countDynFront: byte = 0;
	mapback2 : Array[@DIMTILES] of byte;
	mapback1 : Array[@DIMTILES] of byte;
	mapmain : Array[@DIMTILES] of byte;
	mapfront : Array[@DIMTILES] of byte;
	state, oldState: byte;
	killDuration, killTimer: byte;
	newSceneAfterKill: boolean;
	x1,y1: byte;
	tempColArea: array[9] of byte = ( $ff, $ff, $ff,  $ff, $ff, $ff, $ff, $ff, $ff );
	tempEraseArea: array[9] of byte = ( $ff, $ff, $ff,  $ff, $ff, $ff, $ff, $ff, $ff );
	tempDestroyArea: array[9] of byte = ( $ff, $ff, $ff,  $ff, $ff, $ff, $ff, $ff, $ff );
	
	@ifdef DEBUG
		testarea: array[9] of byte = ($00,$10,$20,$30,$40,$50,$60,$70,$80);
		ret: byte;
		iret: integer;
		i,j,c: byte;
		pg: pointer of gobject;
		pa: pointer of byte;
		x0: byte;
//		tempColArea: array[9] of byte = ( $ff, $ff, $ff,  $ff, $ff, $ff, $ff, $ff, $ff );
	@endif

@endblock

procedure Init();
begin
	state := @STATE_PLAY;
	oldState := 255;
	killDuration := 0;
	killTimer := 0;
	newSceneAfterKill := true;
	countObjects := 0;
	countDeletedObjects := 0;
end;

procedure print2x2block(x,y,c: byte);
begin
	moveto(x*2,y*2,screen);
	
	@IFDEF OVERFLOW_CHECK
		if(x >= @DIMX or y >= @DIMY) then SCREEN_BG_COL:=YELLOW;
	@ENDIF
	
		
	screenmemory[0]:=c;
	screenmemory[1]:=c+1;
	screenmemory[40]:=c+40;
	screenmemory[41]:=c+41;

	moveto(x*2,y*2,hi(SCREEN_COL_LOC));
	screenmemory[0]:=tilesetColors[c]+8;
	screenmemory[1]:=tilesetColors[c+1]+8;
	screenmemory[40]:=tilesetColors[c+40]+8;;
	screenmemory[41]:=tilesetColors[c+41]+8;;
end;

procedure PrintText(x: byte);
begin
	@IFDEF OVERFLOW_CHECK
		if(x >= 40) then SCREEN_BG_COL:=BLUE;
	@ENDIF
	
	moveto(0,24,screen);
	fillfast(screenmemory,$20,40);
	screenmemory[0]:=$1c;
	screenmemory[39]:=$1d;
	moveto(x,24,screen);
	printstring("HELLO",0,40);		
end;


procedure print2x2blockEmpty(x,y:byte);
begin
	@IFDEF OVERFLOW_CHECK
		if(x >= @DIMX or y >= @DIMY) then SCREEN_BG_COL:=GREY;
	@ENDIF
	moveto(x*2,y*2,screen);
	screenmemory[0]:=255;
	screenmemory[1]:=255;
	screenmemory[40]:=255;
	screenmemory[41]:=255;
end;

procedure GetZLayerPointer(z: byte);
begin
	case z of
		@Z_BACK2: tempPointer := #mapback2;
		@Z_BACK1: tempPointer := #mapback1;
		@Z_MAIN: tempPointer := #mapmain;
		@Z_FRONT: tempPointer := #mapfront;
	end;
end;

procedure PaintPos(pos: byte);
var
	x,y: byte;
	t: byte;
	pg: pointer of gobject;
begin
	@IFDEF OVERFLOW_CHECK
		if(pos >= @DIMTILES) then SCREEN_BG_COL:=BROWN;
	@ENDIF
	
	x := mod(pos,@DIMX);
	y := pos / @DIMX;

	print2x2blockEmpty(x,y);
	
	if(mapback2[pos] <> 255) then begin
 	end;
 	if(mapback1[pos] <> 255) then begin
 	end;
 	t := mapmain[pos];
 	if(t <> 255) then begin
	 	pg := #objectList[t];
		print2x2block(x,y,pg.rendTilePos);
 	end;
 	if(mapfront[pos] <> 255) then begin
	end;
	
end;

function HasPhysicsComponent(id: byte) : boolean;
var
	ret: byte;
    	pg: pointer of gobject;
	val: byte;
begin
	ret := false;
	pg := #objectList[id];
	val := (pg.components[0] & @COMP_PHYSICS_0);
	if(val = @COMP_PHYSICS_0) then ret := true;
	HasPhysicsComponent := ret;
end;


function GetObjArea(id: byte, area: pointer of byte, pos: byte) : byte;
var
    gravity: byte;
    pg: pointer of gobject;
    gpos: byte;
begin
	pg := #objectList[id];
	gravity := @DOWN;
	if(HasPhysicsComponent(id) = true) then gravity := pg.physGravity;
	if(pg.physGravity = @DOWN) then gpos := pos
	else if(pg.physGravity = @UP) then gpos := collAreaUp[pos] 
	else if(pg.physGravity = @LEFT) then gpos := collAreaLeft[pos] 
	else if(pg.physGravity = @RIGHT) then gpos := collAreaRight[pos];
 	GetObjArea := area[gpos];
end;

function ConvertShift(gravity: byte, x,y: byte) : integer;
var 
    pg: pointer of gobject;
    pos: byte;
    ret: integer;
begin
	pos := x + y * 3;
	if(gravity = @DOWN) then ret := CreateInteger(shiftAreaDownX[pos],shiftAreaDownY[pos])
 	else if(gravity = @UP) then ret := CreateInteger(shiftAreaUpX[pos],shiftAreaUpY[pos])
 	else if(gravity = @LEFT) then ret := CreateInteger(shiftAreaLeftX[pos],shiftAreaLeftY[pos])
 	else if(gravity = @RIGHT) then ret := CreateInteger(shiftAreaRightX[pos],shiftAreaRightY[pos]);
	ConvertShift := ret; 	
end;


function CalcPosition(startx,starty,offsetx, offsety: byte) : integer;
var
	destx, desty: byte;
begin
	// Eventually optimize if offset abs = 1
	destx := startx + offsetx;
	desty := starty + offsety;
	if(destx < 0) then destx := mod(destx + @DIMX, @DIMX)
	else destx := mod(startx + offsetx, @DIMX);
	if(desty < 0) then desty := mod(desty + @DIMY, @DIMY)
	else desty := mod(starty + offsety, @DIMY);
	CalcPosition := CreateInteger(destx, desty);
end;

function CalcPositionMapPos(startx,starty,offsetx, offsety: byte) : byte;
var 
	pos: integer;
begin
	pos := CalcPosition(startx,starty,offsetx, offsety);
	CalcPositionMapPos := hi(pos) + lo(pos) * @DIMX;
end;

procedure GetCollisionArea(pa: pointer of byte, id: byte, z: byte, compIdx: byte, comp: byte, k: byte);
var
	i,j: byte;
	c: byte;
	pg, pgCol: pointer of gobject;
	colId: byte;
	val: byte;
	ppos: pointer of gobject;
	mapPos: byte;
	x0 :byte;
begin
	pg := #objectList[id];

	GetZLayerPointer(z);
	
	c := 0;
	for i := -1 to 2 do begin
		for j := -1 to 2 do begin
			mapPos := CalcPositionMapPos(pg.transX, pg.transY, j, i);
			// id on map level z
			colId := tempPointer[mapPos];
			pa[c] := $FF;
			if(colId <> $FF) then begin
				pgCol := #objectList[colId];
				tempColArea[c] := colId;
				val := pgCol.components[compIdx] & comp;
				if(val = comp) then pa[c] := colId;
			end;
			c := c + 1;
		end;
	end;
end;

function CalcPositionX(startx,offsetx: byte) : byte;
var
	destx: byte;
begin
	destx := startx + offsetx;
	if(destx < 0) then destx := mod(destx + @DIMX, @DIMX)
	else destx := mod(startx + offsetx, @DIMX);
	CalcPositionX := destx;
end;

function CalcPositionY(starty,offsety: byte) : byte;
var
	desty: byte;
begin
	desty := starty + offsety;
	if(desty < 0) then desty := mod(desty + @DIMY, @DIMY)
	else desty := mod(starty + offsety, @DIMY);
	CalcPositionY := desty;
end;

procedure ChangeMapItem(id: byte, oldx: byte, oldy: byte, x: byte, y: byte, z:byte);
var
	oldpos: byte;
	pos,t: byte;
	pg: pointer of gobject;
	ppos: pointer of byte;
begin
	oldpos := oldx + oldy * @DIMX;
	pos := x + y * @DIMX;
	GetZLayerPointer(z);
	tempPointer[oldpos] := $FF;
	tempPointer[pos] := id;
	PaintPos(oldpos);
	PaintPos(pos);
end;

procedure SetPos(i: byte,x: byte, y: byte, z: byte);
var
	oldx, oldy, oldz: byte;
	pg: pointer of gobject;
	pos: byte;
begin
	pg := #objectList[i];
	pos := x + y * @DIMX;
	GetZLayerPointer(z);
	if(tempPointer[pos] = $FF) then begin
		oldx := pg.transX;
		oldy := pg.transY;
		pg.transX := x;
		pg.transY := y;
		ChangeMapItem(i, oldx, oldy, x, y, z);
	end;
end;

procedure UpdatePhysics(id: byte);
var
	fallDown, fallLeftDown, fallRightDown: boolean;
	pg: pointer of gobject;
	colObj: byte;
	newx, newy: byte = $FF;
	gravity: byte;
	shift: integer;
	
//	tempEraseArea: array[9] of byte;	
//	tempDestroyCollideArea: array[9] of byte;	
begin
	pg := #objectList[id];
	GetCollisionArea(#tempColArea, id, pg.transZ, 0, @COMP_COLLIDE_ABLE_0,0);
	GetCollisionArea(#tempEraseArea, id, pg.transZ, 0, @COMP_ERASE_ABLE_0,0);
	GetCollisionArea(#tempDestroyArea, id, pg.transZ, 0, @COMP_DESTROY_COLLIDE_0,0);
	
	gravity := pg.physGravity;
	fallDown := false;
	fallLeftDown := false;
	fallRightDown := false;
	
	colObj := GetObjArea(id, #tempDestroyArea, 7);
	if(colObj <> $FF) then fallDown := true
	else if((GetObjArea(id, #tempDestroyArea, 3) = $FF and GetObjArea(id, #tempDestroyArea, 6) = $FF) and pg.physRollLeftRight = true) then fallLeftDown := true
	else if((GetObjArea(id, #tempDestroyArea, 5) = $FF and GetObjArea(id, #tempDestroyArea, 8) = $FF) and pg.physRollLeftRight = true) then fallRightDown := true;
	
	
	colObj := GetObjArea(id, #tempColArea, 7);

	if(colObj = $FF) then fallDown := true
	else if((GetObjArea(id, #tempColArea, 3) = $FF and GetObjArea(id, #tempColArea, 6) = $FF) and pg.physRollLeftRight = true) then fallLeftDown := true
	else if((GetObjArea(id, #tempColArea, 5) = $FF and GetObjArea(id, #tempColArea, 8) = $FF) and pg.physRollLeftRight = true) then fallRightDown := true;

	// TODO: Shift Plattform
	
	if(fallDown = true) then begin
		shift := ConvertShift(gravity, 1, 2);
		newx := CalcPositionX(pg.transX, Hi(shift));
		newy := CalcPositionY(pg.transY, Lo(shift));
	end
	else if(fallLeftDown = true) then begin
		shift := ConvertShift(gravity, 0, 2);
		newx := CalcPositionX(pg.transX, Hi(shift));
		newy := CalcPositionY(pg.transY, Lo(shift));
	end
	else if(fallRightDown = true) then begin
		shift := ConvertShift(gravity, 2, 2);
		newx := CalcPositionX(pg.transX, Hi(shift));
		newy := CalcPositionY(pg.transY, Lo(shift));
	end;
	if(newx <> $FF) then SetPos(id,newx,newy,pg.transZ);

end;

procedure UpdateObject(id: byte);
begin
	if(HasPhysicsComponent(id) = true) then UpdatePhysics(id);
end;

procedure Update();
var 
	i: byte;
	id: byte;
begin
	if(countDynBack2 <> 0) then begin
		for i:=0 to countDynBack2 do 	begin
			id := dynObjectListBack2[i];
			UpdateObject(id);
		end;
	end;
	if(countDynBack1 <> 0) then begin
		for i:=0 to countDynBack1 do 	begin
			id := dynObjectListBack1[i];
			UpdateObject(id);
		end;
	end;
	// TODO: Better chunking for main layer
	if(countDynMain <> 0) then begin
		for i:=0 to countDynMain do begin
			id := dynObjectListMain[i];
			UpdateObject(id);
		end;
	end;

	if(countDynFront <> 0) then begin
		for i:=0 to countDynFront do begin
			id := dynObjectListFront[i];
			UpdateObject(id);
		end;
	end;
end;


procedure AddMapItem(Id: byte, x: byte, y: byte, z:byte);
var
	pos: byte;
	pm : pointer of byte;
begin
	pos := x + y * @DIMX;
	GetZLayerPointer(z);
	@IFDEF OVERFLOW_CHECK
		if(z = @DIMX or y >= @DIMY) then SCREEN_BG_COL:=YELLOW;
	@ENDIF
	
	tempPointer[pos] := Id;
end;

procedure ClearMap();
var 
	m: byte;
	pm : pointer of byte;
begin
    for m := 0 to @DIMTILES do	
	begin
 	 	mapback2[m] := 255;
 	 	mapback1[m] := 255;
 	 	mapmain[m] := 255;
 	 	mapfront[m] := 255;
 	end;
end;

procedure AddDynItem(i: byte, z: byte);
begin
	if(z = @Z_BACK2) then begin
		dynObjectListBack2[countDynBack2] := i;
		countDynBack2 := countDynBack2 + 1;
	end;
	if(z = @Z_BACK1) then begin
		dynObjectListBack1[countDynBack1] := i;
		countDynBack1 := countDynBack1 + 1;
	end;
	if(z = @Z_MAIN) then begin
		dynObjectListMain[countDynMain] := i;
		countDynMain := countDynMain + 1;
	end;
	if(z = @Z_FRONT) then begin
		dynObjectListFront[countDynFront] := i;
		countDynFront := countDynFront + 1;
	end;
end;

function PopDeletedIndex() : byte;
var
	i: byte;
	ret: byte;
	moveFrom: byte;
begin
	
	if(countDeletedObjects > 0) then begin 
		ret := deletedObjects[0];
		for i:=1 to countDeletedObjects do begin
			moveFrom := deletedObjects[i];
			deletedObjects[i-1] := moveFrom;
		end;
		dec(countDeletedObjects);
	end
	else ret := $FF;
	
	PopDeletedIndex := ret;
end;

function GetIndex() : byte;
var
	ret: byte;
begin
	ret := PopDeletedIndex();
	if(ret = $FF) then begin
		inc(countObjects);
		ret := countObjects;
	end;
	GetIndex := ret;
end;

procedure InitBrick(x: byte, y: byte);
var 
	pg: pointer of gobject;
	id: byte;
begin
	id := GetIndex();
	pg := #objectList[id];
	pg.id := id;
	pg.rendTilePos := 0;
	pg.components[0] := $00 | @COMP_COLLIDE_ABLE_0;
	pg.components[1] := $00;
	pg.components[2] := $00;
	pg.components[3] := $00;
	pg.isActive := true;
	pg.transIsStatic := true;
	pg.transX := x;
	pg.transY := y;
	pg.transZ := @Z_MAIN;
	pg.physGravity := @DOWN;
	AddMapItem(id, x, y, @Z_MAIN);
end;

procedure InitStone(x: byte; y: byte);
var 
	pg: pointer of gobject;
	id: byte;
begin
	id := GetIndex();
	pg := #objectList[id];
	pg.id := id;
	pg.rendTilePos := 2;
	pg.components[0] := $00 | @COMP_PHYSICS_0|@COMP_COLLIDE_ABLE_0;
	pg.components[1] := $00;
	pg.components[2] := $00;
	pg.components[3] := $00;
	pg.isActive := true;
	pg.transIsStatic := false;
	pg.transX := x;
	pg.transY := y;
	pg.transZ := @Z_MAIN;
	pg.physGravity := @RIGHT;
	pg.physRollLeftRight := true;
	AddDynItem(id, @Z_MAIN);
	AddMapItem(id, x, y, @Z_MAIN);
end;
	
procedure InitMap();
var 
	i,x,y,c : byte;
	newObj : gobject;
begin
	ClearMap();
	countDynBack2 := 0;
	countDynBack1 := 0;	
	countDynMain := 0;	
	countDynFront := 0;
	
	for i := 0 to @DIMTILES do
	begin
		c := lev0[i];
		x := mod(i,@DIMX);
		y := i / @DIMX;
		case c of
			@LEV_BRICK: InitBrick(x, y);
			@LEV_STONE: InitStone(x, y);
		end;
	end;
end;


procedure PaintFull();
var
	i: byte;
begin
    for i := 0 to @DIMTILES do
	begin
		PaintPos(i);
	end;
end;

procedure DeleteMapItem(id: byte, x: byte, y: byte, z:byte);
var	
	pos: byte;
	ppos: pointer of byte;
begin
	pos := x + y * @DIMX;
	GetZLayerPointer(z); 
	tempPointer[pos] := 255;
end;
	
	
procedure DeletePos(dpi: byte);
begin
	objectList[dpi].isActive := false;
	DeleteMapItem(objectList[dpi].transX, objectList[dpi].transY, objectList[dpi].transZ);
end;

procedure SwitchBank();
begin
	if (currentBank = 0) then 
	begin
		SetBank(VIC_BANK1);
		setcharsetlocation(@tilesetLoc2);
		screen := hi(screen_char_loc);
		currentBank := 1;
	end
	else 
	begin
		SetBank(VIC_BANK0);
		setcharsetlocation(@tilesetLoc1);
		screen := hi(screen_char_loc2);
		currentBank := 0;
	end;

end;


interrupt RasterBottomText();

interrupt RasterTopLevel();
var
	i: byte;
begin
	startirq(@USE_KERNAL);
	poke(^$d418,0,31);
	setmulticolormode();
	setcharsetlocation(@tilesetLoc1);
	SCREEN_FG_COL:=BLACK;
	if(frameStatus = 1) then begin
		if(time = 0) then begin
			SwitchBank();
		end
		else if(time = 1 and currentBank = 0) then copyFullScreen(^$0400, ^$4400)
		else if(time = 1 and currentBank = 1) then copyFullScreen(^$4400, ^$0400)
		else if(time = 2) then begin
	      	frameStatus := 0;
	    end;
	end;
	inc(time);
	if(time > 8) then time:=0;
	RasterIRQ(RasterBottomText(), 242, @USE_KERNAL);
	closeIrq();
end;

interrupt RasterBottomText();
var
	i: byte;
begin
	startirq(@USE_KERNAL);
	setregularcolormode();
	setcharsetlocation(@charsetLoc1);
	SCREEN_FG_COL:=WHITE;

	if(time = 2) then begin
		PrintText(4);
	end;
		
	RasterIRQ(RasterTopLevel(),20,@USE_KERNAL);
	closeIrq();
//	setcharsetandscreenlocation(@tilesetLoc1,$4400);
end;

begin
	preventirq();
	disableciainterrupts();
	setmemoryconfig(1,@USE_KERNAL,0);
	
	@IFDEF DEBUG
		clearscreen($20,^$0400);
		InitMap();
		moveto(0,0,$04);
		pg := #objectList[21];
		pg.physGravity := @DOWN;
		
//		ret := (objectList[21].components[0] & @COMP_PHYSICS_0);
//		if(ret = @COMP_PHYSICS_0) then ret:=$FF;
		//ret := HasPhysicsComponent(21);
		//ret := GetObjArea(21, #testarea, 2);
		//iret := CalcPosition(1,12,1,1);
//		UpdatePhysics(21);
//		UpdatePhysics(21);
		SetPos(21,1,1,@Z_MAIN);
		GetCollisionArea(#tempColArea, 21, @Z_MAIN, 0, @COMP_COLLIDE_ABLE_0,0);
//		SetPos(21,1,2,@Z_MAIN);
//		GetCollisionArea(#tempColArea, 21, @Z_MAIN, 0, @COMP_COLLIDE_ABLE_0,10);
		ret := GetObjArea(21, #tempColArea, 8);

		pa := #tempColArea;
		c := 0;
		for i := 0 to 3 do begin
			for j := 0 to 3 do begin
				moveto(j*2,i*2,$04);
				x0 := pa[c];
				printnumber(x0);
				c := c + 1;
			end;
		end;		
		SetPos(21,1,2,@Z_MAIN);
		GetCollisionArea(#tempColArea, 21, @Z_MAIN, 0, @COMP_COLLIDE_ABLE_0,10);
		ret := GetObjArea(21, #tempColArea, 8);

		pa := #tempColArea;
		c := 0;
		for i := 0 to 3 do begin
			for j := 0 to 3 do begin
				moveto(j*2,10+i*2,$04);
				x0 := pa[c];
				printnumber(x0);
				c := c + 1;
			end;
		end;		

/*		moveto(0,10,$04);
		printnumber(ret); 
		printnumber(hi(iret));
		moveto(0,10,$04);
		printnumber(lo(iret)); */
		Loop();
	@ENDIF
	SCREEN_BG_COL:=BLACK;
	SCREEN_FG_COL:=BLACK;
	SPRITE_BITMASK:=0;
	multicolor_char_col[1]:=brown;
	multicolor_char_col[2]:=grey;
	clearscreen($FF,^$0400);
	clearscreen($FF,^$4400);
	clearscreen(BLACK,^$D800);
	
	Init();
	InitMap();
	SwitchBank();
	PaintFull();
	SwitchBank();
	PaintFull();
	setmemoryconfig(1,@USE_KERNAL,0); // Enable all ram, turn off BASIC
	StartRasterChain(RasterTopLevel(), 0,@USE_KERNAL); // Don't use kernal
	frameStatus :=0;
	While(true) do begin
		if(frameStatus = 0)	then begin	
			Update();
			frameStatus := 1;
		end;
	end;
	
	Loop(); 
end.


