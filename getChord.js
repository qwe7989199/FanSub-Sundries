javascript:(function getChord(){
var initialData = window.__INITIAL_DATA__;
var bpm = initialData.state.songs["list"][0]["derived_bpm"];
var chords = document.getElementById("chords");
var chordsSon = chords.getElementsByTagName('div');
var chordsObj = [];
var assStr = "";
var timePerBeat = 60000.0/bpm;
for(var i=0;i<chordsSon.length-3;i+=2){
	var startTime = 0;
	var endTime = 0;
	className = chordsSon[i].className;
	if (className.indexOf("nolabel")==-1){
		var chordName = chordsSon[i].getElementsByTagName('div')[0].children[0].className.replace("chord-label","");
		chordName = chordName.replace(" label-","");
		chordName = chordName.replace("s_","#");
		chordName = chordName.replace("_","");
		var startBeat = chordsSon[i].dataset.i;
		var baseName = chordsSon[i].getElementsByTagName('div')[0].children[1].className.replace("bass-label","");
		baseName = baseName.replace(" label-bass_","");
		if (baseName != ""){
			chordName = chordName+"/"+baseName;
		}
		if (chordName.indexOf("rest") == -1){
		chordsObj.push({"chordName":chordName,"startBeat":startBeat});
		}
	}
}
for(var i=0;i<chordsObj.length;i+=1){
	var chordName = chordsObj[i].chordName;
	var startBeat = chordsObj[i].startBeat;
	var startTime = Math.round(startBeat*timePerBeat-timePerBeat);
	var endTime = Math.round(startBeat*timePerBeat);
	if (i!=chordsObj.length-1){
		var durBeat = chordsObj[i+1].startBeat-chordsObj[i].startBeat;
	} else {
		var durBeat = 2;
	}
	assStr = assStr + "Dialogue: 0," + msToTime(startTime) + "," + msToTime(endTime) + ",Chord,"+(startBeat-1)+"|"+durBeat+",0,0,0,fx," + chordName + "\n";
	}
function msToTime(s) {
    return new Date(s).toISOString().slice(11, -1);
}
navigator.clipboard.writeText(assStr);
alert("估测曲速为BPM"+bpm+"，和弦已复制到剪切板");
})();
