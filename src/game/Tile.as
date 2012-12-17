package game 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Eric
	 */
	public class Tile 
	{
		//set these value to public variable instead get/set function to faster the ergodic speed.
		//不用get/set方法是为了加速遍历查询
		public var tx:int;
		public var ty:int;
		public var isMoving:Boolean;
		
		
		private var _view:Bitmap;
		private var _type:int;							//类型变量
		private var _touchable:Boolean;		//可否点击
		private var _isExist:Boolean;				//是否存在
		
		private static var _textureLib:Vector.<BitmapData>;
		
		
		////////////////////////////////////	Public Functions	/////////////////////////////////////////
		/**
		 * Construction Functioin
		 */
		public function Tile() 
		{
			this._init();
		}
		
		/**
		 * get the view referance
		 */
		public function get view():Bitmap
		{
			return this._view;
		}
		
		/**
		 * Set view 
		 */
		//public function set view(bmp:Bitmap):void
		//{
			//this._view = bmp;
		//}
		
		
		public function get type():int
		{
			return this._type;
		}
		
		public function set type(num:int):void
		{
			this._type = num;
			if (this._type >= 0 && this._type < _textureLib.length) {
				this._setTexture(this._type);
			}
		}
		
		
		public function get touchable():Boolean
		{
			return _touchable;
		}
		
		public function set touchable(boo:Boolean):void
		{
			this._touchable = boo;
		}
		
		public function get isExist():Boolean
		{
			return this._isExist;
		}
		
		public function set isExist(boo:Boolean):void
		{
			this._isExist = boo;
			if(!boo)this._touchable = boo;	//不可见也不可点
			if(this._view != null)this._view.visible = boo;
		}
		
		public function toString():String
		{
			return "Tile: [ " + this.tx + "," + this.ty + " ]";
		}
		
		///	销毁函数
		public function destroy():void
		{
			this._view.bitmapData = null;
			if (this._view.parent != null) this._view.parent.removeChild(this._view);
			this._view = null;			
		}
		
		
		////////////////////////////////////	Private Functions	///////////////////////////////////////
		//	Initiallize
		private function _init():void
		{
			this._view = new Bitmap();
			this._view.visible = true;
			this._touchable = true;
			this._isExist = true;			
			this.isMoving = false;
			if (_textureLib == null) _makeTextureLib();	
		}
		
		/**
		 * Create static texture lib
		 */
		private static function _makeTextureLib():void
		{
			_textureLib = new Vector.<BitmapData>();
			var tmc:MovieClip = new TileMc() as MovieClip;
			var len:int = tmc.totalFrames;	
			var i:int = 0;
			while (i < len) {
				tmc.gotoAndStop(i + 1);
				var bd:BitmapData = new BitmapData(GameData.tileW, GameData.tileH, true, 0);
				bd.draw(tmc);
				_textureLib.push(bd);				
				i++;
			}
		}
		
		private function _setTexture(type:int):void
		{
			var bd:BitmapData = _textureLib[type];
			if (bd != null) {
				this._view.bitmapData = bd; 
				this._view.smoothing = true;
			}
		}
		
		
		
		
		
		
	}

}