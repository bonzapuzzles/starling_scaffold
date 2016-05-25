package 
{
    import starling.animation.Transitions;
    import starling.core.Starling;
    import starling.display.Canvas;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.utils.deg2rad;

    /** The Game class represents the actual game. In this scaffold, it just displays a 
     *  Starling that moves around fast. When the user touches the Starling, the game ends. */ 
    public class Game extends Sprite
    {
		public static const GAME_OVER:String = "gameOver";
		
		private var _container:Sprite;
		private var _bird:Image;
		
		
		public function Game()
		{
			init();
		}
        
		
		private function init():void
		{
			_bird = new Image(Root.assets.getTexture("starling_rocket"));
			_bird.addEventListener(TouchEvent.TOUCH, onBirdTouched);
			
			applyCanvasMask( _bird );
		
			
			//
			//	THIS EXHIBITS LAGGING 
			
			_container = new Sprite();
			_container.addChild( _bird );
			
			_container.x = Constants.STAGE_WIDTH / 2;
			_container.y = Constants.STAGE_HEIGHT / 2;
			_container.pivotX = _container.width / 2;
			_container.pivotY = _container.height / 2;
			
			addChild( _container );
			moveContainer();
			
			
			//
			//	THIS WORKS FINE
			
//			_bird.x = Constants.STAGE_WIDTH / 2;
//			_bird.y = Constants.STAGE_HEIGHT / 2;
//			_bird.pivotX = _bird.width / 2;
//			_bird.pivotY = _bird.height / 2;
//			
//			addChild( _bird );
//			moveBird();

        }
		
		
		private function applyCanvasMask( s:Image ):void
		{
			var radius:Number = Math.min( s.width, s.height ) * 0.5;
			var mask:Canvas = new Canvas();
			mask.x = s.width/2;
			mask.y = s.height/2;
			mask.beginFill(0x0000ff, 0.5);
			mask.drawCircle(0,0,radius);
			mask.endFill();
			s.mask = mask;
		}

		
		private function moveBird():void
		{
			var scale:Number = Math.random() * 0.8 + 0.2;
			Starling.juggler.tween( 
				_bird, 
				Math.random() * 2 + 0.5, 
				{
					x: Math.random() * Constants.STAGE_WIDTH,
					y: Math.random() * Constants.STAGE_HEIGHT,
					scaleX: scale,
					scaleY: scale,
					rotation: Math.random() * deg2rad(180) - deg2rad(90),
					transition: Transitions.EASE_IN_OUT,
					onComplete: moveBird
				}
			);
		}
		
		
		private function moveContainer():void
		{
			var scale:Number = Math.random() * 0.8 + 0.2;
			Starling.juggler.tween( 
				_container, 
				Math.random() * 2 + 0.5, 
				{
					x: Math.random() * Constants.STAGE_WIDTH,
					y: Math.random() * Constants.STAGE_HEIGHT,
					scaleX: scale,
					scaleY: scale,
					rotation: Math.random() * deg2rad(180) - deg2rad(90),
					transition: Transitions.EASE_IN_OUT,
					onComplete: moveContainer
				}
			);
		}
        
		
		private function onBirdTouched(event:TouchEvent):void
		{
			if (event.getTouch(_bird, TouchPhase.BEGAN))
			{
				Root.assets.playSound("click");
				Starling.juggler.removeTweens(_bird);
				dispatchEventWith(GAME_OVER, true, 100);
			}
		}
		
		
    }
	
}
