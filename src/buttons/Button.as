package buttons {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Button extends Sprite {
		private var background:Bitmap;
		private var interaction:Bitmap;
		private var clickMethod:Function;
		
		public function Button(parent:DisplayObjectContainer, width:Number, height:Number, clickMethod:Function, thickness:Number = 4) {
			super();
			this.clickMethod = clickMethod;
			background = new Bitmap(new BitmapData(width, height, true, 0));
			interaction = new Bitmap(new BitmapData(width, height, true, 0xFF000000));
			graphics.beginFill(0x808080);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			graphics.beginFill(0xBFBFBF);
			graphics.drawRect(thickness, height - thickness, width - thickness, thickness);
			graphics.drawRect(width - thickness, 0, thickness, height - thickness);
			graphics.endFill();
			graphics.beginFill(0x191919);
			graphics.drawRect(0, 0, width - thickness, thickness);
			graphics.drawRect(0, thickness, thickness, height - thickness);
			graphics.endFill();
			background.bitmapData.draw(this);
			addChild(background);
			addChild(interaction);
			interaction.alpha = 0;
			graphics.clear();
			parent.addChild(this);
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function onOver(e:MouseEvent):void {
			interaction.alpha = 0.25;
		}
		
		private function onOut(e:MouseEvent):void {
			interaction.alpha = 0;
		}
		
		private function onDown(e:MouseEvent):void {
			interaction.alpha = 0.5;
		}
		
		private function onUp(e:MouseEvent):void {
			clickMethod.call();
			interaction.alpha = 0.25;
		}
	}
}