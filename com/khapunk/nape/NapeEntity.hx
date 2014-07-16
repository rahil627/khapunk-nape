package com.khapunk.nape;

import com.khapunk.Entity;
import com.khapunk.graphics.PunkImage;
import com.khapunk.KP;
import com.khapunk.masks.Circle;
import com.khapunk.masks.Hitbox;
import com.khapunk.masks.Masklist;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;

@:noCompletion typedef NapeCircle = nape.shape.Circle;
@:noCompletion typedef NapePolygon = nape.shape.Polygon;
@:noCompletion typedef KPCircle = com.khapunk.masks.Circle;
@:noCompletion typedef KPPolygon = com.khapunk.masks.Polygon;

class NapeEntity extends Entity
{
	/**
	 * Nape Body of the Entity.
	 */
	public var body:Body;
	/**
	 * Angle of the Entity's Body in Haxepunk format (counter-clockwise degrees).
	 */
	public var angle(get, set):Float;

	/**
	 * If the body's physics are simulated.
	 */
	public var physics(get, set):Bool;

	/**
	 * Constructor. Can be used to place the Entity and assign a graphic, mask and bodytype.
	 * @param	x			X position to place the Entity.
	 * @param	y			Y position to place the Entity.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 * @param	bodyType	BodyType to assign to the Entity's nape Body.
	 * 						Default is BodyType.DYNAMIC.
	 */
	public function new(x:Float = 0, y:Float = 0, graphic:Graphic = null,
						mask:Dynamic = null, bodyType:BodyType = null)
	{
		super(x, y, graphic);
		centerOrigin();

		if (bodyType == null)
			bodyType = BodyType.DYNAMIC;

		body = new Body(bodyType, Vec2.weak(x, y));
		addMask(mask);
	}

	/**
	 * Updates the Entity.
	 */
	public override function update()
	{
		x = body.position.x;
		y = body.position.y;
		if (graphic != null)
			Reflect.setField(graphic, "angle", angle);
		
		super.update();
	}

	/**
	 * Add a Haxepunk Mask or Nape Shape to the Entity's Body.
	 * Haxepunk masks will be converted to Nape masks when possible.
	 * @param	mask		Mask to be added to the Entity's body.
	 * @return	Converted mask or null if conversion not possible.
	 */
	public function addMask(mask:Dynamic)
	{
		var shape:Shape = null;

		if (Std.is(mask, Shape))
		{
			shape = mask;
		}
		else if (Std.is(mask, Hitbox))
		{
			var hitbox = cast(mask, Hitbox);
			var vertices = NapePolygon.rect(hitbox.x, hitbox.y,
									hitbox.width, hitbox.height, true);
			shape = new NapePolygon(vertices); 
		}
		else if (Std.is(mask, KPCircle))
		{
			var circle = cast(mask, KPCircle);
			var offset = Vec2.weak(circle.x, circle.y);
			shape = new NapeCircle(circle.radius, offset);
		}
		else if (Std.is(mask, KPPolygon))
		{
			var polygon = cast(mask, KPPolygon);
			var vertices = new Array<Vec2>();
			for (p in polygon.points)
				vertices.push(Vec2.weak(p.x, p.y));
			shape = new NapePolygon(vertices);
		}
		else if (Std.is(mask, Masklist))
		{
			var masklist = cast(mask, Masklist);
			for (num in 0...masklist.count)
				addMask(masklist.getMask(num));
		}

		if (shape != null)
			body.shapes.add(shape);
		return shape;
	}

	private function get_angle():Float { return body.rotation * KP.DEG; }
	private function set_angle(value:Float) { return body.rotation = value * KP.RAD; }

	private function get_physics():Bool { return body.space != null; }
	private function set_physics(value:Bool):Bool
	{
		if (value)
			if (Std.is(scene, NapeScene))
				body.space = cast(scene, NapeScene).space;
		else
			body.space = null;
		return value;
	}
}