package buttons {
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class ButtonText extends Button {
		private var _text:Text;
		
		public function ButtonText(parent:DisplayObjectContainer, text:String, width:Number, height:Number, clickMethod:Function, thickness:Number = 4) {
			super(parent, width, height, clickMethod, thickness);
			this._text = new Text(this, text, width / 20);
			this._text.x = (width - this._text.width) / 2;
			this._text.y = (height - this._text.height) / 2;
		}
		
		public function get text():Text { return _text; }
	}
}