package {
	import buttons.ButtonError;
	import buttons.ButtonExport;
	import buttons.ButtonRedraw;
	import buttons.ButtonReset;
	import buttons.ButtonText;
	import buttons.ImportImage;
	import buttons.ImportPalette;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Main extends Sprite {
		[Embed(source = "../lib/PixelPaletteWorker.swf", mimeType = "application/octet-stream")]
		private static var BackgroundWorkerClass:Class;
		
		private static var _mainContainer:Sprite = new Sprite();
		private static var _mainDrawable:Sprite = new Sprite();
		private static var _currentFileName:String;
		private static var _stageInstance:Stage;
		private static var _mainToWorkerChannel:MessageChannel;
		private static var _workerToMainChannel:MessageChannel;
		private static var backgroundWorker:Worker;
		private static var sharedByteArray:ByteArray = new ByteArray();
		private static var mouseIsDown:Boolean;
		private static var mousePositionSet:Boolean;
		private static var previousMousePosition:Point = new Point();
		private static var messageQueue:Array = new Array();
		private static var debug:TextField;
		
		public function Main() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public static function get mainContainer():Sprite { return _mainContainer; }
		public static function get mainDrawable():Sprite { return _mainDrawable; }
		public static function get currentFileName():String { return _currentFileName; }
		public static function get stageInstance():Stage { return _stageInstance; }
		public static function get ready():Boolean { return messageQueue.length == 0; }
		
		private function init(e:Event = null):void {
			if (e) removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_stageInstance = stage;
			var workerBytes:ByteArray = new BackgroundWorkerClass();
			backgroundWorker = WorkerDomain.current.createWorker(workerBytes, true);
			_mainToWorkerChannel = Worker.current.createMessageChannel(backgroundWorker);
			_workerToMainChannel = backgroundWorker.createMessageChannel(Worker.current);
			_workerToMainChannel.addEventListener(Event.CHANNEL_MESSAGE, messageFromWorker);
			sharedByteArray.shareable = true;
			backgroundWorker.setSharedProperty("mainToWorkerChannel", _mainToWorkerChannel);
			backgroundWorker.setSharedProperty("workerToMainChannel", _workerToMainChannel);
			backgroundWorker.setSharedProperty("imageBytes", sharedByteArray);
			backgroundWorker.start();
			_mainContainer.graphics.beginFill(0, 0);
			_mainContainer.graphics.drawRect(0, 0, stage.stageWidth, 128);
			_mainContainer.graphics.endFill();
			_mainContainer.scaleX = _mainContainer.scaleY = 1 / stage.contentsScaleFactor;
			debug = new TextField();
			debug.y = 192;
			debug.background = true;
			debug.backgroundColor = 0xFFFFFF;
			debug.mouseEnabled = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addChild(_mainDrawable);
			stage.addChild(_mainContainer);
			stage.addChild(debug);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, zoomHandler);
			Spritesheet.initialize();
			TextParser.initialize();
			new ImportPalette();
			new ImportImage();
			new ButtonReset();
			new ButtonRedraw();
			new ButtonExport();
			new ButtonError();
		}
		
		public static function get mainToWorkerChannel():MessageChannel { return _mainToWorkerChannel; }
		public static function get workerToMainChannel():MessageChannel { return _workerToMainChannel; }
		
		private function messageFromWorker(e:Event):void {
			var message:String = _workerToMainChannel.receive();
			
			if (message == MessageEnum.PREVIOUS_MESSAGE_COMPLETE) {
				messageQueue.shift();
				
				if (messageQueue.length > 0) {
					_mainToWorkerChannel.send(messageQueue[0]);
				}
			}
			else if (message == MessageEnum.DRAW_COMPLETE) {
				var bytes:ByteArray = backgroundWorker.getSharedProperty("imageBytes");
				var imageWidth:uint = bytes.readUnsignedInt();
				var imageHeight:uint =  bytes.readUnsignedInt();
				var data:BitmapData = new BitmapData(imageWidth, imageHeight);
				data.setPixels(data.rect, bytes);
				var bitmap:Bitmap = new Bitmap(data);
				_mainDrawable.removeChildren();
				_mainDrawable.addChild(bitmap);
				backgroundWorker.getSharedProperty("imageBytes").length = 0;
				debug.text = "";
				debug.width = debug.height = 0;
				_mainDrawable.scaleX = _mainDrawable.scaleY = 1;
				_mainDrawable.x = (stage.stageWidth - _mainDrawable.width) / 2;
				_mainDrawable.y = (stage.stageHeight - _mainDrawable.height) / 2;
				_mainToWorkerChannel.send(MessageEnum.SEND_DRAW_CONFIRMATION);
			}
			else if (message.indexOf("File") != -1) {
				_currentFileName = message.replace("File", "");
			}
			else {
				debug.text = message;
				debug.width = debug.textWidth + 8;
				debug.height = debug.textHeight + 8;
			}
		}
		
		private function mouseDown(e:MouseEvent):void {
			mouseIsDown = true;
		}
		
		private function mouseUp(e:MouseEvent):void {
			mouseIsDown = mousePositionSet = false;
		}
		
		private function mouseMove(e:MouseEvent):void {
			if (mouseIsDown) {
				if (!mousePositionSet) {
					previousMousePosition.setTo(stage.mouseX, stage.mouseY);
					mousePositionSet = true;
				}
				else {
					var xDifference:Number = stage.mouseX - previousMousePosition.x;
					var yDifference:Number = stage.mouseY - previousMousePosition.y;
					var xRatio:Number = _mainDrawable.width / stage.stageWidth;
					var yRatio:Number = _mainDrawable.height / stage.stageHeight;
					var leftBound:Number = _mainDrawable.width * (0.25 / xRatio);
					var rightBound:Number = stage.stageWidth - leftBound;
					var upBound:Number = _mainDrawable.height * (0.25 / yRatio);
					var downBound:Number = stage.stageHeight - upBound;
					
					if (xRatio > 1) xRatio = 1;
					if (yRatio > 1) yRatio = 1;
					
					if (_mainDrawable.x + xDifference > rightBound) {
						_mainDrawable.x = rightBound;
					}
					else if (_mainDrawable.x + xDifference < leftBound - _mainDrawable.width) {
						_mainDrawable.x = leftBound - _mainDrawable.width;
					}
					else _mainDrawable.x += xDifference;
					
					if (_mainDrawable.y + yDifference > downBound) {
						_mainDrawable.y = downBound;
					}
					else if (_mainDrawable.y + yDifference < upBound - _mainDrawable.height) {
						_mainDrawable.y = upBound - _mainDrawable.height;
					}
					else _mainDrawable.y += yDifference;
					
					previousMousePosition.setTo(stage.mouseX, stage.mouseY);
				}
			}
		}
		
		private function zoomHandler(e:MouseEvent):void {
			var scroll:Number = e.delta;
			var xRatio:Number = (stage.mouseX - _mainDrawable.x) / _mainDrawable.width;
			var yRatio:Number = (stage.mouseY - _mainDrawable.y) / _mainDrawable.height;
			
			if (scroll > 0) {
				if (_mainDrawable.scaleX + scroll > 20) _mainDrawable.scaleX = _mainDrawable.scaleY = 20;
				else {
					if (_mainDrawable.scaleX < 1) {
						_mainDrawable.scaleX += 0.1;
						_mainDrawable.scaleY = _mainDrawable.scaleX;
					}
					else {
						_mainDrawable.scaleX++;
						_mainDrawable.scaleY++;
					}
				}
			}
			else {
				if (_mainDrawable.scaleX <= 1) {
					if (_mainDrawable.scaleX - 0.1 < 0.1) {
						_mainDrawable.scaleX = _mainDrawable.scaleY = 0.1;
					}
					else {
						_mainDrawable.scaleX -= 0.1;
						_mainDrawable.scaleY = _mainDrawable.scaleX;
					}
				}
				else {
					_mainDrawable.scaleX--;
					_mainDrawable.scaleY--;
				}
			}
			
			_mainDrawable.scaleX = Math.round(_mainDrawable.scaleX * 100) / 100;
			_mainDrawable.scaleY = Math.round(_mainDrawable.scaleY * 100) / 100;
			_mainDrawable.x = stage.mouseX - _mainDrawable.width * xRatio;
			_mainDrawable.y = stage.mouseY - _mainDrawable.height * yRatio;
		}
		
		public static function sendMessage(message:*):void {
			messageQueue.push(message);
			
			if (messageQueue.length == 1) {
				_mainToWorkerChannel.send(message);
			}
		}
		
		public static function showError(value:String):void {
			ButtonError.instance.visible = true;
			ButtonError.instance.text.x = ButtonError.instance.text.y = 0;
			ButtonError.instance.text.update(value, 20);
			ButtonError.instance.text.x = (ButtonError.instance.width - ButtonError.instance.text.width) / 2;
			ButtonError.instance.text.y = (ButtonError.instance.height - ButtonError.instance.text.height) / 2;
			ButtonError.instance.x = (_stageInstance.stageWidth - ButtonError.instance.width) / 2;
			ButtonError.instance.y = (_stageInstance.stageHeight - ButtonError.instance.height) / 2;
		}
		
		public static function setImageBytes(bytes:ByteArray):void {
			backgroundWorker.setSharedProperty("imageBytes", bytes);
		}
	}
}