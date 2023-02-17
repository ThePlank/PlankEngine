package states;

import away3d.primitives.WireframePlane;
import openfl.geom.Vector3D;
import lime.app.Event;
import openfl.events.KeyboardEvent;
import flixel.math.FlxMath;
import away3d.events.MouseEvent3D;
import openfl.events.MouseEvent;
import away3d.cameras.lenses.PerspectiveLens;
import away3d.cameras.Camera3D;
import openfl.Lib;
import util.CoolUtil;
import openfl.ui.Mouse;
import away3d.primitives.PlaneGeometry;
import away3d.primitives.SkyBox;
import away3d.textures.Texture2DBase;
import away3d.materials.TextureMaterial;
import away3d.textures.BitmapTexture;
import openfl.display.BitmapData;
import flixel.addons.display.FlxGridOverlay;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.materials.ColorMaterial;
import away3d.lights.DirectionalLight;
import flixel.FlxG;
import flx3D.FlxView3D;
import away3d.primitives.SphereGeometry;
import away3d.entities.Mesh;
import away3d.tools.commands.SphereMaker;
import states.abstr.MusicBeatState;

/**
 * Tries to replicate the "Boing!" (NOT TO BE CONFUSED WITH "Boing!" USED AS A SONG IN THE FNF SEX MOD) demo
 */
class AmigaVibeState extends MusicBeatState {
    override function create() {
        super.create();
        bgColor = 0xffa9a9a9;

        add(new BoingySphere());
    }
}

class BoingySphere extends FlxView3D {
    var sphere:Mesh;
    var bg:WireframePlane;
    var floor:WireframePlane;
    public function new() {
        super(0, 0, FlxG.width, FlxG.height);
        view.camera = new FunnyCamera();

        var light:DirectionalLight = new DirectionalLight(1, 0, 1);
        light.ambient = 1;
        var lightPicker:StaticLightPicker = new StaticLightPicker([light]);
        view.scene.addChild(light);

        var CheckerMat:BitmapData = FlxGridOverlay.createGrid(8, 8, 512, 512, false, 0xffff1800, 0xffffffff);
        var tex:BitmapTexture = new BitmapTexture(CheckerMat);
        var mat:TextureMaterial = new TextureMaterial();
        mat.texture = tex;
        mat.lightPicker = lightPicker;
        mat.specular = 0;
        sphere = new Mesh(new SphereGeometry(50, 12, 12), mat);
        sphere.scale(2.5);
        sphere.rotationX = 10;
        sphere.material.smooth = false;
        view.scene.addChild(sphere);

        bg = new WireframePlane(100, 100, 50, 50, 0xff9a2391, 2);
        bg.scale(10);
        bg.z += 250;
        bg.rotationX = 90;
        bg.rotationY = 90;
        floor = new WireframePlane(100, 100, 50, 50, 0xff9a2391, 2);
        floor.scale(10);
        floor.z += 250;
        floor.y += 50;

        view.scene.addChild(floor);
        FlxG.mouse.visible = false;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        sphere.rotationY += 1;
        // view.camera.lookAt(sphere.position);
    }
}

class FunnyCamera extends Camera3D {
    var oldX:Float = 0;
    var oldY:Float = 0;
    var sensitivity:Float = 0.51;
    public function new() {
        super();
        FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, (ae:MouseEvent) -> {
            if (Math.abs(FlxG.mouse.wheel) != 0) {
                var lenbs:PerspectiveLens = cast lens;
                lenbs.fieldOfView += FlxG.mouse.wheel * 10;
            }
        });
        FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, (ae:MouseEvent) -> {
            CoolUtil.getMainWindow().mouseLock = true;
        });
        FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, (ae:MouseEvent) -> {
            var x:Float = ae.stageY * sensitivity;
            var y:Float = FlxMath.wrap(Std.int(ae.stageX * sensitivity), -180, 180);
            var deltaX:Float = oldX - x;
            var deltaY:Float = oldY - y;
            rotationX -= deltaX;
            rotationY -= deltaY;
            oldX = x;
            oldY = y;
        });
        FlxG.stage.addEventListener(openfl.events.Event.ENTER_FRAME, (ev:openfl.events.Event) -> {
            if (FlxG.keys.pressed.A)
                translateLocal(Vector3D.X_AXIS, -5);
            if (FlxG.keys.pressed.D)
                translateLocal(Vector3D.X_AXIS, 5);
            if (FlxG.keys.pressed.W)
                translateLocal(Vector3D.Z_AXIS, 5);
            if (FlxG.keys.pressed.S)
                translateLocal(Vector3D.Z_AXIS, -5);
            if (FlxG.keys.pressed.E)
                translateLocal(Vector3D.Y_AXIS, 5);
            if (FlxG.keys.pressed.Q)
                translateLocal(Vector3D.Y_AXIS, -5);
        });
    }
}