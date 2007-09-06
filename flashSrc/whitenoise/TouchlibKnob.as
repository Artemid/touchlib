﻿// A basic knob that listens to both TUIO events and regular MouseEvents.
// TODO: add ability to dispatch events when the value changes.. 

package whitenoise
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.text.*;
	
	import flash.display.*;		
	import flash.events.*;
	import flash.net.*;
	import whitenoise.*;	
	import flash.geom.*;			
	import flash.filters.BlurFilter;
	
    import flash.filters.*;


	public class TouchlibKnob extends MovieClip
	{
		private var gfxIndicator:Sprite;
		private var gfxActiveGlow:Sprite;
		private var knobValue:Number = 0.0;
		private var isActive:Boolean = false;
		private var gfxRadius:Number = 0;

		
		private var activeX:Number;
		private var activeY:Number;		
		
		private var src:String = "none";
		private var srcID:int = 0;
		
		private var minValue:Number = 0;
		private var maxValue:Number = 1.0;		
		
		private var indicatorText:TextField;
		

		public function TouchlibKnob(diam:Number)
		{
			gfxRadius = diam/2;

			gfxIndicator = new Sprite();
			gfxIndicator.graphics.beginFill(0xFF0000, 0.5);
			gfxIndicator.graphics.moveTo(-0.1*gfxRadius, 0);
			gfxIndicator.graphics.lineTo(0, -gfxRadius);			
			gfxIndicator.graphics.lineTo(0.1*gfxRadius, 0);						
			gfxIndicator.graphics.lineTo(-0.1*gfxRadius, 0);			
			gfxIndicator.graphics.endFill();
			gfxIndicator.x = gfxRadius;
			gfxIndicator.y = gfxRadius;			
			addChild(gfxIndicator);
			
			var blurfx:BlurFilter = new BlurFilter(10, 10, 1);
			
			gfxActiveGlow = new Sprite();
			gfxActiveGlow.graphics.beginFill(0xFFFFFF, 0.7);
			gfxActiveGlow.graphics.drawCircle(0,0,20);
			gfxActiveGlow.visible = false;
			gfxActiveGlow.filters = [blurfx];
			addChild(gfxActiveGlow);			
			
			
			this.graphics.beginFill(0xFFFFFF, 0.5);
			this.graphics.drawCircle(gfxRadius, gfxRadius, gfxRadius);
			
			var tf:TextFormat = new TextFormat();
			tf.color = 0xffffff;
			tf.align = "center";
			indicatorText = new TextField();
			indicatorText.x = 0;
			indicatorText.y = gfxRadius*2;
			indicatorText.width = gfxRadius*2;
			indicatorText.defaultTextFormat  = tf;
			addChild(indicatorText);
			

			this.addEventListener(TUIOEvent.MoveEvent, this.tuioMoveHandler);			
			this.addEventListener(TUIOEvent.DownEvent, this.tuioDownEvent);						
			this.addEventListener(TUIOEvent.UpEvent, this.tuioUpEvent);									
			this.addEventListener(TUIOEvent.RollOverEvent, this.tuioRollOverHandler);									
			this.addEventListener(TUIOEvent.RollOutEvent, this.tuioRollOutHandler);

			this.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);									
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent);															
			this.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);	
			this.addEventListener(MouseEvent.ROLL_OVER, this.mouseRollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, this.mouseRollOutHandler);
			
			this.addEventListener(Event.ENTER_FRAME, this.frameUpdate);			
			
			updateGraphics();
		}
		
		function updateGraphics()
		{
			gfxIndicator.rotation = (knobValue+0.5) * 360;
			indicatorText.text = knobValue;
		}

		function knobStartDrag()
		{
			isActive = true;
			gfxActiveGlow.visible = true;			
		}
		
		function setMinValue(v:Number)
		{
			// FIXME: add sanity checking
			minValue = v;
		}
		
		function setMaxValue(v:Number)
		{
			maxValue = v;
		}		
		
		
		function knobStopDrag()
		{
			if(isActive)
			{
				isActive = false;
				gfxActiveGlow.visible = false;			
			}
			mouseActive = false;					
		}		
		
		public function setValue(f:Number)
		{
			if(f < 0)
				f = 0.0;
			if(f > 1.0)
				f = 1.0;
			knobValue = f;
			
			updateGraphics();
		}
		
		public function getValue():Number	
		{
			return knobValue;
		}
		
		public function getActive():Boolean
		{
			return isActive;
		}
		
		function frameUpdate(e:Event)
		{
			if(isActive)
			{
				if(mouseActive)
				{
					activeX = this.mouseX;
					activeY = this.mouseY;
				}
				gfxActiveGlow.x = activeX;
				gfxActiveGlow.y = activeY;
			}
		}

		
		public function tuioDownEvent(e:TUIOEvent)
		{		

			TUIO.listenForObject(e.ID, this);
			knobStartDrag();			
			e.stopPropagation();
		}

		public function tuioUpEvent(e:TUIOEvent)
		{		
			knobStopDrag();		
			e.stopPropagation();
		}		

		public function tuioMoveHandler(e:TUIOEvent)
		{
			if(isActive)
			{
				var tuioobj:TUIOObject = TUIO.getObjectById(e.ID);							
				
				var localPt:Point = globalToLocal(new Point(tuioobj.x, tuioobj.y));														
				activeX = localPt.x;
				activeY = localPt.y;
				var ang:Number = Math.atan2(activeY-gfxRadius, activeX-gfxRadius);
				var val:Number;
				val = 0.25 + (ang / (Math.PI*2));
				val += 0.5;
				val %= 1.0;
				setValue(val);	
			}

			e.stopPropagation();			
		}
		
		public function tuioRollOverHandler(e:TUIOEvent)
		{
			
		}
		
		public function tuioRollOutHandler(e:TUIOEvent)
		{
			e.stopPropagation();			
		
		}			
		
		public function mouseDownEvent(e:MouseEvent)
		{		

			mouseActive = true;
			knobStartDrag();
		}
		
		public function mouseUpEvent(e:MouseEvent)
		{		

			knobStopDrag();

		}		

		public function mouseMoveHandler(e:MouseEvent)
		{
			if(isActive)
			{
				activeX = this.mouseX;
				activeY = this.mouseY;
				var ang:Number = Math.atan2(activeY-gfxRadius, activeX-gfxRadius);
				var val:Number;
				val = 0.25 + (ang / (Math.PI*2));
				val += 0.5;
				val %= 1.0;
				setValue(val);				
			}
		}
		
		public function mouseRollOverHandler(e:MouseEvent)
		{
		}
		
		public function mouseRollOutHandler(e:MouseEvent)
		{
//			sliderStopDrag();			
		
		}					
	}
}