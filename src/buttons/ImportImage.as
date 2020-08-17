package buttons {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ImportImage extends ButtonText {
		private static var _instance:ImportImage;
		private static var importFile:File = new File();
		private static var imageFilter:FileFilter = new FileFilter("All Images", "*.png;*.jpg;*.bmp");
		private static var pngFilter:FileFilter = new FileFilter("PNG Images", "*.png");
		private static var jpgFilter:FileFilter = new FileFilter("JPG Images", "*.jpg");
		private static var bmpFilter:FileFilter = new FileFilter("BMP Images", "*.bmp");
		private static var filterArray:Array = new Array();
		private static var currentFilePath:String;
		
		public function ImportImage() {
			super(Main.mainContainer, "Import Image", 128, 64, importClicked);
			x = 128;
			_instance = this;
			filterArray.push(imageFilter, pngFilter, jpgFilter, bmpFilter);
			importFile.addEventListener(Event.SELECT, fileSelected);
			importFile.addEventListener(Event.COMPLETE, fileLoadComplete);
		}
		
		public static function get instance():ImportImage { return _instance; }
		public static function get fileName():String { return importFile.name.substring(0, importFile.name.length - 4); }
		
		public function redrawImage():void {
			if (Main.ready && currentFilePath != null) {
				Main.setImageBytes(importFile.data);
				Main.sendMessage(MessageEnum.SET_IMAGE_EXTENSION);
				Main.sendMessage(currentFilePath.substring(currentFilePath.length - 3, currentFilePath.length));
				Main.sendMessage(MessageEnum.DRAW_PALETTE);
			}
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
		
		private function fileSelected(e:Event):void {
			importFile.load();
		}
		
		private function fileLoadComplete(e:Event):void {
			var imageType:String = importFile.name.substring(importFile.name.length - 3, importFile.name.length);
			
			if (imageType != "bmp" && imageType != "jpg" && imageType != "png") {
				Main.showError("An incorrect file was selected. Only files of type jpg, png, or bmp are allowed.");
				return;
			}
			
			currentFilePath = importFile.name;
			Main.setImageBytes(importFile.data);
			Main.sendMessage(MessageEnum.SET_IMAGE_EXTENSION);
			Main.sendMessage(importFile.name.substring(importFile.name.length - 3, importFile.name.length));
			Main.sendMessage(MessageEnum.DRAW_PALETTE);
		}
	}
}