package buttons {
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonError extends ButtonText {
		private static var _instance:ButtonError;
		
		public function ButtonError() {
			super(Main.stageInstance, " ", Main.stageInstance.stageWidth / 2, Main.stageInstance.stageHeight / 2, dismiss, 8);
			x = (Main.stageInstance.stageWidth - width) / 2;
			y = (Main.stageInstance.stageHeight - height) / 2;
			visible = false;
			_instance = this;
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			Main.mainContainer.visible = !value;
		}
		
		public static function get instance():ButtonError { return _instance; }
		
		private function dismiss():void {
			visible = false;
		}
	}
}