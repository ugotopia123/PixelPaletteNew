package buttons {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonPalette extends Button {
		[Embed(source = "../../lib/paletteSelected.png")]
		private static var PaletteSelectedClass:Class;
		
		[Embed(source = "../../lib/paletteDelete.png")]
		private static var PaletteDeleteClass:Class;
		
		private var nameText:Text;
		private var _palette:Palette;
		private var background:Bitmap = new Bitmap();
		private var selectedSprite:Sprite = new Sprite();
		private var deleteSprite:Sprite = new Sprite()
		private static var buttonVector:Vector.<ButtonPalette> = new Vector.<ButtonPalette>();
		private static var _currentPalette:ButtonPalette;
		
		public function ButtonPalette(name:String, palette:Palette) {
			super(Main.mainContainer, 128, 128, onClick);
			this._palette = palette;
			x = buttonVector.length * 128;
			y = 64;
			buttonVector.push(this);
			createBackground(name);
			addChild(selectedSprite);
			addChild(deleteSprite);
			selectedSprite.addChild(new PaletteSelectedClass());
			deleteSprite.addChild(new PaletteDeleteClass());
			selectedSprite.x = 4;
			selectedSprite.y = height - selectedSprite.height - 4;
			deleteSprite.x = width - deleteSprite.width - 4;	
			deleteSprite.y = height - deleteSprite.height - 4;
			selectedSprite.visible = false;
			deleteSprite.addEventListener(MouseEvent.RIGHT_CLICK, deleteClick);
		}
		
		public function get palette():Palette { return _palette; }
		public static function get currentPalette():ButtonPalette { return _currentPalette; }
		
		private function createBackground(name:String):void {
			var drawSprite:Sprite = new Sprite();
			var width:uint = _palette.paletteColors.length;
			var height:uint = Math.ceil(_palette.paletteColors.length / 10);
			var increment:uint;
			
			if (width > 10) width = 10;
			
			outerloop : for (var y:uint = 0; y < height; y++) {
				for (var x:uint = 0; x < width; x++) {
					drawSprite.graphics.beginFill(_palette.paletteColors[increment]);
					drawSprite.graphics.drawRect(x * 8, y * 8, 8, 8);
					drawSprite.graphics.endFill();
					increment++;
					
					if (increment == _palette.paletteColors.length) break outerloop;
				}
			}
			
			background.bitmapData = new BitmapData(drawSprite.width, drawSprite.height, true, 0);
			background.bitmapData.draw(drawSprite);
			drawSprite.graphics.clear();
			addChild(background);
			background.x = (this.width - background.width) / 2;
			background.y = (this.height - background.height) / 2;
			nameText = new Text(this, name, 8);
			nameText.x = (this.width - nameText.width) / 2;
			nameText.y = 4;
		}
		
		private function onClick():void {
			if (_currentPalette != null) {
				_currentPalette.selectedSprite.visible = false;
			}
			
			selectedSprite.visible = true;
			_currentPalette = this;
			Main.sendMessage(MessageEnum.SET_PALETTE);
			Main.sendMessage(_palette.paletteName);
		}
		
		private function deleteClick(e:MouseEvent):void {
			if (Main.ready) {
				buttonVector.removeAt(buttonVector.indexOf(this));
				removeChildren();
				selectedSprite.removeChildren();
				deleteSprite.removeChildren();
				background.bitmapData.dispose();
				_palette.deletePalette();
				Main.mainContainer.removeChild(this);
				
				for (var i:uint = 0; i < buttonVector.length; i++) {
					buttonVector[i].x = 128 * i;
				}
				
				if (_currentPalette == this) _currentPalette = null;
				
				Main.sendMessage(MessageEnum.DELETE_PALETTE);
				Main.sendMessage(_palette.paletteName);
			}
		}
	}
}