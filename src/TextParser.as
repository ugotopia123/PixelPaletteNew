package {
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Alec Spilman
	 */
	public class TextParser extends Sprite {
		private static var indexDictionary:Dictionary = new Dictionary();
		private static var wordVector:Vector.<String> = new Vector.<String>();
		private static var parseTextVector:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		
		public function TextParser(value:String):void {
			super();
		}
		
		public static function initialize():void {
			for (var i:uint = 0; i < 36; i++) {
				if (i <= Keyboard.Z - Keyboard.A) {
					indexDictionary[String.fromCharCode(i + Keyboard.A)] = i;
				}
				else {
					indexDictionary[String.fromCharCode(i - (Keyboard.Z - Keyboard.A) + Keyboard.NUMBER_0 - 1)] = i;
				}
			}
			
			indexDictionary[" "] = 36;
			indexDictionary["."] = 37;
			indexDictionary["!"] = 38;
			indexDictionary["?"] = 39;
			indexDictionary[","] = 40;
			indexDictionary[":"] = 41;
			indexDictionary["("] = 42;
			indexDictionary[")"] = 43;
			indexDictionary["'"] = 44;
			indexDictionary["\""] = 45;
			indexDictionary["*"] = 46;
			indexDictionary["="] = 47;
			indexDictionary["+"] = 48;
			indexDictionary["-"] = 49;
		}
		
		public static function parseText(value:String):Vector.<Vector.<uint>> {
			resetParseTextVector();
			sectionWordTextVector(value.toUpperCase());
			
			for (var i:uint = 0; i < wordVector.length; i++) {
				if (i == parseTextVector.length) parseTextVector.push(new Vector.<uint>());
				
				for (var j:uint = 0; j < wordVector[i].length; j++) {
					parseTextVector[i].push(indexDictionary[wordVector[i].charAt(j)]);
				}
			}
			
			return parseTextVector;
		}
		
		private static function resetParseTextVector():void {
			for (var i:uint = 0; i < parseTextVector.length; i++) {
				parseTextVector[i].length = 0;
			}
			
			parseTextVector.length = 0;
		}
		
		private static function sectionWordTextVector(value:String):void {
			var currentWord:String = "";
			wordVector.length = 0;
			
			for (var i:uint = 0; i < value.length; i++) {
				var currentChar:String = value.charAt(i);
				
				if (currentChar == " ") {
					wordVector.push(currentWord + " ");
					currentWord = "";
				}
				else if (i == value.length - 1) {
					currentWord += currentChar;
					wordVector.push(currentWord);
				}
				else currentWord += currentChar;
			}
		}
	}
}