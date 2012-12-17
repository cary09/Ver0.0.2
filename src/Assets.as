package  
{
	/**
	 * Assets binder
	 * @author Eric
	 */
	public class Assets 
	{
		//Embed xml config file
		[Embed(source = "../data/database.xml", mimeType = "application/octet-stream")]
		public static var DataBase:Class;
		
	}

}