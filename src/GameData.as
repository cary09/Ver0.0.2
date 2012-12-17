package  
{
	/**
	 * ...
	 * @author Eric
	 */
	public class GameData 
	{
		
		public static var isDebug:Boolean = true;			//是否在测试状态	
		public static var tileW:int = 60;							//区块宽度
		public static var tileH:int = 60;							//区块高度
		public static var gridW:int = 6;							//网格宽度
		public static var gridH:int = 10;						//网格高度
		public static var tileTypes:int = 3;						//区块总共的类型数
		public static var matchNum:int = 2;					//最小匹配数		
		public static var autoFill:Boolean = true;			//自动填充块
		
		
		public static var testGrid1:Array = [			//测试用数组
			[2, 4, 2, 0, 4, 0, 1, 1, 0, 0],
			[2, 2, 2, 0, 0, 4, 0, 1, 1, 0],
			[3, 3, 0, 0, 3, 0, 0, 0, 3, 3],
			[3, 0, 1, 0, 3, 3, 3, 0, 0, 0],
			[3, 0, 0, 2, 2, 0, 0, 0, 1, 4],
			[3, 0, 1, 0, 0, 0, 1, 0, 0, 4]	
		]
		
		
		public static var testGrid:Array = [			//测试用数组
			[1, 4, 1, 0, 4, 0, 1, 1, 0, 0],
			[2, 2, 2, 2, 2, 2, 2, 1, 1, 0],
			[3, 3, 0, 0, 3, 0, 0, 0, 3, 3],
			[3, 0, 1, 0, 3, 3, 3, 0, 0, 0],
			[3, 0, 0, 2, 2, 0, 0, 0, 1, 4],
			[3, 0, 1, 0, 0, 0, 1, 0, 0, 4]	
		]
	}

}