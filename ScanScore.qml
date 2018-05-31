import QtQuick 2.0
import MuseScore 1.0
import FileIO 1.0


MuseScore {
    menuPath:    "Plugins.ScanScore"
    version:     "1.0"
    description: qsTr("This demo plugin traverses a score by measure-->staff")

    FileIO {
        id: outfile
        onError: console.log(msg)
    }

    property string toWrite: ""
    property int chordCount: 0

    function getElementInformation(element) {
        var cursor = curScore.newCursor();
        for (var staff = 0; staff <= 4; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.voice = voice;
                cursor.staffIdx = staff;
                cursor.rewind(0);
                while (cursor.segment) {
                    if (cursor.element === element) {
                        var xArray = new Array()
                        var measureX = cursor.measure.pagePos.x.toPrecision(8);
                        if (element.type === Element.CHORD) {
                            var chord = element
                            for (var i = 0; i < chord.graceNotes.length; i++) {
                                var graceNote = chord.graceNotes[i]
                                var graceNoteX = graceNote.pagePos.x.toPrecision(8)
                                var defaultX = (graceNoteX - measureX) * 10
                                xArray.push(defaultX.toFixed(2))
                            }
                            for (i = 0; i < chord.notes.length; i++) {
                                var note = chord.notes[i]
                                var noteX = note.pagePos.x.toPrecision(8)
                                defaultX = (noteX - measureX) * 10
                                xArray.push(defaultX.toFixed(2))
                            }
                        }
                        if (element.type === Element.REST) {
                            var rest = element
                            var restX = rest.pagePos.x.toPrecision(8)
                            defaultX = (restX - measureX) * 10
                            xArray.push(defaultX.toFixed(2))
                        }
                        var infoMap = { }
                        infoMap[cursor.staffIdx] = xArray
                        return infoMap
                    }
                    cursor.next();
                }
            }
        }
    }

    function processMeasure(measure, staff) {
        var segment = measure.firstSegment
        while (segment) {
            for (var track = 0; track <= curScore.ntracks; track++) {
                var element = segment.elementAt(track);
                if(element){
                    if (element.type === Element.CHORD || element.type === Element.REST){
                        var infoMap = getElementInformation(element)
                        for(var key in infoMap){
                            var staffIdx = key
                        }
                        if (staffIdx === staff.toString()){
                            console.log("element: " + element)
                            var xArray = infoMap[staffIdx]
                            for (var i = 0; i < xArray.length; i++) {
                                console.log(" x:" + xArray[i])
                                toWrite += xArray[i] + "\n"
                            }
                            if (element.type === Element.CHORD){
                                chordCount += xArray.length;
                            }
                        }
                    }
                }
            }
            segment = segment.nextInMeasure
        }
    }

    onRun: {
        if (typeof curScore === 'undefined')
            Qt.quit();
        var score = curScore
        console.log(score.name)
        outfile.source = "/Users/lisimin/Desktop/Project/xml/" + score.name + ".txt"
        var measure = score.firstMeasure
        var measureNumber = 1;
        while (measure) {
            for (var staff = 0; staff <= 1; staff++) {
                console.log("Measure:" + measureNumber + " Staff:" + (staff+1))
                processMeasure(measure, staff)
                console.log("----------------------------------")
            }
            measure = measure.nextMeasure
            measureNumber++;
        }
        console.log(chordCount)
        outfile.write(toWrite)
        Qt.quit()
    }
}
