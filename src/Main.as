package
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.AssetManager;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	import starling.utils.StringUtil;
	import starling.utils.SystemUtil;
	
	import utils.ProgressBar;
	
	
	/**	
	 * 
	 */
	public class Main extends Sprite
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//
		
		private const StageWidth:int  = 320;
		private const StageHeight:int = 480;
		
		
		////////////////////////////////////////////////////////
		//	VARIABLES
		//
		
		private var _starling:Starling;
		private var _background:Loader;
		private var _progressBar:ProgressBar;
		
		
		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//
		
		/**
		 *  Constructor
		 */
		public function Main()
		{
			var iOS:Boolean = SystemUtil.platform == "IOS";
			var stageSize:Rectangle  = new Rectangle(0, 0, StageWidth, StageHeight);
			var screenSize:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			var viewPort:Rectangle = RectangleUtil.fit(stageSize, screenSize, ScaleMode.SHOW_ALL);
			var scaleFactor:int = viewPort.width < 480 ? 1 : 2; // midway between 320 and 640
			
			Starling.multitouchEnabled = true; // useful on mobile devices
			
			_starling = new Starling(Root, stage, viewPort, null, "auto", "auto");
			_starling.stage.stageWidth    = StageWidth;  // <- same size on all devices!
			_starling.stage.stageHeight   = StageHeight; // <- same size on all devices!
			_starling.enableErrorChecking = Capabilities.isDebugger;
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, function():void
			{
				loadAssets(scaleFactor, startGame);
			});
			
			_starling.start();
			initElements(scaleFactor);
			
			// When the game becomes inactive, we pause Starling; otherwise, the enter frame event
			// would report a very long 'passedTime' when the app is reactivated.
			
			if (!SystemUtil.isDesktop)
			{
				NativeApplication.nativeApplication.addEventListener(
					flash.events.Event.ACTIVATE, function (e:*):void { _starling.start(); });
				NativeApplication.nativeApplication.addEventListener(
					flash.events.Event.DEACTIVATE, function (e:*):void { _starling.stop(true); });
			}
		}
		
		
		
		////////////////////////////////////////////////////////
		//	INTERNALS
		//
		
		private function loadAssets(scaleFactor:int, onComplete:Function):void
		{
			// Our assets are loaded and managed by the 'AssetManager'. To use that class,
			// we first have to enqueue pointers to all assets we want it to load.
			
			var appDir:File = File.applicationDirectory;
			var assets:AssetManager = new AssetManager(scaleFactor);
			
			assets.verbose = Capabilities.isDebugger;
			assets.enqueue(
				appDir.resolvePath("audio"),
				appDir.resolvePath(StringUtil.format("fonts/{0}x",    scaleFactor)),
				appDir.resolvePath(StringUtil.format("textures/{0}x", scaleFactor))
			);
			
			// Now, while the AssetManager now contains pointers to all the assets, it actually
			// has not loaded them yet. This happens in the "loadQueue" method; and since this
			// will take a while, we'll update the progress bar accordingly.
			
			assets.loadQueue(function(ratio:Number):void
			{
				_progressBar.ratio = ratio;
				if (ratio == 1)
				{
					// now would be a good time for a clean-up
					System.pauseForGCIfCollectionImminent(0);
					System.gc();
					
					onComplete(assets);
				}
			});
		}
		
		private function startGame(assets:AssetManager):void
		{
			var root:Root = _starling.root as Root;
			root.start(assets);
			setTimeout(removeElements, 150); // delay to make 100% sure there's no flickering.
		}
		
		private function initElements(scaleFactor:int):void
		{
			// Add background image. By using "loadBytes", we can avoid any flickering.
			
			var bgPath:String = StringUtil.format("textures/{0}x/background.jpg", scaleFactor);
			var bgFile:File = File.applicationDirectory.resolvePath(bgPath);
			var bytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			stream.open(bgFile, FileMode.READ);
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			stream.close();
			
			_background = new Loader();
			_background.loadBytes(bytes);
			_background.scaleX = 1.0 / scaleFactor;
			_background.scaleY = 1.0 / scaleFactor;
			_starling.nativeOverlay.addChild(_background);
			
			_background.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,
				function(e:Object):void
				{
					(_background.content as Bitmap).smoothing = true;
				});
			
			// While the assets are loaded, we will display a progress bar.
			
			_progressBar = new ProgressBar(175, 20);
			_progressBar.x = (StageWidth - _progressBar.width) / 2;
			_progressBar.y =  StageHeight * 0.7;
			_starling.nativeOverlay.addChild(_progressBar);
		}
		
		private function removeElements():void
		{
			if (_background)
			{
				_starling.nativeOverlay.removeChild(_background);
				_background = null;
			}
			
			if (_progressBar)
			{
				_starling.nativeOverlay.removeChild(_progressBar);
				_progressBar = null;
			}
		}
		
		
		////////////////////////////////////////////////////////
		//	EVENT HANDLERS
		//
		
		
	}
}