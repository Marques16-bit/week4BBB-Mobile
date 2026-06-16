package;

import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = TitleState;
	var zoom:Float = -1;
	var framerate:Int = 120;
	var skipSplash:Bool = true;
	var startFullscreen:Bool = false;

	public static var watermarks:Bool = true;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);

		addChild(game);

		#if !mobile
		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		#if web
		var vHandler = new VideoHandler();
		vHandler.init1();
		vHandler.video.name = "HTML CRAP";
		addChild(vHandler.video);
		vHandler.init2();
		GlobalVideo.setVid(vHandler);
		vHandler.source(ourSource);
		#elseif desktop
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = "WEBM SHIT";
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end
		#end

		#if mobile
		setupMobileFPS();
		#else
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);
		#end
	}

	var game:FlxGame;

	#if mobile
	var mobileFPS:openfl.text.TextField;
	var _fpsTime:Float = 0;
	var _fpsFrames:Int = 0;
	var _currentFPS:Int = 0;

	private function setupMobileFPS():Void
	{
		mobileFPS = new openfl.text.TextField();
		mobileFPS.defaultTextFormat = new TextFormat("_sans", 16, 0xFFFFFF, true);
		mobileFPS.x = 10;
		mobileFPS.y = 3;
		mobileFPS.width = 200;
		mobileFPS.height = 30;
		mobileFPS.selectable = false;
		mobileFPS.mouseEnabled = false;
		mobileFPS.visible = FlxG.save.data.fps != null ? FlxG.save.data.fps : true;
		addChild(mobileFPS);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, updateMobileFPS);
	}

	private function updateMobileFPS(_:Event):Void
	{
		_fpsFrames++;
		var now:Float = haxe.Timer.stamp();
		if (now - _fpsTime >= 1.0)
		{
			_currentFPS = _fpsFrames;
			_fpsFrames = 0;
			_fpsTime = now;
		}
		if (mobileFPS != null && mobileFPS.visible)
			mobileFPS.text = _currentFPS + " FPS";
	}
	#else
	var fpsCounter:FPS;
	#end

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		#if mobile
		if (mobileFPS != null)
			mobileFPS.visible = fpsEnabled;
		#else
		if (fpsCounter != null)
			fpsCounter.visible = fpsEnabled;
		#end
	}

	public function changeFPSColor(color:FlxColor):Void
	{
		#if mobile
		if (mobileFPS != null)
			mobileFPS.defaultTextFormat = new TextFormat("_sans", 16, color, true);
		#else
		if (fpsCounter != null)
			fpsCounter.textColor = color;
		#end
	}

	public function setFPSCap(cap:Float):Void
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		#if mobile
		return _currentFPS;
		#else
		return fpsCounter != null ? fpsCounter.currentFPS : 0;
		#end
	}
}
