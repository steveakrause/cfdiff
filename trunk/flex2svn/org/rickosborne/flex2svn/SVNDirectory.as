package org.rickosborne.flex2svn
{
	import mx.collections.ArrayCollection;
	
	public class SVNDirectory extends Object
	{
		public var Loaded: Boolean = false;
		public var Files: ArrayCollection;
		public var Path: String = '/';
		public var Name: String;
		public function SVNDirectory(Path: String) { this.Path = Path; }
	}
}