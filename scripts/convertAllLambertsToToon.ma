// quick script to convert lambert shaders with textures to toon shaders

global proc convertAllLambertsToToon() {
	// get all lambert materials
	string $lamberts[] = `ls -type lambert`;
    
	// loop through and convert any with textures
	for ($mat in $lamberts) {
    	string $tex[] = `listConnections -source true -destination false -type "file" $mat`;
    	if (size($tex) > 0) {
        	makeToon($mat);
    	}
	}
}

// converts single lambert to toon
global proc makeToon(string $lambert) {
	if (!`objExists $lambert`) return;
    
	// make nodes
	string $toon = `shadingNode -asShader rampShader -n ($lambert + "_toon")`;
	string $light = `shadingNode -asTexture file -n ($lambert + "_light")`;
	string $dark = `shadingNode -asTexture file -n ($lambert + "_dark")`;
	string $ramp = `shadingNode -asTexture ramp -n ($lambert + "_ramp")`;
	string $sampler = `shadingNode -asUtility samplerInfo -n ($lambert + "_sampler")`;

	// get texture from lambert
	string $tex[] = `listConnections -type file $lambert`;
	if (size($tex) == 0) return;
	string $path = `getAttr ($tex[0] + ".fileTextureName")`;

	// setup textures
	setAttr ($light + ".fileTextureName") -type "string" $path;
	setAttr ($dark + ".fileTextureName") -type "string" $path;
	setAttr ($light + ".colorGain") -type float3 1 1 1;
	setAttr ($dark + ".colorGain") -type float3 0.3 0.3 0.3;

	// setup ramp
	setAttr ($ramp + ".interpolation") 0;
	setAttr ($ramp + ".colorEntryList[0].position") 0;
	setAttr ($ramp + ".colorEntryList[1].position") 0.5;
	connectAttr -f ($dark + ".outColor") ($ramp + ".colorEntryList[0].color");
	connectAttr -f ($light + ".outColor") ($ramp + ".colorEntryList[1].color");
	connectAttr -f ($sampler + ".facingRatio") ($ramp + ".vCoord");

	// connect ramp to shader
	connectAttr -f ($ramp + ".outColor") ($toon + ".color");

	print("made toon shader from " + $lambert + "\n");
}
