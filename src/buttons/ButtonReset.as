package buttons {
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonReset extends ButtonText {
		private static var _instance:ButtonReset;
		
		public function ButtonReset() {
			super(Main.mainContainer, "Reset Image", 128, 64, onClick);
			x = 256;
		}
		
		public static function get instance():ButtonReset { return _instance; }
		
		private function onClick():void {
			Main.mainDrawable.scaleX = Main.mainDrawable.scaleY = 1;
			Main.mainDrawable.x = (Main.stageInstance.stageWidth - Main.mainDrawable.width) / 2;
			Main.mainDrawable.y = (Main.stageInstance.stageHeight - Main.mainDrawable.height) / 2;
		}
	}
}