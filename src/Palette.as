package {
	import buttons.ButtonPalette;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Palette {
		private var _paletteName:String;
		private var _paletteColors:Vector.<uint>;
		private static var _palettes:Vector.<Palette> = new Vector.<Palette>();
		
		public function Palette(name:String, initColors:Vector.<uint>) {
			_palettes.push(this);
			_paletteName = name;
			_paletteColors = initColors;
			initPalette();
		}
		
		public function get paletteName():String { return _paletteName; }
		public function get paletteColors():Vector.<uint> { return _paletteColors; }
		public static function get palettes():Vector.<Palette> { return _palettes; }
		
		public function deletePalette():void {
			_paletteColors.length = 0;
			_palettes.removeAt(_palettes.indexOf(this));
		}
		
		private function initPalette():void {
			Main.sendMessage(MessageEnum.CREATE_PALETTE);
			Main.sendMessage(_paletteName);
			Main.sendMessage(MessageEnum.SET_PALETTE);
			Main.sendMessage(_paletteName);
			
			for (var i:uint = 0; i < _paletteColors.length; i++) {
				Main.sendMessage(MessageEnum.ADD_COLOR_TO_SET_PALETTE);
				Main.sendMessage(_paletteColors[i]);
			}
			
			new ButtonPalette(_paletteName.substring(0, 7), this);
			
			if (ButtonPalette.currentPalette != null) {
				Main.sendMessage(MessageEnum.SET_PALETTE);
				Main.sendMessage(ButtonPalette.currentPalette.palette._paletteName);
			}
		}
		
		public static function createPalette(name:String, initColors:Vector.<uint>):void {
			for (var i:uint = 0; i < _palettes.length; i++) {
				if (_palettes[i]._paletteName == name) {
					Main.showError("A palette already exists with the name \"" + name + "\", give the file a unique name a try again.");
					return;
				}
			}
			
			new Palette(name, initColors);
		}
	}
}