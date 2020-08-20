package buttons {
	import flash.display.BitmapData;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonExport extends ButtonText {
		private static var saveReference:FileReference = new FileReference();
		
		public function ButtonExport() {
			super(Main.mainContainer, "Export Image", 128, 64, onClick);
			x = 512;
		}
		
		private function onClick():void {
			if (Main.mainDrawable.numChildren > 0) {
				var data:BitmapData = new BitmapData(Main.mainDrawable.width / Main.mainDrawable.scaleX, Main.mainDrawable.height / Main.mainDrawable.scaleX, true, 0);
				data.draw(Main.mainDrawable);
				var bytes:ByteArray = PNGEncoder.encode(data);
				saveReference.save(bytes, Main.currentFileName.substring(0, Main.currentFileName.length - 4) + ButtonPalette.currentPalette.palette.paletteName + ".png");
			}
		}
	}
}