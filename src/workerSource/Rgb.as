package {
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Rgb {
		private var _color:uint;
		private var _red:uint;
		private var _green:uint;
		private var _blue:uint;
		
		public function Rgb(color:uint) {
			_color = color;
			_red = (color >> 16) & 0xFF;
			_green = (color >> 8) & 0xFF;
			_blue = color & 0xFF;
		}
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			_color = value;
			_red = (value >> 16) & 0xFF;
			_green = (value >> 8) & 0xFF;
			_blue = value & 0xFF;
		}
		
		public function get red():uint { return _red; }
		public function get green():uint { return _green; }
		public function get blue():uint { return _blue; }
		
		public function differenceBetween(target:Rgb):Number {
			var redNumerator:Number = (_red + target._red) / 2;
			var deltaR:Number = Math.pow(_red - target._red, 2);
			var deltaG:Number = Math.pow(_green - target._green, 2);
			var deltaB:Number = Math.pow(_blue - target._blue, 2);
			return Math.sqrt((2 + redNumerator / 256) * deltaR + 4 * deltaG + (2 + ((255 - redNumerator) / 256)) * deltaB);
		}
	}
}