package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Main extends Sprite {
		private var mainToWorkerChannel:MessageChannel;
		private var workerToMainChannel:MessageChannel;
		private var fileExtension:String;
		private var currentState:String = "";
		
		public function Main() {
			mainToWorkerChannel = Worker.current.getSharedProperty("mainToWorkerChannel");
			workerToMainChannel = Worker.current.getSharedProperty("workerToMainChannel");
			
			if (mainToWorkerChannel) {
				mainToWorkerChannel.addEventListener(Event.CHANNEL_MESSAGE, messageFromMainWorker);
			}
		}
		
		private function messageFromMainWorker(e:Event):void {
			var message:* = mainToWorkerChannel.receive();
			var acknowledgeMessage:Boolean = true;
			
			if (message == MessageEnum.WORKER_QUERY) {
				var queryString:String = "Worker state: ";
				
				if (currentState == "") queryString += "None\n";
				else queryString += currentState + "\n";
				
				if (fileExtension != null) queryString += "Last loaded image file type: " + fileExtension + "\n";
				
				if (Palette.currentPalette == null) queryString += "Current palette: None\n";
				else {
					queryString += "Current palette: " + Palette.currentPalette.paletteName + "\nCurrent palette colors: ";
					
					if (Palette.currentPalette.paletteColors.length == 0) queryString += "None\n";
					else {
						for (var i:uint = 0; i < Palette.currentPalette.paletteColors.length; i++) {
							queryString += Palette.currentPalette.paletteColors[i].color.toString(16);
							
							if (i < Palette.currentPalette.paletteColors.length - 1) queryString += ", ";
						}
						
						queryString += "\n";
					}
				}
				
				queryString += "Palettes created: " + Palette.palettes.length;
				
				if (Palette.palettes.length > 0) {
					for (var j:uint = 0; j < Palette.palettes.length; j++) {
						if (j == 0) {
							queryString += "\nPalette names: ";
						}
						
						queryString += Palette.palettes[j].paletteName;
						
						if (j < Palette.palettes.length - 1) queryString += ", ";
					}
				}
				
				workerToMainChannel.send(queryString);
			}
			else {
				if (message == MessageEnum.DRAW_PALETTE) {
					if (Palette.currentPalette == null) {
						workerToMainChannel.send("Current palette must be set before color can be added");
					}
					else {
						drawImage();
						acknowledgeMessage = false;
					}
				}
				else if (message == MessageEnum.SEND_DRAW_CONFIRMATION) {
					workerToMainChannel.send(MessageEnum.PREVIOUS_MESSAGE_COMPLETE);
				}
				else if (currentState != "") {
					if (currentState == MessageEnum.CREATE_PALETTE) {
						new Palette(message);
					}
					else if (currentState == MessageEnum.SET_PALETTE) {
						Palette.currentPalette = Palette.getPalette(message);
					}
					else if (currentState == MessageEnum.SET_IMAGE_EXTENSION) {
						fileExtension = message;
					}
					else if (currentState == MessageEnum.ADD_COLOR_TO_SET_PALETTE) {
						if (Palette.currentPalette == null) {
							workerToMainChannel.send("Current palette must be set before color can be added");
						}
						else {
							Palette.currentPalette.addColor(message);
						}
					}
					else if (currentState == MessageEnum.DELETE_PALETTE) {
						Palette.getPalette(message).deletePalette();
					}
					else {
						workerToMainChannel.send("Invalid command sent to the worker");
					}
					
					currentState = "";
				}
				else if (message is String) {
					currentState = message;
				}
			}
			
			if (acknowledgeMessage) {
				workerToMainChannel.send(MessageEnum.PREVIOUS_MESSAGE_COMPLETE);
			}
		}
		
		private function drawImage():void {
			var bytes:ByteArray = Worker.current.getSharedProperty("imageBytes");
			
			if (fileExtension == "bmp") {
				var decoder:BMPDecoder = new BMPDecoder();
				var data:BitmapData = decoder.decode(bytes);
				redrawBitmap(new Bitmap(data));
			}
			else {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
				loader.loadBytes(bytes);
			}
		}
		
		private function loaderComplete(e:Event):void {
			var loaderInfo:LoaderInfo = LoaderInfo(e.target);
			loaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
			redrawBitmap(new Bitmap(Bitmap(loaderInfo.content).bitmapData));
		}
		
		private function redrawBitmap(target:Bitmap):void {
			var copyBitmap:Bitmap = new Bitmap(new BitmapData(target.width, target.height, true, 0));
			var drawSprite:Sprite = new Sprite();
			
			for (var y:uint = 0; y < target.height; y++) {
				for (var x:uint = 0; x < target.width; x++) {
					var pixel:uint = target.bitmapData.getPixel32(x, y);
					var closest:Number = Palette.currentPalette.getLeastDifference((0xFFFFFF & pixel));
					var alpha:Number = Math.round(((pixel >> 24) & 0xFF) / 255 * 100) / 100;
					drawSprite.graphics.beginFill(closest, alpha);
					drawSprite.graphics.drawRect(x, 0, 1, 1);
					drawSprite.graphics.endFill();
				}
				
				copyBitmap.bitmapData.draw(drawSprite, new Matrix(1, 0, 0, 1, 0, y));
				drawSprite.graphics.clear();
				workerToMainChannel.send("Drawing " + (Math.round(y / target.height * 10000) / 100) + "% complete");
			}
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUnsignedInt(copyBitmap.width);
			bytes.writeUnsignedInt(copyBitmap.height);
			bytes.writeBytes(copyBitmap.bitmapData.getPixels(copyBitmap.bitmapData.rect));
			Worker.current.setSharedProperty("imageBytes", bytes);
			workerToMainChannel.send(MessageEnum.DRAW_COMPLETE);
		}
	}
}