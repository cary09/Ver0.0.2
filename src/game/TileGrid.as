package game 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Eric
	 */
	public class TileGrid 
	{
		private var _view:Sprite;				//视图引用
		private var _tileList:Object;			//区块引用列表
		//private var _viewList:Array;			//视图引用列表
		private var _dataList:Array;				//数据列表
		
		private var _gridW:int;
		private var _gridH:int;
		private var _tileW:int;
		private var _tileH:int;
		private var _tileTypes:int = 5;
		
		private var _findNum:int;
		private var _findTileTemp:Object;				//搜索索引缓存，解决重复搜索的问题。
		private var _findTileList:Array;					//搜索数组，盛放找到的块
		private var _moveTileList:Array;					//需要移动的块序列
		private var _fillList:Array;							//填充队列
		private var _fallTileList:Array;						//下落块列表
		
		private var _timer:Timer;			//主循环计时器
		private var _delay:int = 30;		//驱动间隔
		
		private var _spYInc:Number = 0.6;				//速度加成
		private var _spYMin:int = 20;						//最小速度值
		//private var _spYInc:Number = 0.005;		//速度加成
		//private var _spYMin:int = 3;						//最小速度值
		private var _fillP:int;
		private var _fillMax:int;
		
		//////////////////////////////////////	Public Functions	//////////////////////////////////////////////
		public function TileGrid() 
		{
			this._init();
		}
		
		public function get view():Sprite
		{
			return this._view;
		}
		
		public function reset():void
		{
			this.destroy();
			this._makeTiles();
			this._timer = new Timer(30);
			this._timer.addEventListener(TimerEvent.TIMER, this._onUpdata);
			this._timer.start();				
		}
		
		public function destroy():void
		{
			if(this._timer != null){
				this._timer.stop();
				this._timer.removeEventListener(TimerEvent.TIMER, this._onUpdata);
				this._timer = null;
			}
			
			for( var i:* in this._tileList) {
				trace("destroy tile: ", i);
				var tile:Tile = this._tileList[i] as Tile;
				trace(tile.toString())
				if (tile != null) {
					tile.destroy();
					tile = null;
					delete this._tileList[i];
				}				
			}
			
			this._tileList = null;
			this._findTileList = null;
			this._moveTileList = null;
			this._dataList = null;
		}
		
		
		
		//////////////////////////////////////	Private Functions	//////////////////////////////////////////////
		///	 初始化
		private function _init():void
		{
			this._fillP = 0;
			this._fillMax  = 2;	//下落计数点，实际的间隔为_fillMax*_delay毫秒
			this._moveTileList = [];
			this._fillList = [];
			this._view = new Sprite();			
			this._view.addEventListener(MouseEvent.MOUSE_DOWN, this._onMouseDown);
				
			this.reset();
		}
		
		
		
		private function _makeTiles():void
		{
			var i:int; 
			var j:int;
			
			this._gridW = GameData.gridW;
			this._gridH = GameData.gridH;
			this._tileW = GameData.tileW;
			this._tileH = GameData.tileH;
			this._tileTypes = GameData.tileTypes;
			this._tileList = {};
			this._dataList = [];
			
			////////////////////////////////	Debug	//////////////////////////////////
			if (GameData.isDebug) {
				this._gridW = GameData.testGrid.length;
				this._gridH = GameData.testGrid[0].length;
			}
			
			i = 0;
			j = 0;
			
			for (i = 0; i < this._gridW; i++ ) {
				var col:Array  = [];
				for (j= 0; j < this._gridH; j++ ) {
					var x:int = i * this._tileW;
					var y:int = j * this._tileH;
					
					var tile:Tile = new Tile();
					tile.view.x = x;
					tile.view.y = y;
					tile.tx = i;
					tile.ty = j;
					
					if (GameData.isDebug) {
						tile.type = GameData.testGrid[i][j];
					}else {
						tile.type = int(this._tileTypes * Math.random());
					}
					this.view.addChild(tile.view);
					col.push(tile.type);
					this._tileList[i + "_" + j] = tile;
					trace("make Tile[", i, ",", j, "] >>>", tile.type);
				}
				this._dataList.push(col);
			}
			
			trace("------- Make TileList Over --------");
			trace("gridW: ", GameData.gridW);
			trace("gridH: ", GameData.gridH);
			trace("datalist: ", this._dataList);
			
		}
		
		
		///	寻找匹配的块
		private function _startFindMatchTile(target:Tile):void
		{
			this._findNum = 0;
			this._findTileTemp = { };
			this._findTileList = [];
			this._singleAroundMatchTest(target);
		}
		
		private function _singleAroundMatchTest(tile:Tile):void
		{
			//if(tile != null)trace("------Target tile: [" + tile.tx + "," + tile.ty + "]");
			var type:int = tile.type;
			var arr:Array = [];
			var ttile:Tile;
			var i:int;			
			var ln:int = 3;	//搜索范围
			var tx:int;
			var ty:int;
			
			//横向搜索
			i = 0;
			while (i < ln) {
				tx = tile.tx + i - 1;
				ty = tile.ty;
				if (tx >= 0 && tx < GameData.gridW) {
					ttile = this._tileList[tx+"_"+ty];
					if (ttile == null) {
						trace(">>>>>Find Tile Null: id[ " + tx+ " ], ty[ " + ty + " ]");
						return ;						
					}
					if (this._isMatchTile(ttile, type)) {
						trace("Find Tile [ " + tx + "," + ty + " ] to hide");
						if (this._findTileList[tx] == null) this._findTileList[tx] = [];
						this._findTileList[tx].push(ttile);
						//this._findTileList.push(ttile);
						this._singleAroundMatchTest(ttile);
						this._findNum ++;
					}
				}
				i++;
			}
			
			//纵向搜索
			i = 0;
			while (i < ln) {
				tx = tile.tx;
				ty = tile.ty + i - 1;
				if (ty >= 0 && ty < GameData.gridH) {
					ttile = this._tileList[tx+"_"+ty];
					if (ttile == null) {
						trace(">>>>>Find Tile Null: tx[ " + tx  + " ], id[ " + ty + " ]");
						return;						
					}
					if (this._isMatchTile(ttile, type)) {
						trace("Find Tile [ " + tx + "," + ty + " ] to hide");
						if (this._findTileList[tx] == null) this._findTileList[tx] = [];
						this._findTileList[tx].push(ttile);
						//this._findTileList.push(ttile);
						this._singleAroundMatchTest(ttile);
						this._findNum ++;
					}
				}
				i++;
			}			
		}
		
		
		
		/**
		 * Is the tile a new tile which we are finding matching the type.
		 * @param	tile
		 * @param	type
		 * @return
		 */
		private function _isMatchTile(tile:Tile, type:int):Boolean
		{
			if (!tile.isExist || !tile.touchable) return false;		//块不存在或者不可点的话不能匹配
			if (this._findTileTemp == null) this._findTileTemp = { };
			if ((tile.type == type) && (this._findTileTemp[tile.tx+"_"+tile.ty] == null)) 
			{
				this._findTileTemp[tile.tx + "_" + tile.ty] = tile;
				return true;
			}
			return false;
		}
		
		
		
		
		//	鼠标事件
		private function _onMouseDown(e:MouseEvent):void
		{
			//trace(this.view.mouseX, this.view.mouseY);
			var grid:Array = this._posToGrid(this.view.mouseX, this.view.mouseY);			
			var target:Tile = this._tileList[grid[0] + "_" + grid[1]];
			if (target != null) {
				trace("clickTile: " + target.toString());
				trace("type: " + target.type);
				this._startFindMatchTile(target);
			}
			
			
			trace("Match Num: ", this._findNum);
			if (this._findNum >= GameData.matchNum) {
				this._swipeMatchTiles();
			}			
		}
		
		//屏幕坐标转化为网格坐标
		private function _posToGrid(x:Number, y:Number):Array
		{
			var tx:int = int(x / this._tileW);
			var ty:int = int(y / this._tileH);
			return [tx, ty];
		}
		
		//网格坐标转化为屏幕坐标
		private function _gridToPos(tx:int, ty:int):Array
		{
			var x:Number = tx * this._tileW;
			var y:Number = ty * this._tileH;
			return [x, y];
		}
		
		//清除匹配的块
		private function _swipeMatchTiles():void
		{
			//this._moveTileList = [];			
			var i:int = 0;
			var ln:int = this._findTileList.length;
			while (i < ln) {
				if ( this._findTileList[i] != null) this._makeMoveCol(i);								
				i++;
			}
		}
		
		///	排列需要移动的区块序列
		private function _sortTileTemp(tileA:Tile, tileB:Tile):int
		{
			if (tileA.ty > tileB.ty) {
				return 1;
			}
			return -1;
		}
		
		
		/// 创建移动列
		private function _makeMoveCol(tx:int):void
		{
			if (this._moveTileList == null) this._moveTileList = [];
			trace("------make move col------");
			var i:int;
			var j:int;
			var ln:int;
			var list:Array = this._findTileList[tx];
			if (list != null) {
				
				///////////////////////		Test Code		/////////////////////////////////
				i = 0;
				trace("----show find list----");
				list.sort(this._sortTileTemp);
				while (i < list.length) {
					var t:Tile = list[i];
					trace("t[ " + t.tx + "," + t.ty + " ]");
					i++;
				}
				//////////////////////////////////////////////////////////////////////////
				
				
				//////////////////		第一版测试代码，包含一些错误		////////////////////////
				/**
				var topY:int = (list[0] as Tile).ty;
				var botY:int = (list[list.length - 1] as Tile).ty;
				
				trace("topY: ", topY);
				trace("botY: ", botY);
				
				i = 0;
				ln = botY+1;
				trace("set ln: ", ln);
				while (i <ln) {
					var id:int = botY - i;
					//if (id < 0) break;
					var tid:int = topY - i -1;
					//if (tid < 0) break;
					var tile:Tile = this._tileList[tx + "_" + id];
					var ttile:Tile = this._tileList[tx + "_" + tid];
					trace("change tile: [" + tx + "," + id + "] >>>[" + tx + "," + tid + "] ");
					if (ttile != null && ttile.isExist) {
						//如果没有超出网格范围，并且区块可以点击（或者说在网格内却已经能够不存在了）
						//设置视图
						tile.view.x = ttile.view.x;
						tile.view.y = ttile.view.y;
						tile.isExist = true;
						tile.type = ttile.type;
						//压入移动列表
						trace("------make move list------");
						if (this._moveTileList[tx] == null) this._moveTileList[tx] = [];
						this._moveTileList[tx].push(tile);
					}else {
						if (tile != null) {
							tile.view.y = -1000;
							tile.isExist = false;
						}else {
							trace("Null tile: [" + tx + "," + id + "] ");
						}
					}				
					i++;
				}				
				**/
				///////////////////////////////////////////////////////////////////////////////////////
				
				/////////////////////////// Ver2 移动算法	/////////////////////////////////
				
				//标记已经消除的块
				var tile:Tile;	
				var ttile:Tile;
				i = 0;
				ln = list.length;			//找寻数组
				while (i < ln) {
					tile = list[i] as Tile;
					tile.isExist = false; 	//置为不存在
					i++;
				}
				
				i = (list[list.length-1] as Tile).ty;
				while (i >= 0) {
					tile = this._tileList[tx + "_" + i];
					j = i - 1;
					if (j < 0) {
						//最后一个块
					}else {
						//向前搜索如果某个块存在则拷贝颜色和位置
						//并将当前块激活，并隐藏目标块。
						//将该块加入到移动列表内
						while (j >= 0) {
							ttile = this._tileList[tx + "_" + j];
							if (ttile.isExist) {
								tile.type = ttile.type;
								tile.view.y = ttile.view.y;
								tile.isExist = true;
								ttile.isExist = false;
								tile.touchable = false;
								if (this._moveTileList[tx] == null) this._moveTileList[tx] = [];
								this._moveTileList[tx].push(tile);
								break;
							}
							j--;
						}
					}					
					i--;
				}
				
				//如果自动填充开启, 则寻找需要填充的块
				//凡是在列中状态为不存在的块, 并且不在填充列表内才能被填充
				if (GameData.autoFill && this._findTileList[tx] && this._findTileList[tx].length > 0) {
					i = 0;
					ln = this._gridH;
					trace("[i]: ", i);
					if (this._fillList == null) this._fillList = [];
					if (this._fillList[tx] == null) this._fillList[tx] = [];
					while (i <ln) {
						tile = this._tileList[tx + "_" + i];
						if(!tile.isExist && (this._fillList[tx].indexOf(tile)== -1)){
							trace(tile.toString() + " :: need fill [ " + tile.isExist + " ]");
							//tile.isExist = true;
							tile.touchable = false;	
							
							this._fillList[tx].push(tile);
						}
						i++;
					}
				}
				
				
				//////////////////////////////////////////////////////////////////////////////////////
				
			}
			
		}
		
		///	移动块
		private function _moveTiles():void
		{
			var i:int;
			var j:int;
			var ln:int = this._gridW;
			var mln:int;
			var stoped:int = 0;
			var list:Array;
			var tile:Tile; 
			
			i = 0;
			while (i < ln) {
				list = this._moveTileList[i] as Array;
				if (list != null && list.length>0) {
					j = 0;
					mln = list.length;
					while (j < mln) {
						tile= list[j] as Tile;
						if (tile != null) {
							if (tile.isExist) {
								var ay:int = tile.ty * this._tileH;
								var dy:Number = (ay - tile.view.y);
								//trace("ay:", ay)
								//trace("viewy: ", tile.view.y);
								//trace("move to >>>> ",dy);
								if (dy < this._spYMin) {
									//如果区块就位，则移除区块。
									tile.view.y = ay;
									list.splice(j, 1);
									tile.touchable = true;
									j--;
									mln--;
								}else {
									tile.view.y += Math.max(dy * this._spYInc, this._spYMin);
								}								
							}else {
								trace(tile.toString() + "is not exist !");
							}
						}								
						j++;
					}
					
				}else {
					stoped++;
				}
				
				
				if (GameData.autoFill) {						
					list = this._fallTileList[i] as Array;
					if (list != null && list.length > 0) {
						//trace("----------fall tile----------");
						tile = list[0] as Tile;
						tile.isExist = true;
						ay = tile.ty * this._tileH;
						dy = (ay - tile.view.y);
						//dy = ay - tile.view.y;
						//trace("Drop Till: " + tile.toString() + " :: " + ay);
						if (dy < this._spYMin) {
							//如果区块就位，则移除区块。
							tile.view.y = ay;
							list.shift();
							tile.touchable = true;
						}else {
							tile.view.y += Math.max(dy * this._spYInc, this._spYMin);
							//trace("[dy]["+dy+"]"+tile.toString()+" [y]: "+ tile.view.y+" >>> "+ay);
						}
					}else {
						//trace("Fall [" + i + "] is over");
					}
				}
				
				i++;
			}
			if (stoped >= ln) {
				//trace(">>>>>>>> All stoped. ");
				
			}
		}
		
		///	更新填充计数器
		private function _updateFill():void
		{
			if (this._fillP < this._fillMax) {
				this._fillP++;
			}else {
				this._fillP = 0;
				this._fillTiles();
			}
		}
		
		///	填充空余的块
		private function _fillTiles():void
		{
			if (this._fallTileList == null) _fallTileList = [];
			var i:int;
			var ln:int;
			i = 0;
			ln = this._gridW;
			while (i < ln) {
				var list:Array = this._fillList[i] as Array;
				if (list != null && list.length > 0) {
					var tile:Tile = list.pop() as Tile;
					if (tile != null) {
						tile.type = this._getTileType();	//给这个tile赋一个随机的Type值
						tile.view.y = -this._tileH;		
						tile.isExist = true;
						if (this._fallTileList[i] == null) this._fallTileList[i] = [];
						this._fallTileList[i].push(tile);
					}
				}				
				i++;
			}
		}
		
		//获得块类型
		private function _getTileType(byRandom:Boolean =true):int
		{
			var id:int 
			if(byRandom){
				id = int(Math.random() * GameData.tileTypes);
			}
			return id;
		}
		
		
		
		/**
		 * 更新事件
		 * @param	e
		 */
		private function _onUpdata(e:TimerEvent):void
		{
			if (this._moveTileList != null) this._moveTiles();
			if (GameData.autoFill) this._updateFill();
		}
		
		
		/**
		 * 
		 * @param	name
		 * @param	id
		 * @return
		 */
		private function _aaa(name:String, id:int):Boolean
		{
			return false;
		}
		
		
		
	}
}