package  {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Alec Spillman
	 */
	public class Spritesheet {
		[Embed(source = "../lib/textSpritesheet.png")]
		private static var TextClass:Class;
		
		private var background:Bitmap;
		private var spriteWidth:Number;
		private var spriteHeight:Number;
		private static var _textSpritesheet:Spritesheet;
		
		public function Spritesheet(SpritesheetClass:Class, spriteWidth:Number, spriteHeight:Number) {
			this.background = new SpritesheetClass();
			this.spriteWidth = spriteWidth;
			this.spriteHeight = spriteHeight;
		}
		
		private function get xIndicies():uint { return Math.round(background.width / spriteWidth); }
		
		public static function get textSpritesheet():Spritesheet { return _textSpritesheet; }
		
		/**
		 * Creates a new Bitmap that contains the display index of this Spritesheet
		 * @param	spriteIndex The index location of the sprite. Indicies start at 0 and increment left to right, top to bottom
		 * @param	setScale The scale to set the final Bitmap
		 * @param	applySmoothing True to smooth the final Bitmap, false to not smooth
		 * @return	A new Bitmap that contains the drawn index of this Spritesheet
		 */
		public function drawSpriteIndex(spriteIndex:uint, setScale:Number = 1, applySmoothing:Boolean = true):Bitmap {
			var returnBitmap:Bitmap = new Bitmap(new BitmapData(spriteWidth, spriteHeight));
			returnBitmap.bitmapData.copyPixels(background.bitmapData, new Rectangle(xIndex(spriteIndex), yIndex(spriteIndex), spriteWidth, spriteHeight), new Point());
			returnBitmap.scaleX = returnBitmap.scaleY = setScale;
			returnBitmap.smoothing = applySmoothing;
			return returnBitmap;
		}
		
		/**
		 * Updates a given Bitmap with a new index location on this Spritesheet. This is useful when you want to update a sprite Bitmap as opposed to creating a new one using drawSpriteIndex
		 * @param	target The target Bitmap. This function assumes the target is the proper size of the Spritesheet index while drawing
		 * @param	spriteIndex The index location of the sprite. Inidices start at 0 and increment left to right, top to bottom
		 */
		public function redrawSpriteIndex(target:Bitmap, spriteIndex:uint):void {
			target.bitmapData.copyPixels(background.bitmapData, new Rectangle(xIndex(spriteIndex), yIndex(spriteIndex), spriteWidth, spriteHeight), new Point());
		}
		
		private function xIndex(index:uint):uint {
			return Math.round(index % xIndicies * spriteWidth);
		}
		
		private function yIndex(index:uint):uint {
			return Math.floor(index / xIndicies) * spriteHeight;
		}
		
		public static function initialize():void {
			_textSpritesheet = new Spritesheet(TextClass, 17, 17);
		}
	}
}