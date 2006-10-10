import mx.controls.Alert;
import mx.rpc.events.InvokeEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.events.FaultEvent;
import mx.collections.ArrayCollection;
import mx.rpc.http.mxml.HTTPService;
import org.rickosborne.flex2svn.*;
import flash.events.Event;

[Bindable] private var Proxy: ArrayCollection;
[Bindable] private var CurrentDir: SVNDirectory;
[Bindable] private var RootDir: SVNDirectory;
[Bindable] private var CurrentRepository: ArrayCollection;

private function errFaultEvent(event: FaultEvent):void {
	Alert.show(event.fault.message);
} // errConfigLoad

private function startConfigLoad(event: InvokeEvent):void {
	pbLoad.label = 'Loading Configuration ...';
} // startConfigLoad

private function startDirLoad(event: InvokeEvent):void {
	Alert.show(event.message.toString());
} // startDirLoad

private function doneConfigLoad(event: ResultEvent):void {
	Alert.show(event.message.body.toString());
	// currentState = 'PickRepository';
	Proxy = event.result.flex2svn.proxy;
	Alert.show(Proxy[0]);
} // doneConfigLoad

private function doneDirProxy(event: ResultEvent): void {
	Alert.show(event.message.toString());
} // doneDirProxy

private function setRepository(event: Event): void {
	CurrentRepository = event.target.selectedItem;
	RootDir = new SVNDirectory('/');
	CurrentDir = RootDir;
	loadCurrentDir();
}

private function doDirBrowse(): void {
} // doDirBrowse

private function loadCurrentDir(): void {
	if(!CurrentDir.Loaded) {
		var DirParams: Object = {
			'path': CurrentDir.Path,
			'repository': CurrentRepository.id
		};
		DirProxy.send(DirParams);
	} // if not already loaded
} // loadCurrentDir