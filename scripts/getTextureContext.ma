// first script to get texture information
global proc getTextureContext()
{
	// Get all file nodes in the scene
	string $fileNodes[] = `ls -type "file"`;
    
	// Create a formatted output
	print "\n=== TEXTURE CONTEXT ===\n";
    
	// Loop through each file node
	for($node in $fileNodes)
	{
    	string $texturePath = `getAttr ($node + ".fileTextureName")`;
    	string $colorSpace = `getAttr ($node + ".colorSpace")`;
    	string $connections[] = `listConnections -d true -s false $node`;
   	 
    	print ("\nNode Name: " + $node);
    	print ("\nTexture Path: " + $texturePath);
    	print ("\nColor Space: " + $colorSpace);
    	print "\nConnected to: ";
    	for($conn in $connections)
    	{
        	print ($conn + " ");
    	}
    	print "\n------------------------";
	}
}
