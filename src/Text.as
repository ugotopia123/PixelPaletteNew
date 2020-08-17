package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Text extends Sprite {
		private var text:String;
		private var alignCenter:Boolean;
		private var textRows:Vector.<Bitmap> = new Vector.<Bitmap>();
		private var textIndicies:Vector.<uint> = new Vector.<uint>();
		
		public function Text(parent:DisplayObjectContainer, value:String, maxLength:uint = 30, scale:Number = 1, alignCenter:Boolean = true) {
			super();
			this.alignCenter = alignCenter;
			scaleX = scaleY = scale;
			text = value;
			update(text, maxLength);
			parent.addChild(this);
		}
		
		public function update(value:String, maxLength:uint = 30):void {
			clearBitmaps();
			var indicies:Vector.<Vector.<uint>> = TextParser.parseText(value);
			var currentLength:uint;
			var currentHeight:uint;
			var startIndex:uint;
			var largestWidth:Number = 0;
			
			for (var i:uint = 0; i < indicies.length; i++) {
				var nextIndicies:Vector.<uint> = null;
				var lastCharOfNextIndex:uint = 0;
				
				if (i < indicies.length - 1) {
					nextIndicies = indicies[i + 1];
					lastCharOfNextIndex = nextIndicies[nextIndicies.length - 1];
				}
				
				if (currentLength == 0) {
					startIndex = i;
					currentLength += indicies[i].length;
				}
				
				if (nextIndicies == null || (lastCharOfNextIndex != 36 && currentLength + nextIndicies.length > maxLength) || (lastCharOfNextIndex == 36 && currentLength + nextIndicies.length - 1 > maxLength)) {
					var increment:uint = 0;
					
					for (var x:uint = startIndex; x <= i; x++) {
						for (var y:uint = 0; y < indicies[x].length; y++) {
							if (nextIndicies != null && x == i && y == indicies[x].length - 1) {
								break;
							}
							
							var createdBitmap:Bitmap = Spritesheet.textSpritesheet.drawSpriteIndex(indicies[x][y], 1, false);
							addChild(createdBitmap);
							createdBitmap.x = 17 * increment;
							increment++;
						}
					}
					
					var rowBitmap:Bitmap = new Bitmap();
					
					if (nextIndicies == null) {
						rowBitmap.bitmapData = new BitmapData(width - 1, height - 1, true, 0);
					}
					else rowBitmap.bitmapData = new BitmapData(width - 1, height, true, 0);
					
					rowBitmap.bitmapData.draw(this, null, null, null, new Rectangle(0, 0, rowBitmap.width, rowBitmap.height));
					textRows.push(rowBitmap);
					
					if (rowBitmap.width > largestWidth) largestWidth = rowBitmap.width;
					
					removeChildren();
					currentLength = 0;
					currentHeight++;
				}
				else currentLength += indicies[i].length;
			}
			
			for (var j:uint = 0; j < textRows.length; j++) {
				addChild(textRows[j]);
				textRows[j].y = j * 17;
				
				if (alignCenter) {
					textRows[j].x = (largestWidth - textRows[j].width) / 2;
				}
			}
		}
		
		private function clearBitmaps():void {
			removeChildren();
			
			for (var i:uint = 0; i < textRows.length; i++) {
				textRows[i].bitmapData.dispose();
				textRows[i].bitmapData = null;
			}
			
			textRows.length = 0;
		}
	}
}