package;

import lime.app.Application;
import Discord.DiscordClient;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = FirstCheckState; // The FlxState the game starts with.
	var zoom:Float = 1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 480; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public var lastY:Float = 0; // the Y that the game window starts in

	// You can pretty much ignore everything from here on - your code should go in your states.
	public static var watermark:Sprite;

	#if sys
	public var webmHandle:WebmHandler;
	#end

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		lastY = Application.current.window.y;
		// Application.current.window.y = 1000;
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

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
		initialState = FirstCheckState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if sys
		var ourSource:String = "assets/videos/dontDelete.webm";

		var str1:String = "WEBM SHIT";
		webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);

		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		memoryCounter = new MemoryCounter(10, 3, 0xffffff);
		addChild(memoryCounter);
		#end

		var bitmapData = Assets.getBitmapData("assets/images/watermark.png");

		watermark = new Sprite();
		watermark.addChild(new Bitmap(bitmapData)); // Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
		watermark.alpha = 0.4;
		watermark.x = Lib.application.window.width - 10 - watermark.width;
		watermark.y = Lib.application.window.height - 10 - watermark.height;
		addChild(watermark);

		MainVariables.Load(); // Funnily enough you can do this. I say this optimizes options better in a way or another.
	}

	public static var fpsCounter:FPS;

	public static function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	public static var memoryCounter:MemoryCounter;

	public static function toggleMem(memEnabled:Bool):Void
	{
		memoryCounter.visible = memEnabled;
	}

	public function changeColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
		memoryCounter.textColor = color;
	}
}
