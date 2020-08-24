package buttons {
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ImportImage extends ButtonText {
		private static var _instance:ImportImage;
		private var importFile:File = new File();
		private var imageFilter:FileFilter = new FileFilter("All Images", "*.png;*.jpg;*.bmp");
		private var pngFilter:FileFilter = new FileFilter("PNG Images", "*.png");
		private var jpgFilter:FileFilter = new FileFilter("JPG Images", "*.jpg");
		private var bmpFilter:FileFilter = new FileFilter("BMP Images", "*.bmp");
		private var filterArray:Array = new Array();
		
		public function ImportImage() {
			super(Main.mainContainer, "Import Image", 128, 64, importClicked);
			x = 128;
			_instance = this;
			filterArray.push(imageFilter, pngFilter, jpgFilter, bmpFilter);
			importFile.addEventListener(Event.SELECT, fileSelected);
		}
		
		public static function get instance():ImportImage { return _instance; }
		
		public function redrawImage():void {
			if (Main.ready && Main.currentFileName != null) {
				Main.lockDrawing();
				Main.sendMessage(MessageEnum.DRAW_PALETTE);
			}
		}
		
		private function fileSelected(e:Event):void {
			Main.sendMessage(MessageEnum.BROWSE_FILE_FOR_IMPORT);
			Main.sendMessage(importFile.nativePath);
		}
		
		private function importClicked():void {
			if (ButtonPalette.currentPalette == null) {
				if (Palette.palettes.length == 0) {
					Main.showError("You must import and select a palette before importing an image.");
				}
				else {
					Main.showError("You must select a palette before importing an image.");
				}
			}
			else if (Main.ready) {
				importFile.browseForOpen("Import Image", filterArray);
			}
		}
	}
}