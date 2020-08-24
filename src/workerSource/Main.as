package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class Main extends Sprite {
		private static const SEGMENTATION:uint = 1000;
		private var mainToWorkerChannel:MessageChannel;
		private var workerToMainChannel:MessageChannel;
		private var importFile:File;
		private var fileName:String;
		private var fileExtension:String;
		private var currentState:String = "";
		private var imageBytes:ByteArray = new ByteArray();
		private var imageChunks:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		
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
						acknowledgeMessage = false;
						drawImage();
					}
				}
				else if (message == MessageEnum.SEND_DRAW_CONFIRMATION) {
					if (imageChunks.length > 0) {
						imageBytes.clear();
						sendNextChunk();
					}
					else {
						workerToMainChannel.send(MessageEnum.DRAW_COMPLETE);
					}
				}
				else if (currentState != "") {
					if (currentState == MessageEnum.CREATE_PALETTE) {
						new Palette(message);
					}
					else if (currentState == MessageEnum.SET_PALETTE) {
						Palette.currentPalette = Palette.getPalette(message);
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
					else if (currentState == MessageEnum.BROWSE_FILE_FOR_IMPORT) {
						importFile = new File(message);
						importFile.addEventListener(Event.COMPLETE, fileLoadComplete);
						importFile.addEventListener(ProgressEvent.PROGRESS, fileLoadProgress);
						acknowledgeMessage = false;
						importFile.load();
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
		
		private function fileLoadProgress(e:ProgressEvent):void {
			workerToMainChannel.send("Importing: " + (Math.round(e.bytesLoaded / e.bytesTotal * 1000) / 10) + "%");
		}
		
		private function fileLoadComplete(e:Event):void {
			importFile.removeEventListener(Event.COMPLETE, fileLoadComplete);
			importFile.removeEventListener(ProgressEvent.PROGRESS, fileLoadProgress);
			fileName = importFile.name;
			fileExtension = importFile.name.substring(importFile.name.length - 3, importFile.name.length);
			workerToMainChannel.send("File" + fileName);
			drawImage();
		}
		
		private function drawImage():void {
			if (fileExtension == "bmp") {
				var decoder:BMPDecoder = new BMPDecoder();
				var data:BitmapData = decoder.decode(importFile.data);
				redrawBitmap(new Bitmap(data));
			}
			else {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
				loader.loadBytes(importFile.data);
			}
		}
		
		private function loaderComplete(e:Event):void {
			var loaderInfo:LoaderInfo = LoaderInfo(e.target);
			loaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
			redrawBitmap(new Bitmap(Bitmap(loaderInfo.content).bitmapData));
		}
		
		private function redrawBitmap(target:Bitmap):void {
			var vectorWidth:uint = Math.ceil(target.width / SEGMENTATION);
			var vectorHeight:uint = Math.ceil(target.height / SEGMENTATION);
			var totalPixels:uint = target.width * target.height;
			var increment:uint;
			var pixels:Vector.<uint>;
			imageBytes.clear();
			Worker.current.setSharedProperty("imageWidth", target.width);
			Worker.current.setSharedProperty("imageHeight", target.height);
			resetChunkVector();
			
			for (var i:uint = 0; i < vectorWidth * vectorHeight; i++) {
				var startX:uint = i % vectorWidth * SEGMENTATION;
				var startY:uint = Math.floor(i / vectorWidth) * SEGMENTATION;
				var drawWidth:uint = target.width - startX;
				var drawHeight:uint = target.height - startY;
				imageChunks.push(new Vector.<uint>());
				
				if (drawWidth > SEGMENTATION) drawWidth = SEGMENTATION;
				if (drawHeight > SEGMENTATION) drawHeight = SEGMENTATION;
				
				var drawRect:Rectangle = new Rectangle(startX, startY, drawWidth, drawHeight);
				pixels = target.bitmapData.getVector(drawRect);
				
				for (var j:uint = 0; j < pixels.length; j++) {
					var currentPixel:uint = pixels[j];
					var closest:Number = Palette.currentPalette.getLeastDifference((0xFFFFFF & currentPixel));
					var alpha:Number = (currentPixel >> 24) & 0xFF;
					imageChunks[i].push((alpha << 24) | closest);
					increment++;
					
					if (increment % target.width == 0) {
						workerToMainChannel.send("Drawing " + (Math.round(increment / totalPixels * 10000) / 100) + "% complete");
					}
				}
			}
			
			target.bitmapData.dispose();
			target.bitmapData = null;
			pixels.length = 0;
			workerToMainChannel.send(MessageEnum.INIT_DRAW);
		}
		
		private function resetChunkVector():void {
			for (var i:uint = 0; i < imageChunks.length; i++) {
				imageChunks[i].length = 0;
			}
			
			imageChunks.length = 0;
		}
		
		private function sendNextChunk():void {
			for (var i:uint = 0; i < imageChunks[0].length; i++) {
				imageBytes.writeUnsignedInt(imageChunks[0][i]);
			}
			
			imageChunks.shift();
			Worker.current.setSharedProperty("imageBytes", imageBytes);
			workerToMainChannel.send(MessageEnum.CHUNK_COMPLETE);
		}
	}
}