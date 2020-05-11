javascript:(function getChord(){
var initialData = window.__INITIAL_DATA__;
var bpm = initialData.state.songs["list"][0]["derived_bpm"];
var chords = document.getElementById("chords");
var chordsSon = chords.getElementsByTagName('div');
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
		var baseName = chordsSon[i].getElementsByTagName('div')[0].children[1].className.replace("bass-label","");
		baseName = baseName.replace(" label-bass_","");
		var startTime = Math.round(chordsSon[i].dataset.i*timePerBeat-timePerBeat);
		var endTime = Math.round(chordsSon[i].dataset.i*timePerBeat);
		if (baseName != ""){
			chordName = chordName+"/"+baseName;
		}
		if (chordName.indexOf("rest") == -1){
		assStr = assStr + "Dialogue: 0," + msToTime(startTime) + "," + msToTime(endTime) + ",Chord,,0,0,0,fx," + chordName + "\n";
		}
	}
}
function msToTime(s) {
    return new Date(s).toISOString().slice(11, -1);
}
navigator.clipboard.writeText(assStr);
alert("估测曲速为BPM"+bpm+"，和弦已复制到剪切板");
})();
