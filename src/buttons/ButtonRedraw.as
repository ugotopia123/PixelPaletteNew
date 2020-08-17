package buttons {
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonRedraw extends ButtonText {
		private static var _instance:ButtonRedraw;
		
		public function ButtonRedraw() {
			super(Main.mainContainer, "Redraw Image", 128, 64, onClick);
			x = 384;
			_instance = this;
		}
		
		public static function get instance():ButtonRedraw { return _instance; }
		
		private function onClick():void {
			ImportImage.instance.redrawImage();
		}
	}
}