package menus 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import game.TileGrid;
	
	/**
	 * ...
	 * @author Eric
	 */
	public class GameScene extends Sprite 
	{
		private var _uiMc:MovieClip
		private var _grid:TileGrid;
		private var _resetBtn:MovieClip;
		
		
		public function GameScene() 
		{
			this._init();
		}
		
		
		
		
		//////////////////////////////	Priavte Function	//////////////////////////////////////////////
		///	初始化
		private function _init():void
		{
			this._uiMc = new GameUIMc() as MovieClip;
			this._grid = new TileGrid();
			this._resetBtn = this._uiMc["btn_rest"] as MovieClip;
			
			
			this.addChild(this._grid.view);
			this.addChild(this._uiMc);
			
			this._resetBtn.addEventListener(MouseEvent.MOUSE_DOWN, this._onClickButton);
		}
		
		
		private function _onClickButton(e:MouseEvent):void
		{
			switch(e.currentTarget) {
				
				case this._resetBtn:
					trace("-----------reset game---------------");
					this._grid.reset();
					break;
				
			}
		}
		
		
		
		
		
		
		
		
		
		
	}

}