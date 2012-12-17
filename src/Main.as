package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import menus.GameScene;
	
	
	
	
	[SWF(width="480", height="800", frameRate="30", backgroundColor="0x33CCDD")]
	
	/**
	 * Main Entry
	 * @author Eric
	 */
	public class Main extends Sprite 
	{
		private var _gameScene:GameScene;
		
		
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//stage.align = StageAlign.TOP_LEFT;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, this._onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, this._onDeactivate);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeydown);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			this.addEventListener(Event.ADDED_TO_STAGE, this._init);
		}
		
		public static function exitApp():void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}		
		
		/**
		 * Activate handler 
		 * @param	e
		 */
		private function _onActivate(e:Event):void
		{
			trace("---------- Activate -------------");
		}
		
		
		/**
		 * Deactivate handler
		 * @param	e
		 */
		private function _onDeactivate(e:Event):void
		{
			trace("---------- DeActivate -------------");
		}
		
		/**
		 * Keyboard Event handler
		 * @param	e
		 */
		private function _onKeydown(e:KeyboardEvent):void
		{
			switch(e.keyCode) {
				case Keyboard.BACK:
					exitApp();
					break;
			}
		}
		
		///	初始化
		private function _init(e:Event):void
		{
			this._gameScene = new GameScene();
			this.addChild(this._gameScene);
			//this._gameScene.view.y = 100;
		}
		
		
		
		
	}
	
}