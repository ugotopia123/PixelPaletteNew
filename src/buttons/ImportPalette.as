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
	public class ImportPalette extends ButtonText {
		private static var _instance:ImportPalette;
		private static var importFile:File = new File();
		private static var pngFilter:FileFilter = new FileFilter("PNG Palettes", "*.png");
		private static var filterArray:Array = new Array();
		private static var paletteName:String;
		
		public function ImportPalette() {
			super(Main.mainContainer, "Import Palette", 128, 64, buttonClicked);
			filterArray.push(pngFilter);
			importFile.addEventListener(Event.SELECT, fileSelected);
		}
		
		public static function instance():ImportPalette { return _instance; }
		
		private function buttonClicked():void {
			importFile.browseForOpen("Import Palette", filterArray);
		}
		
		private function fileSelected(e:Event):void {
			var imageLoader:Loader = new Loader();
			paletteName = File(e.target).name.substring(0, e.target.name.length - 4);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fileLoaded);
			imageLoader.load(new URLRequest(File(e.target).nativePath));
		}
		
		private function fileLoaded(e:Event):void {
			var colorVector:Vector.<uint> = new Vector.<uint>();
			var data:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
			e.target.removeEventListener(Event.COMPLETE, fileLoaded);
			
			outerloop : for (var y:uint = 0; y < data.height; y++) {
				for (var x:uint = 0; x < data.width; x++) {
					var pixelColor:uint = data.getPixel(x, y);
					
					if (colorVector.indexOf(pixelColor) != -1) continue;
					
					colorVector.push(pixelColor);
					
					if (colorVector.length == 100) break outerloop;
				}
			}
			
			Palette.createPalette(paletteName, colorVector);
		}
	}
}