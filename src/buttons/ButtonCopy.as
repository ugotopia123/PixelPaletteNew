package buttons {
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonCopy extends ButtonText {
		
		public function ButtonCopy() {
			super(Main.mainContainer, "Copy Image", 128, 64, onClick);
			x = 640;
		}
		
		private function onClick():void {
			if (Main.mainDrawable.numChildren > 0) {
				Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, Bitmap(Main.mainDrawable.getChildAt(0)).bitmapData);
			}
		}
	}
}