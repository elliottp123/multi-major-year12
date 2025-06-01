// checks toon shaders and fixes texture order

global proc fixToonColour() {
    string $toonMats[] = `ls -materials "*toon*"`;

    for($mat in $toonMats) {
        if(`nodeType $mat` != "rampShader") continue;
        
        print("\nchecking: " + $mat + "\n");
        
        // get connected textures
        string $texs[] = `listConnections -type file $mat`;
        
        if(size($texs) < 2) continue;
        
        // check if dark texture is first
        string $tex1 = `getAttr ($texs[0] + ".fileTextureName")`;
        string $tex2 = `getAttr ($texs[1] + ".fileTextureName")`;
        float $exp1 = `getAttr ($texs[0] + ".exposure")`;
        float $exp2 = `getAttr ($texs[1] + ".exposure")`;
        
        if($exp1 > -0.4) {
            // swap em
            disconnectAttr ($texs[0] + ".outColor") ($mat + ".color[0].color_Color");
            disconnectAttr ($texs[1] + ".outColor") ($mat + ".color[1].color_Color");
        
            connectAttr -f ($texs[1] + ".outColor") ($mat + ".color[0].color_Color");
            connectAttr -f ($texs[0] + ".outColor") ($mat + ".color[1].color_Color");
        
            print("fixed texture order for " + $mat + "\n");
        } else {
            print("textures already good for " + $mat + "\n");
        }
    }

    Then i released the color_interp on some of them wasnt set correctly, i used this mel script to fix that

    // quick script to set all toon materials to no interpolation

    string $toonMats[] = `ls -materials "*toon*"`;

    for($mat in $toonMats) {
        if(`nodeType $mat` != "rampShader") continue;
        
        print("\nprocessing: " + $mat);
        
        // set the color interpolation to none (0)
        catch(`setAttr ($mat + ".color[0].color_Interp") 0`);
        catch(`setAttr ($mat + ".color[1].color_Interp") 0`);
        
        // also check any connected ramp textures
        string $ramps[] = `listConnections -type ramp $mat`;
        for($ramp in $ramps) {
            catch(`setAttr ($ramp + ".interpolation") 0`);
            print("\n - set " + $ramp + " interpolation to none");
        }
    }

    print("\n\nfinished updating all toon shader interpolations to none\n");
}