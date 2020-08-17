package {
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Palette {
		private var _paletteName:String;
		private var _colors:Vector.<Rgb> = new Vector.<Rgb>();
		public static var currentPalette:Palette;
		private static var _palettes:Vector.<Palette> = new Vector.<Palette>();
		
		public function Palette(name:String) {
			_paletteName = name;
			_palettes.push(this);
		}
		
		public function get paletteName():String { return _paletteName; }
		public function get paletteColors():Vector.<Rgb> { return _colors; }
		public static function get palettes():Vector.<Palette> { return _palettes; }
		
		public function addColor(color:uint):void {
			_colors.push(new Rgb(color));
		}
		
		public function getLeastDifference(sourceColor:uint):uint {
			var sourceRgb:Rgb = new Rgb(sourceColor);
			var smallest:Number = _colors[0].differenceBetween(new Rgb(sourceColor));
			var index:uint = 0;
			
			for (var i:uint = 1; i < _colors.length; i++) {
				var currentDifference:Number = _colors[i].differenceBetween(sourceRgb);
				
				if (currentDifference < smallest) {
					smallest = currentDifference;
					index = i;
				}
			}
			
			return _colors[index].color;
		}
		
		public function deletePalette():void {
			_colors.length = 0;
			_palettes.removeAt(_palettes.indexOf(this));
			
			if (currentPalette == this) currentPalette = null;
		}
		
		public static function getPalette(name:String):Palette {
			for (var i:uint = 0; i < _palettes.length; i++) {
				if (_palettes[i]._paletteName == name) return _palettes[i];
			}
			
			return null;
		}
	}
}