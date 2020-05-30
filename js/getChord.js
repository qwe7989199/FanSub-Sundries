/* 本脚本用于导出ufret和chordify的和弦数据到ASS格式;
   ufret只有在動画プラス模式下才有效;
   后续可以搭配ASS_Chord.lua脚本使用;
   目前在Chrome浏览器测试通过;
   新建一个书签，书签名称自定义，复制注释以外的内容到网址;
   保存后可以通过书签调用;
   by domo 2020.05
*/ 

javascript:(function getChord(){
if (!window.chooseFileSystemEntries) {
  alert("请尽量使用Chrome(版本>=v83)\n并且在chrome://flags中开启Native File System API\n否则只能手动粘贴ASS");
  var noWriteFile=true;
  var assStr="";
}else{
  var assStr="[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n";
  var noWriteFile=false;
}
const saveFileOptions = {type: 'save-file',accepts:[{description: 'Advanced SubStation Alpha Subtitle',mimeTypes: ['text/ssa'],extensions: ['ass'],}]};
var host=window.location.host;
var chordsObj=[];

switch(host){
	case "chordify.net":
		assStr,bpm=fromChordify();
		break;
	case "www.ufret.jp":
		assStr,bpm=fromUfret();
		break;
	default:
		alert("只支持chordify和ufret的和弦导出");
}
if (noWriteFile){
	navigator.clipboard.writeText(assStr);
	alert("估测曲速为BPM"+bpm+"\n和弦已复制到剪切板");
	}else{
(async ()=> {
  const handle = await window.chooseFileSystemEntries(saveFileOptions);
  await writeFile(handle, assStr);
  alert("估测曲速为BPM"+bpm+"\n和弦已保存到本地");
})();
}
function fromChordify(){
	var initialData=window.__INITIAL_DATA__;
	var bpm=initialData.state.songs["list"][0]["derived_bpm"];
	var chords=document.getElementById("chords");
	var chordsSon=chords.getElementsByTagName('div');
	var timePerBeat=60000.0/bpm;
	var initOffset=0;
	for(var i=0;i<chordsSon.length-3;i+=2){
		var startTime=0;
		var endTime=0;
		className = chordsSon[i].className;
		if (className.indexOf("nolabel")==-1){
			var chordName = chordsSon[i].getElementsByTagName('div')[0].children[0].className.replace("chord-label","");
			chordName=chordName.replace(" label-","");
			chordName=chordName.replace("s_","#");
			chordName=chordName.replace("_","");
			var startBeat=chordsSon[i].dataset.i;
			var startTime=Math.round(startBeat*timePerBeat);
			var baseName=chordsSon[i].getElementsByTagName('div')[0].children[1].className.replace("bass-label","");
			baseName = baseName.replace(" label-bass_","");
			if (baseName!=""){
				chordName=chordName+"/"+baseName;
			}
			if (chordName.indexOf("rest")==-1){
			chordsObj.push({"chordName":chordName,"startTime":startTime});
			}
		}
	}
	assStr=chord2ASS(chordsObj,timePerBeat,initOffset);
	return assStr,Math.round(bpm*10)/10;
}
function fromUfret(){
	var chordData=tab_scroller.getElementsByTagName("li");
	var timeData=tab_minite_array;
	var timePerBeat=(timeData[timeData.length-1]-timeData[0])/(timeData.length-1)*1000;
	var bpm=60000.0/timePerBeat;
	var initOffset=timeData[0]*1000;
	for (var i=0;i<chordData.length;i++){
		var chordName=chordData[i].textContent;
		var startTime=timeData[i]*1000;
		var startBeat=Math.round((startTime-initOffset)/timePerBeat);
		if (chordName!=""){
			chordsObj.push({"chordName":chordName,"startTime":startTime});
		}
	}
	assStr=chord2ASS(chordsObj,timePerBeat,initOffset);
	return assStr,Math.round(bpm*10)/10;
}
function chord2ASS(chordsObj,timePerBeat,initOffset){
	for(var i=0;i<chordsObj.length;i++){
		var chordName=chordsObj[i].chordName;
		var startTime=Math.round(chordsObj[i].startTime);
		var startBeat=Math.round((startTime-initOffset)/timePerBeat);
		if (i!=chordsObj.length-1){
			var durBeat=Math.round((chordsObj[i+1].startTime-chordsObj[i].startTime)/timePerBeat);
			var endTime=Math.round(chordsObj[i+1].startTime);
		} else {
			var durBeat=2;
			var endTime=Math.round(startTime+durBeat*timePerBeat);
		}
		assStr=assStr + "Dialogue: 0," + msToTime(startTime) + "," + msToTime(endTime) + ",Chord,"+startBeat+"|"+durBeat+",0,0,0,fx," + chordName + "\n";
	}
	return assStr
}

function msToTime(s){
    return new Date(s).toISOString().slice(11, -1);
}

async function writeFile(fileHandle, contents) {
  const writable = await fileHandle.createWritable();
  await writable.write(contents);
  await writable.close();
}
})();
