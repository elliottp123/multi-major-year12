import maya.cmds as cmds

def convert_toon_to_dx11():
	"""
	Convert all *_toon materials to dx11 shaders with exact template settings
	"""
	# Get all rampShaders ending with _toon
	toon_shaders = cmds.ls("*_toon", type="rampShader")
    
	for toon_shader in toon_shaders:
    	base_name = toon_shader.replace("_toon", "")
    	new_shader_name = f"{base_name}_shade"
   	 
    	# Create new dx11 shader
    	new_shader = cmds.shadingNode("dx11Shader", asShader=True, name=new_shader_name)
   	 
    	# Set hardcoded values from example shader
    	cmds.setAttr(f"{new_shader}.shader", "C:/Users/EVPez/Downloads/MayaToonOutline.fx", type="string")
    	cmds.setAttr(f"{new_shader}.technique", "ToonOutline", type="string")
   	 
    	# Set base attributes
    	base_attrs = {
        	"xLinearSpaceLighting": True,
        	"xUseShadows": False,
        	"xShadowMultiplier": 1.0,
        	"xShadowDepthBias": 0.009999999776482582,
        	"xShadowFilterWidth": 0.00019999999494757503,
        	"xShadowFilterCount": 10,
        	"xOpacity": 1.0,
        	"xBaseColor": (0.7, 0.7, 0.7),
        	"xBaseColorMapUv": 1,
        	"xShadow1Color": (0.5, 0.5, 0.5),
        	"xShadow1Step": 0.5,
        	"xShadow1Feather": 0.0,
        	"xShadow2Color": (0.1, 0.1, 0.1),
        	"xShadow2Step": 0.2,
        	"xShadow2Feather": 0.0,
        	"xSpeclarColor": (0.5, 0.5, 0.5),
        	"xSpeclarStep": 0.0,
        	"xSpeclarFeather": 0.0,
        	"xRimColor": (0.5, 0.5, 0.5),
        	"xRimStep": 0.0,
        	"xRimFeather": 0.0,
        	"xLightDirEffect": 0.0,
        	"xInvertLightDir": False,
        	"xOutlineWidth": 1.0,
        	"xOutlineColor": (0.0, 0.0, 0.0),
        	"xZOffset": 0.0,
        	"xLight0Type": 0,
        	"xLight0Color": (1.0, 1.0, 1.0)
    	}
   	 
    	# Set all base attributes
    	for attr, value in base_attrs.items():
        	try:
            	if isinstance(value, tuple):
                	cmds.setAttr(f"{new_shader}.{attr}", *value)
            	else:
                	cmds.setAttr(f"{new_shader}.{attr}", value)
        	except:
            	print(f"Failed to set {attr} on {new_shader}")
   	 
    	# Get file node connection from toon shader
    	connections = cmds.listConnections(toon_shader,
                                     	source=True,
                                     	destination=False,
                                     	connections=True,
                                     	plugs=True)
   	 
    	if connections:
        	# Get the first file node connection
        	for i in range(0, len(connections), 2):
            	source_node = connections[i+1]
            	if cmds.nodeType(source_node.split('.')[0]) == 'file':
                	file_path = cmds.getAttr(f"{source_node.split('.')[0]}.fileTextureName")
               	 
                	# Create new file node
                	new_file = cmds.shadingNode('file', asTexture=True, name=f"{base_name}_file")
                	cmds.setAttr(f"{new_file}.fileTextureName", file_path, type="string")
               	 
                	# Connect to dx11 shader's base color map
                	cmds.connectAttr(f"{new_file}.outColor", f"{new_shader}.xBaseColorMap")
                	break
   	 
    	# Find and reassign material to objects using the old shader
    	connected_objects = cmds.listConnections(toon_shader, type='shadingEngine')
    	if connected_objects:
        	for sg in connected_objects:
            	new_sg = cmds.sets(name=f"{new_shader_name}SG", renderable=True, noSurfaceShader=True)
            	cmds.connectAttr(f"{new_shader}.outColor", f"{new_sg}.surfaceShader")
           	 
            	objects = cmds.sets(sg, q=True)
            	if objects:
                	cmds.sets(objects, e=True, forceElement=new_sg)
   	 
    	print(f"Converted {toon_shader} to {new_shader}")

#convert_toon_to_dx11()
